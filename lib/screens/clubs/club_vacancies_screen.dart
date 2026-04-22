import 'package:flutter/material.dart';
import '../../data/club_vacancies_mock.dart';
import '../../models/club_vacancy.dart';
import '../../utils/constants.dart';
import '../../utils/vacancy_category_style.dart';
import 'club_module_nav.dart';
import 'vacancy_detail_screen.dart';

class ClubVacanciesScreen extends StatefulWidget {
  final int? filterClubId;
  final String? filterClubName;
  final bool embedInHub;

  const ClubVacanciesScreen({
    super.key,
    this.filterClubId,
    this.filterClubName,
    this.embedInHub = false,
  });

  @override
  State<ClubVacanciesScreen> createState() => _ClubVacanciesScreenState();
}

class _ClubVacanciesScreenState extends State<ClubVacanciesScreen> {
  String _search = '';
  String? _categoryFilter;
  final _searchFocus = FocusNode();

  late final List<String> _allCategories;

  @override
  void initState() {
    super.initState();
    final cats = <String>{};
    for (final v in kClubVacanciesMock) {
      cats.add(v.categoryTag);
    }
    _allCategories = cats.toList()..sort();
  }

  @override
  void dispose() {
    _searchFocus.dispose();
    super.dispose();
  }

  bool get _hasFilter => _categoryFilter != null;

  List<ClubVacancy> get _filtered {
    var list = List<ClubVacancy>.from(kClubVacanciesMock);
    final clubId = widget.filterClubId;
    final clubName = widget.filterClubName;
    if (clubId != null) {
      list = list.where((v) => v.clubId == clubId).toList();
    } else if (clubName != null && clubName.trim().isNotEmpty) {
      final n = clubName.trim().toLowerCase();
      list = list.where((v) => v.clubName.toLowerCase() == n).toList();
    }
    final q = _search.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((v) {
        return v.position.toLowerCase().contains(q) ||
            v.clubName.toLowerCase().contains(q) ||
            v.categoryTag.toLowerCase().contains(q);
      }).toList();
    }
    if (_categoryFilter != null) {
      list = list.where((v) => v.categoryTag == _categoryFilter).toList();
    }
    return list;
  }

  void _openFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        var tmp = _categoryFilter;
        return StatefulBuilder(
          builder: (ctx, setModal) {
            Widget chip(String? value, String label) {
              final sel = tmp == value;
              return GestureDetector(
                onTap: () => setModal(() => tmp = value),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primary : AppColors.gray100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: sel ? AppColors.white : AppColors.gray700,
                    ),
                  ),
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.fromLTRB(20, 14, 20, MediaQuery.of(ctx).padding.bottom + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(color: AppColors.gray300, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Filters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.gray900)),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: const Icon(Icons.close, size: 22, color: AppColors.gray500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gray600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      chip(null, 'All'),
                      ..._allCategories.map((c) => chip(c, c[0] + c.substring(1).toLowerCase())),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => _categoryFilter = tmp);
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: const Text('Apply', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
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
    final scopedClub = widget.filterClubName;

    final body = Column(
      children: [
        _buildSearchRow(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
          child: Row(
            children: [
              Text(
                '${list.length} position${list.length == 1 ? '' : 's'}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.gray500),
              ),
              if (_hasFilter) ...[
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => setState(() => _categoryFilter = null),
                  child: const Text(
                    'Clear filters',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondary),
                  ),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: list.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.work_off_outlined, size: 48, color: AppColors.gray300),
                      SizedBox(height: 12),
                      Text('No vacancies found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.gray700)),
                      SizedBox(height: 4),
                      Text('Try adjusting your search or filters', style: TextStyle(fontSize: 13, color: AppColors.gray500)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _VacancyListItem(
                    vacancy: list[i],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => VacancyDetailScreen(
                          vacancy: list[i],
                          isSaved: false,
                          onSaveToggle: () {},
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );

    if (widget.embedInHub) return body;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.gray900,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              scopedClub != null ? 'Open roles' : 'Club Vacancies',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.gray900),
            ),
            if (scopedClub != null)
              Text(scopedClub, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.gray500)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'My applications',
            onPressed: () => ClubModuleNav.openMyVacancyApplications(context, clubName: scopedClub),
            icon: const Icon(Icons.assignment_outlined),
            color: AppColors.gray700,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.gray200, height: 1),
        ),
      ),
      body: body,
    );
  }

  Widget _buildSearchRow() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      color: AppColors.backgroundLight,
      child: SizedBox(
        height: 40,
        child: TextField(
          focusNode: _searchFocus,
          onChanged: (v) => setState(() => _search = v),
          style: const TextStyle(fontSize: 14, color: AppColors.gray900),
          decoration: InputDecoration(
            hintText: 'Search roles or clubs…',
            hintStyle: const TextStyle(fontSize: 13, color: AppColors.gray400),
            prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.gray400),
            prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 0),
            suffixIcon: GestureDetector(
              onTap: _openFilterSheet,
              child: Container(
                width: 34,
                height: 34,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.tune, size: 17, color: AppColors.primary),
              ),
            ),
            suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 0),
            filled: true,
            fillColor: AppColors.gray50,
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.gray200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.gray200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
          ),
        ),
      ),
    );
  }
}

class _VacancyListItem extends StatelessWidget {
  final ClubVacancy vacancy;
  final VoidCallback onTap;

  const _VacancyListItem({required this.vacancy, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final catColor = vacancyCategoryColor(vacancy.category);
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gray200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(vacancyCategoryIcon(vacancy.category), color: catColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vacancy.position,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.gray900),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        vacancy.clubName,
                        style: const TextStyle(fontSize: 13, color: AppColors.gray500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: catColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              vacancy.categoryTag[0] + vacancy.categoryTag.substring(1).toLowerCase(),
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: catColor),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.schedule, size: 13, color: AppColors.gray400),
                          const SizedBox(width: 3),
                          Text(vacancy.postedAt, style: const TextStyle(fontSize: 11, color: AppColors.gray400)),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.gray400, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
