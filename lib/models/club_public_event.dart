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

  /// e.g. `assets/events/esports.png`; null uses a gradient placeholder.
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
    this.imageAsset,
  });

  factory ClubPublicEvent.fromJson(Map<String, dynamic> json) {
    String? text(dynamic value) {
      final str = value?.toString().trim();
      return str == null || str.isEmpty ? null : str;
    }

    final club = json['club'] is Map<String, dynamic>
        ? json['club'] as Map<String, dynamic>
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
      clubName: text(json['clubName']) ?? text(club?['name']) ?? 'ADA Clubs',
      title: text(json['title']) ?? text(json['name']) ?? 'Untitled Event',
      category:
          text(json['category']) ?? text(json['categoryName']) ?? 'General',
      description: text(json['description']),
      date: date,
      time: text(json['time']) ?? startTime ?? '',
      endTime: text(json['endTime']),
      location: text(json['location']) ?? 'Location TBA',
      imageAsset: text(json['imageUrl']) ??
          text(json['imageAsset']) ??
          text(json['coverUrl']),
    );
  }
}
