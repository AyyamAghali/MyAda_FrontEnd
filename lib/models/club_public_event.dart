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
    final id = int.tryParse((json['id'] ?? json['eventId'] ?? 0).toString()) ?? 0;
    final clubId = int.tryParse((json['clubId'] ?? 0).toString()) ?? 0;
    final clubName = (json['clubName'] ?? json['club']?['name'] ?? '') as String;
    final title = (json['title'] ?? json['name'] ?? '') as String;
    final category = (json['category'] ?? json['categoryName'] ?? '') as String;
    final description = json['description'] as String?;
    final dateRaw = (json['date'] ?? json['startDate'] ?? json['eventDate'] ?? '').toString();
    final date = dateRaw.length >= 10 ? dateRaw.substring(0, 10) : dateRaw;
    final time = (json['time'] ?? json['startTime'] ?? '').toString();
    final endTime = json['endTime']?.toString();
    final location = (json['location'] ?? '') as String;
    final imageAsset = (json['imageUrl'] ?? json['imageAsset'] ?? json['coverUrl']) as String?;

    return ClubPublicEvent(
      id: id,
      clubId: clubId,
      clubName: clubName,
      title: title,
      category: category,
      description: description,
      date: date,
      time: time,
      endTime: endTime,
      location: location,
      imageAsset: imageAsset,
    );
  }
}
