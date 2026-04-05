import 'package:flutter/material.dart';
import 'club_hub_deep_link.dart';
import 'club_management_hub.dart';
import 'club_notifications_screen.dart';
import 'create_club_form.dart';
import 'my_registered_events_screen.dart';
/// Cross-links between club module screens. Standalone destinations open [ClubManagementHub] when needed.
class ClubModuleNav {
  ClubModuleNav._();

  static void toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  static ClubManagementHubState? _maybeHub(BuildContext context) {
    return context.findAncestorStateOfType<ClubManagementHubState>();
  }

  static void _focusHub(BuildContext context, ClubHubDeepLink link) {
    final hub = _maybeHub(context);
    if (hub != null) {
      hub.applyDeepLink(link);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ClubManagementHub(initialDeepLink: link),
      ),
    );
  }

  static void openVacancies(
    BuildContext context, {
    int? clubId,
    String? clubName,
  }) {
    _focusHub(
      context,
      ClubHubDeepLink(
        tabIndex: ClubHubTabs.openings,
        clubId: clubId,
        clubName: clubName,
      ),
    );
  }

  static void openMyVacancyApplications(
    BuildContext context, {
    String? clubName,
  }) {
    _focusHub(
      context,
      ClubHubDeepLink(
        tabIndex: ClubHubTabs.clubs,
        clubsPane: ClubsHomePane.myClubs,
        clubName: clubName,
        myClubsPrimaryTabIndex: 3,
      ),
    );
  }

  /// Opens the Clubs tab on the **My clubs** pane (memberships first).
  static void openMyClubsPane(BuildContext context) {
    _focusHub(
      context,
      const ClubHubDeepLink(
        tabIndex: ClubHubTabs.clubs,
        clubsPane: ClubsHomePane.myClubs,
      ),
    );
  }

  static void openEvents(BuildContext context, {int? clubId}) {
    _focusHub(
      context,
      ClubHubDeepLink(
        tabIndex: ClubHubTabs.events,
        clubId: clubId,
      ),
    );
  }

  static void openProposeClub(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const CreateClubForm()),
    );
  }

  static void openNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const ClubNotificationsScreen()),
    );
  }

  static void openMyRegisteredEvents(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const MyRegisteredEventsScreen()),
    );
  }
}
