import '../models/event_tickets_models.dart';

class RegistrationConflict implements Exception {
  /// Mirrors backend behavior: 409 when event is full.
  final String message;

  const RegistrationConflict(this.message);

  @override
  String toString() => 'RegistrationConflict: $message';
}

abstract class EventTicketsRepository {
  /// POST /api/v1/events/{eventId}/registrations
  Future<RegistrationTicket> registerForEvent(String eventId);

  /// GET /api/v1/events/{eventId}/ticket
  Future<RegistrationTicket> getTicket(String eventId);

  /// GET /api/v1/users/me/event-registrations
  Future<List<MyRegistrationItem>> listMyRegistrations();

  /// POST /api/v1/events/{eventId}/check-in
  Future<CheckInResponse> checkIn({
    required String eventId,
    required String jwt,
  });

  /// Used by UI for:
  /// Disable register when full: registeredCount >= seatLimit
  Future<EventSnapshot> getEventSnapshot(String eventId);
}

