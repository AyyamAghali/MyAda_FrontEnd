import '../models/event_tickets_models.dart';
import 'club_api_service.dart';
import 'event_tickets_repository.dart';

/// Production implementation that hits the club management backend.
class RemoteEventTicketsRepository implements EventTicketsRepository {
  final ClubApiService _api = ClubApiService();

  @override
  Future<RegistrationTicket> registerForEvent(String eventId) async {
    final json = await _api.registerForEvent(eventId);
    return _ticketFromJson(json, eventId);
  }

  @override
  Future<RegistrationTicket> getTicket(String eventId) async {
    final json = await _api.getTicket(eventId);
    return _ticketFromJson(json, eventId);
  }

  @override
  Future<List<MyRegistrationItem>> listMyRegistrations() async {
    final items = await _api.listMyRegistrations();
    return items.map((json) {
      final eventId = (json['eventId'] ?? '').toString();
      final ticketId = (json['ticketId'] ?? '').toString();
      final registeredAt = DateTime.tryParse(
              (json['registeredAt'] ?? '').toString()) ??
          DateTime.now().toUtc();
      final eventJson =
          json['event'] is Map<String, dynamic> ? json['event'] as Map<String, dynamic> : json;
      return MyRegistrationItem(
        eventId: eventId,
        ticketId: ticketId,
        registeredAt: registeredAt,
        event: _snapshotFromJson(eventJson, eventId),
      );
    }).toList();
  }

  @override
  Future<CheckInResponse> checkIn({
    required String eventId,
    required String token,
    String? scannerDeviceId,
    String? gateId,
  }) async {
    Map<String, dynamic> json;
    try {
      json = await _api.scanTicket(
        eventId: eventId,
        token: token,
        scannerDeviceId: scannerDeviceId,
        gateId: gateId,
        scannedAtUtc: DateTime.now().toUtc(),
      );
    } on ClubApiException catch (e) {
      // Backward compatibility: older backend may still expose /check-in only.
      if (e.statusCode == 404 || e.statusCode == 405) {
        json = await _api.checkIn(eventId: eventId, jwt: token);
      } else {
        rethrow;
      }
    }
    final rawStatus = (json['status'] ?? 'unknown').toString();
    final status = _normalizeScanStatus(rawStatus);
    final success = status == 'admitted' || status == 'already_scanned';
    final message = (json['message'] ??
            (status == 'admitted'
                ? 'Ticket admitted.'
                : status == 'already_scanned'
                    ? 'Ticket already scanned.'
                    : 'Ticket denied.'))
        .toString();
    final ticketId = (json['ticketId'] ?? '').toString();

    AttendeeIdentity? attendee;
    final a = json['attendee'] ?? json;
    if (a is Map<String, dynamic>) {
      final userId = (a['attendeeId'] ?? a['userId'] ?? '').toString();
      final name = (a['name'] ?? '').toString();
      if (userId.isNotEmpty || name.isNotEmpty) {
      attendee = AttendeeIdentity(
        userId: userId,
        studentId: (a['studentId'] ?? '').toString(),
        name: name,
        surname: a['surname']?.toString(),
      );
      }
    }

    return CheckInResponse(
      success: success,
      status: status,
      message: message,
      eventId: eventId,
      ticketId: ticketId,
      attendee: attendee,
    );
  }

  String _normalizeScanStatus(String raw) {
    switch (raw) {
      case 'checked_in':
        return 'admitted';
      case 'already_checked_in':
        return 'already_scanned';
      default:
        return raw;
    }
  }

  @override
  Future<EventSnapshot> getEventSnapshot(String eventId) async {
    final json = await _api.getTicket(eventId);
    final eventJson = json['event'] is Map<String, dynamic>
        ? json['event'] as Map<String, dynamic>
        : json;
    return _snapshotFromJson(eventJson, eventId);
  }

  RegistrationTicket _ticketFromJson(Map<String, dynamic> json, String eventId) {
    final token = _pickTicketToken(json);
    final eventJson =
        json['event'] is Map<String, dynamic> ? json['event'] as Map<String, dynamic> : json;
    return RegistrationTicket(
      ticketId: (json['ticketId'] ?? '').toString(),
      eventId: (json['eventId'] ?? eventId).toString(),
      userId: (json['userId'] ?? json['attendeeId'] ?? '').toString(),
      jwt: token,
      event: _snapshotFromJson(eventJson, eventId),
    );
  }

  String _pickTicketToken(Map<String, dynamic> json) {
    final c = [
      json['jwt'],
      json['token'],
      json['accessToken'],
      json['ticketToken'],
      json['qrToken'],
      (json['registration'] is Map<String, dynamic>)
          ? (json['registration'] as Map<String, dynamic>)['jwt']
          : null,
      (json['registration'] is Map<String, dynamic>)
          ? (json['registration'] as Map<String, dynamic>)['token']
          : null,
      (json['registration'] is Map<String, dynamic>)
          ? (json['registration'] as Map<String, dynamic>)['accessToken']
          : null,
    ];
    for (final v in c) {
      final s = v?.toString() ?? '';
      if (s.isNotEmpty) return s;
    }
    return '';
  }

  EventSnapshot _snapshotFromJson(Map<String, dynamic> json, String fallbackId) {
    return EventSnapshot(
      id: (json['id'] ?? json['eventId'] ?? fallbackId).toString(),
      name: (json['name'] ?? json['eventNameSnapshot'] ?? 'Event').toString(),
      imageUrl: (json['imageUrl'] ?? json['eventImageUrlSnapshot']) as String?,
      startTime: (json['startTime'] ?? json['eventStartTimeSnapshot']) as String?,
      endTime: (json['endTime'] ?? json['eventEndTimeSnapshot']) as String?,
      location: (json['location'] ?? json['eventLocationSnapshot']) as String?,
      seatLimit: int.tryParse((json['seatLimit'] ?? json['eventSeatLimitSnapshot'] ?? 0).toString()) ?? 0,
      registeredCount: int.tryParse((json['registeredCount'] ??
              json['eventRegistrationCountSnapshot'] ??
              json['currentRegistrations'] ??
              0)
          .toString()) ?? 0,
    );
  }
}
