import 'package:flutter/material.dart';

import '../app_navigator_key.dart';
import '../screens/call/active_call_screen.dart';
import '../screens/call/incoming_call_dialog.dart';
import '../services/call/call_controller.dart';

/// Wraps the app's navigator so any active/incoming call UI is rendered on
/// top of every route.
///
/// This avoids having to manually push a call route from every caller and
/// also means the user cannot accidentally dismiss the live call UI by
/// navigating around the app.
class CallOverlayHost extends StatefulWidget {
  const CallOverlayHost({super.key, required this.child});

  final Widget child;

  @override
  State<CallOverlayHost> createState() => _CallOverlayHostState();
}

class _CallOverlayHostState extends State<CallOverlayHost> {
  CallPhase? _lastPhase;

  @override
  void initState() {
    super.initState();
    CallController.instance.addListener(_maybeShowTransientMessage);
  }

  @override
  void dispose() {
    CallController.instance.removeListener(_maybeShowTransientMessage);
    super.dispose();
  }

  void _maybeShowTransientMessage() {
    final phase = CallController.instance.phase;
    if (phase == _lastPhase) return;
    _lastPhase = phase;

    String? msg;
    switch (phase) {
      case CallPhase.rejected:
        _showRejectedCallDialog(
          CallController.instance.errorMessage ??
              'The support person declined your call.',
        );
        break;
      case CallPhase.cancelled:
        msg = CallController.instance.errorMessage ?? 'Call cancelled.';
        break;
      case CallPhase.timeout:
        msg = CallController.instance.errorMessage ??
            'The dispatcher did not answer in time.';
        break;
      case CallPhase.ended:
        msg = CallController.instance.errorMessage ?? 'Call ended.';
        break;
      case CallPhase.error:
        msg = CallController.instance.errorMessage;
        break;
      default:
        msg = null;
    }
    if (msg != null && msg.isNotEmpty) {
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) return;
      messenger.showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  void _showRejectedCallDialog(String reason) {
    Future<void>.microtask(() async {
      if (!mounted) return;
      final nav = appNavigatorKey.currentState;
      if (nav == null) return;
      await showDialog<void>(
        context: nav.context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: const Text('Call declined'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'The support person declined your call with this reason:',
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    reason,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Got it'),
              ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CallController.instance,
      builder: (context, _) {
        final controller = CallController.instance;
        return Stack(
          children: [
            widget.child,
            if (controller.shouldShowActiveCall)
              // ignore: prefer_const_constructors
              // Non-const so [CallController] updates rebuild controls (mute/speaker).
              Positioned.fill(child: ActiveCallScreen()),
            if (controller.shouldShowIncoming &&
                controller.incomingCall != null)
              Positioned.fill(
                child: IncomingCallDialog(info: controller.incomingCall!),
              ),
          ],
        );
      },
    );
  }
}
