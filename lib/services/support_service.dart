import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/support_ticket.dart';
import '../widgets/support_location_picker.dart';
import 'auth_service.dart';

const String kSupportBaseUrl = 'http://13.60.31.141:5000/support/api';

enum SupportStaffAvailability {
  offline,
  online,
  onBreak,
}

class SupportStaffStatus {
  final String memberId;
  final SupportStaffAvailability status;

  const SupportStaffStatus({
    required this.memberId,
    required this.status,
  });

  factory SupportStaffStatus.fromJson(Map<String, dynamic> json) {
    return SupportStaffStatus(
      memberId: (json['memberId'] ?? json['id'] ?? '').toString(),
      status: _parseStaffAvailability(json['status']),
    );
  }

  static SupportStaffAvailability _parseStaffAvailability(Object? raw) {
    final value = (raw ?? '').toString().trim().toLowerCase();
    if (value == 'online' || value == 'available') {
      return SupportStaffAvailability.online;
    }
    if (value == 'onbreak' ||
        value == 'on_break' ||
        value == 'break' ||
        value == 'paused') {
      return SupportStaffAvailability.onBreak;
    }
    return SupportStaffAvailability.offline;
  }
}

String supportStaffAvailabilityApiValue(SupportStaffAvailability status) {
  switch (status) {
    case SupportStaffAvailability.online:
      return 'Online';
    case SupportStaffAvailability.onBreak:
      return 'OnBreak';
    case SupportStaffAvailability.offline:
      return 'Offline';
  }
}

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
  Future<List<SupportCategoryOption>> fetchCategories({String? module}) async {
    final path = module == null || module.trim().isEmpty
        ? '$kSupportBaseUrl/Categories'
        : '$kSupportBaseUrl/Categories/module/${Uri.encodeComponent(module)}';
    final response = await _authorizedGet(Uri.parse(path));
    final list = _unwrapList(response.body);
    return list
        .whereType<Map<String, dynamic>>()
        .map(SupportCategoryOption.fromJson)
        .where((c) => c.id > 0 && c.name.trim().isNotEmpty)
        .toList(growable: false);
  }

  Future<List<SupportTicket>> fetchMyRequests(
      {required String memberId}) async {
    final response = await _authorizedGet(
      Uri.parse(
          '$kSupportBaseUrl/SupportRequests/member/${Uri.encodeComponent(memberId)}'),
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
    final response = await _authorizedGet(
      Uri.parse(
        '$kSupportBaseUrl/SupportRequests/staff/${Uri.encodeComponent(staffId)}',
      ),
    );
    final list = _unwrapList(response.body);
    return list
        .whereType<Map<String, dynamic>>()
        .map(SupportTicket.fromApiJson)
        .toList(growable: false);
  }

  Future<SupportStaffStatus> fetchStaffStatus({
    required String memberId,
  }) async {
    final response = await _authorizedGet(
      Uri.parse(
        '$kSupportBaseUrl/SupportStaffStatuses/member/${Uri.encodeComponent(memberId)}',
      ),
    );
    return SupportStaffStatus.fromJson(_unwrapMap(response.body));
  }

  Future<void> updateStaffStatus({
    required String memberId,
    required SupportStaffAvailability status,
  }) async {
    final uri = Uri.parse(
      '$kSupportBaseUrl/SupportStaffStatuses/member/${Uri.encodeComponent(memberId)}',
    );
    final response = await AuthService.instance.sendAuthorized(
      (token) => http.put(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'status': supportStaffAvailabilityApiValue(status),
        }),
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 204) return;
    throw _buildError(response);
  }

  Future<SupportTicket> fetchRequestById(int requestId) async {
    final response = await _authorizedGet(
      Uri.parse('$kSupportBaseUrl/SupportRequests/$requestId'),
    );
    final map = _unwrapMap(response.body);
    return SupportTicket.fromApiJson(map);
  }

  Future<List<SupportTimelineEvent>> fetchRequestTimeline(int requestId) async {
    final response = await _authorizedGet(
      Uri.parse('$kSupportBaseUrl/SupportRequests/$requestId/timeline'),
    );
    final list = _unwrapList(response.body);
    return list
        .whereType<Map<String, dynamic>>()
        .map(SupportTimelineEvent.fromJson)
        .toList(growable: false);
  }

  Future<void> startStaffRequest({
    required int requestId,
    required String staffId,
  }) {
    return _putStaffRequestAction(
      requestId: requestId,
      staffId: staffId,
      action: 'start',
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
    final uri = Uri.parse(
      '$kSupportBaseUrl/SupportRequests/$requestId/$action/staff/${Uri.encodeComponent(staffId)}',
    );
    final response = await AuthService.instance.sendAuthorized(
      (token) => http.put(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 204) return;
    throw _buildError(response);
  }

  Future<void> cancelRequest({
    required int requestId,
    required String memberId,
    required String reason,
  }) async {
    final uri = Uri.parse(
      '$kSupportBaseUrl/SupportRequests/$requestId/cancel/member/${Uri.encodeComponent(memberId)}',
    );

    final body = jsonEncode({'reason': reason});
    final response = await AuthService.instance.sendAuthorized(
      (token) => http.put(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 204) return;
    throw _buildError(response);
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

    final uri = Uri.parse(
      '$kSupportBaseUrl/SupportRequests/member/${Uri.encodeComponent(memberId)}',
    );

    final response = await AuthService.instance.sendAuthorized(
      (token) => http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(payload),
      ),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw _buildError(response);
    }

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
        ? (location.isRoom == true ? 'room' : 'area')
        : null;

    return <String, dynamic>{
      'area': area.toLowerCase(),
      'categoryId': categoryId,
      'locationType': locationType,
      'buildingId': null,
      'placeType': placeType,
      'roomId': null,
      'areaDetails': location.asDisplayString(),
      'description': description,
      'urgency': urgency == TicketPriority.high ? 'urgent' : 'standard',
      'attachmentUrls': attachmentUrls,
      // Compatibility fallbacks for backend variants.
      'module': area.toUpperCase(),
      'location': location.asDisplayString(),
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

    final uri = Uri.parse('$kSupportBaseUrl/SupportRequests/uploads');
    final request = http.MultipartRequest('POST', uri);

    await AuthService.instance.loadSession();
    final token = AuthService.instance.accessToken;
    if (token == null || token.isEmpty) {
      throw const SupportServiceException(message: 'Authentication required.');
    }
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';
    request.files.add(await http.MultipartFile.fromPath('files', path));

    final streamed = await request.send();
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
    final response = await AuthService.instance.sendAuthorized(
      (token) => http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
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
      }
      final rootDirect = decoded['message'];
      if (rootDirect is String && rootDirect.isNotEmpty) {
        message = rootDirect;
      }
    }
    return SupportServiceException(
        statusCode: response.statusCode, message: message);
  }
}
