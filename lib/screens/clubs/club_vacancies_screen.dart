import 'package:flutter/material.dart';
import '../../models/club_vacancy.dart';
import '../../services/club_api_service.dart';
import '../../utils/constants.dart';
import '../../widgets/app_back_button.dart';
import '../../utils/vacancy_category_style.dart';
import 'club_hub_deep_link.dart';
import 'club_module_nav.dart';
import 'vacancy_detail_screen.dart';

class ClubVacanciesScreen extends StatefulWidget {
  final int? filterClubId;
  final String? filterClubName;
  final bool embedInHub;

  /// When [embedInHub], defer the first fetch until this tab is selected (see [ClubManagementHub]).
  final TabController? hubMainTabController;

  const ClubVacanciesScreen({
    super.key,
    this.filterClubId,
    this.filterClubName,
    this.embedInHub = false,
    this.hubMainTabController,
  });

  @override
  State<ClubVacanciesScreen> createState() => _ClubVacanciesScreenState();
}

class _ClubVacanciesScreenState extends State<ClubVacanciesScreen> {
  String _search = '';
  final _searchFocus = FocusNode();
  final ClubApiService _api = ClubApiService();
  List<ClubVacancy> _vacancies = [];
  bool _isLoading = false;
  String? _error;

  bool _embeddedHubFetchStarted = false;

  bool get _deferHubEmbeddedFetch =>
      widget.embedInHub && widget.hubMainTabController != null;

  @override
  void initState() {
    super.initState();
    if (_deferHubEmbeddedFetch) {
      widget.hubMainTabController!.addListener(_onHubMainTabChanged);
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _kickHubEmbeddedFetch());
    } else {
      _loadVacancies();
    }
  }

  void _kickHubEmbeddedFetch() {
    if (!mounted || !_deferHubEmbeddedFetch) return;
    final c = widget.hubMainTabController!;
    if (c.indexIsChanging) return;
    if (c.index != ClubHubTabs.openings) return;
    _startEmbeddedHubFetchIfNeeded();
  }

  void _onHubMainTabChanged() {
    if (!mounted || !_deferHubEmbeddedFetch) return;
    final c = widget.hubMainTabController!;
    if (c.indexIsChanging) return;
    if (c.index == ClubHubTabs.openings) {
      _startEmbeddedHubFetchIfNeeded();
    }
    setState(() {});
  }

  void _startEmbeddedHubFetchIfNeeded() {
    if (_embeddedHubFetchStarted) return;
    _embeddedHubFetchStarted = true;
    _loadVacancies();
  }

  @override
  void dispose() {
    if (_deferHubEmbeddedFetch) {
      widget.hubMainTabController?.removeListener(_onHubMainTabChanged);
    }
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _loadVacancies() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final vacancies = await _api.fetchVacancies(clubId: widget.filterClubId);
      if (mounted) {
        setState(() {
          _vacancies = vacancies;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  List<ClubVacancy> get _filtered {
    var list = List<ClubVacancy>.from(_vacancies);
    final clubName = widget.filterClubName;
    if (clubName != null && clubName.trim().isNotEmpty) {
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
    return list;
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
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray500),
              ),
            ],
          ),
        ),
        Expanded(
          child: (_deferHubEmbeddedFetch && !_embeddedHubFetchStarted)
              ? (widget.hubMainTabController?.index == ClubHubTabs.openings
                  ? const Center(child: CircularProgressIndicator())
                  : const SizedBox.shrink())
              : _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.cloud_off,
                                  size: 48, color: AppColors.gray300),
                              const SizedBox(height: 12),
                              const Text('Failed to load vacancies',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.gray700)),
                              const SizedBox(height: 4),
                              Text(_error!,
                                  style: const TextStyle(
                                      fontSize: 12, color: AppColors.gray500),
                                  textAlign: TextAlign.center),
                              const SizedBox(height: 12),
                              FilledButton.icon(
                                onPressed: _loadVacancies,
                                icon: const Icon(Icons.refresh, size: 18),
                                label: const Text('Retry'),
                                style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.primary),
                              ),
                            ],
                          ),
                        )
                      : list.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.work_off_outlined,
                                      size: 48, color: AppColors.gray300),
                                  SizedBox(height: 12),
                                  Text('No vacancies found',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.gray700)),
                                  SizedBox(height: 4),
                                  Text('Try adjusting your search',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.gray500)),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadVacancies,
                              child: ListView.separated(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 4, 16, 80),
                                itemCount: list.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 8),
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
        centerTitle: false,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Center(
            child: AppBackButton(onPressed: () => Navigator.pop(context)),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              scopedClub != null ? 'Open roles' : 'Club Vacancies',
              style: AppTextStyles.moduleAppBarTitle,
            ),
            if (scopedClub != null)
              Text(scopedClub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.gray500)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'My applications',
            onPressed: () => ClubModuleNav.openMyVacancyApplications(context,
                clubName: scopedClub),
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
            prefixIcon:
                const Icon(Icons.search, size: 20, color: AppColors.gray400),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 40, minHeight: 0),
            suffixIcon: _search.trim().isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close,
                        size: 18, color: AppColors.gray400),
                    onPressed: () => setState(() => _search = ''),
                  ),
            filled: true,
            fillColor: AppColors.gray50,
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.gray200)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.gray200)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5)),
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
                    color: catColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(vacancyCategoryIcon(vacancy.category),
                      color: catColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vacancy.position,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray900),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        vacancy.clubName,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.gray500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (!vacancyListTagIsStatusOnly(
                              vacancy.categoryTag)) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: catColor.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                vacancy.categoryTag[0] +
                                    vacancy.categoryTag
                                        .substring(1)
                                        .toLowerCase(),
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: catColor),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Icon(Icons.schedule,
                              size: 13, color: AppColors.gray400),
                          const SizedBox(width: 3),
                          Text(vacancy.postedAt,
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.gray400)),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right,
                    color: AppColors.gray400, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
