class EventSnapshot {
  final String id;
  final String name;
  final String? imageUrl;
  final String? startTime;
  final String? endTime;
  final String? location;
  final int seatLimit;
  final int registeredCount;

  const EventSnapshot({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.seatLimit,
    required this.registeredCount,
  });
}

class RegistrationTicket {
  final String ticketId;
  final String eventId;
  final String userId;
  final String jwt;
  final EventSnapshot event;

  const RegistrationTicket({
    required this.ticketId,
    required this.eventId,
    required this.userId,
    required this.jwt,
    required this.event,
  });
}

class MyRegistrationItem {
  final String eventId;
  final String ticketId;
  final DateTime registeredAt;
  final EventSnapshot event;

  const MyRegistrationItem({
    required this.eventId,
    required this.ticketId,
    required this.registeredAt,
    required this.event,
  });
}

class AttendeeIdentity {
  final String userId;
  final String studentId;
  final String name;
  final String? surname;

  const AttendeeIdentity({
    required this.userId,
    required this.studentId,
    required this.name,
    this.surname,
  });
}

class CheckInResponse {
  final bool success;
  final String status; // checked_in | already_checked_in | invalid | expired | not_found | outside_window ...
  final String message;
  final String eventId;
  final String ticketId;
  final AttendeeIdentity? attendee;

  const CheckInResponse({
    required this.success,
    required this.status,
    required this.message,
    required this.eventId,
    required this.ticketId,
    required this.attendee,
  });
}

