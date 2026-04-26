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
  final String userId;

  ClubOfficer({
    required this.name,
    required this.role,
    required this.photo,
    this.userId = '',
  });
}

/// A resource link surfaced on the public club profile (API `resources` array).
class ClubResource {
  final String title;
  final String url;

  const ClubResource({required this.title, required this.url});

  factory ClubResource.fromApi(dynamic raw) {
    if (raw is String) return ClubResource(title: raw.trim(), url: '');
    if (raw is Map) {
      final m = Map<String, dynamic>.from(raw);
      return ClubResource(
        title: (m['title'] ?? m['name'] ?? '').toString().trim(),
        url: (m['url'] ?? m['link'] ?? '').toString().trim(),
      );
    }
    return const ClubResource(title: '', url: '');
  }

  bool get isEmpty => title.isEmpty && url.isEmpty;
}

/// A document (e.g. constitution PDF) from the club detail API `documents` array.
class ClubDocument {
  final String title;
  final String url;

  const ClubDocument({required this.title, required this.url});

  factory ClubDocument.fromApi(dynamic raw) {
    if (raw is String) return ClubDocument(title: 'Document', url: raw.trim());
    if (raw is Map) {
      final m = Map<String, dynamic>.from(raw);
      return ClubDocument(
        title: (m['title'] ?? m['name'] ?? 'Document').toString().trim(),
        url: (m['url'] ?? m['link'] ?? m['fileUrl'] ?? '').toString().trim(),
      );
    }
    return const ClubDocument(title: '', url: '');
  }

  bool get isEmpty => title.isEmpty && url.isEmpty;
}

/// Normalized focus area for public club profile (API `focusAreas` array).
class ClubFocusArea {
  final String title;
  final String description;

  /// Icon key from API (e.g. `target`); used for UI mapping.
  final String icon;

  const ClubFocusArea({
    required this.title,
    required this.description,
    required this.icon,
  });

  factory ClubFocusArea.fromApi(dynamic raw) {
    if (raw is String) {
      final t = raw.trim();
      return ClubFocusArea(title: t, description: '', icon: 'target');
    }
    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      final title = (map['title'] ?? map['name'] ?? '').toString().trim();
      final description = (map['description'] ?? '').toString().trim();
      final icon = (map['icon'] ?? 'target').toString().trim();
      return ClubFocusArea(
        title: title,
        description: description,
        icon: icon.isEmpty ? 'target' : icon,
      );
    }
    return const ClubFocusArea(title: '', description: '', icon: 'target');
  }

  bool get isEmpty => title.isEmpty && description.isEmpty;
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

  /// Structured key focus areas (API `focusAreas`); not the same as [tags].
  final List<ClubFocusArea> focusAreas;

  /// Merged social URLs: keys typically `website`, `instagram`, `x`, `tiktok`.
  final Map<String, String> socialLinks;

  /// Free-form resources list from API `resources` array (titles + optional urls).
  final List<ClubResource> resources;

  /// Document list from API `documents` array (e.g. club constitution).
  final List<ClubDocument> documents;

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
    this.focusAreas = const [],
    this.socialLinks = const {},
    this.resources = const [],
    this.documents = const [],
  });

  factory Club.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? json['clubId'] ?? '').toString();
    final name = (json['name'] ?? json['clubName'] ?? 'Unnamed Club') as String;
    final logo = (json['image'] ??
            json['logo'] ??
            json['logoUrl'] ??
            json['profileImageUrl'] ??
            '')
        .toString();
    final banner = (json['banner'] ??
        json['bannerUrl'] ??
        json['backgroundImageUrl'] ??
        '') as String;
    final category = (json['category'] ?? json['categoryName'] ?? '') as String;

    final tags = <String>[];
    final rawTags = json['tags'];
    if (rawTags is List) {
      for (final t in rawTags) {
        tags.add(t.toString());
      }
    }

    final focusAreas = <ClubFocusArea>[];
    final rawFocus = json['focusAreas'];
    if (rawFocus is List) {
      for (final item in rawFocus) {
        final area = ClubFocusArea.fromApi(item);
        if (!area.isEmpty) focusAreas.add(area);
      }
    }

    final memberCount = _toInt(
            json['memberCount'] ?? json['membersCount'] ?? json['members']) ??
        0;
    final status = _statusFromString(
        (json['status'] ?? json['clubStatus'] ?? 'open').toString());
    final about = (json['description'] ?? json['about'] ?? '') as String;

    final rawOfficers = json['officers'] ?? json['leadership'];
    final officers = <ClubOfficer>[];
    if (rawOfficers is List) {
      for (final o in rawOfficers) {
        if (o is Map<String, dynamic>) {
          final first = (o['firstName'] ?? '').toString().trim();
          final last = (o['lastName'] ?? '').toString().trim();
          final composedName = ('$first $last').trim();
          final nameRaw = (o['name'] ?? o['fullName'] ?? '').toString().trim();
          final name = composedName.isNotEmpty ? composedName : nameRaw;

          String roleFromPosition(dynamic p) {
            if (p is Map<String, dynamic>) {
              final t = (p['title'] ??
                      p['name'] ??
                      p['positionTitle'] ??
                      p['label'] ??
                      '')
                  .toString()
                  .trim();
              if (t.isNotEmpty) return t;
            }
            return '';
          }

          final pos = o['position'];
          final roleRaw = [
            o['role'],
            o['positionTitle'],
            o['title'],
            o['positionName'],
            o['roleName'],
            o['memberRole'],
            o['clubRole'],
            roleFromPosition(pos),
            (pos is String) ? pos : null,
          ]
              .map((v) => v?.toString().trim() ?? '')
              .firstWhere((s) => s.isNotEmpty && s.toLowerCase() != 'null',
                  orElse: () => '');

          officers.add(ClubOfficer(
            name: name,
            role: roleRaw,
            photo:
                (o['photo'] ?? o['photoUrl'] ?? o['avatarUrl'] ?? '') as String,
            userId: (o['userId'] ??
                    o['studentId'] ??
                    o['memberUserId'] ??
                    o['id'] ??
                    '')
                .toString()
                .trim(),
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

    final resourcesList = <ClubResource>[];
    final rawResources = json['resources'];
    if (rawResources is List) {
      for (final r in rawResources) {
        final res = ClubResource.fromApi(r);
        if (!res.isEmpty) resourcesList.add(res);
      }
    }

    final documentsList = <ClubDocument>[];
    final rawDocs = json['documents'];
    if (rawDocs is List) {
      for (final d in rawDocs) {
        final doc = ClubDocument.fromApi(d);
        if (!doc.isEmpty) documentsList.add(doc);
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
      shortDescription:
          (json['shortDescription'] ?? json['summary']) as String?,
      mainGoals: json['mainGoals'] as String?,
      contactEmail: (json['contactEmail'] ?? json['email']) as String?,
      focusAreas: focusAreas,
      socialLinks: _parseSocialLinks(json),
      resources: resourcesList,
      documents: documentsList,
    );
  }

  static Map<String, String> _parseSocialLinks(Map<String, dynamic> json) {
    final out = <String, String>{};

    void putNonEmpty(String canonicalKey, Object? value) {
      final s = value?.toString().trim();
      if (s == null || s.isEmpty) return;
      out[canonicalKey] = s;
    }

    final sl = json['socialLinks'];
    if (sl is Map) {
      for (final entry in sl.entries) {
        putNonEmpty(entry.key.toString(), entry.value);
      }
    }

    putNonEmpty('website', json['website'] ?? json['websiteUrl']);
    putNonEmpty('instagram', json['instagram'] ?? json['instagramUrl']);
    putNonEmpty(
        'x', json['x'] ?? json['twitter'] ?? json['twitterUrl'] ?? json['X']);
    putNonEmpty('tiktok', json['tiktok'] ?? json['tiktokUrl']);

    return out;
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
