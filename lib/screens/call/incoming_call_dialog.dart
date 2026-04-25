import 'package:flutter/material.dart';

import '../../services/call/call_controller.dart';

/// Full-screen, modal overlay shown when an incoming call arrives.
///
/// Mirrors the WhatsApp / FaceTime pattern: large caller avatar + label,
/// circular red "decline" button and green "accept" button.
class IncomingCallDialog extends StatelessWidget {
  const IncomingCallDialog({super.key, required this.info});

  static const _avatarAsset = 'assets/images/support_dispatcher_avatar.png';

  final IncomingCallInfo info;

  @override
  Widget build(BuildContext context) {
    final displayName = info.fromDisplayName?.trim().isNotEmpty == true
        ? info.fromDisplayName!
        : info.fromUserId;

    return Material(
      color: Colors.black.withValues(alpha: 0.85),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              const Text(
                'Incoming voice call',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 40),
              Container(
                width: 120,
                height: 120,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.18),
                  border: Border.all(color: Colors.white24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    _avatarAsset,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                displayName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'is calling you...',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _CircleAction(
                    label: 'Decline',
                    color: const Color(0xFFE53935),
                    icon: Icons.call_end,
                    onTap: () {
                      CallController.instance
                          .rejectIncomingCall(reason: 'Busy');
                    },
                  ),
                  _CircleAction(
                    label: 'Accept',
                    color: const Color(0xFF2E7D32),
                    icon: Icons.call,
                    onTap: () {
                      CallController.instance.acceptIncomingCall();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: color,
          shape: const CircleBorder(),
          elevation: 6,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 72,
              height: 72,
              child: Icon(icon, color: Colors.white, size: 32),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
