import 'package:intl/intl.dart';

class VacancyBenefit {
  final String text;
  final String iconKey;

  const VacancyBenefit({required this.text, required this.iconKey});
}

class ClubVacancy {
  final int id;
  final int clubId;
  final String clubName;
  final String position;
  final String category;
  final String categoryTag;
  final String postedAt;
  final String employmentType;
  final String location;
  final List<String> aboutRole;
  final List<String> responsibilities;
  final List<VacancyBenefit> benefits;
  final String deadline;
  final String applicants;
  final List<String> requirements;

  /// API: `postedBy` (poster user id, often a UUID).
  final String? postedBy;

  /// API: `clubPositionId`
  final int? clubPositionId;

  /// API: `isActive`
  final bool isActive;

  /// API: `isDraft`
  final bool isDraft;

  /// API: `status` (e.g. `active`, `draft`).
  final String status;

  /// Raw ISO timestamp for sorting/debug (optional).
  final String? createdAtIso;

  /// Raw ISO application deadline (optional).
  final String? applicationDeadlineIso;

  const ClubVacancy({
    required this.id,
    required this.clubId,
    required this.clubName,
    required this.position,
    required this.category,
    required this.categoryTag,
    required this.postedAt,
    required this.employmentType,
    required this.location,
    required this.aboutRole,
    required this.responsibilities,
    required this.benefits,
    required this.deadline,
    required this.applicants,
    required this.requirements,
    this.postedBy,
    this.clubPositionId,
    this.isActive = true,
    this.isDraft = false,
    this.status = 'active',
    this.createdAtIso,
    this.applicationDeadlineIso,
  });

  static String _formatDisplayDate(String? isoOrText) {
    if (isoOrText == null || isoOrText.isEmpty) return '—';
    final dt = DateTime.tryParse(isoOrText);
    if (dt != null) {
      return DateFormat.yMMMd().format(dt.toLocal());
    }
    return isoOrText;
  }

  factory ClubVacancy.fromJson(Map<String, dynamic> json) {
    final id = int.tryParse((json['id'] ?? json['vacancyId'] ?? 0).toString()) ?? 0;
    final clubId = int.tryParse((json['clubId'] ?? 0).toString()) ?? 0;
    final clubName = (json['clubName'] ?? '') as String;
    final title = (json['title'] ?? json['position'] ?? json['positionTitle'] ?? 'Untitled') as String;
    final description = (json['description'] ?? '') as String;

    final isDraft = json['isDraft'] == true;
    final isActive = json['isActive'] != false;
    final statusRaw = (json['status'] ?? 'active').toString().toLowerCase();
    final categoryTag =
        (isDraft || statusRaw == 'draft') ? 'DRAFT' : statusRaw.toUpperCase();

    final createdAt = (json['createdAt'] ?? json['postedAt'] ?? '').toString();
    final postedAt = _formatDisplayDate(
        createdAt.isNotEmpty ? createdAt : null);

    final deadlineRaw =
        (json['applicationDeadline'] ?? json['deadline'] ?? '').toString();
    final deadline = deadlineRaw.isEmpty
        ? 'Open'
        : _formatDisplayDate(deadlineRaw);

    final requirementsRaw = json['requirements'];
    final requirements = <String>[];
    if (requirementsRaw is List) {
      for (final r in requirementsRaw) {
        requirements.add(r.toString());
      }
    }
    if (requirements.isEmpty) {
      final pos = json['position'];
      if (pos is Map<String, dynamic>) {
        final nested = pos['requirements'];
        if (nested is List) {
          for (final r in nested) {
            requirements.add(r.toString());
          }
        }
      }
    }

    final postedBy = json['postedBy']?.toString().trim();

    final clubPositionId =
        int.tryParse((json['clubPositionId'] ?? '').toString());

    return ClubVacancy(
      id: id,
      clubId: clubId,
      clubName: clubName,
      position: title,
      category: title,
      categoryTag: categoryTag,
      postedAt: postedAt,
      employmentType: 'Club Position',
      location: 'ADA University',
      aboutRole: description.isNotEmpty ? [description] : [],
      responsibilities: const [],
      benefits: const [],
      deadline: deadline,
      applicants: '',
      requirements: requirements,
      postedBy:
          (postedBy != null && postedBy.isNotEmpty) ? postedBy : null,
      clubPositionId: clubPositionId,
      isActive: isActive,
      isDraft: isDraft,
      status: statusRaw,
      createdAtIso: createdAt.isNotEmpty ? createdAt : null,
      applicationDeadlineIso:
          deadlineRaw.isNotEmpty ? deadlineRaw : null,
    );
  }
}
