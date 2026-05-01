/// Campus club event for discovery list (MyAda_Front_Web `clubEventsData`).
class ClubPublicEvent {
  final int id;
  final int clubId;
  final String clubName;
  final String title;
  final String category;
  final String? description;
  final String date;
  final String time;
  final String? endTime;
  final String location;
  final int? seatLimit;
  final int? registeredCount;

  /// Absolute/relative backend image URL, or a bundled asset path for local data.
  final String? imageAsset;

  const ClubPublicEvent({
    required this.id,
    required this.clubId,
    required this.clubName,
    required this.title,
    required this.category,
    this.description,
    required this.date,
    required this.time,
    this.endTime,
    required this.location,
    this.seatLimit,
    this.registeredCount,
    this.imageAsset,
  });

  factory ClubPublicEvent.fromJson(Map<String, dynamic> json) {
    String? text(dynamic value) {
      final str = value?.toString().trim();
      return str == null || str.isEmpty ? null : str;
    }

    final club = json['club'] is Map<String, dynamic>
        ? json['club'] as Map<String, dynamic>
        : json['Club'] is Map<String, dynamic>
            ? json['Club'] as Map<String, dynamic>
            : null;
    final hoster = json['hoster'] is Map<String, dynamic>
        ? json['hoster'] as Map<String, dynamic>
        : null;
    final host = json['host'] is Map<String, dynamic>
        ? json['host'] as Map<String, dynamic>
        : null;
    final id =
        int.tryParse((json['id'] ?? json['eventId'] ?? 0).toString()) ?? 0;
    final clubId = int.tryParse((json['clubId'] ?? 0).toString()) ?? 0;
    final startTime = text(json['startTime']);
    final dateRaw = text(json['date']) ??
        text(json['startDate']) ??
        text(json['eventDate']) ??
        startTime ??
        '';
    final date = dateRaw.length >= 10 ? dateRaw.substring(0, 10) : dateRaw;

    return ClubPublicEvent(
      id: id,
      clubId: clubId,
      clubName: text(json['clubName']) ??
          text(json['ClubName']) ??
          text(json['hostedBy']) ??
          text(json['organizerName']) ??
          text(json['hosterName']) ??
          text(json['hostName']) ??
          text(hoster?['name']) ??
          text(hoster?['Name']) ??
          text(host?['name']) ??
          text(host?['Name']) ??
          text(club?['name']) ??
          text(club?['Name']) ??
          '',
      title: text(json['title']) ?? text(json['name']) ?? 'Untitled Event',
      category:
          text(json['category']) ?? text(json['categoryName']) ?? 'General',
      description: text(json['description']),
      date: date,
      time: text(json['time']) ?? startTime ?? '',
      endTime: text(json['endTime']),
      location: text(json['location']) ?? 'Location TBA',
      seatLimit: _optionalNonNegativeInt(json['seatLimit'] ??
          json['SeatLimit'] ??
          json['capacity'] ??
          json['Capacity'] ??
          json['attendance'] ??
          json['Attendance'] ??
          json['maxAttendees'] ??
          json['seat_count']),
      registeredCount: _optionalNonNegativeInt(json['registeredCount'] ??
          json['RegisteredCount'] ??
          json['registrationsCount'] ??
          json['currentRegistrations'] ??
          json['ticketsSold'] ??
          json['registrationCount'] ??
          json['bookedCount'] ??
          json['attendeeCount'] ??
          json['AttendeeCount']),
      imageAsset: text(json['imageUrl']) ??
          text(json['imageAsset']) ??
          text(json['posterUrl']) ??
          text(json['coverUrl']),
    );
  }

  int get remainingSlots {
    final limit = seatLimit ?? 0;
    final count = registeredCount ?? 0;
    if (limit <= 0) return 0;
    return (limit - count).clamp(0, limit);
  }

  /// Parses capacity / headcount; `0` is kept (some APIs use 0 for unlimited — UI decides).
  static int? _optionalNonNegativeInt(dynamic v) {
    if (v == null) return null;
    final n = int.tryParse(v.toString());
    if (n == null || n < 0) return null;
    return n;
  }
}
