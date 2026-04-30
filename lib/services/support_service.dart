import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/support_ticket.dart';
import '../widgets/support_location_picker.dart';
import 'auth_service.dart';
import 'support_api_config.dart';

const Duration _kSupportRequestTimeout = Duration(seconds: 20);

/// Mobile Support module service aligned with:
/// "Support (Dispatcher + Staff) — Mobile Developer Documentation".
///
/// This client intentionally only implements endpoints listed in that doc.

class SupportCategoryOption {
  final int id;
  final String module;
  final String name;

  const SupportCategoryOption({
    required this.id,
    required this.module,
    required this.name,
  });

  factory SupportCategoryOption.fromJson(Map<String, dynamic> json) {
    final id =
        int.tryParse((json['id'] ?? json['categoryId'] ?? 0).toString()) ?? 0;
    final module = (json['module'] ?? '').toString();
    final name = (json['name'] ?? json['categoryName'] ?? '').toString();
    return SupportCategoryOption(id: id, module: module, name: name);
  }
}

class SupportTimelineEvent {
  final String title;
  final String? description;
  final DateTime? createdAt;

  const SupportTimelineEvent({
    required this.title,
    this.description,
    this.createdAt,
  });

  factory SupportTimelineEvent.fromJson(Map<String, dynamic> json) {
    DateTime? parse(Object? raw) {
      if (raw == null) return null;
      return DateTime.tryParse(raw.toString());
    }

    return SupportTimelineEvent(
      title: (json['title'] ?? json['status'] ?? json['event'] ?? 'Update')
          .toString(),
      description:
          (json['description'] ?? json['note'] ?? json['message'])?.toString(),
      createdAt:
          parse(json['createdAt'] ?? json['timestamp'] ?? json['createdAtUtc']),
    );
  }
}

class SupportServiceException implements Exception {
  final int? statusCode;
  final String message;

  const SupportServiceException({this.statusCode, required this.message});

  @override
  String toString() => message;
}

class SupportService {
  Future<List<String>> _baseUrls() async {
    await SupportApiConfig.ensureInitialized();
    return SupportApiConfig.baseUrlCandidates;
  }

  Uri _uriFromBase(String baseUrl, String path) => Uri.parse('$baseUrl$path');

  bool _shouldTryNextBase(Object error) {
    if (error is SocketException) return true;
    if (error is HttpException) return true;
    if (error is TimeoutException) return true;
    if (error is SupportServiceException) {
      final code = error.statusCode;
      if (code == null) return false;
      // Doc behavior: retry across bases on 404 and gateway errors.
      return code == 404 || code == 502 || code == 503 || code == 504;
    }
    return false;
  }

  Future<http.Response> _authorizedGetWithFailover(String path) async {
    final bases = await _baseUrls();
    Object? lastError;
    for (final base in bases) {
      final uri = _uriFromBase(base, path);
      try {
        final response = await _authorizedGet(uri);
        return response;
      } catch (e) {
        lastError = e;
        if (!_shouldTryNextBase(e)) rethrow;
      }
    }
    if (lastError is Exception) throw lastError;
    throw const SupportServiceException(message: 'Support request failed.');
  }

  Future<http.Response> _authorizedPutWithFailover(
    String path, {
    Map<String, dynamic>? jsonBody,
  }) async {
    final bases = await _baseUrls();
    Object? lastError;
    for (final base in bases) {
      final uri = _uriFromBase(base, path);
      try {
        final response = await AuthService.instance
            .sendAuthorized(
              (token) => http.put(
                uri,
                headers: {
                  'Authorization': 'Bearer $token',
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
                body: jsonEncode(jsonBody ?? const <String, dynamic>{}),
              ),
            )
            .timeout(
              _kSupportRequestTimeout,
              onTimeout: () => throw const SupportServiceException(
                message: 'Support service timed out. Please try again.',
              ),
            );

        if (response.statusCode == 200 || response.statusCode == 204) {
          return response;
        }
        throw _buildError(response);
      } catch (e) {
        lastError = e;
        if (!_shouldTryNextBase(e)) rethrow;
      }
    }
    if (lastError is Exception) throw lastError;
    throw const SupportServiceException(message: 'Support request failed.');
  }

  Future<http.Response> _authorizedPostWithFailover(
    String path, {
    required Map<String, dynamic> jsonBody,
  }) async {
    final bases = await _baseUrls();
    Object? lastError;
    for (final base in bases) {
      final uri = _uriFromBase(base, path);
      try {
        final response = await AuthService.instance
            .sendAuthorized(
              (token) => http.post(
                uri,
                headers: {
                  'Authorization': 'Bearer $token',
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
                body: jsonEncode(jsonBody),
              ),
            )
            .timeout(
              _kSupportRequestTimeout,
              onTimeout: () => throw const SupportServiceException(
                message: 'Support service timed out. Please try again.',
              ),
            );

        if (response.statusCode == 200 || response.statusCode == 201) {
          return response;
        }
        throw _buildError(response);
      } catch (e) {
        lastError = e;
        if (!_shouldTryNextBase(e)) rethrow;
      }
    }
    if (lastError is Exception) throw lastError;
    throw const SupportServiceException(message: 'Support request failed.');
  }

  /// Dispatcher/admin view: fetches all support requests visible to the caller.
  Future<List<SupportTicket>> fetchAllRequests({
    String sortBy = 'newest', // newest | oldest
  }) async {
    final qp = <String, String>{};
    if (sortBy.trim().isNotEmpty) qp['sortBy'] = sortBy.trim();
    final path = Uri(path: '/SupportRequests', queryParameters: qp).toString();
    final response = await _authorizedGetWithFailover(path);
    final list = _unwrapList(response.body);
    return list
        .whereType<Map<String, dynamic>>()
        .map(SupportTicket.fromApiJson)
        .toList(growable: false);
  }

  Future<List<SupportCategoryOption>> fetchCategories({String? module}) async {
    final path = module == null || module.trim().isEmpty
        ? '/Categories'
        : '/Categories/module/${Uri.encodeComponent(module)}';
    final response = await _authorizedGetWithFailover(path);
    final list = _unwrapList(response.body);
    return list
        .whereType<Map<String, dynamic>>()
        .map(SupportCategoryOption.fromJson)
        .where((c) => c.id > 0 && c.name.trim().isNotEmpty)
        .toList(growable: false);
  }

  Future<List<SupportTicket>> fetchMyRequests(
      {required String memberId}) async {
    final response = await _authorizedGetWithFailover(
      '/SupportRequests/member/${Uri.encodeComponent(memberId)}',
    );
    final list = _unwrapList(response.body);
    return list
        .whereType<Map<String, dynamic>>()
        .map(SupportTicket.fromApiJson)
        .toList(growable: false);
  }

  Future<List<SupportTicket>> fetchStaffRequests({
    required String staffId,
  }) async {
    final response = await _authorizedGetWithFailover(
      '/SupportRequests/staff/${Uri.encodeComponent(staffId)}',
    );
    final list = _unwrapList(response.body);
    return list
        .whereType<Map<String, dynamic>>()
        .map(SupportTicket.fromApiJson)
        .toList(growable: false);
  }

  Future<SupportTicket> fetchRequestById(int requestId) async {
    final response = await _authorizedGetWithFailover('/SupportRequests/$requestId');
    final map = _unwrapMap(response.body);
    return SupportTicket.fromApiJson(map);
  }

  Future<List<SupportTimelineEvent>> fetchRequestTimeline(int requestId) async {
    final response =
        await _authorizedGetWithFailover('/SupportRequests/$requestId/timeline');
    final list = _unwrapList(response.body);
    return list
        .whereType<Map<String, dynamic>>()
        .map(SupportTimelineEvent.fromJson)
        .toList(growable: false);
  }

  /// Dispatcher action: assign (or update assignment).
  ///
  /// API: `PUT /SupportRequests/{requestId}/assign/dispatcher/{dispatcherId}`
  Future<void> assignRequest({
    required int requestId,
    required String dispatcherId,
    required String staffId,
    required String dispatcherInstructions,
  }) async {
    await _authorizedPutWithFailover(
      '/SupportRequests/$requestId/assign/dispatcher/${Uri.encodeComponent(dispatcherId)}',
      jsonBody: <String, dynamic>{
        'staffId': staffId,
        'dispatcherInstructions': dispatcherInstructions,
      },
    );
  }

  /// Dispatcher action: reassign staff (optional, if backend supports).
  ///
  /// API: `PUT /SupportRequests/{requestId}/reassign/dispatcher/{dispatcherId}`
  Future<void> reassignRequest({
    required int requestId,
    required String dispatcherId,
    required String staffId,
    required String dispatcherInstructions,
  }) async {
    await _authorizedPutWithFailover(
      '/SupportRequests/$requestId/reassign/dispatcher/${Uri.encodeComponent(dispatcherId)}',
      jsonBody: <String, dynamic>{
        'staffId': staffId,
        'dispatcherInstructions': dispatcherInstructions,
      },
    );
  }

  /// Dispatcher action: update internal instructions only.
  ///
  /// API: `PUT /SupportRequests/{requestId}/dispatcher-instructions/dispatcher/{dispatcherId}`
  Future<void> setDispatcherInstructions({
    required int requestId,
    required String dispatcherId,
    required String instructions,
  }) async {
    await _authorizedPutWithFailover(
      '/SupportRequests/$requestId/dispatcher-instructions/dispatcher/${Uri.encodeComponent(dispatcherId)}',
      jsonBody: <String, dynamic>{'instructions': instructions},
    );
  }

  /// Staff action: mark the request as "in progress".
  ///
  /// API: `PUT /support/api/SupportRequests/{requestId}/in-progress/staff/{staffId}`
  Future<void> markStaffRequestInProgress({
    required int requestId,
    required String staffId,
  }) {
    return _putStaffRequestAction(
      requestId: requestId,
      staffId: staffId,
      action: 'in-progress',
    );
  }

  Future<void> completeStaffRequest({
    required int requestId,
    required String staffId,
  }) {
    return _putStaffRequestAction(
      requestId: requestId,
      staffId: staffId,
      action: 'complete',
    );
  }

  Future<void> _putStaffRequestAction({
    required int requestId,
    required String staffId,
    required String action,
  }) async {
    await _authorizedPutWithFailover(
      '/SupportRequests/$requestId/$action/staff/${Uri.encodeComponent(staffId)}',
    );
  }

  Future<void> cancelRequest({
    required int requestId,
    required String memberId,
    required String reason,
  }) async {
    await _authorizedPutWithFailover(
      '/SupportRequests/$requestId/cancel/member/${Uri.encodeComponent(memberId)}',
      jsonBody: <String, dynamic>{'reason': reason},
    );
  }

  Future<int> createRequest({
    required String memberId,
    required String area,
    required int categoryId,
    required SupportLocationValue location,
    required String description,
    required TicketPriority urgency,
    required List<String> attachmentPaths,
  }) async {
    final attachmentUrls = <String>[];
    for (final path in attachmentPaths) {
      final uploaded = await _uploadAttachment(path);
      if (uploaded != null && uploaded.isNotEmpty) attachmentUrls.add(uploaded);
    }

    final payload = _buildCreatePayload(
      area: area,
      categoryId: categoryId,
      location: location,
      description: description,
      urgency: urgency,
      attachmentUrls: attachmentUrls,
    );

    final response = await _authorizedPostWithFailover(
      '/SupportRequests/member/${Uri.encodeComponent(memberId)}',
      jsonBody: payload,
    );

    final map = _unwrapMap(response.body);
    final id = int.tryParse(
      (map['id'] ?? map['requestId'] ?? map['supportRequestId'] ?? 0)
          .toString(),
    );
    return id ?? 0;
  }

  Map<String, dynamic> _buildCreatePayload({
    required String area,
    required int categoryId,
    required SupportLocationValue location,
    required String description,
    required TicketPriority urgency,
    required List<String> attachmentUrls,
  }) {
    final locationType =
        location.type == SupportLocationType.building ? 'building' : 'campus';
    final placeType = location.type == SupportLocationType.building
        ? (location.isRoom == true ? 'room' : 'nonRoom')
        : null;

    String? areaDetails;
    if (location.type == SupportLocationType.campus) {
      areaDetails = (location.details ?? '').trim().isEmpty
          ? null
          : (location.details ?? '').trim();
    } else if (location.type == SupportLocationType.building &&
        location.isRoom == false) {
      areaDetails = (location.details ?? '').trim().isEmpty
          ? null
          : (location.details ?? '').trim();
    }

    return <String, dynamic>{
      'area': area.toLowerCase(), // it|fm
      'categoryId': categoryId,
      'locationType': locationType, // building|campus
      'buildingId': location.type == SupportLocationType.building
          ? location.buildingId
          : null,
      'placeType': placeType, // room|nonRoom
      'roomId': location.type == SupportLocationType.building &&
              location.isRoom == true
          ? location.roomId
          : null,
      'areaDetails': areaDetails,
      'description': description,
      'urgency': urgency == TicketPriority.critical ? 'critical' : 'standard',
      'attachmentUrls': attachmentUrls,
    };
  }

  Future<String?> _uploadAttachment(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;
    final ext = path.toLowerCase();
    final isAllowed = ext.endsWith('.jpg') ||
        ext.endsWith('.jpeg') ||
        ext.endsWith('.png') ||
        ext.endsWith('.webp') ||
        ext.endsWith('.gif');
    if (!isAllowed) return null;

    final bases = await _baseUrls();
    if (bases.isEmpty) return null;
    final uri = _uriFromBase(bases.first, '/SupportRequests/uploads');
    final request = http.MultipartRequest('POST', uri);

    await AuthService.instance.loadSession();
    final token = AuthService.instance.accessToken;
    if (token == null || token.isEmpty) {
      throw const SupportServiceException(message: 'Authentication required.');
    }
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';
    request.files.add(await http.MultipartFile.fromPath('files', path));

    final streamed = await request.send().timeout(
      _kSupportRequestTimeout,
      onTimeout: () => throw const SupportServiceException(
        message: 'Attachment upload timed out. Please try again.',
      ),
    );
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw _buildError(response);
    }

    final decoded = _decode(response.body);
    if (decoded is List && decoded.isNotEmpty) {
      final first = decoded.first?.toString() ?? '';
      if (first.isNotEmpty) return first;
    }
    if (decoded is Map<String, dynamic>) {
      final root = _unwrapRoot(decoded);
      if (root is List && root.isNotEmpty) {
        final first = root.first?.toString() ?? '';
        if (first.isNotEmpty) return first;
      }
      if (root is Map<String, dynamic>) {
        for (final key in ['url', 'fileUrl', 'uploadedUrl', 'path', 'location']) {
          final s = root[key]?.toString() ?? '';
          if (s.isNotEmpty) return s;
        }
      }
    }
    return null;
  }

  Future<http.Response> _authorizedGet(Uri uri) async {
    final response = await AuthService.instance
        .sendAuthorized(
          (token) => http.get(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          ),
        )
        .timeout(
          _kSupportRequestTimeout,
          onTimeout: () => throw const SupportServiceException(
            message: 'Support service timed out. Please try again.',
          ),
        );
    if (response.statusCode != 200) throw _buildError(response);
    return response;
  }

  List<dynamic> _unwrapList(String body) {
    final decoded = _decode(body);
    if (decoded is List) return decoded;
    if (decoded is! Map<String, dynamic>) return const [];
    final root = _unwrapRoot(decoded);
    if (root is List) return root;
    if (root is Map<String, dynamic>) {
      final listKeys = [
        'items',
        'results',
        'data',
        'value',
        'supportRequests',
        'requests',
        'tickets',
      ];
      for (final key in listKeys) {
        final candidate = root[key];
        if (candidate is List) return candidate;
      }
    }
    return const [];
  }

  Map<String, dynamic> _unwrapMap(String body) {
    final decoded = _decode(body);
    if (decoded is Map<String, dynamic>) {
      final root = _unwrapRoot(decoded);
      if (root is Map<String, dynamic>) return root;
      return decoded;
    }
    return const {};
  }

  Object? _unwrapRoot(Map<String, dynamic> map) {
    if (map['result'] != null) return map['result'];
    if (map['data'] != null) return map['data'];
    return map;
  }

  Object? _decode(String body) {
    if (body.trim().isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  SupportServiceException _buildError(http.Response response) {
    final decoded = _decode(response.body);
    String message = 'Support request failed (${response.statusCode}).';
    if (decoded is Map<String, dynamic>) {
      final unwrapped = _unwrapRoot(decoded);
      if (unwrapped is Map<String, dynamic>) {
        final direct =
            unwrapped['message'] ?? unwrapped['title'] ?? unwrapped['detail'];
        if (direct is String && direct.isNotEmpty) {
          message = direct;
        }
        final exception = unwrapped['responseException'];
        if (exception is Map<String, dynamic>) {
          final exMsg =
              (exception['exceptionMessage'] ?? exception['message'])?.toString();
          if (exMsg != null && exMsg.trim().isNotEmpty) {
            message = exMsg;
          }
        }
      }
      final rootDirect = decoded['message'];
      if (rootDirect is String && rootDirect.isNotEmpty) {
        message = rootDirect;
      }
    }
    final raw = response.body.trim();
    if (raw.isNotEmpty &&
        !raw.startsWith('{') &&
        !raw.startsWith('[') &&
        raw.length <= 240) {
      message = '$message\n$raw';
    }
    return SupportServiceException(
        statusCode: response.statusCode, message: message);
  }
}
