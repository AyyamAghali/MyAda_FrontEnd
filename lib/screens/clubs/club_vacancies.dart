import 'package:flutter/material.dart';
import '../../models/club_vacancy.dart';
import '../../utils/constants.dart';
import 'vacancy_detail_screen.dart';
import 'my_applications_screen.dart';

// ── Mock data ────────────────────────────────────────────────────────
const List<ClubVacancy> mockVacancies = [
  ClubVacancy(
    id: 1,
    clubId: 1,
    clubName: 'ADA Digital Entertainment Club',
    position: 'Event Coordinator',
    category: 'Technology',
    categoryTag: 'technology',
    postedAt: '2d ago',
    employmentType: 'Part-time',
    location: 'On-campus',
    aboutRole: [
      'We are looking for a creative and passionate Event Coordinator to join our core team. In this role, you will help plan and run events for the ADA Digital Entertainment Club.',
      "You'll work closely with the Marketing and Content teams to deliver memorable experiences for the university community.",
    ],
    responsibilities: [
      'Plan and coordinate club events from concept to execution',
      'Manage logistics, venues, and communications',
      'Collaborate with other committees on joint events',
    ],
    benefits: [
      VacancyBenefit(text: 'Hands-on event management experience', iconKey: 'chart'),
      VacancyBenefit(text: 'Certificate of leadership & contribution', iconKey: 'certificate'),
      VacancyBenefit(text: 'Networking with professionals', iconKey: 'network'),
      VacancyBenefit(text: 'Creative freedom to shape events', iconKey: 'palette'),
    ],
    deadline: 'Oct 24, 2024',
    applicants: '12 students',
    requirements: [
      'Currently enrolled student in good standing',
      'Prior experience in club activities or team projects',
      'Strong organizational and communication skills',
      'Availability for at least 5 hours per week',
    ],
  ),
  ClubVacancy(
    id: 2,
    clubId: 1,
    clubName: 'ADA Digital Entertainment Club',
    position: 'Content Creator',
    category: 'Technology',
    categoryTag: 'technology',
    postedAt: '1d ago',
    employmentType: 'Full-time',
    location: 'On-campus',
    aboutRole: [
      "We are looking for a creative and passionate Content Creator to join our core team. You'll be the voice and visual storyteller of the club.",
      "You will work closely with the Marketing and Events teams to develop content strategies for Instagram, TikTok, and our official newsletter.",
    ],
    responsibilities: [
      'Conceptualize and produce high-quality short-form videos',
      'Write engaging captions and copy for social media posts',
      'Collaborate on visual branding for seasonal campaigns',
      'Interview members and guest speakers for feature stories',
    ],
    benefits: [
      VacancyBenefit(text: 'Industry-standard production tools experience', iconKey: 'chart'),
      VacancyBenefit(text: 'Certificate of leadership & contribution', iconKey: 'certificate'),
      VacancyBenefit(text: 'Networking with industry professionals', iconKey: 'network'),
      VacancyBenefit(text: "Creative freedom to shape the club's visual identity", iconKey: 'palette'),
    ],
    deadline: 'Oct 24, 2024',
    applicants: '12 students',
    requirements: [
      'Currently enrolled student in good standing',
      'Prior experience in club activities or team projects',
      'Proficiency in basic video editing (CapCut, Premiere, etc.)',
      'Portfolio of past work or creative projects',
      'Availability for at least 5 hours per week',
    ],
  ),
  ClubVacancy(
    id: 3,
    clubId: 2,
    clubName: 'Business Society',
    position: 'Marketing Lead',
    category: 'Marketing',
    categoryTag: 'marketing',
    postedAt: '5d ago',
    employmentType: 'Part-time',
    location: 'On-campus',
    aboutRole: [
      'Lead marketing efforts for the Business Society. Develop and execute campaigns to increase engagement and membership.',
    ],
    responsibilities: [
      'Manage social media and promotional content',
      'Coordinate with external partners for sponsorships',
    ],
    benefits: [
      VacancyBenefit(text: 'Marketing experience in student-led org', iconKey: 'chart'),
      VacancyBenefit(text: 'Certificate of contribution', iconKey: 'certificate'),
    ],
    deadline: 'Nov 1, 2024',
    applicants: '8 students',
    requirements: [
      'Experience with social media marketing',
      'Creative mindset for promotional content',
      'Ability to manage club social accounts',
    ],
  ),
  ClubVacancy(
    id: 4,
    clubId: 3,
    clubName: 'Sports Union',
    position: 'Treasurer',
    category: 'Finance',
    categoryTag: 'finance',
    postedAt: '1w ago',
    employmentType: 'Part-time',
    location: 'On-campus',
    aboutRole: ['Manage finances for the Sports Union. Track budgets, expenses, and funding requests.'],
    responsibilities: [
      'Maintain budget records and reports',
      'Process funding requests and reimbursements',
    ],
    benefits: [
      VacancyBenefit(text: 'Finance and budgeting experience', iconKey: 'chart'),
      VacancyBenefit(text: 'Leadership recognition', iconKey: 'certificate'),
    ],
    deadline: 'Oct 30, 2024',
    applicants: '5 students',
    requirements: [
      'Basic understanding of budgeting and finance',
      'Attention to detail and accuracy',
      'Excel or spreadsheet proficiency',
    ],
  ),
  ClubVacancy(
    id: 5,
    clubId: 4,
    clubName: 'Creative Arts Club',
    position: 'Social Media Manager',
    category: 'Media',
    categoryTag: 'media',
    postedAt: '3h ago',
    employmentType: 'Part-time',
    location: 'On-campus',
    aboutRole: ['Run social media for the Creative Arts Club. Create and schedule content across platforms.'],
    responsibilities: [
      'Create and schedule posts',
      'Engage with followers and report analytics',
    ],
    benefits: [
      VacancyBenefit(text: 'Social media and content experience', iconKey: 'chart'),
      VacancyBenefit(text: 'Portfolio of managed accounts', iconKey: 'certificate'),
    ],
    deadline: 'Nov 5, 2024',
    applicants: '10 students',
    requirements: [
      'Experience with Instagram, TikTok, or similar',
      'Creative and consistent posting style',
      'Basic graphic design skills preferred',
    ],
  ),
  ClubVacancy(
    id: 6,
    clubId: 5,
    clubName: 'Coding Society',
    position: 'Tech Lead',
    category: 'Engineering',
    categoryTag: 'engineering',
    postedAt: '1d ago',
    employmentType: 'Part-time',
    location: 'On-campus',
    aboutRole: ['Lead technical projects and workshops for the Coding Society. Support members with tools and best practices.'],
    responsibilities: [
      'Run workshops and hackathons',
      'Maintain club websites and tools',
    ],
    benefits: [
      VacancyBenefit(text: 'Technical leadership experience', iconKey: 'chart'),
      VacancyBenefit(text: 'Certificate and portfolio projects', iconKey: 'certificate'),
    ],
    deadline: 'Oct 28, 2024',
    applicants: '6 students',
    requirements: [
      'Strong programming skills in at least one language',
      'Experience with version control',
      'Willingness to mentor others',
    ],
  ),
  ClubVacancy(
    id: 7,
    clubId: 6,
    clubName: 'Design Collective',
    position: 'Graphic Designer',
    category: 'Arts',
    categoryTag: 'arts',
    postedAt: '6h ago',
    employmentType: 'Part-time',
    location: 'On-campus',
    aboutRole: ['Create visual assets for the Design Collective. Work on posters, branding, and digital graphics.'],
    responsibilities: [
      'Design posters, flyers, and social graphics',
      'Support club branding and identity',
    ],
    benefits: [
      VacancyBenefit(text: 'Portfolio of real client work', iconKey: 'chart'),
      VacancyBenefit(text: 'Creative leadership recognition', iconKey: 'certificate'),
    ],
    deadline: 'Nov 2, 2024',
    applicants: '9 students',
    requirements: [
      'Proficiency in design tools (Figma, Illustrator, etc.)',
      'Portfolio of past work',
      'Ability to meet deadlines',
    ],
  ),
  ClubVacancy(
    id: 8,
    clubId: 1,
    clubName: 'ADA Digital Entertainment Club',
    position: 'Video Editor',
    category: 'Technology',
    categoryTag: 'technology',
    postedAt: '4d ago',
    employmentType: 'Part-time',
    location: 'On-campus',
    aboutRole: ['Edit video content for events and social media.'],
    responsibilities: ['Edit short-form and long-form video content.'],
    benefits: [
      VacancyBenefit(text: 'Video production experience', iconKey: 'chart'),
    ],
    deadline: 'Oct 31, 2024',
    applicants: '7 students',
    requirements: ['Video editing experience (CapCut, Premiere, etc.)'],
  ),
  ClubVacancy(
    id: 9,
    clubId: 2,
    clubName: 'Business Society',
    position: 'Events Coordinator',
    category: 'Technology',
    categoryTag: 'technology',
    postedAt: '3d ago',
    employmentType: 'Part-time',
    location: 'On-campus',
    aboutRole: ['Coordinate events and logistics for the Business Society.'],
    responsibilities: ['Plan events, book venues, manage RSVPs.'],
    benefits: [
      VacancyBenefit(text: 'Event management experience', iconKey: 'chart'),
    ],
    deadline: 'Nov 3, 2024',
    applicants: '4 students',
    requirements: ['Organizational skills', 'Good communication.'],
  ),
  ClubVacancy(
    id: 10,
    clubId: 4,
    clubName: 'Creative Arts Club',
    position: 'Photography Lead',
    category: 'Arts',
    categoryTag: 'arts',
    postedAt: '2d ago',
    employmentType: 'Part-time',
    location: 'On-campus',
    aboutRole: ['Lead photography at events and for club content.'],
    responsibilities: ['Take and edit photos for events and social.'],
    benefits: [
      VacancyBenefit(text: 'Portfolio building opportunity', iconKey: 'chart'),
    ],
    deadline: 'Nov 4, 2024',
    applicants: '5 students',
    requirements: ['Photography experience', 'Own camera preferred.'],
  ),
  ClubVacancy(
    id: 11,
    clubId: 5,
    clubName: 'Coding Society',
    position: 'Workshop Facilitator',
    category: 'Engineering',
    categoryTag: 'engineering',
    postedAt: '5d ago',
    employmentType: 'Part-time',
    location: 'On-campus',
    aboutRole: ['Facilitate coding workshops for members.'],
    responsibilities: ['Prepare and run beginner-friendly workshops.'],
    benefits: [
      VacancyBenefit(text: 'Teaching and leadership experience', iconKey: 'chart'),
    ],
    deadline: 'Oct 29, 2024',
    applicants: '3 students',
    requirements: ['Strong in at least one language', 'Patient communicator.'],
  ),
  ClubVacancy(
    id: 12,
    clubId: 6,
    clubName: 'Design Collective',
    position: 'UX Research Assistant',
    category: 'Technology',
    categoryTag: 'technology',
    postedAt: '1w ago',
    employmentType: 'Part-time',
    location: 'On-campus',
    aboutRole: ['Support UX research for club and partner projects.'],
    responsibilities: ['Conduct user interviews and usability tests.'],
    benefits: [
      VacancyBenefit(text: 'UX research experience', iconKey: 'chart'),
    ],
    deadline: 'Oct 27, 2024',
    applicants: '6 students',
    requirements: ['Interest in UX and user research', 'Good note-taking.'],
  ),
];

// ── Category metadata ─────────────────────────────────────────────────
class _CategoryMeta {
  final Color color;
  final IconData icon;
  const _CategoryMeta({required this.color, required this.icon});
}

const Map<String, _CategoryMeta> _categoryMeta = {
  'Technology': _CategoryMeta(color: Color(0xFF3b82f6), icon: Icons.computer),
  'Marketing': _CategoryMeta(color: Color(0xFFf97316), icon: Icons.campaign),
  'Finance': _CategoryMeta(color: Color(0xFF22c55e), icon: Icons.attach_money),
  'Media': _CategoryMeta(color: Color(0xFFec4899), icon: Icons.photo_camera),
  'Engineering': _CategoryMeta(color: Color(0xFF8b5cf6), icon: Icons.developer_mode),
  'Arts': _CategoryMeta(color: Color(0xFFef4444), icon: Icons.brush),
  'Business': _CategoryMeta(color: Color(0xFF22c55e), icon: Icons.business_center),
  'Academic': _CategoryMeta(color: Color(0xFF6366f1), icon: Icons.school),
};

_CategoryMeta _metaFor(String category) =>
    _categoryMeta[category] ??
    const _CategoryMeta(color: Color(0xFF3b82f6), icon: Icons.work_outline);

// ════════════════════════════════════════════════════════════════════
// VacanciesTab widget
// ════════════════════════════════════════════════════════════════════

class VacanciesTab extends StatefulWidget {
  const VacanciesTab({super.key});

  @override
  State<VacanciesTab> createState() => _VacanciesTabState();
}

class _VacanciesTabState extends State<VacanciesTab> {
  String _searchQuery = '';
  String _selectedCategory = '';
  bool _savedOnly = false;
  final Set<int> _savedIds = {};

  final TextEditingController _searchController = TextEditingController();

  List<ClubVacancy> get _filtered {
    var list = mockVacancies.toList();
    if (_savedOnly) list = list.where((v) => _savedIds.contains(v.id)).toList();
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list
          .where((v) =>
              v.position.toLowerCase().contains(q) ||
              v.clubName.toLowerCase().contains(q) ||
              v.category.toLowerCase().contains(q))
          .toList();
    }
    if (_selectedCategory.isNotEmpty) {
      list = list.where((v) => v.category == _selectedCategory).toList();
    }
    return list;
  }

  List<String> get _categories {
    final cats = mockVacancies.map((v) => v.category).toSet().toList()..sort();
    return cats;
  }

  void _toggleSave(int id) {
    setState(() {
      if (_savedIds.contains(id)) {
        _savedIds.remove(id);
      } else {
        _savedIds.add(id);
      }
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _FilterSheet(
        categories: _categories,
        selectedCategory: _selectedCategory,
        savedOnly: _savedOnly,
        onCategoryChanged: (c) {
          setState(() => _selectedCategory = c);
          Navigator.pop(ctx);
        },
        onSavedOnlyChanged: (v) {
          setState(() => _savedOnly = v);
          Navigator.pop(ctx);
        },
        onClear: () {
          setState(() {
            _selectedCategory = '';
            _savedOnly = false;
          });
          Navigator.pop(ctx);
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final hasActiveFilter = _selectedCategory.isNotEmpty || _savedOnly;

    return Column(
      children: [
        // ── Search + actions row ─────────────────────────────────────
        Container(
          color: AppColors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search positions or clubs…',
                    prefixIcon: const Icon(Icons.search,
                        color: AppColors.gray400, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close,
                                size: 18, color: AppColors.gray400),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.gray50,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.gray200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.gray200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Filter button
              _IconActionButton(
                icon: Icons.tune,
                badged: hasActiveFilter,
                onTap: _showFilterSheet,
              ),
              const SizedBox(width: 6),
              // My Applications button
              _IconActionButton(
                icon: Icons.assignment_outlined,
                badged: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const MyApplicationsScreen()),
                  );
                },
              ),
            ],
          ),
        ),
        // ── Category chips ───────────────────────────────────────────
        _buildCategoryChips(),
        // ── Count row ────────────────────────────────────────────────
        Container(
          color: AppColors.backgroundLight,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: Row(
            children: [
              Text(
                '${filtered.length} position${filtered.length == 1 ? '' : 's'} found',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.gray500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (hasActiveFilter) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() {
                    _selectedCategory = '';
                    _savedOnly = false;
                  }),
                  child: const Text(
                    'Clear filters',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        // ── List ─────────────────────────────────────────────────────
        Expanded(
          child: filtered.isEmpty
              ? _buildEmpty()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) => _VacancyCard(
                    vacancy: filtered[i],
                    isSaved: _savedIds.contains(filtered[i].id),
                    onSaveToggle: () => _toggleSave(filtered[i].id),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VacancyDetailScreen(
                            vacancy: filtered[i],
                            isSaved: _savedIds.contains(filtered[i].id),
                            onSaveToggle: () => _toggleSave(filtered[i].id),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildCategoryChips() {
    return Container(
      color: AppColors.white,
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _CategoryChip(
            label: 'All',
            selected: _selectedCategory.isEmpty,
            onTap: () => setState(() => _selectedCategory = ''),
          ),
          ..._categories.map((cat) => _CategoryChip(
                label: cat,
                selected: _selectedCategory == cat,
                color: _metaFor(cat).color,
                onTap: () => setState(() {
                  _selectedCategory = _selectedCategory == cat ? '' : cat;
                }),
              )),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.work_off_outlined, size: 56, color: AppColors.gray300),
          SizedBox(height: 16),
          Text('No vacancies found',
              style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Try adjusting your search or filters',
              style: TextStyle(fontSize: 13, color: AppColors.gray500)),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// Vacancy card
// ════════════════════════════════════════════════════════════════════

class _VacancyCard extends StatelessWidget {
  final ClubVacancy vacancy;
  final bool isSaved;
  final VoidCallback onSaveToggle;
  final VoidCallback onTap;

  const _VacancyCard({
    required this.vacancy,
    required this.isSaved,
    required this.onSaveToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final meta = _metaFor(vacancy.category);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.gray200, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: meta.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(meta.icon, color: meta.color, size: 22),
              ),
              const SizedBox(width: 12),
              // Main content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            vacancy.position,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.gray900,
                            ),
                          ),
                        ),
                        // Save button
                        GestureDetector(
                          onTap: onSaveToggle,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Icon(
                              isSaved ? Icons.bookmark : Icons.bookmark_border,
                              size: 20,
                              color: isSaved
                                  ? AppColors.secondary
                                  : AppColors.gray400,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      vacancy.clubName,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.gray600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Tags row
                    Row(
                      children: [
                        _MiniTag(
                          label: vacancy.category,
                          color: meta.color,
                        ),
                        const SizedBox(width: 6),
                        _MiniTag(
                          label: vacancy.employmentType,
                          color: AppColors.primary,
                        ),
                        const Spacer(),
                        const Icon(Icons.access_time,
                            size: 12, color: AppColors.gray400),
                        const SizedBox(width: 3),
                        Text(
                          vacancy.postedAt,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.gray400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// Helper widgets
// ════════════════════════════════════════════════════════════════════

class _MiniTag extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? activeColor : AppColors.gray100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? activeColor : AppColors.gray200,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.white : AppColors.gray600,
          ),
        ),
      ),
    );
  }
}

class _IconActionButton extends StatelessWidget {
  final IconData icon;
  final bool badged;
  final VoidCallback onTap;

  const _IconActionButton({
    required this.icon,
    required this.badged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.gray700, size: 20),
          ),
          if (badged)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// Filter bottom sheet
// ════════════════════════════════════════════════════════════════════

class _FilterSheet extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final bool savedOnly;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<bool> onSavedOnlyChanged;
  final VoidCallback onClear;

  const _FilterSheet({
    required this.categories,
    required this.selectedCategory,
    required this.savedOnly,
    required this.onCategoryChanged,
    required this.onSavedOnlyChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter Vacancies',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray900,
                  ),
                ),
                if (selectedCategory.isNotEmpty || savedOnly)
                  TextButton(
                    onPressed: onClear,
                    child: const Text(
                      'Clear all',
                      style: TextStyle(color: AppColors.secondary),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'SHOW',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.gray500,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            _FilterRow(
              label: 'All vacancies',
              selected: !savedOnly,
              onTap: () => onSavedOnlyChanged(false),
            ),
            _FilterRow(
              label: 'Saved only',
              selected: savedOnly,
              onTap: () => onSavedOnlyChanged(true),
            ),
            const SizedBox(height: 16),
            const Text(
              'CATEGORY',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.gray500,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            ...categories.map(
              (cat) => _FilterRow(
                label: cat,
                selected: selectedCategory == cat,
                onTap: () => onCategoryChanged(cat),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.secondary : AppColors.gray300,
                  width: 2,
                ),
                color: selected ? AppColors.secondary : Colors.transparent,
              ),
              child: selected
                  ? const Icon(Icons.check, size: 12, color: AppColors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color:
                    selected ? AppColors.gray900 : AppColors.gray700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}