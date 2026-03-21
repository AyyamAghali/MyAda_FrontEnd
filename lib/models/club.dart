enum ClubStatus {
  open,
  closed,
  paused,
  disabled,
  byInvitation,
}

class ClubEvent {
  final String id;
  final String title;
  final String date;
  final String location;
  final String? description;
  final String? time;

  ClubEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    this.description,
    this.time,
  });
}

class ClubOfficer {
  final String name;
  final String role;
  final String photo;

  ClubOfficer({
    required this.name,
    required this.role,
    required this.photo,
  });
}

class Club {
  final String id;
  final String name;
  final String logo;
  final String banner;
  final String category;
  final List<String> tags;
  final int memberCount;
  final ClubStatus status;
  final String about;
  final List<ClubOfficer> officers;
  final List<ClubEvent> events;
  /// Optional metadata (see web `clubsData.js`).
  final int? establishedYear;
  final String? location;

  Club({
    required this.id,
    required this.name,
    required this.logo,
    required this.banner,
    required this.category,
    required this.tags,
    required this.memberCount,
    required this.status,
    required this.about,
    required this.officers,
    required this.events,
    this.establishedYear,
    this.location,
  });

  String get statusString {
    switch (status) {
      case ClubStatus.open:
        return 'Open';
      case ClubStatus.closed:
        return 'Closed';
      case ClubStatus.paused:
        return 'Paused';
      case ClubStatus.disabled:
        return 'Disabled';
      case ClubStatus.byInvitation:
        return 'By Invitation';
    }
  }
}

