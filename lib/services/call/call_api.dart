import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../auth_service.dart';

/// Base URL for the call gateway routes (SignalR hub + ICE config endpoint).
/// Must match the auth service gateway host.
const String kCallGatewayBase = 'http://13.60.31.141:5000';

/// Full SignalR hub URL used by [CallSignaling].
const String kCallHubUrl = '$kCallGatewayBase/call/hub';

/// HTTP endpoint that returns short-lived TURN/STUN credentials.
const String kIceServersEndpoint = '$kCallGatewayBase/call/webrtc/ice-servers';

/// REST endpoint for persisted call history.
const String kCallHistoryEndpoint = '$kCallGatewayBase/call/api/call-history';

/// Backend integration point for APNs VoIP tokens.
///
/// Locked/background iOS incoming calls require the backend to send PushKit
/// VoIP pushes to this token. Adjust this path if the backend contract differs.
const String kVoipTokenEndpoint = '$kCallGatewayBase/call/api/devices/voip-token';

enum CallHistoryStatus {
  all(null, 'All'),
  pending('pending', 'Pending'),
  accepted('accepted', 'Accepted'),
  rejected('rejected', 'Rejected'),
  cancelled('cancelled', 'Cancelled'),
  timedOut('timed-out', 'Timed out');

  const CallHistoryStatus(this.apiValue, this.label);

  final String? apiValue;
  final String label;

  static CallHistoryStatus fromApi(Object? value) {
    final raw = value?.toString().trim().toLowerCase();
    for (final status in CallHistoryStatus.values) {
      if (status.apiValue == raw) return status;
    }
    return CallHistoryStatus.pending;
  }
}

class CallApiException implements Exception {
  final int? statusCode;
  final String message;

  const CallApiException({this.statusCode, required this.message});

  @override
  String toString() => message;
}

class CallHistoryPerson {
  final String userId;
  final String displayName;

  const CallHistoryPerson({
    required this.userId,
    required this.displayName,
  });

  factory CallHistoryPerson.fromJson(Map<String, dynamic> json) {
    final id = (json['userId'] ?? '').toString();
    final name = (json['displayName'] ?? '').toString().trim();
    return CallHistoryPerson(
      userId: id,
      displayName: name.isNotEmpty ? name : id,
    );
  }
}

class CallHistoryItem {
  final String callId;
  final String roomId;
  final CallHistoryStatus status;
  final CallHistoryPerson caller;
  final CallHistoryPerson dispatcher;
  final DateTime? requestedAtUtc;
  final DateTime? acceptedAtUtc;
  final DateTime? endedAtUtc;
  final int? durationSeconds;
  final DateTime? resolvedAtUtc;
  final String? resolveReason;
  final String? endReason;

  const CallHistoryItem({
    required this.callId,
    required this.roomId,
    required this.status,
    required this.caller,
    required this.dispatcher,
    this.requestedAtUtc,
    this.acceptedAtUtc,
    this.endedAtUtc,
    this.durationSeconds,
    this.resolvedAtUtc,
    this.resolveReason,
    this.endReason,
  });

  bool get isAccepted => status == CallHistoryStatus.accepted;
  bool get hasFinishedAcceptedCall => isAccepted && endedAtUtc != null;

  factory CallHistoryItem.fromJson(Map<String, dynamic> json) {
    return CallHistoryItem(
      callId: (json['callId'] ?? '').toString(),
      roomId: (json['roomId'] ?? '').toString(),
      status: CallHistoryStatus.fromApi(json['status']),
      caller: CallHistoryPerson.fromJson(_mapValue(json['caller'])),
      dispatcher: CallHistoryPerson.fromJson(_mapValue(json['dispatcher'])),
      requestedAtUtc: _parseUtc(json['requestedAtUtc']),
      acceptedAtUtc: _parseUtc(json['acceptedAtUtc']),
      endedAtUtc: _parseUtc(json['endedAtUtc']),
      durationSeconds: _parseInt(json['durationSeconds']),
      resolvedAtUtc: _parseUtc(json['resolvedAtUtc']),
      resolveReason: _optionalString(json['resolveReason']),
      endReason: _optionalString(json['endReason']),
    );
  }
}

/// Minimal representation of a single ICE server entry.
class CallIceServer {
  final List<String> urls;
  final String? username;
  final String? credential;

  const CallIceServer({
    required this.urls,
    this.username,
    this.credential,
  });

  Map<String, dynamic> toRtcMap() {
    final map = <String, dynamic>{'urls': urls};
    if (username != null && username!.isNotEmpty) {
      map['username'] = username;
    }
    if (credential != null && credential!.isNotEmpty) {
      map['credential'] = credential;
    }
    return map;
  }
}

/// ICE config payload returned by `GET /call/webrtc/ice-servers` and the
/// `Connected` SignalR event.
class CallIceConfig {
  final DateTime? generatedAtUtc;
  final DateTime? expiresAtUtc;
  final List<CallIceServer> iceServers;

  const CallIceConfig({
    this.generatedAtUtc,
    this.expiresAtUtc,
    this.iceServers = const [],
  });

  /// Returns true if we still have valid credentials with at least ~30s of
  /// headroom before expiry.
  bool get isFresh {
    if (iceServers.isEmpty) return false;
    final expiry = expiresAtUtc;
    if (expiry == null) return true;
    return expiry.difference(DateTime.now().toUtc()).inSeconds > 30;
  }

  /// Returns the list shape expected by `createPeerConnection`.
  List<Map<String, dynamic>> toRtcList() =>
      iceServers.map((s) => s.toRtcMap()).toList(growable: false);

  factory CallIceConfig.fromJson(Map<String, dynamic> json) {
    final rawServers = json['iceServers'];
    final servers = <CallIceServer>[];
    if (rawServers is List) {
      for (final entry in rawServers) {
        if (entry is! Map) continue;
        final rawUrls = entry['urls'];
        final urls = <String>[];
        if (rawUrls is String) {
          urls.add(rawUrls);
        } else if (rawUrls is List) {
          for (final u in rawUrls) {
            if (u is String && u.isNotEmpty) urls.add(u);
          }
        }
        if (urls.isEmpty) continue;
        servers.add(CallIceServer(
          urls: urls,
          username: _optionalString(entry['username']),
          credential: _optionalString(entry['credential']),
        ));
      }
    }

    DateTime? parseUtc(Object? value) {
      if (value is! String || value.isEmpty) return null;
      try {
        return DateTime.parse(value).toUtc();
      } catch (_) {
        return null;
      }
    }

    return CallIceConfig(
      generatedAtUtc: parseUtc(json['generatedAtUtc']),
      expiresAtUtc: parseUtc(json['expiresAtUtc']),
      iceServers: servers,
    );
  }
}

/// Fetches ICE server configuration over HTTPS using the current access token.
///
/// Used as a fallback when the SignalR `Connected` event does not carry an
/// `iceConfiguration` (or when cached credentials are about to expire).
/// Piggy-backs on [AuthService.sendAuthorized] so that an expired access
/// token is transparently refreshed and the request retried.
Future<CallIceConfig?> fetchIceConfiguration() async {
  try {
    final response = await AuthService.instance.sendAuthorized(
      (token) => http.get(
        Uri.parse(kIceServersEndpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15)),
    );
    if (response.statusCode != 200) return null;
    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic>) return null;
    return CallIceConfig.fromJson(body);
  } catch (_) {
    return null;
  }
}

class CallApiClient {
  const CallApiClient();

  Future<void> registerVoipToken({
    required String token,
    required String platform,
    String? bundleId,
  }) async {
    final trimmed = token.trim();
    if (trimmed.isEmpty) return;

    final response = await _authorizedPost(
      Uri.parse(kVoipTokenEndpoint),
      body: <String, dynamic>{
        'token': trimmed,
        'platform': platform,
        'provider': 'apns-voip',
        if (bundleId != null && bundleId.trim().isNotEmpty)
          'bundleId': bundleId.trim(),
      },
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _buildError(response);
    }
  }

  Future<List<CallHistoryItem>> fetchCallHistory({
    CallHistoryStatus status = CallHistoryStatus.all,
    int limit = 50,
  }) async {
    final params = <String, String>{
      'limit': limit.clamp(1, 200).toString(),
    };
    final apiStatus = status.apiValue;
    if (apiStatus != null) params['status'] = apiStatus;

    final response = await _authorizedGet(
      Uri.parse(kCallHistoryEndpoint).replace(queryParameters: params),
    );
    final decoded = _decode(response.body);
    final rawList = _unwrapList(decoded);
    return rawList
        .whereType<Map<String, dynamic>>()
        .map(CallHistoryItem.fromJson)
        .where((item) => item.callId.isNotEmpty)
        .toList(growable: false);
  }

  Future<CallHistoryItem> fetchCallHistoryItem(String callId) async {
    final trimmed = callId.trim();
    if (trimmed.isEmpty) {
      throw const CallApiException(message: 'Call id is required.');
    }

    final response = await _authorizedGet(
      Uri.parse('$kCallHistoryEndpoint/${Uri.encodeComponent(trimmed)}'),
    );
    final map = _unwrapMap(_decode(response.body));
    final item = CallHistoryItem.fromJson(map);
    if (item.callId.isEmpty) {
      throw const CallApiException(
          message: 'Call history response is invalid.');
    }
    return item;
  }

  Future<http.Response> _authorizedGet(Uri uri) async {
    final response = await AuthService.instance.sendAuthorized(
      (token) => http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15)),
    );
    if (response.statusCode != 200) throw _buildError(response);
    return response;
  }

  Future<http.Response> _authorizedPost(
    Uri uri, {
    required Map<String, dynamic> body,
  }) async {
    return AuthService.instance.sendAuthorized(
      (token) => http
          .post(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15)),
    );
  }
}

Map<String, dynamic> _mapValue(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.cast<String, dynamic>();
  return const {};
}

DateTime? _parseUtc(Object? value) {
  final raw = value?.toString();
  if (raw == null || raw.isEmpty) return null;
  return DateTime.tryParse(raw)?.toUtc();
}

int? _parseInt(Object? value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '');
}

String? _optionalString(Object? value) {
  final raw = value?.toString().trim();
  return raw == null || raw.isEmpty ? null : raw;
}

Object? _decode(String body) {
  if (body.trim().isEmpty) return null;
  try {
    return jsonDecode(body);
  } catch (_) {
    return null;
  }
}

List<dynamic> _unwrapList(Object? decoded) {
  if (decoded is List) return decoded;
  if (decoded is Map<String, dynamic>) {
    final root = _unwrapRoot(decoded);
    if (root is List) return root;
    if (root is Map<String, dynamic>) {
      for (final key in const ['items', 'results', 'data', 'value', 'calls']) {
        final value = root[key];
        if (value is List) return value;
      }
    }
  }
  return const [];
}

Map<String, dynamic> _unwrapMap(Object? decoded) {
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

CallApiException _buildError(http.Response response) {
  final decoded = _decode(response.body);
  var message = 'Call request failed (${response.statusCode}).';
  if (decoded is Map<String, dynamic>) {
    final root = _unwrapRoot(decoded);
    if (root is Map<String, dynamic>) {
      final direct = root['message'] ?? root['title'] ?? root['detail'];
      if (direct is String && direct.trim().isNotEmpty) {
        message = direct.trim();
      }
    }
    final rootDirect = decoded['message'];
    if (rootDirect is String && rootDirect.trim().isNotEmpty) {
      message = rootDirect.trim();
    }
  }
  return CallApiException(statusCode: response.statusCode, message: message);
}
