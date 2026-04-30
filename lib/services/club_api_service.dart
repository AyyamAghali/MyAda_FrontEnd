import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException;

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../models/club.dart';
import '../models/club_public_event.dart';
import '../models/club_vacancy.dart';
import 'auth_service.dart';

/// Gateway origin (shared for media URL resolution when no club request succeeded yet).
/// Prefer the same API gateway host used by the rest of the Flutter app.
const String kGatewayOrigin = 'http://13.60.31.141:5000';

/// Ordered Club Management API roots to try.
///
/// Per `CLUB_API_DOC.md`, versioned routes are hosted at `{host}/api/v1/...`
/// (not `{host}/club/api/v1/...`).
const List<String> kClubApiBaseCandidates = [
  'http://13.60.31.141:5000',
];

/// Preferred API root (first candidate), for callers that need a single string.
const String kClubApiBase = 'http://13.60.31.141:5000';

/// Resolve a potentially relative media path to an absolute URL.
/// If [path] is already absolute (starts with http), returns as-is.
/// Otherwise, prefixes with the gateway that last worked for club API, then [kGatewayOrigin].
String resolveMediaUrl(String? path) {
  if (path == null || path.isEmpty) return '';
  if (path.startsWith('http://') || path.startsWith('https://')) return path;
  final origin = ClubApiService.clubMediaOrigin ?? kGatewayOrigin;
  final sep = path.startsWith('/') ? '' : '/';
  return '$origin$sep$path';
}

class ClubApiException implements Exception {
  final int? statusCode;
  final String message;
  const ClubApiException({this.statusCode, required this.message});

  @override
  String toString() => 'ClubApiException($statusCode): $message';
}

class ClubApiService {
  /// Last club gateway that responded successfully (session-wide).
  static String? _sessionClubBase;
  static String? _sessionMediaOrigin;

  static String? get clubMediaOrigin => _sessionMediaOrigin;

  List<String> _orderedClubBases() {
    final out = <String>[];
    if (_sessionClubBase != null) out.add(_sessionClubBase!);
    for (final b in kClubApiBaseCandidates) {
      if (!out.contains(b)) out.add(b);
    }
    return out;
  }

  void _rememberClubGateway(String base) {
    _sessionClubBase = base;
    try {
      _sessionMediaOrigin = Uri.parse(base).origin;
    } catch (_) {
      _sessionMediaOrigin = null;
    }
  }

  bool _shouldRetryOnOtherClubGateway(ClubApiException e) {
    final code = e.statusCode;
    if (code == 502 || code == 503 || code == 504) return true;
    if (code != null) return false;
    final m = e.message.toLowerCase();
    return m.contains('timeout') ||
        m.contains('internet') ||
        m.contains('socket') ||
        m.contains('connection refused') ||
        m.contains('failed host lookup');
  }

  /// GET with Bearer, trying each club gateway until one succeeds.
  Future<Object?> _clubAuthorizedGet(Uri Function(String base) buildUri) async {
    ClubApiException? last;
    for (final base in _orderedClubBases()) {
      try {
        final json = await _authorizedGet(buildUri(base));
        _rememberClubGateway(base);
        return json;
      } on ClubApiException catch (e) {
        last = e;
        if (_shouldRetryOnOtherClubGateway(e)) continue;
        rethrow;
      }
    }
    throw last ??
        const ClubApiException(
            message: 'Club service unreachable on all gateways.');
  }

  Future<Object?> _clubAuthorizedPost(
    Uri Function(String base) buildUri, {
    Map<String, dynamic>? body,
  }) async {
    ClubApiException? last;
    for (final base in _orderedClubBases()) {
      try {
        final json = await _authorizedPost(buildUri(base), body: body);
        _rememberClubGateway(base);
        return json;
      } on ClubApiException catch (e) {
        last = e;
        if (_shouldRetryOnOtherClubGateway(e)) continue;
        rethrow;
      }
    }
    throw last ??
        const ClubApiException(
            message: 'Club service unreachable on all gateways.');
  }

  Future<Object?> _clubAuthorizedPatch(
    Uri Function(String base) buildUri, {
    Map<String, dynamic>? body,
  }) async {
    ClubApiException? last;
    for (final base in _orderedClubBases()) {
      try {
        final json = await _authorizedPatch(buildUri(base), body: body);
        _rememberClubGateway(base);
        return json;
      } on ClubApiException catch (e) {
        last = e;
        if (_shouldRetryOnOtherClubGateway(e)) continue;
        rethrow;
      }
    }
    throw last ??
        const ClubApiException(
            message: 'Club service unreachable on all gateways.');
  }

  Future<void> _clubAuthorizedDelete(Uri Function(String base) buildUri) async {
    ClubApiException? last;
    for (final base in _orderedClubBases()) {
      try {
        await _authorizedDelete(buildUri(base));
        _rememberClubGateway(base);
        return;
      } on ClubApiException catch (e) {
        last = e;
        if (_shouldRetryOnOtherClubGateway(e)) continue;
        rethrow;
      }
    }
    throw last ??
        const ClubApiException(
            message: 'Club service unreachable on all gateways.');
  }

  // ── Categories ─────────────────────────────────────────────────────────

  /// `GET /api/v1/categories` (public)
  Future<List<String>> fetchCategories() async {
    try {
      Object? decoded;
      for (final base in _orderedClubBases()) {
        final uri = Uri.parse('$base/api/v1/categories');
        try {
          final response = await http.get(uri, headers: {
            'Accept': 'application/json'
          }).timeout(const Duration(seconds: 8));
          if (response.statusCode == 200 && response.body.isNotEmpty) {
            decoded = jsonDecode(response.body);
            _rememberClubGateway(base);
            break;
          }
        } on TimeoutException {
          continue;
        } on SocketException {
          continue;
        }
      }
      if (decoded == null) return [];
      final list = _unwrapList(decoded);
      return list
          .map((e) => (e['name'] ?? '').toString())
          .where((n) => n.isNotEmpty)
          .toList();
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
    final json = await _clubAuthorizedGet(
      (base) =>
          Uri.parse('$base/api/v1/clubs').replace(queryParameters: params),
    );
    return _unwrapList(json).map((e) => Club.fromJson(e)).toList();
  }

  /// `GET /api/v1/clubs/{clubId}`
  Future<Club> fetchClubDetail(String clubId) async {
    final json = await _clubAuthorizedGet(
      (base) => Uri.parse('$base/api/v1/clubs/$clubId'),
    );
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
    ClubApiException? last;
    for (final base in _orderedClubBases()) {
      final uri = Uri.parse('$base/api/v1/clubs/$clubId/join-applications');
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
            await http.MultipartFile.fromPath(
                'portfolioFiles', portfolioFile.path),
          );
        }
        final streamed = await req.send().timeout(const Duration(seconds: 45));
        final response = await http.Response.fromStream(streamed);
        if (response.statusCode >= 200 && response.statusCode < 300) {
          _rememberClubGateway(base);
          return;
        }
        final msg = _extractMsg(response.body) ?? 'Application failed.';
        final err =
            ClubApiException(statusCode: response.statusCode, message: msg);
        last = err;
        if (_shouldRetryOnOtherClubGateway(err)) continue;
        throw err;
      } on ClubApiException catch (e) {
        last = e;
        if (_shouldRetryOnOtherClubGateway(e)) continue;
        rethrow;
      } on SocketException {
        last = const ClubApiException(message: 'No internet connection.');
        continue;
      } on TimeoutException {
        last = const ClubApiException(message: 'Request timed out.');
        continue;
      } catch (e) {
        if (e is ClubApiException) rethrow;
        throw ClubApiException(message: 'Unexpected error: ${e.runtimeType}');
      }
    }
    throw last ??
        const ClubApiException(
            message: 'Club service unreachable on all gateways.');
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
    final json = await _clubAuthorizedGet(
      (base) =>
          Uri.parse('$base/api/v1/events').replace(queryParameters: params),
    );
    return _unwrapList(json).map((e) => ClubPublicEvent.fromJson(e)).toList();
  }

  /// `GET /api/v1/events/{eventId}`
  Future<ClubPublicEvent?> fetchEventById(int eventId) async {
    try {
      final json = await _clubAuthorizedGet(
        (base) => Uri.parse('$base/api/v1/events/$eventId'),
      );
      final inner = _unwrapSingle(json);
      if (inner.isEmpty) return null;
      return ClubPublicEvent.fromJson(inner);
    } catch (_) {
      return null;
    }
  }

  /// `POST /api/v1/events/{eventId}/registrations`
  Future<Map<String, dynamic>> registerForEvent(String eventId) async {
    final body = await _clubAuthorizedPost(
      (base) => Uri.parse('$base/api/v1/events/$eventId/registrations'),
    );
    return _unwrapSingle(body);
  }

  /// `DELETE /api/v1/events/{eventId}/registrations`
  Future<void> cancelRegistration(String eventId) async {
    await _clubAuthorizedDelete(
      (base) => Uri.parse('$base/api/v1/events/$eventId/registrations'),
    );
  }

  /// `GET /api/v1/events/{eventId}/ticket`
  Future<Map<String, dynamic>> getTicket(String eventId) async {
    final json = await _clubAuthorizedGet(
      (base) => Uri.parse('$base/api/v1/events/$eventId/ticket'),
    );
    return _unwrapSingle(json);
  }

  /// `GET /api/v1/users/me/event-registrations`
  Future<List<Map<String, dynamic>>> listMyRegistrations() async {
    final studentId = AuthService.instance.studentId;
    final json = await _clubAuthorizedGet(
      (base) => (studentId != null && studentId.isNotEmpty)
          ? Uri.parse('$base/api/v1/users/$studentId/event-registrations')
          : Uri.parse('$base/api/v1/users/me/event-registrations'),
    );
    return _unwrapList(json);
  }

  /// `POST /api/v1/events/{eventId}/check-in`
  Future<Map<String, dynamic>> checkIn({
    required String eventId,
    required String jwt,
  }) async {
    final body = await _clubAuthorizedPost(
      (base) => Uri.parse('$base/api/v1/events/$eventId/check-in'),
      body: {'jwt': jwt},
    );
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
    final body = await _clubAuthorizedPost(
      (base) => Uri.parse('$base/api/v1/events/$eventId/tickets/scan'),
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
    final json = await _clubAuthorizedGet(
      (base) => clubId != null
          ? Uri.parse('$base/api/v1/vacancies/by-club/$clubId')
          : Uri.parse('$base/api/v1/vacancies')
              .replace(queryParameters: params),
    );
    return _unwrapList(json).map((e) => ClubVacancy.fromJson(e)).toList();
  }

  /// `POST /api/v1/vacancies/{vacancyId}/applications`  (multipart)
  Future<void> applyToVacancy({
    required int vacancyId,
    required String purposeOfApplication,
    XFile? cvFile,
  }) async {
    ClubApiException? last;
    for (final base in _orderedClubBases()) {
      final uri = Uri.parse('$base/api/v1/vacancies/$vacancyId/applications');
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
        final streamed = await req.send().timeout(const Duration(seconds: 45));
        final response = await http.Response.fromStream(streamed);
        if (response.statusCode >= 200 && response.statusCode < 300) {
          _rememberClubGateway(base);
          return;
        }
        final msg = _extractMsg(response.body) ?? 'Application failed.';
        final err =
            ClubApiException(statusCode: response.statusCode, message: msg);
        if (_shouldRetryOnOtherClubGateway(err)) {
          last = err;
          continue;
        }
        throw err;
      } on ClubApiException catch (e) {
        last = e;
        if (_shouldRetryOnOtherClubGateway(e)) continue;
        rethrow;
      } on SocketException {
        last = const ClubApiException(message: 'No internet connection.');
        continue;
      } on TimeoutException {
        last = const ClubApiException(message: 'Request timed out.');
        continue;
      } catch (e) {
        if (e is ClubApiException) rethrow;
        throw ClubApiException(message: 'Unexpected error: ${e.runtimeType}');
      }
    }
    throw last ??
        const ClubApiException(
            message: 'Club service unreachable on all gateways.');
  }

  // ── Vacancy by ID ──────────────────────────────────────────────────────

  /// `GET /api/v1/vacancies/{vacancyId}`
  ///
  /// Response envelope: `{ statusCode, message, result: { ... } }` (handled by [_unwrapSingle]).
  Future<ClubVacancy> fetchVacancyById(int vacancyId) async {
    final json = await _clubAuthorizedGet(
      (base) => Uri.parse('$base/api/v1/vacancies/$vacancyId'),
    );
    final inner = _unwrapSingle(json);
    if (inner.isEmpty) {
      throw const ClubApiException(
          statusCode: 404, message: 'Vacancy not found.');
    }
    return ClubVacancy.fromJson(inner);
  }

  /// `GET /api/v1/club-position-requirements?clubPositionId=`
  ///
  /// Requirement rows are ordered by [sortOrder] when present.
  Future<List<String>> fetchClubPositionRequirementTexts(
    int clubPositionId,
  ) async {
    if (clubPositionId <= 0) return [];
    final json = await _clubAuthorizedGet(
      (base) => Uri.parse('$base/api/v1/club-position-requirements').replace(
            queryParameters: {'clubPositionId': '$clubPositionId'},
          ),
    );
    final rows = _unwrapList(json);
    rows.sort((a, b) {
      final ia = _sortOrderKey(a['sortOrder']);
      final ib = _sortOrderKey(b['sortOrder']);
      return ia.compareTo(ib);
    });
    return rows
        .map((e) => (e['text'] ?? '').toString().trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  int _sortOrderKey(Object? raw) {
    if (raw is int) return raw;
    return int.tryParse('${raw ?? 0}') ?? 0;
  }

  // ── User-scoped endpoints ─────────────────────────────────────────────

  String get _userId => AuthService.instance.studentId ?? '';

  /// `GET /api/v1/users/{userId}/club-memberships`
  Future<List<Map<String, dynamic>>> fetchMyMemberships() async {
    final json = await _clubAuthorizedGet(
      (base) => Uri.parse('$base/api/v1/users/$_userId/club-memberships'),
    );
    return _unwrapList(json);
  }

  /// `GET /api/v1/users/{userId}/membership-applications`
  Future<List<Map<String, dynamic>>> fetchMyMembershipApplications() async {
    final json = await _clubAuthorizedGet(
      (base) =>
          Uri.parse('$base/api/v1/users/$_userId/membership-applications'),
    );
    return _unwrapList(json);
  }

  /// `GET /api/v1/users/{userId}/vacancy-applications?page=&limit=`
  Future<List<Map<String, dynamic>>> fetchMyVacancyApplications({
    int page = 1,
    int limit = 50,
  }) async {
    final json = await _clubAuthorizedGet(
      (base) => Uri.parse('$base/api/v1/users/$_userId/vacancy-applications')
          .replace(queryParameters: {'page': '$page', 'limit': '$limit'}),
    );
    return _unwrapList(json);
  }

  /// `GET /api/v1/users/{userId}/club-notifications?type=all`
  Future<List<Map<String, dynamic>>> fetchMyNotifications({
    String type = 'all',
  }) async {
    final json = await _clubAuthorizedGet(
      (base) => Uri.parse('$base/api/v1/users/$_userId/club-notifications')
          .replace(queryParameters: {'type': type}),
    );
    return _unwrapList(json);
  }

  /// `PATCH /api/v1/users/{userId}/club-notifications/{notificationId}/read`
  Future<void> markNotificationRead(String notificationId) async {
    await _clubAuthorizedPatch(
      (base) => Uri.parse(
          '$base/api/v1/users/$_userId/club-notifications/$notificationId/read'),
      body: {},
    );
  }

  // ── Interview slots ───────────────────────────────────────────────────

  /// `GET /api/v1/applications/{applicationId}/interview-slots`
  Future<List<Map<String, dynamic>>> fetchInterviewSlots(
      String applicationId) async {
    final json = await _clubAuthorizedGet(
      (base) =>
          Uri.parse('$base/api/v1/applications/$applicationId/interview-slots'),
    );
    return _unwrapList(json);
  }

  /// `POST /api/v1/applications/{applicationId}/interview-slot`
  Future<void> bookInterviewSlot({
    required String applicationId,
    required String slotId,
  }) async {
    await _clubAuthorizedPost(
      (base) =>
          Uri.parse('$base/api/v1/applications/$applicationId/interview-slot'),
      body: {'slotId': slotId},
    );
  }

  /// `GET /api/v1/clubs/{clubId}/members`
  ///
  /// API returns AutoWrapper `result` with `{ items: [{ userId }] }` (see CLUB_API_DOC).
  Future<List<Map<String, dynamic>>> fetchClubMembers(String clubId) async {
    try {
      final json = await _clubAuthorizedGet(
        (base) => Uri.parse('$base/api/v1/clubs/$clubId/members'),
      );
      final list = _unwrapList(json);
      return list.map(_normalizeClubMemberRow).toList();
    } catch (_) {
      return [];
    }
  }

  /// Ensures a stable `userId` key for roster rows (PascalCase / aliases).
  Map<String, dynamic> _normalizeClubMemberRow(Map<String, dynamic> raw) {
    final out = Map<String, dynamic>.from(raw);
    final id = (out['userId'] ??
            out['UserId'] ??
            out['studentId'] ??
            out['StudentId'] ??
            out['memberUserId'] ??
            out['memberId'] ??
            out['id'])
        ?.toString()
        .trim();
    if (id != null && id.isNotEmpty && id.toLowerCase() != 'null') {
      out['userId'] = id;
    }
    return out;
  }

  /// `GET /api/v1/club-admin/{clubId}/members`
  ///
  /// This endpoint returns richer member rows (names/roles) used for the Club profile UI.
  Future<List<Map<String, dynamic>>> fetchClubAdminMembers(
    String clubId, {
    int page = 1,
    int limit = 200,
  }) async {
    try {
      final json = await _clubAuthorizedGet(
        (base) => Uri.parse('$base/api/v1/club-admin/$clubId/members')
            .replace(queryParameters: {'page': '$page', 'limit': '$limit'}),
      );
      return _unwrapList(json).map(_normalizeClubMemberRow).toList();
    } catch (_) {
      return [];
    }
  }

  // ── Private HTTP helpers ───────────────────────────────────────────────

  Future<Object?> _authorizedGet(Uri uri) async {
    Object? transientErr;
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        final response = await AuthService.instance
            .sendAuthorized(
              (token) => http.get(uri, headers: {
                'Authorization': 'Bearer $token',
                'Accept': 'application/json',
              }).timeout(const Duration(seconds: 10)),
            )
            .timeout(const Duration(seconds: 14));
        if (response.statusCode == 200) {
          return response.body.isNotEmpty ? jsonDecode(response.body) : null;
        }
        _throwForStatus(response);
      } on ClubApiException {
        rethrow;
      } on SocketException catch (e) {
        transientErr = e;
      } on TimeoutException catch (e) {
        transientErr = e;
      }
      if (attempt == 0) {
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }
    }
    if (transientErr is TimeoutException) {
      throw const ClubApiException(message: 'Request timed out.');
    }
    throw const ClubApiException(message: 'No internet connection.');
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
                .timeout(const Duration(seconds: 40)),
          )
          .timeout(const Duration(seconds: 55));
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

  Future<Object?> _authorizedPatch(Uri uri,
      {Map<String, dynamic>? body}) async {
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
                .timeout(const Duration(seconds: 40)),
          )
          .timeout(const Duration(seconds: 55));
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
            (token) => http.delete(uri, headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            }).timeout(const Duration(seconds: 40)),
          )
          .timeout(const Duration(seconds: 55));
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
          statusCode: 409,
          message: msg ?? 'Conflict (already exists or full).');
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
