import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/app_notification.dart';
import 'auth_service.dart';

const String kNotificationProductionBase = 'https://myada.site/notification';
const String kNotificationLocalGatewayBase = 'http://localhost:5000/notification';
const String kNotificationApiBase = kNotificationProductionBase;
const String kNotificationHubUrl =
    '$kNotificationProductionBase/hubs/notifications';

class NotificationApiService {
  const NotificationApiService();

  Future<List<AppNotification>> fetchMyNotifications() async {
    final response = await _authorizedGet(
      Uri.parse('$kNotificationApiBase/api/v1/notifications/me'),
    );
    _throwIfFailed(response);
    return _unwrapList(_decode(response.body))
        .map(AppNotification.fromJson)
        .where((n) => n.id.isNotEmpty)
        .toList(growable: false);
  }

  Future<List<AppNotification>> fetchNotifications() async {
    final response = await _authorizedGet(
      Uri.parse('$kNotificationApiBase/api/v1/notifications'),
    );
    _throwIfFailed(response);
    return _unwrapList(_decode(response.body))
        .map(AppNotification.fromJson)
        .where((n) => n.id.isNotEmpty)
        .toList(growable: false);
  }

  Future<AppNotification?> fetchNotification(String id) async {
    final trimmed = id.trim();
    if (trimmed.isEmpty) return null;
    final response = await _authorizedGet(
      Uri.parse(
        '$kNotificationApiBase/api/v1/notifications/${Uri.encodeComponent(trimmed)}',
      ),
    );
    _throwIfFailed(response);
    final map = _unwrapMap(_decode(response.body));
    if (map.isEmpty) return null;
    return AppNotification.fromJson(map);
  }

  Future<void> deleteNotification(String id) async {
    final trimmed = id.trim();
    if (trimmed.isEmpty) return;
    final response = await AuthService.instance.sendAuthorized(
      (token) => http.delete(
        Uri.parse(
          '$kNotificationApiBase/api/v1/notifications/${Uri.encodeComponent(trimmed)}',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ),
    );
    _throwIfFailed(response);
  }

  Future<void> sendEmailNotification({
    required String recipientUserId,
    required String message,
    String? type,
  }) async {
    final response = await AuthService.instance.sendAuthorized(
      (token) => http.post(
        Uri.parse('$kNotificationApiBase/api/v1/notifications/email'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'recipientUserId': recipientUserId,
          'message': message,
          if (type != null && type.trim().isNotEmpty) 'type': type.trim(),
        }),
      ),
    );
    _throwIfFailed(response);
  }

  Future<http.Response> _authorizedGet(Uri uri) {
    return AuthService.instance.sendAuthorized(
      (token) => http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ),
    );
  }

  void _throwIfFailed(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    throw Exception(_extractMessage(response.body) ??
        'Notification request failed (${response.statusCode}).');
  }

  Object? _decode(String body) {
    if (body.trim().isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  List<Map<String, dynamic>> _unwrapList(Object? decoded) {
    if (decoded is List) return decoded.whereType<Map<String, dynamic>>().toList();
    if (decoded is Map<String, dynamic>) {
      final root = decoded['result'] ?? decoded['data'] ?? decoded;
      if (root is List) return root.whereType<Map<String, dynamic>>().toList();
      if (root is Map<String, dynamic>) {
        for (final key in const ['items', 'results', 'notifications', 'data']) {
          final value = root[key];
          if (value is List) {
            return value.whereType<Map<String, dynamic>>().toList();
          }
        }
      }
    }
    return const [];
  }

  Map<String, dynamic> _unwrapMap(Object? decoded) {
    if (decoded is! Map<String, dynamic>) return const {};
    final root = decoded['result'] ?? decoded['data'] ?? decoded['item'] ?? decoded;
    if (root is Map<String, dynamic>) return root;
    return decoded;
  }

  String? _extractMessage(String body) {
    final decoded = _decode(body);
    if (decoded is! Map<String, dynamic>) return null;
    final root = _unwrapMap(decoded);
    final message = root['message'] ?? root['title'] ?? root['detail'];
    final text = message?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}
