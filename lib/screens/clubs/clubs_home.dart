import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import '../../models/club.dart';
import '../../services/club_api_service.dart';
import '../../utils/constants.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/responsive_container.dart';
import '../../widgets/club_card.dart';
import 'club_details.dart';
import 'club_hub_deep_link.dart';
import 'create_club_form.dart';
import 'my_memberships.dart';

class ClubsHome extends StatefulWidget {
  /// When true, this widget is embedded in [ClubManagementHub] (no outer scaffold chrome).
  final bool embeddedInHub;

  /// Hub-controlled: Discover vs My clubs (only used when [embeddedInHub] is true).
  final ClubsHomePane clubsPane;

  final ValueChanged<ClubsHomePane>? onClubsPaneChanged;

  final int myClubsInnerTabIndex;
  final String? applicationsClubNameFilter;

  /// When set (hub mode), opening a club uses this instead of pushing [ClubDetails] directly.
  final Future<void> Function(Club club)? onClubOpen;

  /// [ClubManagementHub]'s main tab controller. When set with [embeddedInHub], directory
  /// requests run only while the Clubs tab is selected so Vacancies/Events do not compete
  /// on the same gateway (avoids timeouts / flaky first load on mobile).
  final TabController? hubMainTabController;

  const ClubsHome({
    super.key,
    this.embeddedInHub = false,
    this.clubsPane = ClubsHomePane.browse,
    this.onClubsPaneChanged,
    this.myClubsInnerTabIndex = 0,
    this.applicationsClubNameFilter,
    this.onClubOpen,
    this.hubMainTabController,
  });

  @override
  State<ClubsHome> createState() => _ClubsHomeState();
}

class _ClubsHomeState extends State<ClubsHome> {
  // ── Directory state ───────────────────────────────────────────────
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final ClubApiService _api = ClubApiService();
  List<Club> _clubs = [];
  bool _isLoading = false;
  String? _error;

  int _page = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  static const _limit = 24;

  bool _embeddedHubFetchStarted = false;

  bool get _deferHubEmbeddedFetch =>
      widget.embeddedInHub && widget.hubMainTabController != null;

  @override
  void initState() {
    super.initState();
    if (_deferHubEmbeddedFetch) {
      widget.hubMainTabController!.addListener(_onHubMainTabChanged);
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _kickHubEmbeddedFetch());
    } else {
      unawaited(_bootstrapClubsDirectory());
    }
  }

  void _kickHubEmbeddedFetch() {
    if (!mounted || !_deferHubEmbeddedFetch) return;
    final c = widget.hubMainTabController!;
    if (c.indexIsChanging) return;
    if (c.index != ClubHubTabs.clubs) return;
    _startEmbeddedHubFetchIfNeeded();
  }

  void _onHubMainTabChanged() {
    if (!mounted || !_deferHubEmbeddedFetch) return;
    final c = widget.hubMainTabController!;
    if (c.indexIsChanging) return;
    if (c.index == ClubHubTabs.clubs) {
      _startEmbeddedHubFetchIfNeeded();
    }
    setState(() {});
  }

  void _startEmbeddedHubFetchIfNeeded() {
    if (_embeddedHubFetchStarted) return;
    _embeddedHubFetchStarted = true;
    unawaited(_bootstrapClubsDirectory());
  }

  /// Load club directory.
  Future<void> _bootstrapClubsDirectory() async {
    await _loadClubs();
  }

  @override
  void dispose() {
    if (_deferHubEmbeddedFetch) {
      widget.hubMainTabController?.removeListener(_onHubMainTabChanged);
    }
    _searchFocus.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadClubs({bool loadMore = false}) async {
    if (loadMore) {
      setState(() => _isLoadingMore = true);
    } else {
      setState(() {
        _isLoading = true;
        _error = null;
        _page = 1;
        _hasMore = true;
      });
    }
    try {
      final page = loadMore ? _page + 1 : 1;
      final search = searchQuery.trim().isEmpty ? null : searchQuery.trim();
      final clubs = await _api.fetchClubs(
          search: search, category: null, page: page, limit: _limit);
      if (mounted) {
        setState(() {
          if (loadMore) {
            _clubs.addAll(clubs);
            _page = page;
            _isLoadingMore = false;
          } else {
            _clubs = clubs;
            _page = page;
            _isLoading = false;
          }
          _hasMore = clubs.length >= _limit;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _onClubCardTap(BuildContext context, Club club) async {
    final opener = widget.onClubOpen;
    if (opener != null) {
      await opener(club);
      return;
    }
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => ClubDetails(club: club),
      ),
    );
  }

  List<Club> get filteredClubs {
    return _clubs.where((club) {
      final q = searchQuery.toLowerCase();
      final matchesSearch = club.name.toLowerCase().contains(q) ||
          club.tags.any((tag) => tag.toLowerCase().contains(q));
      return matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final body = ResponsiveContainer(
      backgroundColor: AppColors.backgroundLight,
      padding: widget.embeddedInHub ? EdgeInsets.zero : null,
      child: Column(
        children: [
          if (!widget.embeddedInHub) _buildStandaloneHeader(context),
          Expanded(
            child: widget.embeddedInHub
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildPaneSwitcher(context),
                      Expanded(
                        child: widget.clubsPane == ClubsHomePane.browse
                            ? _buildBrowsePane(context)
                            : MyMemberships(
                                key: ValueKey(
                                  'mc-${widget.myClubsInnerTabIndex}-${widget.applicationsClubNameFilter}',
                                ),
                                embeddedInHub: true,
                                embeddedInClubsTab: true,
                                initialPrimaryTabIndex:
                                    widget.myClubsInnerTabIndex,
                                applicationsClubNameFilter:
                                    widget.applicationsClubNameFilter,
                              ),
                      ),
                    ],
                  )
                : _buildBrowsePane(context),
          ),
        ],
      ),
    );

    if (widget.embeddedInHub) {
      return body;
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(child: body),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateClubForm()),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _buildPaneSwitcher(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 2),
      child: Row(
        children: [
          Expanded(
            child: _paneToggle(
              label: 'Discover',
              icon: Icons.travel_explore_outlined,
              selected: widget.clubsPane == ClubsHomePane.browse,
              onTap: () =>
                  widget.onClubsPaneChanged?.call(ClubsHomePane.browse),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _paneToggle(
              label: 'My clubs',
              icon: Icons.folder_special_outlined,
              selected: widget.clubsPane == ClubsHomePane.myClubs,
              onTap: () =>
                  widget.onClubsPaneChanged?.call(ClubsHomePane.myClubs),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paneToggle({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withOpacity(0.08)
                : AppColors.gray50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected
                  ? AppColors.primary.withOpacity(0.35)
                  : AppColors.gray200,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? AppColors.primary : AppColors.gray600,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected ? AppColors.primary : AppColors.gray600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrowsePane(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildCompactSearchAndCategories(context),
        Expanded(child: _buildClubsList(context)),
      ],
    );
  }

  // ── Header (standalone: full chrome; embedded: subtitle only) ─────
  Widget _buildStandaloneHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      color: AppColors.white,
      child: Row(
        children: [
          AppBackButton(onPressed: () => Navigator.pop(context)),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ADA Clubs',
                  style: AppTextStyles.moduleAppBarTitle,
                ),
                Text(
                  '${filteredClubs.length} clubs',
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.gray500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactSearchAndCategories(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      color: AppColors.backgroundLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 40,
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              onChanged: (value) => setState(() => searchQuery = value),
              style: const TextStyle(fontSize: 14, color: AppColors.gray900),
              decoration: InputDecoration(
                hintText: 'Search by name or tag…',
                hintStyle:
                    const TextStyle(fontSize: 13, color: AppColors.gray400),
                prefixIcon: const Icon(Icons.search,
                    size: 20, color: AppColors.gray400),
                prefixIconConstraints:
                    const BoxConstraints(minWidth: 40, minHeight: 0),
                suffixIcon: searchQuery.trim().isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close,
                            size: 18, color: AppColors.gray400),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => searchQuery = '');
                        },
                      ),
                filled: true,
                fillColor: AppColors.gray50,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.gray200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.gray200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${filteredClubs.length} club${filteredClubs.length == 1 ? '' : 's'}',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClubsList(BuildContext context) {
    if (_deferHubEmbeddedFetch && !_embeddedHubFetchStarted) {
      final c = widget.hubMainTabController;
      if (c != null && c.index == ClubHubTabs.clubs) {
        return const Center(child: CircularProgressIndicator());
      }
      return const SizedBox.shrink();
    }
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 48, color: AppColors.gray300),
              const SizedBox(height: 12),
              Text('Failed to load clubs',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray700)),
              const SizedBox(height: 6),
              Text(_error!,
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.gray500),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadClubs,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
                style:
                    FilledButton.styleFrom(backgroundColor: AppColors.primary),
              ),
            ],
          ),
        ),
      );
    }
    if (filteredClubs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.groups, size: 64, color: AppColors.gray300),
            const SizedBox(height: 16),
            const Text('No clubs found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your search',
              style: TextStyle(fontSize: 14, color: AppColors.gray500),
            ),
          ],
        ),
      );
    }

    final clubs = filteredClubs;
    return RefreshIndicator(
      onRefresh: _loadClubs,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
        itemCount: clubs.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= clubs.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: _isLoadingMore
                    ? const CircularProgressIndicator()
                    : TextButton(
                        onPressed: () => _loadClubs(loadMore: true),
                        child: const Text('Load more'),
                      ),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ClubCard(
              club: clubs[index],
              onTap: () => _onClubCardTap(context, clubs[index]),
            ),
          );
        },
      ),
    );
  }
}
