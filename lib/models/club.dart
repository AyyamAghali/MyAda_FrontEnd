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

  /// Short public blurb (mirrors registration form "Short Description").
  final String? shortDescription;

  /// Main goals from registration form; shown on club profile.
  final String? mainGoals;

  /// Public contact email for the club.
  final String? contactEmail;

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
    this.shortDescription,
    this.mainGoals,
    this.contactEmail,
  });

  factory Club.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? json['clubId'] ?? '').toString();
    final name = (json['name'] ?? json['clubName'] ?? 'Unnamed Club') as String;
    final logo = (json['logo'] ?? json['logoUrl'] ?? json['profileImageUrl'] ?? '') as String;
    final banner = (json['banner'] ?? json['bannerUrl'] ?? json['backgroundImageUrl'] ?? '') as String;
    final category = (json['category'] ?? json['categoryName'] ?? '') as String;

    final rawTags = json['tags'] ?? json['focusAreas'];
    final tags = <String>[];
    if (rawTags is List) {
      for (final t in rawTags) {
        tags.add(t.toString());
      }
    }

    final memberCount = _toInt(json['memberCount'] ?? json['membersCount']) ?? 0;
    final status = _statusFromString(
        (json['status'] ?? json['clubStatus'] ?? 'open').toString());
    final about = (json['description'] ?? json['about'] ?? '') as String;

    final rawOfficers = json['officers'] ?? json['leadership'];
    final officers = <ClubOfficer>[];
    if (rawOfficers is List) {
      for (final o in rawOfficers) {
        if (o is Map<String, dynamic>) {
          officers.add(ClubOfficer(
            name: (o['name'] ?? o['fullName'] ?? '') as String,
            role: (o['role'] ?? o['position'] ?? '') as String,
            photo: (o['photo'] ?? o['photoUrl'] ?? o['avatarUrl'] ?? '') as String,
          ));
        }
      }
    }

    final rawEvents = json['events'] ?? json['upcomingEvents'];
    final events = <ClubEvent>[];
    if (rawEvents is List) {
      for (final e in rawEvents) {
        if (e is Map<String, dynamic>) {
          events.add(ClubEvent(
            id: (e['id'] ?? e['eventId'] ?? '').toString(),
            title: (e['title'] ?? e['name'] ?? '') as String,
            date: (e['date'] ?? e['startDate'] ?? '').toString(),
            location: (e['location'] ?? '') as String,
            description: e['description'] as String?,
            time: (e['time'] ?? e['startTime'])?.toString(),
          ));
        }
      }
    }

    return Club(
      id: id,
      name: name,
      logo: logo,
      banner: banner,
      category: category,
      tags: tags,
      memberCount: memberCount,
      status: status,
      about: about,
      officers: officers,
      events: events,
      establishedYear: _toInt(json['establishedYear']),
      location: json['location'] as String?,
      shortDescription: (json['shortDescription'] ?? json['summary']) as String?,
      mainGoals: json['mainGoals'] as String?,
      contactEmail: (json['contactEmail'] ?? json['email']) as String?,
    );
  }

  static int? _toInt(Object? v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static ClubStatus _statusFromString(String raw) {
    switch (raw.toLowerCase()) {
      case 'open':
      case 'active':
        return ClubStatus.open;
      case 'closed':
      case 'inactive':
        return ClubStatus.closed;
      case 'paused':
      case 'suspended':
        return ClubStatus.paused;
      case 'disabled':
        return ClubStatus.disabled;
      case 'byinvitation':
      case 'by_invitation':
      case 'invitation':
        return ClubStatus.byInvitation;
      default:
        return ClubStatus.open;
    }
  }

  /// Fallback when [shortDescription] is not set.
  String get effectiveShortDescription => shortDescription ?? about;

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

