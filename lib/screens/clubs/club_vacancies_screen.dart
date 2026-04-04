import 'package:flutter/material.dart';
import '../../data/club_vacancies_mock.dart';
import '../../models/club_vacancy.dart';
import '../../services/club_module_prefs.dart';
import '../../utils/constants.dart';
import '../../widgets/clubs/clubs_top_nav.dart';
import '../../widgets/responsive_container.dart';
import '../../utils/vacancy_category_style.dart';
import 'club_module_nav.dart';
import 'clubs_home.dart';
import 'my_memberships.dart';
import 'vacancy_detail_screen.dart';

class ClubVacanciesScreen extends StatefulWidget {
  const ClubVacanciesScreen({super.key});

  @override
  State<ClubVacanciesScreen> createState() => _ClubVacanciesScreenState();
}

class _ClubVacanciesScreenState extends State<ClubVacanciesScreen> {
  String search = '';
  final Set<String> _categories = {};
  String? _categoryFilter;
  bool _savedOnly = false;
  bool _grid = true;
  Set<int> _savedIds = {};

  @override
  void initState() {
    super.initState();
    for (final v in kClubVacanciesMock) {
      _categories.add(v.categoryTag);
    }
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final s = await ClubModulePrefs.savedVacancyIds();
    if (mounted) setState(() => _savedIds = s);
  }

  List<ClubVacancy> get _filtered {
    var list = List<ClubVacancy>.from(kClubVacanciesMock);
    if (_savedOnly) {
      list = list.where((v) => _savedIds.contains(v.id)).toList();
    }
    final q = search.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((v) {
        return v.position.toLowerCase().contains(q) ||
            v.clubName.toLowerCase().contains(q) ||
            v.categoryTag.toLowerCase().contains(q);
      }).toList();
    }
    if (_categoryFilter != null && _categoryFilter!.isNotEmpty) {
      list = list.where((v) => v.categoryTag == _categoryFilter).toList();
    }
    return list;
  }

  Future<void> _toggleSave(int id) async {
    await ClubModulePrefs.toggleSavedVacancy(id);
    await _loadSaved();
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModal) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Show', style: TextStyle(fontWeight: FontWeight.w600)),
                  RadioListTile<bool>(
                    title: const Text('All vacancies'),
                    value: false,
                    groupValue: _savedOnly,
                    onChanged: (v) {
                      setModal(() => _savedOnly = false);
                      setState(() => _savedOnly = false);
                    },
                  ),
                  RadioListTile<bool>(
                    title: const Text('Saved only'),
                    value: true,
                    groupValue: _savedOnly,
                    onChanged: (v) {
                      setModal(() => _savedOnly = true);
                      setState(() => _savedOnly = true);
                    },
                  ),
                  const SizedBox(height: 8),
                  const Text('Category', style: TextStyle(fontWeight: FontWeight.w600)),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _categoryFilter == null,
                        onSelected: (_) {
                          setModal(() => _categoryFilter = null);
                          setState(() => _categoryFilter = null);
                        },
                      ),
                      ..._categories.map(
                        (c) => FilterChip(
                          label: Text(c),
                          selected: _categoryFilter == c,
                          onSelected: (sel) {
                            setModal(() => _categoryFilter = sel ? c : null);
                            setState(() => _categoryFilter = sel ? c : null);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      setModal(() {
                        _categoryFilter = null;
                        _savedOnly = false;
                      });
                      setState(() {
                        _categoryFilter = null;
                        _savedOnly = false;
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('Clear filters'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    return Scaffold(
      backgroundColor: ClubUiColors.pageBg,
      body: SafeArea(
        child: ResponsiveContainer(
          backgroundColor: ClubUiColors.pageBg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.gray700),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              ClubsTopNav(
                active: ClubsNavSection.vacancies,
                onVacanciesTap: () {},
                onMyApplicationsTap: () => ClubModuleNav.openMyVacancyApplications(context),
                onEventsTap: () => ClubModuleNav.openEvents(context),
                onClubsTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(builder: (_) => const ClubsHome()),
                  );
                },
                onProposeTap: () => ClubModuleNav.openProposeClub(context),
                onNotificationsTap: () => ClubModuleNav.openNotifications(context),
                onProfileTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(builder: (_) => const MyMemberships()),
                  );
                },
              ),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Club Vacancies',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${list.length} positions available for your profile',
                              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              onChanged: (v) => setState(() => search = v),
                              decoration: InputDecoration(
                                hintText: 'Search roles or clubs',
                                prefixIcon: const Icon(Icons.search, color: AppColors.gray400),
                                filled: true,
                                fillColor: AppColors.gray50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: AppColors.gray200),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: AppColors.gray200),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    _viewBtn(Icons.grid_view_rounded, _grid, () => setState(() => _grid = true)),
                                    const SizedBox(width: 8),
                                    _viewBtn(Icons.view_list_rounded, !_grid, () => setState(() => _grid = false)),
                                  ],
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.filter_list, color: Color(0xFF64748B)),
                                  onPressed: () => _showFilterSheet(context),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (list.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(
                            'No vacancies match your filters.',
                            style: TextStyle(color: Color(0xFF64748B)),
                          ),
                        ),
                      )
                    else if (_grid)
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.72,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, i) => _VacancyCard(
                              vacancy: list[i],
                              grid: true,
                              saved: _savedIds.contains(list[i].id),
                              onSave: () => _toggleSave(list[i].id),
                              onOpen: () => Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (_) => VacancyDetailScreen(
                                    vacancy: list[i],
                                    isSaved: _savedIds.contains(list[i].id),
                                    onSaveToggle: () => _toggleSave(list[i].id),
                                  ),
                                ),
                              ),
                            ),
                            childCount: list.length,
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, i) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _VacancyCard(
                                vacancy: list[i],
                                grid: false,
                                saved: _savedIds.contains(list[i].id),
                                onSave: () => _toggleSave(list[i].id),
                                onOpen: () => Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (_) => VacancyDetailScreen(
                                      vacancy: list[i],
                                      isSaved: _savedIds.contains(list[i].id),
                                      onSaveToggle: () => _toggleSave(list[i].id),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            childCount: list.length,
                          ),
                        ),
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

  Widget _viewBtn(IconData icon, bool active, VoidCallback onTap) {
    return Material(
      color: active ? ClubNavColors.activeBg : AppColors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.gray200),
          ),
          child: Icon(icon, size: 20, color: active ? ClubNavColors.activeText : AppColors.gray600),
        ),
      ),
    );
  }
}

class _VacancyCard extends StatelessWidget {
  final ClubVacancy vacancy;
  final bool grid;
  final bool saved;
  final VoidCallback onSave;
  final VoidCallback onOpen;

  const _VacancyCard({
    required this.vacancy,
    required this.grid,
    required this.saved,
    required this.onSave,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final c = vacancyCategoryColor(vacancy.category);
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: c.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(vacancyCategoryIcon(vacancy.category), color: c, size: 24),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: onSave,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          saved ? Icons.bookmark : Icons.bookmark_border,
                          size: 18,
                          color: saved ? ClubNavColors.activeText : AppColors.gray500,
                        ),
                        const SizedBox(width: 4),
                        Text(saved ? 'Saved' : 'Save', style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  vacancy.categoryTag,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                vacancy.position,
                style: TextStyle(
                  fontSize: grid ? 15 : 17,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                vacancy.clubName,
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.schedule, size: 14, color: AppColors.gray400),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Posted ${vacancy.postedAt}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
