import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException;

import 'package:http/http.dart' as http;

import '../models/qr_scan_result.dart';
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
  String toString() => 'AttendanceServiceException($statusCode): $message';
}

// ── Service ───────────────────────────────────────────────────────────────────

class AttendanceService {
  /// Attendance service base URL (always via API gateway).
  ///
  /// Every attendance endpoint must be prefixed with `/attendance` as per
  /// `ATTENDANCE_API_DOC.md`.
  static const String _baseUrl = 'http://13.60.31.141:5000/attendance';

  // ── Validation ───────────────────────────────────────────────────────────

  /// QR text is treated as an opaque backend token (no decode/verification).
  static void validateToken(String token) {
    if (token.isEmpty) {
      throw const AttendanceServiceException(message: 'QR token is empty.');
    }
    if (token.length > 4096) {
      throw const AttendanceServiceException(message: 'QR token is too long.');
    }
  }

  // ── HTTP ─────────────────────────────────────────────────────────────────

  /// Submits a QR scan to the backend and returns the parsed response.
  ///
  /// Endpoint: `POST /attendance/api/students/{studentId}/attendance/qr/scan`
  /// All network and HTTP errors are wrapped as [AttendanceServiceException].
  Future<QrScanResult> submitQrScan({
    required String studentId,
    required String token,
  }) async {
    final uri =
        Uri.parse('$_baseUrl/api/students/$studentId/attendance/qr/scan');

    final tokenToSend = '$token|$studentId';
    final body = <String, dynamic>{
      'studentId': studentId,
      'token': tokenToSend,
    };

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
          message: 'No internet connection. Check your network and try again.');
    } on TimeoutException {
      throw const AttendanceServiceException(
          message: 'Request timed out. Please try again.');
    } catch (e) {
      throw AttendanceServiceException(
          message: 'Unexpected error (${e.runtimeType}). Please try again.');
    }
  }

  /// Fetches the signed-in student's enrolled lessons and aggregate
  /// attendance stats.
  ///
  /// Endpoint: `GET /attendance/api/students/{studentId}/enrollments`
  /// Returns the raw JSON object/list as delivered by the gateway.
  Future<Object?> fetchStudentEnrollments({required String studentId}) async {
    final uri = Uri.parse('$_baseUrl/api/students/$studentId/enrollments');
    return _authorizedGetJson(uri);
  }

  /// Fetches per-session attendance for a single lesson.
  ///
  /// Endpoint: `GET /attendance/api/students/{studentId}/lessons/{lessonId}/attendance`
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
      final serverMsg = _extractServerMessage(response.body);
      throw AttendanceServiceException(
        statusCode: response.statusCode,
        message: serverMsg ?? 'Could not load attendance data.',
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
    switch (response.statusCode) {
      case 200:
      case 201:
        try {
          final map = jsonDecode(response.body) as Map<String, dynamic>;
          return QrScanResult.fromJson(map);
        } catch (_) {
          throw const AttendanceServiceException(
              message: 'Server returned an unexpected response format.');
        }

      case 400:
        _throwMappedError(response);

      case 401:
      case 403:
        throw AttendanceServiceException(
            statusCode: response.statusCode,
            message: 'Unauthorized request or wrong student.');

      default:
        _throwMappedError(response);
    }
  }

  Never _throwMappedError(http.Response response) {
    try {
      final map = jsonDecode(response.body) as Map<String, dynamic>;
      final errorCode = map['errorCode']?.toString();
      final message = _mapErrorCodeToMessage(errorCode) ??
          (map['message']?.toString()) ??
          'Something went wrong. Please try again.';
      throw AttendanceServiceException(
        statusCode: response.statusCode,
        errorCode: errorCode,
        message: message,
      );
    } catch (_) {
      throw AttendanceServiceException(
        statusCode: response.statusCode,
        message: _extractServerMessage(response.body) ??
            'Something went wrong. Please try again.',
      );
    }
  }

  String? _mapErrorCodeToMessage(String? code) {
    switch (code) {
      case 'token_expired':
        return 'QR code expired. Ask the instructor to refresh it.';
      case 'activation_inactive':
        return 'Attendance is not active right now.';
      case 'already_scanned_this_round':
        return 'You already scanned for this round.';
      case 'replay_token':
        return 'This QR token was already used. Scan a new one.';
      case 'student_token_mismatch':
        return 'This QR is not for your account.';
      case 'outside_attendance_window':
        return 'You are outside the attendance window.';
      case 'student_not_enrolled':
        return 'You are not enrolled in this lesson.';
      default:
        return null;
    }
  }

  String? _extractServerMessage(String body) {
    try {
      final map = jsonDecode(body) as Map<String, dynamic>;
      final direct = map['message'] ?? map['title'] ?? map['detail'];
      if (direct is String && direct.isNotEmpty) return direct;
      final errors = map['errors'];
      if (errors is Map<String, dynamic>) {
        for (final v in errors.values) {
          if (v is List && v.isNotEmpty) return v.first.toString();
          if (v is String && v.isNotEmpty) return v;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
