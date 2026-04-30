import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:proximity_sensor/proximity_sensor.dart';

import '../../services/call/call_controller.dart';
import '../../utils/constants.dart';

/// WhatsApp-style active call screen rendered on top of the app while a call
/// is dialing, ringing, being answered, or in progress.
class ActiveCallScreen extends StatefulWidget {
  const ActiveCallScreen({super.key});

  static const _avatarAsset = 'assets/images/support_dispatcher_avatar.png';

  @override
  State<ActiveCallScreen> createState() => _ActiveCallScreenState();
}

class _ActiveCallScreenState extends State<ActiveCallScreen> {
  static const _avatarAsset = ActiveCallScreen._avatarAsset;

  StreamSubscription<int>? _proximitySub;
  bool _proximityNear = false;
  bool _androidProximityNativeOn = false;

  @override
  void initState() {
    super.initState();
    CallController.instance.addListener(_onCallControllerChanged);
    _onCallControllerChanged();
  }

  @override
  void dispose() {
    CallController.instance.removeListener(_onCallControllerChanged);
    unawaited(_setAndroidProximityScreenOff(false));
    unawaited(_proximitySub?.cancel());
    super.dispose();
  }

  void _onCallControllerChanged() {
    if (!mounted) return;
    final phase = CallController.instance.phase;
    final voiceProximityActive =
        phase == CallPhase.inCall || phase == CallPhase.accepted;

    if (voiceProximityActive) {
      unawaited(_setAndroidProximityScreenOff(true));
      _proximitySub ??= ProximitySensor.events.listen((event) {
        if (!mounted) return;
        final near = event > 0;
        if (near != _proximityNear) {
          setState(() => _proximityNear = near);
        }
      });
    } else {
      unawaited(_setAndroidProximityScreenOff(false));
      unawaited(_proximitySub?.cancel());
      _proximitySub = null;
      if (_proximityNear) {
        _proximityNear = false;
      }
    }

    setState(() {});
  }

  Future<void> _setAndroidProximityScreenOff(bool enabled) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    if (_androidProximityNativeOn == enabled) return;
    try {
      await ProximitySensor.setProximityScreenOff(enabled);
      _androidProximityNativeOn = enabled;
    } catch (_) {}
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    if (minutes >= 60) {
      final hours = d.inHours;
      return '${two(hours)}:${two(minutes % 60)}:${two(seconds)}';
    }
    return '${two(minutes)}:${two(seconds)}';
  }

  String _statusText(CallPhase phase, CallController controller) {
    switch (phase) {
      case CallPhase.inCall:
        return _formatDuration(controller.callDuration);
      case CallPhase.calling:
      case CallPhase.ringing:
      case CallPhase.accepted:
        return 'Ringing';
      default:
        return 'Ringing';
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = CallController.instance;
    final phase = controller.phase;
    final peer = controller.peer;

    final name = peer?.displayName?.trim();
    final displayName = (name != null && name.isNotEmpty)
        ? name
        : (peer?.userId?.trim().isNotEmpty == true ? peer!.userId! : 'Support');
    final timerText = _statusText(phase, controller);
    final showElapsedOnly = phase == CallPhase.inCall;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 24),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Material(
        color: const Color(0xFF071923),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF071923),
                      AppColors.primaryDark,
                      AppColors.secondaryDark.withValues(alpha: 0.92),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -80,
              right: -80,
              child:
                  _SoftGlow(color: AppColors.primary.withValues(alpha: 0.45)),
            ),
            Positioned(
              bottom: -110,
              left: -90,
              child:
                  _SoftGlow(color: AppColors.secondary.withValues(alpha: 0.36)),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        child: Text(
                          phase == CallPhase.inCall
                              ? 'Support call'
                              : 'Calling support',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(flex: 2),
                    Center(
                      child: _PulsingAvatar(
                        assetPath: _avatarAsset,
                        isRinging: phase == CallPhase.calling ||
                            phase == CallPhase.ringing ||
                            phase == CallPhase.accepted,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      displayName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      timerText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.78),
                        fontSize: showElapsedOnly ? 20 : 16,
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const Spacer(flex: 3),
                    _ActionsRow(controller: controller),
                    const SizedBox(height: 30),
                    _HangUpButton(controller: controller),
                  ],
                ),
              ),
            ),
            if (_proximityNear &&
                (phase == CallPhase.inCall || phase == CallPhase.accepted))
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black,
                  child: Center(
                    child: Icon(
                      Icons.phone_in_talk_rounded,
                      size: 56,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SoftGlow extends StatelessWidget {
  const _SoftGlow({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 90,
            spreadRadius: 50,
          ),
        ],
      ),
    );
  }
}

class _PulsingAvatar extends StatefulWidget {
  const _PulsingAvatar({required this.assetPath, required this.isRinging});

  final String assetPath;
  final bool isRinging;

  @override
  State<_PulsingAvatar> createState() => _PulsingAvatarState();
}

class _PulsingAvatarState extends State<_PulsingAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    if (widget.isRinging) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant _PulsingAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRinging && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isRinging && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final pulse = widget.isRinging ? _controller.value : 0.0;
        return Stack(
          alignment: Alignment.center,
          children: [
            for (final offset in const [0.0, 0.28])
              Transform.scale(
                scale: 1 + (((pulse + offset) % 1) * 0.38),
                child: Opacity(
                  opacity: widget.isRinging
                      ? (1 - ((pulse + offset) % 1)) * 0.22
                      : 0,
                  child: Container(
                    width: 176,
                    height: 176,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            child!,
          ],
        );
      },
      child: Container(
        width: 168,
        height: 168,
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.18),
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.32), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 34,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            widget.assetPath,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class _ActionsRow extends StatelessWidget {
  const _ActionsRow({required this.controller});

  final CallController controller;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.11),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Row(
            children: [
              Expanded(
                child: _CallControl(
                  icon: controller.isMuted ? Icons.mic_off : Icons.mic,
                  label: controller.isMuted ? 'Muted' : 'Mute',
                  active: controller.isMuted,
                  activeColor: const Color(0xFFE53935),
                  onTap: controller.toggleMute,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CallControl(
                  icon: controller.isSpeakerOn
                      ? Icons.volume_up_rounded
                      : Icons.volume_up_outlined,
                  label: controller.isSpeakerOn ? 'Speaker on' : 'Speaker',
                  active: controller.isSpeakerOn,
                  activeColor: AppColors.primary,
                  onTap: () => controller.toggleSpeaker(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CallControl extends StatelessWidget {
  const _CallControl({
    required this.icon,
    required this.label,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = active ? Colors.white : Colors.white.withValues(alpha: 0.12);
    final fg = active ? activeColor : Colors.white;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  active ? Colors.white : Colors.white.withValues(alpha: 0.14),
              width: active ? 2 : 1,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.28),
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                  ]
                : const [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: fg, size: 26),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HangUpButton extends StatelessWidget {
  const _HangUpButton({required this.controller});

  final CallController controller;

  Future<void> _handleHangUp() async {
    final phase = controller.phase;
    if (phase == CallPhase.calling || phase == CallPhase.ringing) {
      await controller.cancelOutgoingCall(reason: 'Cancelled by caller');
      return;
    }
    await controller.endCall();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Material(
          color: const Color(0xFFE53935),
          shape: const CircleBorder(),
          elevation: 6,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: _handleHangUp,
            child: const SizedBox(
              width: 76,
              height: 76,
              child: Icon(Icons.call_end, color: Colors.white, size: 34),
            ),
          ),
        ),
      ],
    );
  }
}
