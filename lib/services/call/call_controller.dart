import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';

import '../auth_service.dart';
import 'call_api.dart';
import 'call_history_controller.dart';
import 'call_signaling.dart';

/// High-level state of the in-app voice call feature. Mirrors the phases used
/// by the web client so the UI can react in the same way on all platforms.
enum CallPhase {
  idle,
  connecting,
  connected,
  /// Outbound: invite sent, waiting for server `CallRinging`.
  calling,
  ringing,
  incoming,
  accepted,
  inCall,
  ended,
  rejected,
  cancelled,
  timeout,
  error,
}

class CallParticipant {
  final String connectionId;
  final String? userId;
  final String? displayName;

  const CallParticipant({
    required this.connectionId,
    this.userId,
    this.displayName,
  });

  factory CallParticipant.fromMap(Map map) => CallParticipant(
        connectionId: map['connectionId']?.toString() ?? '',
        userId: map['userId']?.toString(),
        displayName: map['displayName']?.toString(),
      );
}

class IncomingCallInfo {
  final String callId;
  final String roomId;
  final String fromUserId;
  final String fromConnectionId;
  final String? fromDisplayName;
  final DateTime? expiresAtUtc;

  const IncomingCallInfo({
    required this.callId,
    required this.roomId,
    required this.fromUserId,
    required this.fromConnectionId,
    this.fromDisplayName,
    this.expiresAtUtc,
  });

  factory IncomingCallInfo.fromMap(Map map) {
    DateTime? parse(Object? v) {
      if (v is! String || v.isEmpty) return null;
      try {
        return DateTime.parse(v).toUtc();
      } catch (_) {
        return null;
      }
    }

    return IncomingCallInfo(
      callId: map['callId']?.toString() ?? '',
      roomId: map['roomId']?.toString() ?? '',
      fromUserId: map['fromUserId']?.toString() ?? '',
      fromConnectionId: map['fromConnectionId']?.toString() ?? '',
      fromDisplayName: map['fromDisplayName']?.toString(),
      expiresAtUtc: parse(map['expiresAtUtc']),
    );
  }
}

/// Singleton [ChangeNotifier] that owns SignalR signaling + a single WebRTC
/// peer connection for the active call, and exposes a small action surface to
/// the UI.
class CallController extends ChangeNotifier {
  CallController._();

  static final CallController instance = CallController._();

  final CallSignaling _signaling = CallSignaling();

  CallPhase _phase = CallPhase.idle;
  String? _errorMessage;
  String? _selfConnectionId;
  String? _selfUserId;
  String? _selfDisplayName;

  IncomingCallInfo? _incomingCall;
  String? _callId;
  String? _roomId;
  CallParticipant? _peer;

  CallIceConfig? _cachedIceConfig;
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  bool _isMuted = false;
  bool _isSpeakerOn = false;
  DateTime? _callStartedAt;
  Timer? _durationTicker;
  Duration _callDuration = Duration.zero;

  DateTime? _connectingStartedAt;
  Timer? _connectingTicker;
  Duration _connectingDuration = Duration.zero;

  bool _listenersAttached = false;
  /// Created only when a ringtone is needed; avoids [MissingPluginException]
  /// on app start / hot restart when the native audioplayers bridge is not ready.
  AudioPlayer? _ringPlayer;
  bool _ringtoneActive = false;
  bool _localAudioEnsureInFlight = false;
  Timer? _outboundNoAnswerTimer;
  bool _pendingNoDispatcherAvailableDialog = false;

  static const Duration _outboundNoAnswerLimit = Duration(seconds: 20);

  // ---- Public getters -------------------------------------------------------

  CallPhase get phase => _phase;
  String? get errorMessage => _errorMessage;
  IncomingCallInfo? get incomingCall => _incomingCall;
  String? get callId => _callId;
  String? get roomId => _roomId;
  CallParticipant? get peer => _peer;
  MediaStream? get localStream => _localStream;
  MediaStream? get remoteStream => _remoteStream;
  bool get isMuted => _isMuted;
  bool get isSpeakerOn => _isSpeakerOn;
  Duration get callDuration => _callDuration;
  Duration get connectingDuration => _connectingDuration;
  bool get isHubConnected => _signaling.isConnected;

  /// One-shot: UI shows "no dispatcher" popup when this returns true once.
  bool consumeNoDispatcherAvailableDialog() {
    if (!_pendingNoDispatcherAvailableDialog) return false;
    _pendingNoDispatcherAvailableDialog = false;
    return true;
  }

  static String? _mergeDisplayName(String? a, String? b) {
    for (final s in [a, b]) {
      final t = s?.trim();
      if (t != null && t.isNotEmpty) return t;
    }
    return null;
  }

  /// True if an incoming call modal should be shown over any screen.
  bool get shouldShowIncoming =>
      _incomingCall != null &&
      _phase != CallPhase.inCall &&
      _phase != CallPhase.accepted;

  /// True if the active call overlay (mute / speaker / hang-up) should be
  /// shown over any screen.
  bool get shouldShowActiveCall =>
      _phase == CallPhase.calling ||
      _phase == CallPhase.ringing ||
      _phase == CallPhase.accepted ||
      _phase == CallPhase.inCall;

  // ---- Lifecycle ------------------------------------------------------------

  /// Opens the SignalR connection. Safe to call every time the user lands on
  /// an authenticated screen; it is a no-op when already connected.
  Future<void> connect() async {
    if (_signaling.isConnected) return;
    _setPhase(CallPhase.connecting);
    _errorMessage = null;
    try {
      _attachListenersOnce();
      await _signaling.connect();
      _selfConnectionId = _signaling.connectionId;
      if (_phase == CallPhase.connecting) {
        _setPhase(CallPhase.connected);
      }
    } catch (err) {
      _setError('Could not connect to call service: ${_stringify(err)}');
      rethrow;
    }
  }

  /// Stops the hub and tears down any in-flight call. Called on logout.
  Future<void> disconnect() async {
    _cancelOutboundNoAnswerTimer();
    _pendingNoDispatcherAvailableDialog = false;
    await _cleanupPeer();
    await _disposeRingPlayer();
    await _signaling.disconnect();
    _incomingCall = null;
    _callId = null;
    _roomId = null;
    _peer = null;
    _selfConnectionId = null;
    _cachedIceConfig = null;
    _setPhase(CallPhase.idle);
  }

  // ---- Actions --------------------------------------------------------------

  /// Starts an outbound call to the given dispatcher (their JWT `sub`).
  Future<void> requestCall(
    String dispatcherUserId, {
    String? dispatcherDisplayName,
  }) async {
    final trimmed = dispatcherUserId.trim();
    if (trimmed.isEmpty) {
      _setError('Please provide the dispatcher user id.');
      return;
    }
    try {
      await _ensureMicrophonePermission();
      await connect();
      _peer = CallParticipant(
        connectionId: '',
        userId: trimmed,
        displayName: _mergeDisplayName(dispatcherDisplayName, null) ?? trimmed,
      );
      _setPhase(CallPhase.calling);
      _startOutboundNoAnswerTimer();
      unawaited(ensureLocalAudioForControls());
      await _signaling.invoke('RequestCall', args: [trimmed]);
    } catch (err) {
      _cancelOutboundNoAnswerTimer();
      await _cleanupPeer();
      _clearCallIdentity();
      _setError(_stringify(err));
    }
  }

  /// Dispatcher-side accept for an incoming call.
  Future<void> acceptIncomingCall() async {
    final info = _incomingCall;
    if (info == null) return;
    try {
      await _ensureMicrophonePermission();
      await connect();
      // Activate microphone immediately so we have a track ready when the
      // peer sends its offer.
      await _ensurePeerConnection();
      await _signaling.invoke('AcceptCall', args: [info.callId]);
      _incomingCall = null;
      _setPhase(CallPhase.accepted);
    } catch (err) {
      _setError(_stringify(err));
    }
  }

  /// Dispatcher-side reject for an incoming call.
  Future<void> rejectIncomingCall({String? reason}) async {
    final info = _incomingCall;
    if (info == null) return;
    try {
      await _signaling.invoke('RejectCall', args: [info.callId, reason]);
    } catch (err) {
      _setError(_stringify(err));
    } finally {
      _incomingCall = null;
      _clearCallIdentity();
      _setPhase(CallPhase.connected);
    }
  }

  /// Caller-side cancel of a pending outbound call (before it is accepted).
  Future<void> cancelOutgoingCall({
    String? reason,
    bool showNoDispatcherAvailable = false,
  }) async {
    final id = _callId;
    try {
      if (id != null) {
        await _signaling.invoke('CancelCall', args: [id, reason]);
      }
    } catch (err) {
      _setError(_stringify(err));
    } finally {
      if (showNoDispatcherAvailable) {
        _pendingNoDispatcherAvailableDialog = true;
      }
      _clearCallIdentity();
      _setPhase(CallPhase.connected);
    }
  }

  /// Ends the active call for every participant in the room.
  Future<void> endCall() async {
    try {
      if (_signaling.isConnected) {
        await _signaling.invoke('EndCall');
      }
    } catch (_) {
      // ignore; we still tear down locally
    }
    _errorMessage = 'Call ended.';
    await _cleanupPeer();
    _clearCallIdentity();
    CallHistoryController.instance.refreshAfterRealtimeEvent();
    _setPhase(CallPhase.ended);
  }

  /// Toggles the mute state of the local microphone track.
  void toggleMute() {
    _isMuted = !_isMuted;
    _applyMuteToLocalTracks();
    notifyListeners();
  }

  /// Toggles the device loudspeaker (earpiece vs speakerphone).
  Future<void> toggleSpeaker() async {
    _isSpeakerOn = !_isSpeakerOn;
    try {
      await Helper.setSpeakerphoneOn(_isSpeakerOn);
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await Future<void>.delayed(const Duration(milliseconds: 90));
        await Helper.setSpeakerphoneOn(_isSpeakerOn);
      }
    } catch (_) {
      // ignore on platforms that do not support audio routing
    }
    notifyListeners();
  }

  /// Ensures a local microphone stream exists so mute works while ringing and
  /// before the peer connection is created.
  Future<void> ensureLocalAudioForControls() async {
    if (_localStream != null && _localStream!.getAudioTracks().isNotEmpty) {
      _applyMuteToLocalTracks();
      notifyListeners();
      return;
    }
    if (_localAudioEnsureInFlight) return;
    _localAudioEnsureInFlight = true;
    try {
      await _ensureMicrophonePermission();
      final local = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': false,
      });
      _localStream = local;
      _applyMuteToLocalTracks();
      notifyListeners();
    } catch (_) {
      // Ringing may start before permission is granted; ignore here.
    } finally {
      _localAudioEnsureInFlight = false;
    }
  }

  void _applyMuteToLocalTracks() {
    final stream = _localStream;
    if (stream == null) return;
    for (final track in stream.getAudioTracks()) {
      track.enabled = !_isMuted;
    }
  }

  void _startConnectingTicker() {
    _connectingTicker?.cancel();
    _connectingStartedAt = DateTime.now();
    _connectingDuration = Duration.zero;
    _connectingTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      final started = _connectingStartedAt;
      if (started == null) return;
      _connectingDuration = DateTime.now().difference(started);
      notifyListeners();
    });
  }

  void _stopConnectingTicker() {
    _connectingTicker?.cancel();
    _connectingTicker = null;
    _connectingStartedAt = null;
    _connectingDuration = Duration.zero;
  }

  // ---- Internals ------------------------------------------------------------

  void _attachListenersOnce() {
    if (_listenersAttached) return;
    _listenersAttached = true;

    _signaling.on('Connected', (args) {
      final payload = _firstMap(args);
      if (payload == null) return;
      _selfConnectionId = payload['connectionId']?.toString();
      _selfUserId = payload['userId']?.toString();
      _selfDisplayName = payload['displayName']?.toString();
      final iceJson = payload['iceConfiguration'];
      if (iceJson is Map<String, dynamic>) {
        _cachedIceConfig = CallIceConfig.fromJson(iceJson);
      } else if (iceJson is Map) {
        _cachedIceConfig = CallIceConfig.fromJson(
          iceJson.cast<String, dynamic>(),
        );
      }
      _setPhase(CallPhase.connected);
    });

    _signaling.on('IncomingCall', (args) {
      final payload = _firstMap(args);
      if (payload == null) return;
      _incomingCall = IncomingCallInfo.fromMap(payload);
      _callId = _incomingCall?.callId;
      _roomId = _incomingCall?.roomId;
      _setPhase(CallPhase.incoming);
      unawaited(ensureLocalAudioForControls());
    });

    _signaling.on('CallRinging', (args) {
      final payload = _firstMap(args);
      if (payload == null) return;
      _callId = payload['callId']?.toString();
      _roomId = payload['roomId']?.toString();
      final existing = _peer;
      final uid = payload['dispatcherUserId']?.toString() ??
          payload['toUserId']?.toString() ??
          existing?.userId ??
          '';
      final fromPayload = payload['dispatcherDisplayName']?.toString() ??
          payload['toDisplayName']?.toString();
      _peer = CallParticipant(
        connectionId: existing?.connectionId ?? '',
        userId: uid.isNotEmpty ? uid : existing?.userId,
        displayName: _mergeDisplayName(fromPayload, existing?.displayName) ??
            (uid.isNotEmpty ? uid : existing?.userId),
      );
      _setPhase(CallPhase.ringing);
      unawaited(ensureLocalAudioForControls());
    });

    _signaling.on('CallAccepted', (args) {
      final payload = _firstMap(args);
      if (payload == null) return;
      _cancelOutboundNoAnswerTimer();
      _callId = payload['callId']?.toString();
      _roomId = payload['roomId']?.toString();

      final acceptedBy = payload['acceptedByConnectionId']?.toString();
      final self = _selfConnectionId;

      String? peerConnectionId;
      if (acceptedBy != null && acceptedBy != self && acceptedBy.isNotEmpty) {
        peerConnectionId = acceptedBy;
      } else {
        final parts = payload['participants'];
        if (parts is List) {
          for (final p in parts) {
            if (p is Map) {
              final cid = p['connectionId']?.toString();
              if (cid != null && cid.isNotEmpty && cid != self) {
                peerConnectionId = cid;
                break;
              }
            }
          }
        }
      }
      if (peerConnectionId != null) {
        final existing = _peer;
        CallParticipant? acceptedPeer;
        final parts = payload['participants'];
        if (parts is List) {
          for (final p in parts) {
            if (p is Map) {
              final participant = CallParticipant.fromMap(p);
              if (participant.connectionId == peerConnectionId) {
                acceptedPeer = participant;
                break;
              }
            }
          }
        }
        _peer = CallParticipant(
          connectionId: peerConnectionId,
          userId: acceptedPeer?.userId ?? existing?.userId,
          displayName: _mergeDisplayName(
                acceptedPeer?.displayName,
                existing?.displayName,
              ) ??
              acceptedPeer?.userId ??
              existing?.userId,
        );
      }
      CallHistoryController.instance.refreshAfterRealtimeEvent();
      _setPhase(CallPhase.accepted);
    });

    _signaling.on('CallRejected', (args) {
      final payload = _firstMap(args);
      final reason = payload?['reason']?.toString().trim();
      _errorMessage = reason != null && reason.isNotEmpty
          ? reason
          : 'Call rejected by dispatcher.';
      _setPhase(CallPhase.rejected);
      unawaited(() async {
        await _cleanupPeer();
        _clearCallIdentity();
        CallHistoryController.instance.refreshAfterRealtimeEvent();
      }());
    });

    _signaling.on('CallCancelled', (args) async {
      final payload = _firstMap(args);
      final reason = payload?['reason']?.toString().trim();
      _errorMessage = reason != null && reason.isNotEmpty
          ? reason
          : 'The call was cancelled.';
      await _cleanupPeer();
      _clearCallIdentity();
      CallHistoryController.instance.refreshAfterRealtimeEvent();
      _setPhase(CallPhase.cancelled);
    });

    _signaling.on('CallTimedOut', (args) async {
      final payload = _firstMap(args);
      final reason = payload?['reason']?.toString().trim();
      _errorMessage = reason != null && reason.isNotEmpty
          ? reason
          : 'No dispatcher response before timeout.';
      await _cleanupPeer();
      _clearCallIdentity();
      CallHistoryController.instance.refreshAfterRealtimeEvent();
      _setPhase(CallPhase.timeout);
    });

    _signaling.on('JoinedRoom', (args) async {
      final payload = _firstMap(args);
      if (payload == null) return;
      _roomId = payload['roomId']?.toString();
      final others = payload['otherParticipants'];
      CallParticipant? peer;
      if (others is List && others.isNotEmpty) {
        final first = others.first;
        if (first is Map) peer = CallParticipant.fromMap(first);
      }
      if (peer != null) {
        final existing = _peer;
        _peer = CallParticipant(
          connectionId: peer.connectionId,
          userId: peer.userId ?? existing?.userId,
          displayName: _mergeDisplayName(peer.displayName, existing?.displayName) ??
              peer.userId ??
              existing?.userId,
        );
      }
      _setPhase(CallPhase.inCall);
      _startDurationTicker();

      // Deterministic offerer selection so only one side creates the offer.
      final self = _selfConnectionId;
      final peerId = peer?.connectionId;
      if (peerId != null && self != null && self.compareTo(peerId) < 0) {
        await _createAndSendOffer(peerId);
      }
    });

    _signaling.on('ParticipantLeft', (args) async {
      final payload = _firstMap(args);
      final name = payload?['displayName']?.toString().trim();
      _errorMessage = name != null && name.isNotEmpty
          ? '$name left or disconnected.'
          : 'The other participant left or disconnected.';
      await _cleanupPeer();
      _clearCallIdentity();
      CallHistoryController.instance.refreshAfterRealtimeEvent();
      _setPhase(CallPhase.ended);
    });

    _signaling.on('LeftRoom', (_) async {
      await _cleanupPeer();
      _clearCallIdentity();
      _setPhase(CallPhase.connected);
    });

    _signaling.on('CallEnded', (_) async {
      _errorMessage = 'Call ended.';
      await _cleanupPeer();
      _clearCallIdentity();
      CallHistoryController.instance.refreshAfterRealtimeEvent();
      _setPhase(CallPhase.ended);
    });

    _signaling.on('ReceiveOffer', (args) async {
      final payload = _firstMap(args);
      if (payload == null) return;
      final fromConnectionId = payload['fromConnectionId']?.toString();
      final sdp = payload['sdp']?.toString();
      if (fromConnectionId == null || sdp == null) return;
      final keep = _peer;
      _peer = CallParticipant(
        connectionId: fromConnectionId,
        userId: keep?.userId,
        displayName: keep?.displayName,
      );
      try {
        final pc = await _ensurePeerConnection();
        await pc.setRemoteDescription(RTCSessionDescription(sdp, 'offer'));
        final answer = await pc.createAnswer();
        await pc.setLocalDescription(answer);
        await _signaling.invoke(
          'SendAnswer',
          args: [fromConnectionId, answer.sdp ?? ''],
        );
      } catch (err) {
        _setError('Failed to answer call: ${_stringify(err)}');
      }
    });

    _signaling.on('ReceiveAnswer', (args) async {
      final payload = _firstMap(args);
      if (payload == null) return;
      final sdp = payload['sdp']?.toString();
      if (sdp == null) return;
      try {
        final pc = await _ensurePeerConnection();
        await pc.setRemoteDescription(RTCSessionDescription(sdp, 'answer'));
      } catch (err) {
        _setError('Failed to finalize call: ${_stringify(err)}');
      }
    });

    _signaling.on('ReceiveIceCandidate', (args) async {
      final payload = _firstMap(args);
      if (payload == null) return;
      final candidate = payload['candidate']?.toString();
      if (candidate == null || candidate.isEmpty) return;
      final sdpMid = payload['sdpMid']?.toString();
      final idxRaw = payload['sdpMLineIndex'];
      int? sdpMLineIndex;
      if (idxRaw is int) {
        sdpMLineIndex = idxRaw;
      } else if (idxRaw is String) {
        sdpMLineIndex = int.tryParse(idxRaw);
      }
      try {
        final pc = await _ensurePeerConnection();
        await pc.addCandidate(
          RTCIceCandidate(candidate, sdpMid, sdpMLineIndex),
        );
      } catch (_) {
        // ignore ICE errors during teardown
      }
    });
  }

  Future<List<Map<String, dynamic>>> _resolveIceServers() async {
    if (_cachedIceConfig?.isFresh ?? false) {
      return _cachedIceConfig!.toRtcList();
    }

    try {
      if (_signaling.isConnected) {
        final result = await _signaling.invoke('GetIceConfiguration');
        if (result is Map) {
          final cfg = CallIceConfig.fromJson(
            result.cast<String, dynamic>(),
          );
          if (cfg.iceServers.isNotEmpty) {
            _cachedIceConfig = cfg;
            return cfg.toRtcList();
          }
        }
      }
    } catch (_) {
      // fall through to HTTP fetch
    }

    final fetched = await fetchIceConfiguration();
    if (fetched != null && fetched.iceServers.isNotEmpty) {
      _cachedIceConfig = fetched;
      return fetched.toRtcList();
    }

    throw StateError('The call service did not return ICE servers.');
  }

  Future<RTCPeerConnection> _ensurePeerConnection() async {
    final existing = _peerConnection;
    if (existing != null) return existing;

    final iceServers = await _resolveIceServers();
    final pc = await createPeerConnection({
      'iceServers': iceServers,
      'sdpSemantics': 'unified-plan',
    });

    pc.onIceCandidate = (RTCIceCandidate candidate) {
      final peer = _peer;
      if (peer == null) return;
      _signaling.invoke(
        'SendIceCandidate',
        args: [
          peer.connectionId,
          candidate.candidate,
          candidate.sdpMid,
          candidate.sdpMLineIndex,
        ],
      ).catchError((_) => null);
    };

    pc.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        _remoteStream = event.streams.first;
      } else {
        _remoteStream ??= event.track.kind == 'audio' ? null : _remoteStream;
      }
      notifyListeners();
    };

    pc.onConnectionState = (state) {
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        _setError('Call connection failed.');
      }
    };

    // Attach local microphone (reuse preview stream from ringing if present).
    MediaStream local;
    final previewMic = _localStream;
    if (previewMic != null && previewMic.getAudioTracks().isNotEmpty) {
      local = previewMic;
    } else {
      local = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': false,
      });
      _localStream = local;
    }
    for (final track in local.getAudioTracks()) {
      track.enabled = !_isMuted;
      await pc.addTrack(track, local);
    }

    // Apply the user's current speaker routing choice.
    try {
      await Helper.setSpeakerphoneOn(_isSpeakerOn);
    } catch (_) {}

    _peerConnection = pc;
    notifyListeners();
    return pc;
  }

  Future<void> _createAndSendOffer(String peerConnectionId) async {
    try {
      final pc = await _ensurePeerConnection();
      final offer = await pc.createOffer();
      await pc.setLocalDescription(offer);
      await _signaling
          .invoke('SendOffer', args: [peerConnectionId, offer.sdp ?? '']);
    } catch (err) {
      _setError('Failed to start call: ${_stringify(err)}');
    }
  }

  Future<void> _cleanupPeer() async {
    _cancelOutboundNoAnswerTimer();
    _stopConnectingTicker();
    _durationTicker?.cancel();
    _durationTicker = null;
    _callStartedAt = null;
    _callDuration = Duration.zero;
    _isMuted = false;
    _isSpeakerOn = false;
    await _stopRingingTone();

    final pc = _peerConnection;
    _peerConnection = null;
    if (pc != null) {
      try {
        await pc.close();
      } catch (_) {}
    }

    final local = _localStream;
    _localStream = null;
    if (local != null) {
      for (final track in local.getTracks()) {
        try {
          await track.stop();
        } catch (_) {}
      }
      try {
        await local.dispose();
      } catch (_) {}
    }

    final remote = _remoteStream;
    _remoteStream = null;
    if (remote != null) {
      try {
        await remote.dispose();
      } catch (_) {}
    }
  }

  void _startDurationTicker() {
    _durationTicker?.cancel();
    _callStartedAt = DateTime.now();
    _callDuration = Duration.zero;
    _durationTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      final started = _callStartedAt;
      if (started == null) return;
      _callDuration = DateTime.now().difference(started);
      notifyListeners();
    });
  }

  void _clearCallIdentity({bool clearPeer = true}) {
    _callId = null;
    _roomId = null;
    if (clearPeer) _peer = null;
    _incomingCall = null;
  }

  void _setPhase(CallPhase next) {
    if (_phase == next) return;
    _phase = next;
    final outboundPreAnswer = _incomingCall == null &&
        (next == CallPhase.calling || next == CallPhase.ringing);
    if (outboundPreAnswer) {
      unawaited(_startRingingTone());
    } else {
      unawaited(_stopRingingTone());
    }
    if (next == CallPhase.accepted) {
      _startConnectingTicker();
    } else {
      _stopConnectingTicker();
    }
    if (next != CallPhase.calling && next != CallPhase.ringing) {
      _cancelOutboundNoAnswerTimer();
    }
    notifyListeners();
  }

  void _startOutboundNoAnswerTimer() {
    _outboundNoAnswerTimer?.cancel();
    _outboundNoAnswerTimer = Timer(_outboundNoAnswerLimit, () async {
      if (_phase != CallPhase.calling && _phase != CallPhase.ringing) return;
      if (_incomingCall != null) return;
      try {
        await cancelOutgoingCall(
          reason: 'No answer (20s).',
          showNoDispatcherAvailable: true,
        );
      } catch (_) {}
    });
  }

  void _cancelOutboundNoAnswerTimer() {
    _outboundNoAnswerTimer?.cancel();
    _outboundNoAnswerTimer = null;
  }

  void _setError(String message) {
    _errorMessage = message;
    _phase = CallPhase.error;
    notifyListeners();
  }

  Future<void> _ensureMicrophonePermission() async {
    final mic = await Permission.microphone.request();
    if (!mic.isGranted) {
      throw StateError(
        'Microphone permission is required to start a voice call.',
      );
    }
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }
    // iOS audio routing to Bluetooth headsets/speaker may require explicit
    // bluetooth permission grants, depending on OS version and device settings.
    final bluetoothStatus = await Permission.bluetooth.request();
    if (bluetoothStatus.isDenied || bluetoothStatus.isPermanentlyDenied) {
      // Do not block the call on bluetooth permission; speaker/earpiece still works.
      return;
    }
  }

  Map<String, dynamic>? _firstMap(List<Object?>? args) {
    if (args == null || args.isEmpty) return null;
    final first = args.first;
    if (first is Map<String, dynamic>) return first;
    if (first is Map) return first.cast<String, dynamic>();
    return null;
  }

  String _stringify(Object? err) {
    final raw = err?.toString() ?? 'Unknown error.';
    return raw.replaceFirst('Exception: ', '');
  }

  /// Clears a transient error flag (useful after the UI shows a snack bar).
  void clearError() {
    if (_errorMessage == null && _phase != CallPhase.error) return;
    _errorMessage = null;
    if (_phase == CallPhase.error) {
      _phase = _signaling.isConnected ? CallPhase.connected : CallPhase.idle;
    }
    notifyListeners();
  }

  /// Returns the JWT `sub` of the currently authenticated user. Used by the
  /// UI to label the active call screen.
  String? get selfLabel =>
      _selfDisplayName ?? _selfUserId ?? AuthService.instance.studentId;

  Future<AudioPlayer?> _ensureRingPlayer() async {
    if (_ringPlayer != null) return _ringPlayer;
    try {
      _ringPlayer = AudioPlayer();
      return _ringPlayer;
    } on MissingPluginException {
      _ringPlayer = null;
      return null;
    } catch (_) {
      _ringPlayer = null;
      return null;
    }
  }

  Future<void> _disposeRingPlayer() async {
    _ringtoneActive = false;
    final p = _ringPlayer;
    _ringPlayer = null;
    if (p == null) return;
    try {
      await p.stop();
    } catch (_) {}
    try {
      await p.dispose();
    } catch (_) {}
  }

  Future<void> _startRingingTone() async {
    if (_ringtoneActive) return;
    try {
      final player = await _ensureRingPlayer();
      if (player == null) return;
      _ringtoneActive = true;
      await player.stop();
      await player.setReleaseMode(ReleaseMode.loop);
      await player.play(
        AssetSource('ringing.mp3'),
        volume: 1.0,
        mode: PlayerMode.mediaPlayer,
      );
    } on MissingPluginException {
      _ringtoneActive = false;
      await _disposeRingPlayer();
    } catch (_) {
      _ringtoneActive = false;
      await _disposeRingPlayer();
    }
  }

  Future<void> _stopRingingTone() async {
    if (!_ringtoneActive && _ringPlayer == null) return;
    _ringtoneActive = false;
    final p = _ringPlayer;
    if (p == null) return;
    try {
      await p.stop();
    } catch (_) {}
  }
}
