import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'browser_storage_stub.dart'
    if (dart.library.html) 'browser_storage_web.dart';

class AuthRoleUser {
  final String id;
  final String userName;
  final String? firstName;
  final String? lastName;
  final String? email;

  const AuthRoleUser({
    required this.id,
    required this.userName,
    this.firstName,
    this.lastName,
    this.email,
  });

  String get displayName {
    final full = '${firstName ?? ''} ${lastName ?? ''}'.trim();
    if (full.isNotEmpty) return full;
    if (userName.isNotEmpty) return userName;
    if (email != null && email!.isNotEmpty) return email!;
    return id;
  }

  factory AuthRoleUser.fromJson(Map<String, dynamic> json) {
    return AuthRoleUser(
      id: (json['id'] ?? '').toString(),
      userName: (json['userName'] ?? '').toString(),
      firstName: json['firstName']?.toString(),
      lastName: json['lastName']?.toString(),
      email: json['email']?.toString(),
    );
  }
}

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

  static const String _authBaseUrl = 'http://13.60.31.141:5000/api/auth';
  static const String _keyStudentId = 'auth_student_id';
  static const String _keyAccessToken = 'auth_access_token';
  static const String _refreshTokenCookie = 'myada_refresh_token';
  static const String _refreshTokenPrefs = 'auth_refresh_token';

  String? _studentId;
  String? _accessToken;

  String? get studentId => _studentId;

  /// Returns the raw access token for Authorization headers.
  /// Never surface this value directly in UI strings.
  String? get accessToken => _accessToken;

  bool get hasSession => _accessToken != null;

  /// Loads a previously persisted session from SharedPreferences.
  /// Safe to call multiple times; skips reload if already loaded.
  Future<void> loadSession() async {
    if (_accessToken != null) return;

    if (kIsWeb) {
      _studentId = BrowserStorage.getSessionValue(_keyStudentId);
      _accessToken = BrowserStorage.getSessionValue(_keyAccessToken);
      return;
    }

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
    String? studentId,
    required String accessToken,
    required String refreshToken,
  }) async {
    _studentId = studentId;
    _accessToken = accessToken;

    if (kIsWeb) {
      if (studentId != null && studentId.isNotEmpty) {
        BrowserStorage.setSessionValue(_keyStudentId, studentId);
      } else {
        BrowserStorage.removeSessionValue(_keyStudentId);
      }
      BrowserStorage.setSessionValue(_keyAccessToken, accessToken);
      BrowserStorage.setCookie(
        _refreshTokenCookie,
        refreshToken,
        maxAgeSeconds: 30 * 24 * 60 * 60,
        secure: true,
        sameSite: 'Lax',
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      if (studentId != null && studentId.isNotEmpty) {
        await prefs.setString(_keyStudentId, studentId);
      } else {
        await prefs.remove(_keyStudentId);
      }
      await prefs.setString(_keyAccessToken, accessToken);
      await prefs.setString(_refreshTokenPrefs, refreshToken);
    } catch (_) {}
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    final uri = Uri.parse('$_authBaseUrl/login');
    final response = await http.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode != 200) {
      throw Exception('Login failed (${response.statusCode}).');
    }

    final body = _decodeJsonMap(response.body);
    final accessToken = body['accessToken'] as String?;
    final refreshToken = body['refreshToken'] as String?;

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Login response did not include accessToken.');
    }
    if (refreshToken == null || refreshToken.isEmpty) {
      throw Exception('Login response did not include refreshToken.');
    }

    final studentId = _extractSubjectFromJwt(accessToken);
    await setSession(
      studentId: studentId,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  /// Fetches users assigned to [role] using:
  /// `GET /api/auth/users-by-role/{role}`
  ///
  /// Note: backend may require admin role for this endpoint.
  Future<List<AuthRoleUser>> fetchUsersByRole(String role) async {
    final normalized = role.trim();
    if (normalized.isEmpty) return const [];
    final uri = Uri.parse(
      '$_authBaseUrl/users-by-role/${Uri.encodeComponent(normalized)}',
    );
    final response = await sendAuthorized(
      (token) => http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load $normalized users (${response.statusCode}).');
    }
    final body = _decodeJsonMap(response.body);
    final rawUsers = body['users'];
    if (rawUsers is! List) return const [];
    return rawUsers
        .whereType<Map<String, dynamic>>()
        .map(AuthRoleUser.fromJson)
        .where((u) => u.id.isNotEmpty)
        .toList(growable: false);
  }

  Future<String> refreshAccessToken() async {
    final refreshToken = await _readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      throw Exception('Refresh token is missing. Please login again.');
    }

    final uri = Uri.parse('$_authBaseUrl/refresh');
    final response = await http.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    if (response.statusCode != 200) {
      await clearSession();
      throw Exception('Session expired. Please login again.');
    }

    final body = _decodeJsonMap(response.body);
    final newAccessToken = body['accessToken'] as String?;
    final newRefreshToken = body['refreshToken'] as String?;
    if (newAccessToken == null || newAccessToken.isEmpty) {
      await clearSession();
      throw Exception('Refresh response did not include accessToken.');
    }
    if (newRefreshToken == null || newRefreshToken.isEmpty) {
      await clearSession();
      throw Exception('Refresh response did not include refreshToken.');
    }

    final studentId = _extractSubjectFromJwt(newAccessToken) ?? _studentId;
    await setSession(
      studentId: studentId,
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
    );
    return newAccessToken;
  }

  Future<http.Response> sendAuthorized(
    Future<http.Response> Function(String accessToken) sendRequest,
  ) async {
    await loadSession();
    var token = _accessToken;
    if (token == null || token.isEmpty) {
      throw Exception('You are not logged in. Please login first.');
    }

    var response = await sendRequest(token);
    if (response.statusCode == 400) {
      token = await refreshAccessToken();
      response = await sendRequest(token);
    }

    if (response.statusCode == 401) {
      await clearSession();
    }

    return response;
  }

  /// Clears all session data. Call on logout.
  /// Sends a password-reset email for [email].
  ///
  /// The API always returns the same success message to prevent user
  /// enumeration, so we surface it as-is to the caller.
  Future<String> forgotPassword({required String email}) async {
    final uri = Uri.parse('$_authBaseUrl/forgot-password');
    final response = await http.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Request failed (${response.statusCode}). Please try again.');
    }

    try {
      final body = _decodeJsonMap(response.body);
      return body['message'] as String? ??
          'If this email exists, password reset link sent.';
    } catch (_) {
      return 'If this email exists, password reset link sent.';
    }
  }

  /// Resets the password using the token received via email.
  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    final uri = Uri.parse('$_authBaseUrl/reset-password');
    final response = await http.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'token': token,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode == 404) {
      throw Exception('No account found for that email address.');
    }

    if (response.statusCode != 200) {
      String detail = '';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is List && decoded.isNotEmpty) {
          detail = (decoded.first as Map<String, dynamic>)['description']
                  ?.toString() ??
              '';
        } else if (decoded is String) {
          detail = decoded;
        }
      } catch (_) {}
      throw Exception(detail.isNotEmpty
          ? detail
          : 'Password reset failed (${response.statusCode}).');
    }
  }

  Future<void> clearSession() async {
    _studentId = null;
    _accessToken = null;

    if (kIsWeb) {
      BrowserStorage.removeSessionValue(_keyStudentId);
      BrowserStorage.removeSessionValue(_keyAccessToken);
      BrowserStorage.removeCookie(_refreshTokenCookie);
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyStudentId);
      await prefs.remove(_keyAccessToken);
      await prefs.remove(_refreshTokenPrefs);
    } catch (_) {}
  }

  Future<String?> _readRefreshToken() async {
    if (kIsWeb) {
      return BrowserStorage.getCookie(_refreshTokenCookie);
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_refreshTokenPrefs);
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic> _decodeJsonMap(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw Exception('Unexpected API response format.');
  }

  static String? _extractSubjectFromJwt(String jwt) {
    final parts = jwt.split('.');
    if (parts.length < 2) return null;
    try {
      final payload = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(payload));
      final map = jsonDecode(decoded);
      if (map is Map<String, dynamic>) {
        final sub = map['sub']?.toString();
        return (sub == null || sub.isEmpty) ? null : sub;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
