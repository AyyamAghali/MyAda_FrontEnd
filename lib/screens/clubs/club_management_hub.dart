import 'package:flutter/material.dart';
import '../../models/club.dart';
import '../../utils/constants.dart';
import '../../widgets/app_back_button.dart';
import 'club_details.dart';
import 'club_events_screen.dart';
import 'club_hub_deep_link.dart';
import 'club_hub_scope.dart';
import 'club_vacancies_screen.dart';
import 'clubs_home.dart';

/// Three-tab shell: Clubs (Discover + My clubs) · Openings · Events.
class ClubManagementHub extends StatefulWidget {
  final int initialTab;
  final ClubHubDeepLink? initialDeepLink;

  const ClubManagementHub({
    super.key,
    this.initialTab = ClubHubTabs.clubs,
    this.initialDeepLink,
  });

  @override
  State<ClubManagementHub> createState() => ClubManagementHubState();
}

class ClubManagementHubState extends State<ClubManagementHub>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  int? _openingsClubId;
  String? _openingsClubName;
  int? _eventsClubId;
  ClubsHomePane _clubsPane = ClubsHomePane.browse;
  int _myClubsInnerTab = 0;
  String? _myClubsApplicationsClubName;

  @override
  void initState() {
    super.initState();
    final link = widget.initialDeepLink;
    final start = link?.tabIndex ?? widget.initialTab;
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: start.clamp(0, 2),
    );
    if (link != null) {
      _applyLinkToFilters(link);
    }
    _tabController.addListener(_onMainTabChanged);
  }

  void _applyLinkToFilters(ClubHubDeepLink link) {
    _openingsClubId = null;
    _openingsClubName = null;
    _eventsClubId = null;
    _clubsPane = ClubsHomePane.browse;
    _myClubsInnerTab = 0;
    _myClubsApplicationsClubName = null;
    switch (link.tabIndex) {
      case ClubHubTabs.openings:
        _openingsClubId = link.clubId;
        _openingsClubName = link.clubName;
        break;
      case ClubHubTabs.events:
        _eventsClubId = link.clubId;
        break;
      case ClubHubTabs.clubs:
        _clubsPane = link.clubsPane ?? ClubsHomePane.browse;
        if (_clubsPane == ClubsHomePane.myClubs) {
          _myClubsInnerTab = (link.myClubsPrimaryTabIndex ?? 0).clamp(0, 2);
          _myClubsApplicationsClubName = link.clubName;
        }
        break;
    }
  }

  void _onMainTabChanged() {
    if (_tabController.indexIsChanging) return;
    setState(() {
      final i = _tabController.index;
      if (i != ClubHubTabs.openings) {
        _openingsClubId = null;
        _openingsClubName = null;
      }
      if (i != ClubHubTabs.events) {
        _eventsClubId = null;
      }
      if (i != ClubHubTabs.clubs) {
        _clubsPane = ClubsHomePane.browse;
        _myClubsInnerTab = 0;
        _myClubsApplicationsClubName = null;
      }
    });
  }

  void applyDeepLink(ClubHubDeepLink link) {
    setState(() {
      _applyLinkToFilters(link);
    });
    _tabController.animateTo(link.tabIndex.clamp(0, 2));
  }

  void _setClubsPane(ClubsHomePane pane) {
    setState(() {
      _clubsPane = pane;
      if (pane == ClubsHomePane.browse) {
        _myClubsInnerTab = 0;
        _myClubsApplicationsClubName = null;
      }
    });
  }

  Future<void> _openClub(Club club) async {
    final link = await Navigator.push<ClubHubDeepLink?>(
      context,
      MaterialPageRoute<ClubHubDeepLink?>(
        builder: (_) => ClubDetails(club: club),
      ),
    );
    if (!mounted || link == null) return;
    applyDeepLink(link);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onMainTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.gray900,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Center(
            child: AppBackButton(onPressed: () => Navigator.pop(context)),
          ),
        ),
        title: const Text('ADA Clubs'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(46),
          child: TabBar(
            controller: _tabController,
            isScrollable: false,
            tabAlignment: TabAlignment.fill,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.gray500,
            indicatorColor: AppColors.primary,
            indicatorWeight: 2.5,
            labelStyle:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            unselectedLabelStyle:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
            tabs: const [
              Tab(text: 'Clubs'),
              Tab(text: 'Vacancies'),
              Tab(text: 'Events'),
            ],
          ),
        ),
      ),
      body: ClubHubScope(
        applyDeepLink: applyDeepLink,
        child: TabBarView(
          controller: _tabController,
          children: [
            ColoredBox(
              color: AppColors.backgroundLight,
              child: ClubsHome(
                embeddedInHub: true,
                clubsPane: _clubsPane,
                onClubsPaneChanged: _setClubsPane,
                myClubsInnerTabIndex: _myClubsInnerTab,
                applicationsClubNameFilter: _myClubsApplicationsClubName,
                onClubOpen: _openClub,
                hubMainTabController: _tabController,
              ),
            ),
            ColoredBox(
              color: AppColors.backgroundLight,
              child: ClubVacanciesScreen(
                key: ValueKey('openings-$_openingsClubId-$_openingsClubName'),
                embedInHub: true,
                filterClubId: _openingsClubId,
                filterClubName: _openingsClubName,
                hubMainTabController: _tabController,
              ),
            ),
            ColoredBox(
              color: AppColors.backgroundLight,
              child: ClubEventsScreen(
                key: ValueKey('events-$_eventsClubId'),
                embedInHub: true,
                filterClubId: _eventsClubId,
                hubMainTabController: _tabController,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
