import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform, SocketException;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

import '../models/qr_scan_result.dart';

// ── DTOs ─────────────────────────────────────────────────────────────────────

/// Optional consistency context attached to a QR scan request.
///
/// The API uses these fields to cross-check the signed token.
/// [sessionId] maps to the `sessionId` JSON key in the QR payload.
/// [roundCount] maps to `roundCount` in the QR payload.
///
/// Note: `qrContext.instructorJwt` (API field) is intentionally NOT populated
/// from the QR payload's plain `instructorId` — the API expects a signed JWT
/// there, not a bare ID. If an instructor JWT is available separately, add it.
class QrContext {
  final int? sessionId;
  final int? roundCount;

  const QrContext({this.sessionId, this.roundCount});

  bool get isEmpty => sessionId == null && roundCount == null;

  Map<String, dynamic> toJson() => {
        if (sessionId != null) 'sessionId': sessionId,
        if (roundCount != null) 'roundCount': roundCount,
      };
}

/// Result of parsing raw QR text.
class ParsedQrPayload {
  final String token;
  final QrContext? qrContext;

  const ParsedQrPayload({required this.token, this.qrContext});
}

/// Thrown by [AttendanceService] on any failure path.
/// [message] is always safe to display to the user.
class AttendanceServiceException implements Exception {
  final int? statusCode;
  final String message;

  const AttendanceServiceException({this.statusCode, required this.message});

  @override
  String toString() => 'AttendanceServiceException($statusCode): $message';
}

// ── Service ───────────────────────────────────────────────────────────────────

class AttendanceService {
  /// TODO: Replace with the real base URL from your environment config.
  static const String _baseUrl = 'https://myada-api.example.com';

  static final _tokenPattern = RegExp(r'^[A-Za-z0-9._~\-]{6,512}$');
  static final _urlPattern =
      RegExp(r'^https?://', caseSensitive: false);

  // ── Parsing ──────────────────────────────────────────────────────────────

  /// Parses raw QR text → [ParsedQrPayload].
  ///
  /// If [raw] starts with `{`, tries JSON decode:
  ///   - reads `token` (falls back to `payload`)
  ///   - extracts `sessionId` and `roundCount` into [QrContext]
  ///   - silently ignores `instructorId` (not mapped to instructorJwt)
  /// On any JSON failure, falls back to treating the whole string as the token.
  static ParsedQrPayload parseQrPayload(String raw) {
    final text = raw.trim();

    if (text.startsWith('{')) {
      try {
        final json = jsonDecode(text) as Map<String, dynamic>;

        final token =
            ((json['token'] ?? json['payload'] ?? '') as Object).toString();

        // Safely coerce int-or-string fields to int.
        int? asInt(Object? v) {
          if (v == null) return null;
          if (v is int) return v;
          return int.tryParse(v.toString());
        }

        final sessionId = asInt(json['sessionId']);
        final roundCount = asInt(json['roundCount']);

        final ctx = (sessionId != null || roundCount != null)
            ? QrContext(sessionId: sessionId, roundCount: roundCount)
            : null;

        return ParsedQrPayload(token: token, qrContext: ctx);
      } catch (_) {
        // Fall through to plain-token path.
      }
    }

    return ParsedQrPayload(token: text, qrContext: null);
  }

  // ── Validation ───────────────────────────────────────────────────────────

  /// Validates a token string.
  /// Throws [AttendanceServiceException] with a display-safe message on failure.
  static void validateToken(String token) {
    if (token.isEmpty) {
      throw const AttendanceServiceException(message: 'QR token is empty.');
    }
    if (token.contains(' ') ||
        token.contains('\n') ||
        token.contains('\r')) {
      throw const AttendanceServiceException(
          message: 'Token contains invalid whitespace.');
    }
    if (_urlPattern.hasMatch(token)) {
      throw const AttendanceServiceException(
          message: 'QR code contains a URL, not an attendance token.');
    }
    if (token.length < 6) {
      throw const AttendanceServiceException(
          message: 'Token is too short (minimum 6 characters).');
    }
    if (token.length > 512) {
      throw const AttendanceServiceException(message: 'Token is too long.');
    }
    if (!_tokenPattern.hasMatch(token)) {
      throw const AttendanceServiceException(
          message: 'Token contains invalid characters.');
    }
  }

  // ── HTTP ─────────────────────────────────────────────────────────────────

  /// Submits a QR scan to the backend and returns the parsed response.
  ///
  /// All network and HTTP errors are wrapped as [AttendanceServiceException].
  Future<QrScanResult> submitQrScan({
    required String studentId,
    required String token,
    QrContext? qrContext,
    required String accessToken,
  }) async {
    final uri = Uri.parse(
        '$_baseUrl/api/students/$studentId/attendance/qr/scan');

    final body = <String, dynamic>{
      'studentId': studentId,
      'token': token,
      if (qrContext != null && !qrContext.isEmpty)
        'qrContext': qrContext.toJson(),
      'deviceInfo': _deviceInfo(),
    };

    try {
      final response = await http
          .post(
            uri,
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on AttendanceServiceException {
      rethrow;
    } on SocketException {
      throw const AttendanceServiceException(
          message:
              'No internet connection. Check your network and try again.');
    } on TimeoutException {
      throw const AttendanceServiceException(
          message: 'Request timed out. Please try again.');
    } catch (e) {
      throw AttendanceServiceException(
          message: 'Unexpected error (${e.runtimeType}). Please try again.');
    }
  }

  QrScanResult _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        try {
          return QrScanResult.fromJson(
              jsonDecode(response.body) as Map<String, dynamic>);
        } catch (_) {
          throw const AttendanceServiceException(
              message: 'Server returned an unexpected response format.');
        }

      case 400:
        throw const AttendanceServiceException(
            statusCode: 400, message: 'Invalid or expired QR code.');

      case 401:
      case 403:
        throw AttendanceServiceException(
            statusCode: response.statusCode,
            message: 'Unauthorized request or wrong student.');

      default:
        final serverMsg = _extractServerMessage(response.body);
        throw AttendanceServiceException(
            statusCode: response.statusCode,
            message:
                serverMsg ?? 'Something went wrong. Please try again.');
    }
  }

  String? _extractServerMessage(String body) {
    try {
      return (jsonDecode(body) as Map<String, dynamic>)['message']
          as String?;
    } catch (_) {
      return null;
    }
  }

  static String _deviceInfo() {
    if (kIsWeb) return 'web/unknown';
    try {
      return '${Platform.operatingSystem}/${Platform.operatingSystemVersion}';
    } catch (_) {
      return 'unknown/unknown';
    }
  }
}
