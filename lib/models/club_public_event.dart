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
}
