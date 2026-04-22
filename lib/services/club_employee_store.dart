import 'package:shared_preferences/shared_preferences.dart';

/// Local source of "club employee assignments" used for showing Scan button.
///
/// For now we store clubIds where the user is an Event Manager.
/// Later, swap this for a backend-driven source.
class ClubEmployeeStore {
  ClubEmployeeStore._();

  static const _keyEventManagerClubIds = 'club_event_manager_ids_v1';

  static Future<Set<int>> eventManagerClubIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_keyEventManagerClubIds) ?? const [];
      return raw
          .map((e) => int.tryParse(e) ?? -1)
          .where((e) => e > 0)
          .toSet();
    } catch (_) {
      return <int>{};
    }
  }

  static Future<void> setEventManagerClubIds(Set<int> ids) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _keyEventManagerClubIds,
        ids.map((e) => e.toString()).toList(),
      );
    } catch (_) {}
  }
}

