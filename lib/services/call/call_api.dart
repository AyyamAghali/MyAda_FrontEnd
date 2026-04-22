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
          username: entry['username'] as String?,
          credential: entry['credential'] as String?,
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
      (token) => http
          .get(
            Uri.parse(kIceServersEndpoint),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15)),
    );
    if (response.statusCode != 200) return null;
    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic>) return null;
    return CallIceConfig.fromJson(body);
  } catch (_) {
    return null;
  }
}
