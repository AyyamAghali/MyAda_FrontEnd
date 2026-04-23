import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException;

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../models/club.dart';
import '../models/club_public_event.dart';
import '../models/club_vacancy.dart';
import 'auth_service.dart';

/// Gateway origin (shared for media URL resolution).
const String kGatewayOrigin = 'http://13.60.31.141:5000';

/// Gateway base for the Club Management microservice.
///
/// All requests go through the API gateway with `/club` prefix.
/// The gateway strips `/club` before forwarding to the service container.
const String kClubApiBase = '$kGatewayOrigin/club';

/// Resolve a potentially relative media path to an absolute URL.
/// If [path] is already absolute (starts with http), returns as-is.
/// Otherwise, prefixes with [kGatewayOrigin].
String resolveMediaUrl(String? path) {
  if (path == null || path.isEmpty) return '';
  if (path.startsWith('http://') || path.startsWith('https://')) return path;
  final sep = path.startsWith('/') ? '' : '/';
  return '$kGatewayOrigin$sep$path';
}

class ClubApiException implements Exception {
  final int? statusCode;
  final String message;
  const ClubApiException({this.statusCode, required this.message});

  @override
  String toString() => 'ClubApiException($statusCode): $message';
}

class ClubApiService {
  // ── Categories ─────────────────────────────────────────────────────────

  /// `GET /api/v1/categories` (public)
  Future<List<String>> fetchCategories() async {
    final uri = Uri.parse('$kClubApiBase/api/v1/categories');
    try {
      final response = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final json = jsonDecode(response.body);
        final list = _unwrapList(json);
        return list
            .map((e) => (e['name'] ?? '').toString())
            .where((n) => n.isNotEmpty)
            .toList();
      }
    } catch (_) {}
    return [];
  }

  // ── Clubs ──────────────────────────────────────────────────────────────

  /// `GET /api/v1/clubs?search=&category=&page=&limit=`
  Future<List<Club>> fetchClubs({
    String? search,
    String? category,
    int page = 1,
    int limit = 50,
  }) async {
    final params = <String, String>{
      'page': '$page',
      'limit': '$limit',
    };
    if (search != null && search.trim().isNotEmpty) {
      params['search'] = search.trim();
    }
    if (category != null && category != 'All' && category.isNotEmpty) {
      params['category'] = category;
    }
    final uri = Uri.parse('$kClubApiBase/api/v1/clubs')
        .replace(queryParameters: params);
    final json = await _authorizedGet(uri);
    return _unwrapList(json).map((e) => Club.fromJson(e)).toList();
  }

  /// `GET /api/v1/clubs/{clubId}`
  Future<Club> fetchClubDetail(String clubId) async {
    final uri = Uri.parse('$kClubApiBase/api/v1/clubs/$clubId');
    final json = await _authorizedGet(uri);
    final inner = _unwrapSingle(json);
    return Club.fromJson(inner);
  }

  /// `POST /api/v1/clubs/{clubId}/join-applications`  (multipart)
  Future<void> submitJoinApplication({
    required String clubId,
    required String letterOfPurpose,
    String? portfolioLinks,
    XFile? portfolioFile,
  }) async {
    final uri =
        Uri.parse('$kClubApiBase/api/v1/clubs/$clubId/join-applications');
    try {
      final req = http.MultipartRequest('POST', uri);
      final token = AuthService.instance.accessToken ?? '';
      req.headers['Authorization'] = 'Bearer $token';
      req.fields['letterOfPurpose'] = letterOfPurpose;
      if (portfolioLinks != null && portfolioLinks.trim().isNotEmpty) {
        req.fields['portfolioLinks'] = portfolioLinks.trim();
      }
      if (portfolioFile != null) {
        req.files.add(
          await http.MultipartFile.fromPath('portfolioFiles', portfolioFile.path),
        );
      }
      final streamed =
          await req.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode >= 200 && response.statusCode < 300) return;
      final msg = _extractMsg(response.body) ?? 'Application failed.';
      throw ClubApiException(statusCode: response.statusCode, message: msg);
    } on ClubApiException {
      rethrow;
    } on SocketException {
      throw const ClubApiException(message: 'No internet connection.');
    } on TimeoutException {
      throw const ClubApiException(message: 'Request timed out.');
    } catch (e) {
      if (e is ClubApiException) rethrow;
      throw ClubApiException(message: 'Unexpected error: ${e.runtimeType}');
    }
  }

  // ── Events ─────────────────────────────────────────────────────────────

  /// `GET /api/v1/events?search=&clubId=&page=&limit=`
  Future<List<ClubPublicEvent>> fetchEvents({
    String? search,
    int? clubId,
    int page = 1,
    int limit = 50,
  }) async {
    final params = <String, String>{
      'page': '$page',
      'limit': '$limit',
    };
    if (search != null && search.trim().isNotEmpty) {
      params['search'] = search.trim();
    }
    if (clubId != null) params['clubId'] = '$clubId';
    final uri = Uri.parse('$kClubApiBase/api/v1/events')
        .replace(queryParameters: params);
    final json = await _authorizedGet(uri);
    return _unwrapList(json).map((e) => ClubPublicEvent.fromJson(e)).toList();
  }

  /// `GET /api/v1/events/{eventId}`
  Future<ClubPublicEvent?> fetchEventById(int eventId) async {
    final uri = Uri.parse('$kClubApiBase/api/v1/events/$eventId');
    try {
      final json = await _authorizedGet(uri);
      final inner = _unwrapSingle(json);
      if (inner.isEmpty) return null;
      return ClubPublicEvent.fromJson(inner);
    } catch (_) {
      return null;
    }
  }

  /// `POST /api/v1/events/{eventId}/registrations`
  Future<Map<String, dynamic>> registerForEvent(String eventId) async {
    final uri = Uri.parse(
        '$kClubApiBase/api/v1/events/$eventId/registrations');
    final body = await _authorizedPost(uri);
    return _unwrapSingle(body);
  }

  /// `DELETE /api/v1/events/{eventId}/registrations`
  Future<void> cancelRegistration(String eventId) async {
    final uri = Uri.parse(
        '$kClubApiBase/api/v1/events/$eventId/registrations');
    await _authorizedDelete(uri);
  }

  /// `GET /api/v1/events/{eventId}/ticket`
  Future<Map<String, dynamic>> getTicket(String eventId) async {
    final uri = Uri.parse('$kClubApiBase/api/v1/events/$eventId/ticket');
    final json = await _authorizedGet(uri);
    return _unwrapSingle(json);
  }

  /// `GET /api/v1/users/me/event-registrations`
  Future<List<Map<String, dynamic>>> listMyRegistrations() async {
    final studentId = AuthService.instance.studentId;
    final uri = (studentId != null && studentId.isNotEmpty)
        ? Uri.parse(
            '$kClubApiBase/api/v1/users/$studentId/event-registrations')
        : Uri.parse(
            '$kClubApiBase/api/v1/users/me/event-registrations');
    final json = await _authorizedGet(uri);
    return _unwrapList(json);
  }

  /// `POST /api/v1/events/{eventId}/check-in`
  Future<Map<String, dynamic>> checkIn({
    required String eventId,
    required String jwt,
  }) async {
    final uri =
        Uri.parse('$kClubApiBase/api/v1/events/$eventId/check-in');
    final body = await _authorizedPost(uri, body: {'jwt': jwt});
    return _unwrapSingle(body);
  }

  /// `POST /api/v1/events/{eventId}/tickets/scan`
  Future<Map<String, dynamic>> scanTicket({
    required String eventId,
    required String token,
    String? scannerDeviceId,
    String? gateId,
    DateTime? scannedAtUtc,
  }) async {
    final uri = Uri.parse('$kClubApiBase/api/v1/events/$eventId/tickets/scan');
    final body = await _authorizedPost(
      uri,
      body: {
        'token': token,
        if (scannerDeviceId != null && scannerDeviceId.isNotEmpty)
          'scannerDeviceId': scannerDeviceId,
        if (gateId != null && gateId.isNotEmpty) 'gateId': gateId,
        'scannedAtUtc':
            (scannedAtUtc ?? DateTime.now().toUtc()).toIso8601String(),
      },
    );
    return _unwrapSingle(body);
  }

  // ── Vacancies ──────────────────────────────────────────────────────────

  /// `GET /api/v1/vacancies?search=&page=&limit=`
  Future<List<ClubVacancy>> fetchVacancies({
    String? search,
    int? clubId,
    int page = 1,
    int limit = 50,
  }) async {
    final params = <String, String>{
      'page': '$page',
      'limit': '$limit',
    };
    if (search != null && search.trim().isNotEmpty) {
      params['search'] = search.trim();
    }
    final uri = (clubId != null)
        ? Uri.parse('$kClubApiBase/api/v1/vacancies/by-club/$clubId')
        : Uri.parse('$kClubApiBase/api/v1/vacancies')
            .replace(queryParameters: params);
    final json = await _authorizedGet(uri);
    return _unwrapList(json).map((e) => ClubVacancy.fromJson(e)).toList();
  }

  /// `POST /api/v1/vacancies/{vacancyId}/applications`  (multipart)
  Future<void> applyToVacancy({
    required int vacancyId,
    required String purposeOfApplication,
    XFile? cvFile,
  }) async {
    final uri = Uri.parse(
        '$kClubApiBase/api/v1/vacancies/$vacancyId/applications');
    try {
      final req = http.MultipartRequest('POST', uri);
      final token = AuthService.instance.accessToken ?? '';
      req.headers['Authorization'] = 'Bearer $token';
      req.fields['purposeOfApplication'] = purposeOfApplication;
      if (cvFile != null) {
        req.files.add(
          await http.MultipartFile.fromPath('cvFile', cvFile.path),
        );
      }
      final streamed =
          await req.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode >= 200 && response.statusCode < 300) return;
      final msg = _extractMsg(response.body) ?? 'Application failed.';
      throw ClubApiException(statusCode: response.statusCode, message: msg);
    } on ClubApiException {
      rethrow;
    } on SocketException {
      throw const ClubApiException(message: 'No internet connection.');
    } on TimeoutException {
      throw const ClubApiException(message: 'Request timed out.');
    } catch (e) {
      if (e is ClubApiException) rethrow;
      throw ClubApiException(message: 'Unexpected error: ${e.runtimeType}');
    }
  }

  // ── Vacancy by ID ──────────────────────────────────────────────────────

  /// `GET /api/v1/vacancies/{vacancyId}`
  Future<ClubVacancy?> fetchVacancyById(int vacancyId) async {
    final uri = Uri.parse('$kClubApiBase/api/v1/vacancies/$vacancyId');
    try {
      final json = await _authorizedGet(uri);
      final inner = _unwrapSingle(json);
      if (inner.isEmpty) return null;
      return ClubVacancy.fromJson(inner);
    } catch (_) {
      return null;
    }
  }

  // ── User-scoped endpoints ─────────────────────────────────────────────

  String get _userId => AuthService.instance.studentId ?? '';

  /// `GET /api/v1/users/{userId}/club-memberships`
  Future<List<Map<String, dynamic>>> fetchMyMemberships() async {
    final uri =
        Uri.parse('$kClubApiBase/api/v1/users/$_userId/club-memberships');
    final json = await _authorizedGet(uri);
    return _unwrapList(json);
  }

  /// `GET /api/v1/users/{userId}/membership-applications`
  Future<List<Map<String, dynamic>>> fetchMyMembershipApplications() async {
    final uri = Uri.parse(
        '$kClubApiBase/api/v1/users/$_userId/membership-applications');
    final json = await _authorizedGet(uri);
    return _unwrapList(json);
  }

  /// `GET /api/v1/users/{userId}/vacancy-applications?page=&limit=`
  Future<List<Map<String, dynamic>>> fetchMyVacancyApplications({
    int page = 1,
    int limit = 50,
  }) async {
    final uri = Uri.parse(
            '$kClubApiBase/api/v1/users/$_userId/vacancy-applications')
        .replace(queryParameters: {'page': '$page', 'limit': '$limit'});
    final json = await _authorizedGet(uri);
    return _unwrapList(json);
  }

  /// `GET /api/v1/users/{userId}/club-notifications?type=all`
  Future<List<Map<String, dynamic>>> fetchMyNotifications({
    String type = 'all',
  }) async {
    final uri = Uri.parse(
            '$kClubApiBase/api/v1/users/$_userId/club-notifications')
        .replace(queryParameters: {'type': type});
    final json = await _authorizedGet(uri);
    return _unwrapList(json);
  }

  /// `PATCH /api/v1/users/{userId}/club-notifications/{notificationId}/read`
  Future<void> markNotificationRead(String notificationId) async {
    final uri = Uri.parse(
        '$kClubApiBase/api/v1/users/$_userId/club-notifications/$notificationId/read');
    await _authorizedPatch(uri, body: {});
  }

  // ── Interview slots ───────────────────────────────────────────────────

  /// `GET /api/v1/applications/{applicationId}/interview-slots`
  Future<List<Map<String, dynamic>>> fetchInterviewSlots(
      String applicationId) async {
    final uri = Uri.parse(
        '$kClubApiBase/api/v1/applications/$applicationId/interview-slots');
    final json = await _authorizedGet(uri);
    return _unwrapList(json);
  }

  /// `POST /api/v1/applications/{applicationId}/interview-slot`
  Future<void> bookInterviewSlot({
    required String applicationId,
    required String slotId,
  }) async {
    final uri = Uri.parse(
        '$kClubApiBase/api/v1/applications/$applicationId/interview-slot');
    await _authorizedPost(uri, body: {'slotId': slotId});
  }

  /// `GET /api/v1/clubs/{clubId}/members`
  Future<List<Map<String, dynamic>>> fetchClubMembers(String clubId) async {
    final uri = Uri.parse('$kClubApiBase/api/v1/clubs/$clubId/members');
    try {
      final json = await _authorizedGet(uri);
      return _unwrapList(json);
    } catch (_) {
      return [];
    }
  }

  // ── Private HTTP helpers ───────────────────────────────────────────────

  Future<Object?> _authorizedGet(Uri uri) async {
    try {
      final response = await AuthService.instance
          .sendAuthorized(
            (token) => http
                .get(uri, headers: {
                  'Authorization': 'Bearer $token',
                  'Accept': 'application/json',
                })
                .timeout(const Duration(seconds: 20)),
          )
          .timeout(const Duration(seconds: 25));
      if (response.statusCode == 200) {
        return response.body.isNotEmpty ? jsonDecode(response.body) : null;
      }
      _throwForStatus(response);
    } on ClubApiException {
      rethrow;
    } on SocketException {
      throw const ClubApiException(message: 'No internet connection.');
    } on TimeoutException {
      throw const ClubApiException(message: 'Request timed out.');
    }
  }

  Future<Object?> _authorizedPost(Uri uri, {Map<String, dynamic>? body}) async {
    try {
      final response = await AuthService.instance
          .sendAuthorized(
            (token) => http
                .post(
                  uri,
                  headers: {
                    'Authorization': 'Bearer $token',
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                  },
                  body: body != null ? jsonEncode(body) : null,
                )
                .timeout(const Duration(seconds: 20)),
          )
          .timeout(const Duration(seconds: 25));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.body.isNotEmpty ? jsonDecode(response.body) : null;
      }
      _throwForStatus(response);
    } on ClubApiException {
      rethrow;
    } on SocketException {
      throw const ClubApiException(message: 'No internet connection.');
    } on TimeoutException {
      throw const ClubApiException(message: 'Request timed out.');
    }
  }

  Future<Object?> _authorizedPatch(Uri uri, {Map<String, dynamic>? body}) async {
    try {
      final response = await AuthService.instance
          .sendAuthorized(
            (token) => http
                .patch(
                  uri,
                  headers: {
                    'Authorization': 'Bearer $token',
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                  },
                  body: body != null ? jsonEncode(body) : null,
                )
                .timeout(const Duration(seconds: 20)),
          )
          .timeout(const Duration(seconds: 25));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.body.isNotEmpty ? jsonDecode(response.body) : null;
      }
      _throwForStatus(response);
    } on ClubApiException {
      rethrow;
    } on SocketException {
      throw const ClubApiException(message: 'No internet connection.');
    } on TimeoutException {
      throw const ClubApiException(message: 'Request timed out.');
    }
  }

  Future<void> _authorizedDelete(Uri uri) async {
    try {
      final response = await AuthService.instance
          .sendAuthorized(
            (token) => http
                .delete(uri, headers: {
                  'Authorization': 'Bearer $token',
                  'Accept': 'application/json',
                })
                .timeout(const Duration(seconds: 20)),
          )
          .timeout(const Duration(seconds: 25));
      if (response.statusCode >= 200 && response.statusCode < 300) return;
      _throwForStatus(response);
    } on ClubApiException {
      rethrow;
    } on SocketException {
      throw const ClubApiException(message: 'No internet connection.');
    } on TimeoutException {
      throw const ClubApiException(message: 'Request timed out.');
    }
  }

  Never _throwForStatus(http.Response response) {
    final msg = _extractMsg(response.body);
    if (response.statusCode == 409) {
      throw ClubApiException(
          statusCode: 409, message: msg ?? 'Conflict (already exists or full).');
    }
    if (response.statusCode == 404) {
      throw ClubApiException(statusCode: 404, message: msg ?? 'Not found.');
    }
    throw ClubApiException(
        statusCode: response.statusCode,
        message: msg ?? 'Request failed (${response.statusCode}).');
  }

  /// AutoWrapper may return nested payloads like:
  /// - `{ result: [ ... ] }`
  /// - `{ result: { items: [ ... ], total, page, limit } }`
  /// - `{ data: { items: [ ... ] } }`
  /// - `{ items: [ ... ] }`
  List<Map<String, dynamic>> _unwrapList(Object? json) {
    if (json == null) return [];
    if (json is List) {
      return json.whereType<Map<String, dynamic>>().toList();
    }
    if (json is Map<String, dynamic>) {
      final candidates = <Object?>[
        json['result'],
        json['data'],
        json['items'],
        json['results'],
        json,
      ];
      for (final c in candidates) {
        final out = _extractListFromAny(c);
        if (out.isNotEmpty) return out;
      }
    }
    return [];
  }

  Map<String, dynamic> _unwrapSingle(Object? json) {
    if (json is Map<String, dynamic>) {
      final candidates = <Object?>[
        json['result'],
        json['data'],
        json['item'],
        json['payload'],
      ];
      for (final c in candidates) {
        if (c is Map<String, dynamic>) return c;
      }
      return json;
    }
    return {};
  }

  List<Map<String, dynamic>> _extractListFromAny(Object? value) {
    if (value == null) return [];
    if (value is List) {
      return value.whereType<Map<String, dynamic>>().toList();
    }
    if (value is Map<String, dynamic>) {
      final nestedItems = value['items'] ??
          value['results'] ??
          value['data'] ??
          value['list'] ??
          value['rows'];
      if (nestedItems is List) {
        return nestedItems.whereType<Map<String, dynamic>>().toList();
      }
    }
    return [];
  }

  String? _extractMsg(String body) {
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
      if (errors is List && errors.isNotEmpty) return errors.first.toString();
      return null;
    } catch (_) {
      return null;
    }
  }
}
