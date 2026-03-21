import 'package:flutter/material.dart';
import 'club_vacancies_screen.dart';
import 'club_events_screen.dart';
import 'my_vacancy_applications_screen.dart';
import 'my_registered_events_screen.dart';
import 'club_notifications_screen.dart';
import 'create_club_form.dart';

/// Cross-links between club module screens (avoids cycles with [ClubsHome] / [MyMemberships]).
class ClubModuleNav {
  ClubModuleNav._();

  static void toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  static void openVacancies(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const ClubVacanciesScreen()),
    );
  }

  static void openMyVacancyApplications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const MyVacancyApplicationsScreen()),
    );
  }

  static void openEvents(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const ClubEventsScreen()),
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
