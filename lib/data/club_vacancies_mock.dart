import '../models/club_vacancy.dart';

/// From `MyAda_Front_Web/src/data/clubVacanciesData.js` (subset; extend as needed).
final List<ClubVacancy> kClubVacanciesMock = [
  ClubVacancy(
    id: 1,
    clubId: 1,
    clubName: 'ADA Digital Entertainment Club',
    position: 'Event Coordinator',
    category: 'Technology',
    categoryTag: 'TECHNOLOGY',
    postedAt: '2d ago',
    employmentType: 'Part-time',
    location: 'On-campus',
    aboutRole: const [
      'We are looking for a creative and passionate Event Coordinator to join our core team. In this role, you will help plan and run events for the ADA Digital Entertainment Club.',
      "You'll work closely with the Marketing and Content teams to deliver memorable experiences for the university community.",
    ],
    responsibilities: const [
      'Plan and coordinate club events from concept to execution',
      'Manage logistics, venues, and communications',
      'Collaborate with other committees on joint events',
    ],
    benefits: const [
      VacancyBenefit(text: 'Hands-on experience with event management tools.', iconKey: 'chart'),
      VacancyBenefit(text: 'Official certificate of leadership and contribution.', iconKey: 'certificate'),
      VacancyBenefit(text: 'Networking with industry professionals and guest speakers.', iconKey: 'network'),
      VacancyBenefit(text: "Creative freedom to shape the club's event identity.", iconKey: 'palette'),
    ],
    deadline: 'Oct 24, 2023',
    applicants: '12 students',
    requirements: const [
      'Currently enrolled student in good standing.',
      'Prior experience in club activities or team projects.',
      'Strong organizational and communication skills.',
      'Availability for at least 5 hours per week.',
    ],
  ),
  ClubVacancy(
    id: 2,
    clubId: 1,
    clubName: 'ADA Digital Entertainment Club',
    position: 'Content Creator',
    category: 'Technology',
    categoryTag: 'TECHNOLOGY',
    postedAt: '1d ago',
    employmentType: 'Full-time',
    location: 'On-campus',
    aboutRole: const [
      'We are looking for a creative Content Creator to join our core team — the voice and visual storyteller of the club.',
    ],
    responsibilities: const [
      'Conceptualize and produce short-form videos (Reels/TikToks).',
      'Write engaging captions for social media posts.',
    ],
    benefits: const [
      VacancyBenefit(text: 'Hands-on experience with production tools.', iconKey: 'chart'),
      VacancyBenefit(text: 'Certificate of leadership and contribution.', iconKey: 'certificate'),
    ],
    deadline: 'Oct 24, 2023',
    applicants: '12 students',
    requirements: const [
      'Currently enrolled student in good standing.',
      'Proficiency in basic video editing.',
      'Availability for at least 5 hours per week.',
    ],
  ),
  ClubVacancy(
    id: 3,
    clubId: 2,
    clubName: 'Business Society',
    position: 'Marketing Lead',
    category: 'Marketing',
    categoryTag: 'MARKETING',
    postedAt: '5d ago',
    employmentType: 'Part-time',
    location: 'On-campus',
    aboutRole: const [
      'Lead marketing efforts for the Business Society. Develop and execute campaigns to increase engagement and membership.',
    ],
    responsibilities: const [
      'Manage social media and promotional content',
      'Coordinate with external partners for sponsorships',
    ],
    benefits: const [
      VacancyBenefit(text: 'Marketing experience in a student-led organization.', iconKey: 'chart'),
      VacancyBenefit(text: 'Certificate of contribution.', iconKey: 'certificate'),
    ],
    deadline: 'Nov 1, 2023',
    applicants: '8 students',
    requirements: const [
      'Experience with social media marketing',
      'Creative mindset for promotional content',
    ],
  ),
  ClubVacancy(
    id: 4,
    clubId: 3,
    clubName: 'Sports Union',
    position: 'Treasurer',
    category: 'Finance',
    categoryTag: 'FINANCE',
    postedAt: '1w ago',
    employmentType: 'Part-time',
    location: 'On-campus',
    aboutRole: const [
      'Manage finances for the Sports Union. Track budgets, expenses, and funding requests.',
    ],
    responsibilities: const [
      'Maintain budget records and reports',
      'Process funding requests and reimbursements',
    ],
    benefits: const [
      VacancyBenefit(text: 'Finance and budgeting experience.', iconKey: 'chart'),
      VacancyBenefit(text: 'Leadership recognition.', iconKey: 'certificate'),
    ],
    deadline: 'Oct 30, 2023',
    applicants: '5 students',
    requirements: const [
      'Basic understanding of budgeting and finance',
      'Excel or spreadsheet proficiency',
    ],
  ),
  ClubVacancy(
    id: 5,
    clubId: 4,
    clubName: 'Creative Arts Club',
    position: 'Social Media Manager',
    category: 'Media',
    categoryTag: 'MEDIA',
    postedAt: '3h ago',
    employmentType: 'Part-time',
    location: 'On-campus',
    aboutRole: const [
      'Run social media for the Creative Arts Club. Create and schedule content across platforms.',
    ],
    responsibilities: const [
      'Create and schedule posts',
      'Engage with followers and report analytics',
    ],
    benefits: const [
      VacancyBenefit(text: 'Social media and content experience.', iconKey: 'chart'),
      VacancyBenefit(text: 'Portfolio of managed accounts.', iconKey: 'certificate'),
    ],
    deadline: 'Nov 5, 2023',
    applicants: '10 students',
    requirements: const [
      'Experience with Instagram, TikTok, or similar',
      'Basic graphic design skills preferred',
    ],
  ),
  ClubVacancy(
    id: 6,
    clubId: 5,
    clubName: 'Coding Society',
    position: 'Tech Lead',
    category: 'Engineering',
    categoryTag: 'ENGINEERING',
    postedAt: '1d ago',
    employmentType: 'Part-time',
    location: 'On-campus',
    aboutRole: const [
      'Lead technical projects and workshops for the Coding Society.',
    ],
    responsibilities: const [
      'Run workshops and hackathons',
      'Maintain club websites and tools',
    ],
    benefits: const [
      VacancyBenefit(text: 'Technical leadership experience.', iconKey: 'chart'),
      VacancyBenefit(text: 'Certificate and portfolio projects.', iconKey: 'certificate'),
    ],
    deadline: 'Oct 28, 2023',
    applicants: '6 students',
    requirements: const [
      'Strong programming skills in at least one language',
      'Willingness to mentor others',
    ],
  ),
  ClubVacancy(
    id: 7,
    clubId: 6,
    clubName: 'Design Collective',
    position: 'Graphic Designer',
    category: 'Arts',
    categoryTag: 'ARTS',
    postedAt: '6h ago',
    employmentType: 'Part-time',
    location: 'On-campus',
    aboutRole: const [
      'Create visual assets for the Design Collective. Work on posters, branding, and digital graphics.',
    ],
    responsibilities: const [
      'Design posters, flyers, and social graphics',
      'Support club branding and identity',
    ],
    benefits: const [
      VacancyBenefit(text: 'Portfolio of real client work.', iconKey: 'chart'),
      VacancyBenefit(text: 'Creative leadership recognition.', iconKey: 'certificate'),
    ],
    deadline: 'Nov 2, 2023',
    applicants: '9 students',
    requirements: const [
      'Proficiency in design tools (Figma, Illustrator, etc.)',
      'Portfolio of past work',
    ],
  ),
  ClubVacancy(
    id: 8,
    clubId: 1,
    clubName: 'ADA Digital Entertainment Club',
    position: 'Video Editor',
    category: 'Technology',
    categoryTag: 'TECHNOLOGY',
    postedAt: '4d ago',
    employmentType: 'Part-time',
    location: 'On-campus',
    aboutRole: const ['Edit video content for events and social media.'],
    responsibilities: const ['Edit short-form and long-form video content.'],
    benefits: const [
      VacancyBenefit(text: 'Video production experience.', iconKey: 'chart'),
      VacancyBenefit(text: 'Certificate.', iconKey: 'certificate'),
    ],
    deadline: 'Oct 31, 2023',
    applicants: '7 students',
    requirements: const [
      'Video editing experience (CapCut, Premiere, etc.)',
      'Creative and detail-oriented.',
    ],
  ),
];

ClubVacancy? getClubVacancyById(int id) {
  for (final v in kClubVacanciesMock) {
    if (v.id == id) return v;
  }
  return null;
}
