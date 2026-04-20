import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight session singleton.
///
/// The login screen calls [setSession] after a successful auth response.
/// Everything else (services, screens) reads [studentId] and [accessToken].
///
/// Access tokens are stored in SharedPreferences so the session survives
/// app restarts. Clear them on logout with [clearSession].
///
/// Security note: access tokens should ideally be stored in the platform
/// secure storage (e.g. flutter_secure_storage) in a production release.
class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  static const _keyStudentId = 'auth_student_id';
  static const _keyAccessToken = 'auth_access_token';

  String? _studentId;
  String? _accessToken;

  String? get studentId => _studentId;

  /// Returns the raw access token for Authorization headers.
  /// Never surface this value directly in UI strings.
  String? get accessToken => _accessToken;

  bool get hasSession => _studentId != null && _accessToken != null;

  /// Loads a previously persisted session from SharedPreferences.
  /// Safe to call multiple times; skips reload if already loaded.
  Future<void> loadSession() async {
    if (_studentId != null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _studentId = prefs.getString(_keyStudentId);
      _accessToken = prefs.getString(_keyAccessToken);
    } catch (_) {
      // Storage unavailable; session stays null.
    }
  }

  /// Persists a new session. Call this from the login handler.
  Future<void> setSession({
    required String studentId,
    required String accessToken,
  }) async {
    _studentId = studentId;
    _accessToken = accessToken;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyStudentId, studentId);
      await prefs.setString(_keyAccessToken, accessToken);
    } catch (_) {}
  }

  /// Clears all session data. Call on logout.
  Future<void> clearSession() async {
    _studentId = null;
    _accessToken = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyStudentId);
      await prefs.remove(_keyAccessToken);
    } catch (_) {}
  }
}
