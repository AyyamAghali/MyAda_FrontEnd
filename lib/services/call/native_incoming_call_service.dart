import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:incoming_call_kit/incoming_call_kit.dart';

import 'call_api.dart';

typedef NativeCallActionHandler = Future<void> Function(
  Map<String, dynamic> payload,
);

@pragma('vm:entry-point')
Future<void> nativeIncomingCallBackgroundHandler(CallKitEvent event) async {
  // The native plugin queues events until Dart is ready. Foreground handling is
  // wired in [NativeIncomingCallService.initialize].
}

/// iOS CallKit/PushKit bridge used by [CallController].
///
/// SignalR still owns live call signaling while the app is active. PushKit is
/// used to wake iOS and show the same incoming call through the system UI.
class NativeIncomingCallService {
  NativeIncomingCallService._();

  static final NativeIncomingCallService instance =
      NativeIncomingCallService._();

  final IncomingCallKit _callKit = IncomingCallKit.instance;
  final CallApiClient _api = const CallApiClient();
  final Map<String, Map<String, dynamic>> _payloadsByCallId =
      <String, Map<String, dynamic>>{};

  StreamSubscription<CallKitEvent>? _subscription;
  NativeCallActionHandler? _onAccept;
  NativeCallActionHandler? _onDecline;
  NativeCallActionHandler? _onTimeout;
  bool _initialized = false;
  String? _lastRegisteredVoipToken;

  bool get _supportsNativeCalls =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  Future<void> initialize({
    required NativeCallActionHandler onAccept,
    required NativeCallActionHandler onDecline,
    required NativeCallActionHandler onTimeout,
  }) async {
    _onAccept = onAccept;
    _onDecline = onDecline;
    _onTimeout = onTimeout;
    if (!_supportsNativeCalls || _initialized) return;

    _initialized = true;
    IncomingCallKit.registerBackgroundHandler(
      nativeIncomingCallBackgroundHandler,
    );
    _subscription = _callKit.onEvent.listen(_handleEvent);
    unawaited(_registerCurrentVoipToken());
  }

  Future<void> showIncomingCall({
    required String callId,
    required String roomId,
    required String fromUserId,
    required String fromConnectionId,
    required String callerName,
    DateTime? expiresAtUtc,
  }) async {
    if (!_supportsNativeCalls || callId.trim().isEmpty) return;

    final payload = <String, dynamic>{
      'callId': callId,
      'roomId': roomId,
      'fromUserId': fromUserId,
      'fromConnectionId': fromConnectionId,
      'fromDisplayName': callerName,
      if (expiresAtUtc != null)
        'expiresAtUtc': expiresAtUtc.toUtc().toIso8601String(),
    };
    _payloadsByCallId[callId] = payload;

    final duration = expiresAtUtc == null
        ? const Duration(seconds: 30)
        : expiresAtUtc.toUtc().difference(DateTime.now().toUtc());

    await _callKit.show(
      CallKitParams(
        id: callId,
        callerName: callerName.trim().isEmpty ? 'MyADA Support' : callerName,
        callerNumber: 'MyADA',
        type: 0,
        duration:
            duration.inSeconds > 0 ? duration : const Duration(seconds: 30),
        textAccept: 'Accept',
        textDecline: 'Decline',
        extra: payload,
        missedCallNotification: NotificationParams(
          showNotification: true,
          subtitle: 'Missed call from $callerName',
          showCallback: false,
        ),
        ios: const IOSCallKitParams(
          handleType: 'generic',
          supportsVideo: false,
          maximumCallGroups: 1,
          maximumCallsPerCallGroup: 1,
          supportsDTMF: false,
          supportsHolding: false,
        ),
      ),
    );
  }

  Future<void> markConnected(String? callId) async {
    if (!_supportsNativeCalls || callId == null || callId.isEmpty) return;
    try {
      await _callKit.setCallConnected(callId);
    } catch (_) {
      // The native call may already be gone.
    }
  }

  Future<void> dismiss(String? callId) async {
    if (!_supportsNativeCalls) return;
    try {
      if (callId == null || callId.isEmpty) {
        await _callKit.dismissAll();
      } else {
        await _callKit.dismiss(callId);
        _payloadsByCallId.remove(callId);
      }
    } catch (_) {
      // Best effort only; call state is still driven by SignalR/WebRTC.
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    _initialized = false;
    _payloadsByCallId.clear();
  }

  Future<void> _handleEvent(CallKitEvent event) async {
    switch (event.action) {
      case CallKitAction.accept:
        final payload = _payloadFor(event);
        if (payload != null) await _onAccept?.call(payload);
        break;
      case CallKitAction.decline:
        final payload = _payloadFor(event);
        if (payload != null) await _onDecline?.call(payload);
        _payloadsByCallId.remove(event.callId);
        break;
      case CallKitAction.dismissed:
        _payloadsByCallId.remove(event.callId);
        break;
      case CallKitAction.timeout:
        final payload = _payloadFor(event);
        if (payload != null) await _onTimeout?.call(payload);
        _payloadsByCallId.remove(event.callId);
        break;
      case CallKitAction.callConnected:
      case CallKitAction.callEnded:
        _payloadsByCallId.remove(event.callId);
        break;
      case CallKitAction.voipTokenUpdated:
        final token = event.extra?['token']?.toString() ?? '';
        unawaited(_registerVoipToken(token));
        break;
      case CallKitAction.callback:
      case CallKitAction.callStart:
      case CallKitAction.audioSessionActivated:
      case CallKitAction.toggleHold:
      case CallKitAction.toggleMute:
      case CallKitAction.toggleDmtf:
      case CallKitAction.toggleGroup:
        break;
    }
  }

  Map<String, dynamic>? _payloadFor(CallKitEvent event) {
    final fromExtra = event.extra;
    final callId = (fromExtra?['callId'] ?? event.callId).toString();
    if (fromExtra != null && callId.isNotEmpty) {
      final payload = Map<String, dynamic>.from(fromExtra);
      payload['callId'] = callId;
      _payloadsByCallId[callId] = payload;
      return payload;
    }
    return _payloadsByCallId[event.callId] ?? _payloadsByCallId[callId];
  }

  Future<void> _registerCurrentVoipToken() async {
    try {
      final token = await _callKit.getDevicePushTokenVoIP();
      await _registerVoipToken(token);
    } catch (_) {
      // Token may arrive later through the voipTokenUpdated event.
    }
  }

  Future<void> _registerVoipToken(String token) async {
    final trimmed = token.trim();
    if (trimmed.isEmpty || trimmed == _lastRegisteredVoipToken) return;
    try {
      await _api.registerVoipToken(
        token: trimmed,
        platform: 'ios',
        bundleId: 'com.example.adaFront',
      );
      _lastRegisteredVoipToken = trimmed;
    } catch (_) {
      // Backend route may not exist yet; do not block app startup/calls.
    }
  }
}
