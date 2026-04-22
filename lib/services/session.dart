import 'package:shared_preferences/shared_preferences.dart';

/// Minimal local session holder.
///
/// - Today: only used for local UI decisions and stable userId derivation.
/// - Later: you can extend it to store tokens and integrate auth.
class Session {
  Session._();

  static const _keyUserId = 'session_user_id';
  static const _keyStudentId = 'session_student_id';

  static Future<String> userId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getString(_keyUserId);
      if (existing != null && existing.isNotEmpty) return existing;
      final id = 'usr_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString(_keyUserId, id);
      return id;
    } catch (_) {
      return 'usr_local';
    }
  }

  static Future<String> studentId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getString(_keyStudentId);
      if (existing != null && existing.isNotEmpty) return existing;
      // Local placeholder; set from profile/login later.
      const id = '202012345';
      await prefs.setString(_keyStudentId, id);
      return id;
    } catch (_) {
      return '202012345';
    }
  }

  static Future<void> setStudentId(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyStudentId, id.trim());
    } catch (_) {}
  }
}

