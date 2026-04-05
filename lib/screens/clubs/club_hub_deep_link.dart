/// Main tabs on [ClubManagementHub].
abstract class ClubHubTabs {
  static const int clubs = 0;
  static const int openings = 1;
  static const int events = 2;
}

/// Browse all clubs vs your memberships (both live under the Clubs hub tab).
enum ClubsHomePane {
  browse,
  myClubs,
}

/// Returned from [ClubDetails] quick actions to refocus the hub, or used as cold-start args.
class ClubHubDeepLink {
  final int tabIndex;
  final int? clubId;
  final String? clubName;

  /// When [tabIndex] is [ClubHubTabs.clubs], which pane to show.
  final ClubsHomePane? clubsPane;

  /// Sub-tab inside My clubs: 0 Active, 1 Pending, 2 Declined, 3 Applications.
  final int? myClubsPrimaryTabIndex;

  const ClubHubDeepLink({
    required this.tabIndex,
    this.clubId,
    this.clubName,
    this.clubsPane,
    this.myClubsPrimaryTabIndex,
  });
}
