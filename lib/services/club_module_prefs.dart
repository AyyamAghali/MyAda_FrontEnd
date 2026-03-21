import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists saved vacancy IDs and registered event IDs (web cookies / React context).
/// Falls back to in-memory storage if `shared_preferences` is not linked (hot reload / some runners).
class ClubModulePrefs {
  ClubModulePrefs._();

  static const _kSavedVacancies = 'club_saved_vacancy_ids';
  static const _kRegisteredEvents = 'club_registered_event_ids';

  static final Set<int> _memorySavedVacancies = {};
  static final Set<int> _memoryRegisteredEvents = {};
  static bool _useMemory = false;

  static void _notePrefsFailure(Object e, StackTrace st) {
    _useMemory = true;
    if (kDebugMode) {
      debugPrint(
        'ClubModulePrefs: SharedPreferences unavailable ($e). Using memory. '
        'Stop the app and run again (full restart) after `flutter pub get`. $st',
      );
    }
  }

  static Future<SharedPreferences?> _prefs() async {
    if (_useMemory) return null;
    try {
      return await SharedPreferences.getInstance();
    } catch (e, st) {
      _notePrefsFailure(e, st);
      return null;
    }
  }

  static Future<Set<int>> savedVacancyIds() async {
    if (_useMemory) return Set<int>.from(_memorySavedVacancies);
    try {
      final p = await _prefs();
      if (p == null) return Set<int>.from(_memorySavedVacancies);
      final raw = p.getStringList(_kSavedVacancies) ?? [];
      return raw.map(int.parse).toSet();
    } catch (e, st) {
      _notePrefsFailure(e, st);
      return Set<int>.from(_memorySavedVacancies);
    }
  }

  static Future<void> setSavedVacancyIds(Set<int> ids) async {
    if (_useMemory) {
      _memorySavedVacancies
        ..clear()
        ..addAll(ids);
      return;
    }
    try {
      final p = await _prefs();
      if (p == null) {
        _memorySavedVacancies
          ..clear()
          ..addAll(ids);
        return;
      }
      await p.setStringList(_kSavedVacancies, ids.map((e) => e.toString()).toList());
    } catch (e, st) {
      _notePrefsFailure(e, st);
      _memorySavedVacancies
        ..clear()
        ..addAll(ids);
    }
  }

  static Future<void> toggleSavedVacancy(int id) async {
    final cur = await savedVacancyIds();
    if (cur.contains(id)) {
      cur.remove(id);
    } else {
      cur.add(id);
    }
    await setSavedVacancyIds(cur);
  }

  static Future<Set<int>> registeredEventIds() async {
    if (_useMemory) return Set<int>.from(_memoryRegisteredEvents);
    try {
      final p = await _prefs();
      if (p == null) return Set<int>.from(_memoryRegisteredEvents);
      final raw = p.getStringList(_kRegisteredEvents) ?? [];
      return raw.map(int.parse).toSet();
    } catch (e, st) {
      _notePrefsFailure(e, st);
      return Set<int>.from(_memoryRegisteredEvents);
    }
  }

  static Future<void> registerForEvent(int eventId) async {
    final cur = await registeredEventIds();
    cur.add(eventId);
    if (_useMemory) {
      _memoryRegisteredEvents
        ..clear()
        ..addAll(cur);
      return;
    }
    try {
      final p = await _prefs();
      if (p == null) {
        _memoryRegisteredEvents
          ..clear()
          ..addAll(cur);
        return;
      }
      await p.setStringList(_kRegisteredEvents, cur.map((e) => e.toString()).toList());
    } catch (e, st) {
      _notePrefsFailure(e, st);
      _memoryRegisteredEvents
        ..clear()
        ..addAll(cur);
    }
  }

  static Future<bool> isRegisteredForEvent(int eventId) async {
    final cur = await registeredEventIds();
    return cur.contains(eventId);
  }
}
