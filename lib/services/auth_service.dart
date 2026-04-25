import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_role.dart';
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

class AuthUserProfile {
  final String id;
  final String userName;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneNumber;
  final String? profileImage;
  final String? userType;
  final String? status;
  final String? organizationalId;
  final Set<UserRole> roles;

  const AuthUserProfile({
    required this.id,
    required this.userName,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.profileImage,
    this.userType,
    this.status,
    this.organizationalId,
    this.roles = const {},
  });

  String get displayFirstName {
    final value = firstName?.trim();
    if (value != null && value.isNotEmpty) return value;
    final nameParts = userName.trim().split(RegExp(r'\s+'));
    if (nameParts.isNotEmpty && nameParts.first.isNotEmpty) {
      return nameParts.first;
    }
    final emailPrefix = email?.split('@').first.trim();
    if (emailPrefix != null && emailPrefix.isNotEmpty) return emailPrefix;
    return 'ADA';
  }

  String get displayLastName {
    final value = lastName?.trim();
    if (value != null && value.isNotEmpty) return value;
    final nameParts = userName.trim().split(RegExp(r'\s+'));
    if (nameParts.length > 1) return nameParts.skip(1).join(' ');
    return 'User';
  }

  String get displayRoleLabel {
    if (roles.isNotEmpty) return roles.displayLabel;
    final type = userType?.trim();
    if (type != null && type.isNotEmpty) return type;
    return UserRole.student.label;
  }

  factory AuthUserProfile.fromJson(Map<String, dynamic> json) {
    final roles = <UserRole>{};

    void collectRole(Object? value) {
      if (value == null) return;
      if (value is Iterable) {
        for (final item in value) {
          collectRole(item);
        }
        return;
      }
      if (value is Map<String, dynamic>) {
        collectRole(value['name']);
        collectRole(value['normalizedName']);
        collectRole(value['role']);
        collectRole(value['roleName']);
        return;
      }
      final role = UserRole.fromApiName(value);
      if (role != null) roles.add(role);
    }

    collectRole(json['role']);
    collectRole(json['roles']);
    collectRole(json['normalizedRole']);
    collectRole(json['normalizedRoles']);

    return AuthUserProfile(
      id: (json['id'] ?? '').toString(),
      userName: (json['userName'] ?? '').toString(),
      firstName: json['firstName']?.toString(),
      lastName: json['lastName']?.toString(),
      email: json['email']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      profileImage: json['profileImage']?.toString(),
      userType: json['userType']?.toString(),
      status: json['status']?.toString(),
      organizationalId: (json['organizationalId'] ??
              json['organizationId'] ??
              json['orgId'] ??
              json['studentNumber'] ??
              json['employeeNumber'])
          ?.toString(),
      roles: roles,
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
  static const String _keyRoles = 'auth_roles';
  static const String _keyUsername = 'auth_username';
  static const String _refreshTokenCookie = 'myada_refresh_token';
  static const String _refreshTokenPrefs = 'auth_refresh_token';

  String? _studentId;
  String? _accessToken;
  String? _username;
  Set<UserRole> _roles = {UserRole.student};

  String? get studentId => _studentId;

  /// Returns the raw access token for Authorization headers.
  /// Never surface this value directly in UI strings.
  String? get accessToken => _accessToken;

  String? get username => _username;

  Set<UserRole> get roles => Set.unmodifiable(_roles);

  String get roleLabel => _roles.displayLabel;

  bool get hasSession => _accessToken != null;

  /// Loads a previously persisted session from SharedPreferences.
  /// Safe to call multiple times; skips reload if already loaded.
  Future<void> loadSession() async {
    if (_accessToken != null) return;

    if (kIsWeb) {
      _studentId = BrowserStorage.getSessionValue(_keyStudentId);
      _accessToken = BrowserStorage.getSessionValue(_keyAccessToken);
      _username = BrowserStorage.getSessionValue(_keyUsername);
      _roles = _deserializeRoles(BrowserStorage.getSessionValue(_keyRoles));
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      _studentId = prefs.getString(_keyStudentId);
      _accessToken = prefs.getString(_keyAccessToken);
      _username = prefs.getString(_keyUsername);
      _roles = _deserializeRoles(prefs.getString(_keyRoles));
    } catch (_) {
      // Storage unavailable; session stays null.
    }
  }

  /// Persists a new session. Call this from the login handler.
  Future<void> setSession({
    String? studentId,
    required String accessToken,
    required String refreshToken,
    Iterable<UserRole>? roles,
    String? username,
  }) async {
    _studentId = studentId;
    _accessToken = accessToken;
    _username = username;
    _roles = _normalizeRoles(roles);

    if (kIsWeb) {
      if (studentId != null && studentId.isNotEmpty) {
        BrowserStorage.setSessionValue(_keyStudentId, studentId);
      } else {
        BrowserStorage.removeSessionValue(_keyStudentId);
      }
      BrowserStorage.setSessionValue(_keyAccessToken, accessToken);
      if (_username != null && _username!.isNotEmpty) {
        BrowserStorage.setSessionValue(_keyUsername, _username!);
      } else {
        BrowserStorage.removeSessionValue(_keyUsername);
      }
      BrowserStorage.setSessionValue(_keyRoles, _serializeRoles(_roles));
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
      if (_username != null && _username!.isNotEmpty) {
        await prefs.setString(_keyUsername, _username!);
      } else {
        await prefs.remove(_keyUsername);
      }
      await prefs.setString(_keyRoles, _serializeRoles(_roles));
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

    final jwtClaims = _extractJwtClaims(accessToken);
    final studentId = _extractSubjectFromClaims(jwtClaims);
    final roles = {
      ..._extractRolesFromClaims(jwtClaims),
      ..._extractRolesFromLoginBody(body),
    };
    final signedInUsername = _extractUsername(jwtClaims, body);
    await setSession(
      studentId: studentId,
      accessToken: accessToken,
      refreshToken: refreshToken,
      roles: roles,
      username: signedInUsername,
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
      throw Exception(
          'Failed to load $normalized users (${response.statusCode}).');
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

  /// Fetches user details using:
  /// `GET /api/auth/users/{id}`
  Future<AuthUserProfile> fetchUserById(String id) async {
    final normalized = id.trim();
    if (normalized.isEmpty) {
      throw Exception('User id is required.');
    }

    final uri = Uri.parse(
      '$_authBaseUrl/users/${Uri.encodeComponent(normalized)}',
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
      throw Exception(
          'Failed to load user ($normalized) (${response.statusCode}).');
    }

    final body = _decodeJsonMap(response.body);
    final source = body['result'] is Map<String, dynamic>
        ? body['result'] as Map<String, dynamic>
        : body['data'] is Map<String, dynamic>
            ? body['data'] as Map<String, dynamic>
            : body;
    final profile = AuthUserProfile.fromJson(source);
    if (profile.id.isEmpty) {
      throw Exception('User profile response is invalid.');
    }
    return profile;
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

    final jwtClaims = _extractJwtClaims(newAccessToken);
    final studentId = _extractSubjectFromClaims(jwtClaims) ?? _studentId;
    final roles = _extractRolesFromClaims(jwtClaims);
    await setSession(
      studentId: studentId,
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
      roles: roles.isEmpty ? _roles : roles,
      username: _extractUsername(jwtClaims, body) ?? _username,
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
    _username = null;
    _roles = {UserRole.student};

    if (kIsWeb) {
      BrowserStorage.removeSessionValue(_keyStudentId);
      BrowserStorage.removeSessionValue(_keyAccessToken);
      BrowserStorage.removeSessionValue(_keyRoles);
      BrowserStorage.removeSessionValue(_keyUsername);
      BrowserStorage.removeCookie(_refreshTokenCookie);
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyStudentId);
      await prefs.remove(_keyAccessToken);
      await prefs.remove(_keyRoles);
      await prefs.remove(_keyUsername);
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

  static Map<String, dynamic> _extractJwtClaims(String jwt) {
    final parts = jwt.split('.');
    if (parts.length < 2) return const {};
    try {
      final payload = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(payload));
      final map = jsonDecode(decoded);
      if (map is Map<String, dynamic>) {
        return map;
      }
      return const {};
    } catch (_) {
      return const {};
    }
  }

  static String? _extractSubjectFromClaims(Map<String, dynamic> claims) {
    final sub = claims['sub']?.toString();
    return (sub == null || sub.isEmpty) ? null : sub;
  }

  static String? _extractUsername(
    Map<String, dynamic> claims,
    Map<String, dynamic> loginBody,
  ) {
    final candidates = [
      claims['unique_name'],
      claims['name'],
      claims['preferred_username'],
      claims['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'],
      loginBody['userName'],
      loginBody['username'],
      loginBody['email'],
    ];

    final user = loginBody['user'];
    if (user is Map<String, dynamic>) {
      candidates.addAll([user['userName'], user['username'], user['email']]);
    }

    for (final candidate in candidates) {
      final value = candidate?.toString().trim() ?? '';
      if (value.isNotEmpty) return value;
    }
    return null;
  }

  static Set<UserRole> _extractRolesFromClaims(Map<String, dynamic> claims) {
    const roleClaim =
        'http://schemas.microsoft.com/ws/2008/06/identity/claims/role';
    return _rolesFromValues([
      claims['role'],
      claims['roles'],
      claims['Role'],
      claims['Roles'],
      claims[roleClaim],
    ]);
  }

  static Set<UserRole> _extractRolesFromLoginBody(Map<String, dynamic> body) {
    final values = <Object?>[
      body['role'],
      body['roles'],
      body['normalizedRole'],
      body['normalizedRoles'],
    ];
    final user = body['user'];
    if (user is Map<String, dynamic>) {
      values.addAll([
        user['role'],
        user['roles'],
        user['normalizedRole'],
        user['normalizedRoles'],
      ]);
    }
    return _rolesFromValues(values);
  }

  static Set<UserRole> _rolesFromValues(Iterable<Object?> values) {
    final roles = <UserRole>{};

    void collect(Object? value) {
      if (value == null) return;
      if (value is Iterable) {
        for (final item in value) {
          collect(item);
        }
        return;
      }
      if (value is Map<String, dynamic>) {
        collect(value['name']);
        collect(value['normalizedName']);
        collect(value['role']);
        collect(value['roleName']);
        return;
      }

      final role = UserRole.fromApiName(value);
      if (role != null) roles.add(role);
    }

    for (final value in values) {
      collect(value);
    }
    return roles;
  }

  static Set<UserRole> _normalizeRoles(Iterable<UserRole>? roles) {
    final normalized = roles?.toSet() ?? <UserRole>{};
    return normalized.isEmpty ? {UserRole.student} : normalized;
  }

  static String _serializeRoles(Iterable<UserRole> roles) {
    return jsonEncode(roles.map((role) => role.apiName).toList());
  }

  static Set<UserRole> _deserializeRoles(String? value) {
    if (value == null || value.trim().isEmpty) return {UserRole.student};
    try {
      final decoded = jsonDecode(value);
      if (decoded is Iterable) {
        return _normalizeRoles(decoded.map(UserRole.fromApiName).nonNulls);
      }
    } catch (_) {
      final role = UserRole.fromApiName(value);
      if (role != null) return {role};
    }
    return {UserRole.student};
  }
}
