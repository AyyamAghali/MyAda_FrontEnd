import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException;

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:http/http.dart' as http;

import '../models/qr_scan_result.dart';
import 'attendance_device_info.dart';
import 'auth_service.dart';

/// Thrown by [AttendanceService] on any failure path.
/// [message] is always safe to display to the user.
class AttendanceServiceException implements Exception {
  final int? statusCode;
  final String? errorCode;
  final String message;

  const AttendanceServiceException({
    this.statusCode,
    this.errorCode,
    required this.message,
  });

  @override
  String toString() =>
      'AttendanceServiceException($statusCode, $errorCode): $message';
}

// ── Service ───────────────────────────────────────────────────────────────────

class AttendanceService {
  /// Set per flavor, e.g. `--dart-define=ATTENDANCE_BASE_URL=https://.../attendance`
  static const String _baseUrl = String.fromEnvironment(
    'ATTENDANCE_BASE_URL',
    defaultValue: 'http://localhost:5009',
  );

  static final _urlPattern = RegExp(r'^https?://', caseSensitive: false);

  // ── Token: raw QR / manual → `rawJwt|currentStudentGuid` (docs / ATTENDANCE_API) ─

  /// Builds the [token] field for `POST .../attendance/scan`.
  ///
  /// QR should contain the JWT only; the client appends `|` + the signed-in
  /// student GUID (same as URL `{studentId}`) so the server can reject
  /// [student_token_mismatch].
  ///
  /// Manual paste may be the JWT only, or a full `jwt|guid` line; the suffix
  /// is always normalized to [studentId] when a `|` is present.
  static String buildScanTokenForRequest({
    required String rawFromReader,
    required String studentId,
  }) {
    final t = rawFromReader.trim();
    if (t.isEmpty) return t;
    if (t.endsWith('|$studentId')) {
      return t;
    }
    final pipe = t.indexOf('|');
    if (pipe == -1) {
      return '$t|$studentId';
    }
    // `jwt|...` from paste: keep JWT part, force current user's GUID
    return '${t.substring(0, pipe)}|$studentId';
  }

  /// Validates the value read from the camera (or pasted JWT segment) before
  /// composing. Treat as opaque; do not decode the JWT.
  static void validateRawQrInput(String raw) {
    if (raw.trim().isEmpty) {
      throw const AttendanceServiceException(message: 'QR token is empty.');
    }
    if (raw.contains('\n') || raw.contains('\r')) {
      throw const AttendanceServiceException(
        message: 'Token contains invalid line breaks.',
      );
    }
    // Whole-line URL is not a JWT
    if (_urlPattern.hasMatch(raw.trim())) {
      throw const AttendanceServiceException(
        message: 'QR code contains a URL, not an attendance token.',
      );
    }
    if (raw.trim().length > 2048) {
      throw const AttendanceServiceException(message: 'Token is too long.');
    }
  }

  /// Validates the composed `token` sent in JSON (after `|guid` is applied).
  static void validateComposedRequestToken(String token) {
    if (token.isEmpty) {
      throw const AttendanceServiceException(message: 'Token is empty.');
    }
    if (token.length > 4096) {
      throw const AttendanceServiceException(message: 'Token is too long.');
    }
    if (token.contains('\n') || token.contains('\r')) {
      throw const AttendanceServiceException(
        message: 'Token contains invalid line breaks.',
      );
    }
  }

  // ── HTTP ─────────────────────────────────────────────────────────────────

  /// `POST /attendance/api/students/{studentId}/attendance/scan`
  ///
  /// Does **not** send `qrContext` (per API).
  /// JSON body: `{ "token", "deviceInfo"? }` — `studentId` omitted when it
  /// matches the route.
  Future<QrScanResult> submitQrScan({
    required String studentId,
    required String token,
  }) async {
    final uri =
        Uri.parse('$_baseUrl/api/students/$studentId/attendance/scan');

    final body = <String, dynamic>{
      'token': token,
      'deviceInfo': await resolveAttendanceDeviceInfo(),
    };

    if (kDebugMode) {
      // Never log the raw token.
      // ignore: avoid_print
      print('[Attendance] POST $uri (token: composed opaque string)');
    }

    try {
      final response = await AuthService.instance
          .sendAuthorized(
            (accessToken) => http
                .post(
                  uri,
                  headers: {
                    'Authorization': 'Bearer $accessToken',
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                  },
                  body: jsonEncode(body),
                )
                .timeout(const Duration(seconds: 30)),
          )
          .timeout(const Duration(seconds: 35));

      return _handleResponse(response);
    } on AttendanceServiceException {
      rethrow;
    } on SocketException {
      throw const AttendanceServiceException(
        message: 'No internet connection. Check your network and try again.',
      );
    } on TimeoutException {
      throw const AttendanceServiceException(
        message: 'Request timed out. Please try again.',
      );
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('not logged in') || msg.contains('not logged in.')) {
        throw const AttendanceServiceException(
          message:
              'You must be signed in to record attendance. Please log in and try again.',
        );
      }
      if (msg.contains('Session expired') || msg.contains('Please login again')) {
        throw const AttendanceServiceException(
          message: 'Session expired. Please sign in again and rescan.',
        );
      }
      throw AttendanceServiceException(
        message: 'Unexpected error (${e.runtimeType}). Please try again.',
      );
    }
  }

  /// Fetches the signed-in student's enrollments.
  Future<Object?> fetchStudentEnrollments({required String studentId}) async {
    final uri = Uri.parse('$_baseUrl/api/students/$studentId/enrollments');
    return _authorizedGetJson(uri);
  }

  /// Fetches per-session attendance for a single lesson.
  Future<Object?> fetchStudentLessonAttendance({
    required String studentId,
    required int lessonId,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/api/students/$studentId/lessons/$lessonId/attendance',
    );
    return _authorizedGetJson(uri);
  }

  Future<Object?> _authorizedGetJson(Uri uri) async {
    try {
      final response = await AuthService.instance
          .sendAuthorized(
            (accessToken) => http
                .get(
                  uri,
                  headers: {
                    'Authorization': 'Bearer $accessToken',
                    'Accept': 'application/json',
                  },
                )
                .timeout(const Duration(seconds: 30)),
          )
          .timeout(const Duration(seconds: 35));

      if (response.statusCode == 200) {
        if (response.body.isEmpty) return null;
        return jsonDecode(response.body);
      }
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw AttendanceServiceException(
          statusCode: response.statusCode,
          message: 'Unauthorized request. Please sign in again.',
        );
      }
      final serverMsg = _parseServerError(response.body);
      throw AttendanceServiceException(
        statusCode: response.statusCode,
        errorCode: serverMsg?.$1,
        message: serverMsg?.$2 ?? 'Could not load attendance data.',
      );
    } on AttendanceServiceException {
      rethrow;
    } on SocketException {
      throw const AttendanceServiceException(
        message: 'No internet connection. Check your network and try again.',
      );
    } on TimeoutException {
      throw const AttendanceServiceException(
        message: 'Request timed out. Please try again.',
      );
    }
  }

  QrScanResult _handleResponse(http.Response response) {
    (String, String?)? errorFromBody() {
      if (response.body.isEmpty) return null;
      try {
        return _parseServerError(response.body);
      } catch (_) {
        return null;
      }
    }

    switch (response.statusCode) {
      case 200:
      case 201:
        try {
          return QrScanResult.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>,
          );
        } catch (_) {
          throw const AttendanceServiceException(
            message: 'Server returned an unexpected response format.',
          );
        }

      case 400:
        final fromBody = errorFromBody();
        throw AttendanceServiceException(
          statusCode: 400,
          errorCode: fromBody?.$1,
          message: fromBody?.$2 ??
              'Request was rejected. Check your code or try again.',
        );

      case 401:
      case 403:
        final fromBody = errorFromBody();
        throw AttendanceServiceException(
          statusCode: response.statusCode,
          errorCode: fromBody?.$1,
          message: fromBody?.$2 ?? 'Unauthorized or wrong account.',
        );

      default:
        final fromBody = errorFromBody();
        throw AttendanceServiceException(
          statusCode: response.statusCode,
          errorCode: fromBody?.$1,
          message: fromBody?.$2 ?? 'Something went wrong. Please try again.',
        );
    }
  }

  /// (errorCode, message) from error JSON, if any.
  (String, String?)? _parseServerError(String body) {
    try {
      final map = jsonDecode(body) as Map<String, dynamic>;
      final String? err = map['errorCode'] as String?;
      final String? message = map['message'] as String?;
      if (err != null || message != null) {
        return (err ?? '', message);
      }
    } catch (_) {}
    return null;
  }
}
