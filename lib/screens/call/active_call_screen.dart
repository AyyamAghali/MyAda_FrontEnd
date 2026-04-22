import 'package:flutter/material.dart';

import '../../services/call/call_controller.dart';
import '../../utils/constants.dart';

/// WhatsApp-style active call screen rendered on top of the app while a call
/// is ringing, being answered, or in progress.
///
/// The widget is intentionally stateless - it reads everything it needs from
/// the [CallController] singleton which is provided to the overlay host via
/// an [AnimatedBuilder] rebuild.
class ActiveCallScreen extends StatelessWidget {
  const ActiveCallScreen({super.key});

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

  String _statusText(CallPhase phase) {
    switch (phase) {
      case CallPhase.ringing:
        return 'Ringing...';
      case CallPhase.accepted:
        return 'Connecting...';
      case CallPhase.inCall:
        return 'In call';
      default:
        return 'Connecting...';
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = CallController.instance;
    final phase = controller.phase;
    final peer = controller.peer;

    final displayName = peer?.displayName?.trim().isNotEmpty == true
        ? peer!.displayName!
        : (peer?.userId ?? 'Support dispatcher');
    final initial = displayName.isNotEmpty
        ? displayName.characters.first.toUpperCase()
        : '?';

    return Material(
      color: const Color(0xFF101114),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _statusText(phase),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.4,
                    ),
                  ),
                  if (phase == CallPhase.inCall)
                    Text(
                      _formatDuration(controller.callDuration),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 48),
              Center(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 30,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 56,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                displayName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (controller.roomId != null) ...[
                const SizedBox(height: 6),
                Text(
                  controller.roomId!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 11,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
              const Spacer(),
              _ActionsRow(controller: controller),
              const SizedBox(height: 28),
              _HangUpButton(controller: controller),
              const SizedBox(height: 8),
            ],
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
    final hasLocal = controller.localStream != null;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _CircularToggle(
          icon: controller.isMuted ? Icons.mic_off : Icons.mic,
          label: controller.isMuted ? 'Unmute' : 'Mute',
          active: controller.isMuted,
          enabled: hasLocal,
          onTap: controller.toggleMute,
        ),
        _CircularToggle(
          icon: controller.isSpeakerOn ? Icons.volume_up : Icons.hearing,
          label: controller.isSpeakerOn ? 'Speaker' : 'Earpiece',
          active: controller.isSpeakerOn,
          enabled: true,
          onTap: () => controller.toggleSpeaker(),
        ),
        _CircularToggle(
          icon: Icons.dialpad,
          label: 'Keypad',
          active: false,
          enabled: false,
          onTap: () {},
        ),
      ],
    );
  }
}

class _CircularToggle extends StatelessWidget {
  const _CircularToggle({
    required this.icon,
    required this.label,
    required this.active,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background = active ? Colors.white : Colors.white.withOpacity(0.12);
    final iconColor = active
        ? const Color(0xFF101114)
        : (enabled ? Colors.white : Colors.white38);
    final textColor = enabled ? Colors.white : Colors.white38;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: background,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: enabled ? onTap : null,
            child: SizedBox(
              width: 64,
              height: 64,
              child: Icon(icon, color: iconColor, size: 28),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _HangUpButton extends StatelessWidget {
  const _HangUpButton({required this.controller});

  final CallController controller;

  Future<void> _handleHangUp() async {
    final phase = controller.phase;
    if (phase == CallPhase.ringing) {
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
