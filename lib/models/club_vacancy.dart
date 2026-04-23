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
  });

  factory ClubVacancy.fromJson(Map<String, dynamic> json) {
    final id = int.tryParse((json['id'] ?? json['vacancyId'] ?? 0).toString()) ?? 0;
    final clubId = int.tryParse((json['clubId'] ?? 0).toString()) ?? 0;
    final clubName = (json['clubName'] ?? '') as String;
    final title = (json['title'] ?? json['position'] ?? json['positionTitle'] ?? 'Untitled') as String;
    final description = (json['description'] ?? '') as String;

    final statusRaw = (json['status'] ?? 'active').toString().toLowerCase();
    final categoryTag = statusRaw == 'draft' ? 'DRAFT' : 'ACTIVE';

    final createdAt = (json['createdAt'] ?? json['postedAt'] ?? '').toString();
    final postedAt = createdAt.length >= 10 ? createdAt.substring(0, 10) : createdAt;

    final deadline = (json['applicationDeadline'] ?? json['deadline'] ?? 'Open').toString();
    final formattedDeadline = deadline.length >= 10 ? deadline.substring(0, 10) : deadline;

    final requirementsRaw = json['requirements'];
    final requirements = <String>[];
    if (requirementsRaw is List) {
      for (final r in requirementsRaw) {
        requirements.add(r.toString());
      }
    }

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
      deadline: formattedDeadline,
      applicants: '',
      requirements: requirements,
    );
  }
}
