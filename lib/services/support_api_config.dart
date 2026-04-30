import 'dart:async';

import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:http/http.dart' as http;

/// Support API config aligned with:
/// "Support (Dispatcher + Staff) — Mobile Developer Documentation".
///
/// Support REST base candidates (in order):
/// - `${AUTH_API_BASE}/support/api` (preferred in web)
/// - `http://localhost:5000/support/api`
/// - `http://127.0.0.1:5000/support/api`
/// - `http://localhost:5008/api`
///
/// Mobile app doesn't have Vite env vars, so we keep a small candidate list
/// and let the service layer retry across bases on network/gateway/404.
class SupportApiConfig {
  SupportApiConfig._();

  /// Default gateway base URL.
  ///
  /// Note: the gateway host may answer on `/`, but Support REST endpoints are
  /// served under `/support/api`.
  static const String gatewayBaseUrl = 'http://13.60.31.141:5000/support/api';

  /// Local gateway (for local dev / emulator).
  static const String localGatewayBaseUrl = 'http://localhost:5000/support/api';

  /// Local gateway (IPv4 loopback).
  static const String localGatewayBaseUrlIpv4 = 'http://127.0.0.1:5000/support/api';

  /// Local direct service base (optional).
  static const String localDirectBaseUrl = 'http://localhost:5008/api';

  static String? _baseUrlOverride;
  static String? _resolvedBaseUrl;
  static Future<void>? _initFuture;

  /// Optional manual override (e.g. to force local gateway).
  static void setBaseUrlOverride(String? url) {
    _baseUrlOverride = url?.trim().isEmpty == true ? null : url?.trim();
    _resolvedBaseUrl = null;
    _initFuture = null;
  }

  static String get baseUrl =>
      _resolvedBaseUrl ?? (_baseUrlOverride ?? gatewayBaseUrl);

  /// Ordered list of base URL candidates to try.
  static List<String> get baseUrlCandidates {
    final override = _baseUrlOverride;
    final resolved = _resolvedBaseUrl;
    final items = <String>[
      if (override != null) override,
      if (resolved != null && resolved != override) resolved,
      gatewayBaseUrl,
      localGatewayBaseUrl,
      localGatewayBaseUrlIpv4,
      localDirectBaseUrl,
    ];
    // Deduplicate while preserving order.
    final seen = <String>{};
    return [
      for (final s in items)
        if (seen.add(s)) s,
    ];
  }

  /// Ensures [baseUrl] is reachable. If not reachable, falls back to a known
  /// reachable host in dev builds, while keeping production pointed at the
  /// documented gateway.
  static Future<void> ensureInitialized({
    Duration timeout = const Duration(seconds: 2),
  }) async {
    final inflight = _initFuture;
    if (inflight != null) return inflight;

    final work = _ensureInitializedInternal(timeout: timeout);
    _initFuture = work;
    try {
      await work;
    } finally {
      if (_initFuture == work) _initFuture = null;
    }
  }

  static Future<void> _ensureInitializedInternal({
    required Duration timeout,
  }) async {
    final override = _baseUrlOverride;
    if (override != null) {
      _resolvedBaseUrl = override;
      return;
    }

    // In release we keep the documented gateway URL; network issues should be handled by retry UX.
    if (kReleaseMode) {
      _resolvedBaseUrl = gatewayBaseUrl;
      return;
    }

    // In debug/profile, auto-select the first reachable candidate.
    final candidates = <String>[
      gatewayBaseUrl,
      localGatewayBaseUrl,
      localGatewayBaseUrlIpv4,
      localDirectBaseUrl,
    ];

    for (final candidate in candidates) {
      final ok = await _probe(candidate, timeout: timeout);
      if (ok) {
        _resolvedBaseUrl = candidate;
        return;
      }
    }

    // If everything fails, keep the documented gateway.
    _resolvedBaseUrl = gatewayBaseUrl;
  }

  static Future<bool> _probe(String baseUrl, {required Duration timeout}) async {
    try {
      final uri = Uri.parse('$baseUrl/Categories');
      final res = await http.get(uri, headers: const {'Accept': 'application/json'}).timeout(timeout);
      // 401 is expected without token, and confirms routing is alive.
      return res.statusCode == 401 || res.statusCode == 200 || res.statusCode == 403;
    } catch (_) {
      return false;
    }
  }
}

