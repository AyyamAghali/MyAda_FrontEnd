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
}
