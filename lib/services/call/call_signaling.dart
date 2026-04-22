import 'dart:async';

import 'package:signalr_netcore/signalr_client.dart';

import '../auth_service.dart';
import 'call_api.dart';

/// Thin wrapper around the SignalR hub client that owns a single connection
/// for the app lifetime and exposes typed `invoke` helpers for the call hub
/// methods documented in `CALL_API_DOC.md`.
class CallSignaling {
  HubConnection? _connection;
  Future<void>? _connectInFlight;
  final Map<String, List<void Function(List<Object?>?)>> _listeners = {};

  bool get isConnected =>
      _connection?.state == HubConnectionState.Connected;

  String? get connectionId => _connection?.connectionId;

  /// Registers a persistent event handler. Handlers registered through this
  /// method survive reconnect/rebuild of the underlying connection because
  /// they are replayed whenever [_attachListeners] runs.
  void on(String event, void Function(List<Object?>? args) handler) {
    _listeners.putIfAbsent(event, () => <void Function(List<Object?>?)>[])
        .add(handler);
    _connection?.on(event, handler);
  }

  /// Removes all listeners for a given event name. Rarely needed because the
  /// controller owns the signaling object for the app lifetime.
  void off(String event) {
    _listeners.remove(event);
    _connection?.off(event);
  }

  /// Opens (or re-uses) a SignalR connection to the call hub. Requires a
  /// valid access token; throws otherwise.
  Future<void> connect() async {
    if (isConnected) return;
    if (_connectInFlight != null) return _connectInFlight;

    _connectInFlight = _doConnect().whenComplete(() {
      _connectInFlight = null;
    });
    return _connectInFlight;
  }

  Future<void> _doConnect() async {
    await AuthService.instance.loadSession();
    final token = AuthService.instance.accessToken;
    if (token == null || token.isEmpty) {
      throw StateError('Cannot connect to call hub: missing access token.');
    }

    // Reuse the current connection instance when possible to preserve the
    // registered listeners. If the previous connection is in a non-recoverable
    // state we rebuild it from scratch.
    final existing = _connection;
    if (existing != null &&
        existing.state != HubConnectionState.Disconnected) {
      await existing.stop();
    }

    final connection = HubConnectionBuilder()
        .withUrl(
          kCallHubUrl,
          options: HttpConnectionOptions(
            accessTokenFactory: () async =>
                AuthService.instance.accessToken ?? '',
            // The signalr_netcore default is 2 seconds, which throws
            // `TimeoutException ... Future not completed` on slow mobile
            // links before the hub can even finish the handshake.
            requestTimeout: 20000,
          ),
        )
        .withAutomaticReconnect()
        .build();

    // Keep alive / server timeout tuned for mobile.
    connection.serverTimeoutInMilliseconds = 60000;
    connection.keepAliveIntervalInMilliseconds = 15000;

    _connection = connection;
    _attachListeners();

    await connection.start();
  }

  /// Stops the hub connection and clears state. Safe to call multiple times.
  Future<void> disconnect() async {
    final current = _connection;
    _connection = null;
    if (current == null) return;
    try {
      await current.stop();
    } catch (_) {
      // ignore shutdown errors
    }
  }

  /// Invokes a hub method. Throws [StateError] if called before [connect].
  Future<Object?> invoke(String method, {List<Object?>? args}) {
    final conn = _connection;
    if (conn == null || conn.state != HubConnectionState.Connected) {
      throw StateError('Call hub is not connected.');
    }
    final List<Object>? nonNullArgs =
        args?.map<Object>((e) => e ?? '').toList(growable: false);
    return conn.invoke(method, args: nonNullArgs);
  }

  void _attachListeners() {
    final conn = _connection;
    if (conn == null) return;
    _listeners.forEach((event, handlers) {
      for (final h in handlers) {
        conn.on(event, h);
      }
    });
  }
}
