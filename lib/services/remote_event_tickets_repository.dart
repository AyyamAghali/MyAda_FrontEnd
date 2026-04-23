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
    required String jwt,
  }) async {
    final json = await _api.checkIn(eventId: eventId, jwt: jwt);
    final success = json['success'] == true;
    final status = (json['status'] ?? 'unknown').toString();
    final message = (json['message'] ?? '').toString();
    final ticketId = (json['ticketId'] ?? '').toString();

    AttendeeIdentity? attendee;
    final a = json['attendee'] ?? json;
    if (a is Map<String, dynamic> && a.containsKey('attendeeId')) {
      attendee = AttendeeIdentity(
        userId: (a['attendeeId'] ?? a['userId'] ?? '').toString(),
        studentId: (a['studentId'] ?? '').toString(),
        name: (a['name'] ?? '').toString(),
        surname: (a['surname'] ?? '').toString(),
      );
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

  @override
  Future<EventSnapshot> getEventSnapshot(String eventId) async {
    final json = await _api.getTicket(eventId);
    return _snapshotFromJson(json, eventId);
  }

  RegistrationTicket _ticketFromJson(Map<String, dynamic> json, String eventId) {
    final eventJson =
        json['event'] is Map<String, dynamic> ? json['event'] as Map<String, dynamic> : json;
    return RegistrationTicket(
      ticketId: (json['ticketId'] ?? '').toString(),
      eventId: (json['eventId'] ?? eventId).toString(),
      userId: (json['userId'] ?? json['attendeeId'] ?? '').toString(),
      jwt: (json['jwt'] ?? '').toString(),
      event: _snapshotFromJson(eventJson, eventId),
    );
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
      registeredCount: int.tryParse((json['registeredCount'] ?? 0).toString()) ?? 0,
    );
  }
}
