import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/club_events_discovery_mock.dart';
import '../models/event_tickets_models.dart';
import 'event_tickets_repository.dart';
import 'session.dart';

/// Local-only implementation that matches the API shapes from the documentation.
///
/// No endpoints are called. Data is stored in SharedPreferences so it is
/// dynamic during runtime and persists across restarts.
class LocalEventTicketsRepository implements EventTicketsRepository {
  static const _keyTicketsByEvent = 'tickets_by_event_v1';
  static const _keyCheckedInByEvent = 'checked_in_by_event_v1';
  static const _keyEventCapacity = 'event_capacity_v1';

  final Random _rng = Random();

  Future<Map<String, dynamic>> _loadMap(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(key);
      if (raw == null || raw.isEmpty) return {};
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : {};
    } catch (_) {
      return {};
    }
  }

  Future<void> _saveMap(String key, Map<String, dynamic> map) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, jsonEncode(map));
    } catch (_) {}
  }

  String _ticketId() => 'TCK-${100000 + _rng.nextInt(899999)}';

  String _jwt(String eventId, String userId) {
    // Stable-enough token string for local flow; QR encodes ONLY this string.
    final r = 100000 + _rng.nextInt(899999);
    return 'local.jwt.evt$eventId.$userId.$r';
  }

  EventSnapshot _eventSnapshotFromDiscovery(String eventId) {
    final id = int.tryParse(eventId) ?? -1;
    final ev = getClubPublicEventById(id);
    // Fallback snapshot when discovery list doesn't include it.
    final title = ev?.title ?? 'Event $eventId';
    final imageUrl = ev?.imageAsset; // local asset path; UI can render asset.
    final location = ev?.location;

    // Capacities stored separately so they can evolve locally.
    // Default values help demo full/remaining states.
    return EventSnapshot(
      id: eventId,
      name: title,
      imageUrl: imageUrl,
      startTime: ev?.time,
      endTime: ev?.endTime,
      location: location,
      seatLimit: 150,
      registeredCount: 0,
    );
  }

  @override
  Future<EventSnapshot> getEventSnapshot(String eventId) async {
    final base = _eventSnapshotFromDiscovery(eventId);
    final cap = await _loadMap(_keyEventCapacity);
    final stored = cap[eventId];
    if (stored is Map<String, dynamic>) {
      final seatLimit = int.tryParse(stored['seatLimit']?.toString() ?? '') ??
          base.seatLimit;
      final registeredCount =
          int.tryParse(stored['registeredCount']?.toString() ?? '') ??
              base.registeredCount;
      return EventSnapshot(
        id: base.id,
        name: base.name,
        imageUrl: base.imageUrl,
        startTime: base.startTime,
        endTime: base.endTime,
        location: base.location,
        seatLimit: seatLimit,
        registeredCount: registeredCount,
      );
    }
    return base;
  }

  Future<void> _bumpRegisteredCount(String eventId) async {
    final cap = await _loadMap(_keyEventCapacity);
    final current = cap[eventId];
    final seatLimit = current is Map<String, dynamic>
        ? (int.tryParse(current['seatLimit']?.toString() ?? '') ?? 150)
        : 150;
    final registeredCount = current is Map<String, dynamic>
        ? (int.tryParse(current['registeredCount']?.toString() ?? '') ?? 0)
        : 0;

    cap[eventId] = {
      'seatLimit': seatLimit,
      'registeredCount': registeredCount + 1,
    };
    await _saveMap(_keyEventCapacity, cap);
  }

  @override
  Future<RegistrationTicket> registerForEvent(String eventId) async {
    final tickets = await _loadMap(_keyTicketsByEvent);
    final existing = tickets[eventId];
    if (existing is Map<String, dynamic>) {
      // Already registered → return same ticketId and jwt.
      return _ticketFromStored(existing, eventId);
    }

    final snapshot = await getEventSnapshot(eventId);
    if (snapshot.registeredCount >= snapshot.seatLimit) {
      throw const RegistrationConflict('Event is full');
    }

    final userId = await Session.userId();
    final ticketId = _ticketId();
    final jwt = _jwt(eventId, userId);

    final stored = {
      'ticketId': ticketId,
      'eventId': eventId,
      'userId': userId,
      'jwt': jwt,
      'registeredAt': DateTime.now().toUtc().toIso8601String(),
      'event': {
        'id': snapshot.id,
        'name': snapshot.name,
        'imageUrl': snapshot.imageUrl,
        'startTime': snapshot.startTime,
        'endTime': snapshot.endTime,
        'location': snapshot.location,
        'seatLimit': snapshot.seatLimit,
        'registeredCount': snapshot.registeredCount + 1,
      },
    };
    tickets[eventId] = stored;
    await _saveMap(_keyTicketsByEvent, tickets);
    await _bumpRegisteredCount(eventId);

    return _ticketFromStored(stored, eventId);
  }

  RegistrationTicket _ticketFromStored(Map<String, dynamic> json, String eventId) {
    final e = json['event'] is Map<String, dynamic>
        ? json['event'] as Map<String, dynamic>
        : <String, dynamic>{};
    final snapshot = EventSnapshot(
      id: (e['id'] ?? eventId).toString(),
      name: (e['name'] ?? 'Event $eventId').toString(),
      imageUrl: e['imageUrl']?.toString(),
      startTime: e['startTime']?.toString(),
      endTime: e['endTime']?.toString(),
      location: e['location']?.toString(),
      seatLimit: int.tryParse(e['seatLimit']?.toString() ?? '') ?? 150,
      registeredCount:
          int.tryParse(e['registeredCount']?.toString() ?? '') ?? 0,
    );
    return RegistrationTicket(
      ticketId: (json['ticketId'] ?? '').toString(),
      eventId: (json['eventId'] ?? eventId).toString(),
      userId: (json['userId'] ?? '').toString(),
      jwt: (json['jwt'] ?? '').toString(),
      event: snapshot,
    );
  }

  @override
  Future<RegistrationTicket> getTicket(String eventId) async {
    final tickets = await _loadMap(_keyTicketsByEvent);
    final stored = tickets[eventId];
    if (stored is Map<String, dynamic>) {
      return _ticketFromStored(stored, eventId);
    }
    throw StateError('Ticket not found');
  }

  @override
  Future<List<MyRegistrationItem>> listMyRegistrations() async {
    final tickets = await _loadMap(_keyTicketsByEvent);
    final items = <MyRegistrationItem>[];
    for (final entry in tickets.entries) {
      final eventId = entry.key;
      final v = entry.value;
      if (v is! Map<String, dynamic>) continue;
      final ticket = _ticketFromStored(v, eventId);
      final registeredAt = DateTime.tryParse(v['registeredAt']?.toString() ?? '') ??
          DateTime.now().toUtc();
      items.add(
        MyRegistrationItem(
          eventId: ticket.eventId,
          ticketId: ticket.ticketId,
          registeredAt: registeredAt,
          event: ticket.event,
        ),
      );
    }
    items.sort((a, b) => b.registeredAt.compareTo(a.registeredAt));
    return items;
  }

  @override
  Future<CheckInResponse> checkIn({
    required String eventId,
    required String jwt,
  }) async {
    // Find matching ticket by jwt.
    final tickets = await _loadMap(_keyTicketsByEvent);
    Map<String, dynamic>? match;
    for (final v in tickets.values) {
      if (v is Map<String, dynamic> && v['jwt']?.toString() == jwt) {
        match = v;
        break;
      }
    }
    if (match == null) {
      return CheckInResponse(
        success: false,
        status: 'not_found',
        message: 'Ticket not found',
        eventId: eventId,
        ticketId: '-',
        attendee: null,
      );
    }

    final ticketId = (match['ticketId'] ?? '').toString();
    final checked = await _loadMap(_keyCheckedInByEvent);
    final list = (checked[eventId] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toSet();

    final already = list.contains(ticketId);
    if (!already) {
      list.add(ticketId);
      checked[eventId] = list.toList();
      await _saveMap(_keyCheckedInByEvent, checked);
    }

    final studentId = await Session.studentId();
    final attendee = AttendeeIdentity(
      userId: (match['userId'] ?? '').toString(),
      studentId: studentId,
      name: 'Student',
      surname: ticketId.substring(ticketId.length - 3),
    );

    return CheckInResponse(
      success: true,
      status: already ? 'already_checked_in' : 'checked_in',
      message: already ? 'Ticket already used' : 'Entry allowed',
      eventId: eventId,
      ticketId: ticketId,
      attendee: attendee,
    );
  }
}

