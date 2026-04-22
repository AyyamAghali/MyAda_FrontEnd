import 'package:flutter/material.dart';

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

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    String? msg;
    switch (phase) {
      case CallPhase.rejected:
        msg = CallController.instance.errorMessage ??
            'The dispatcher declined your call.';
        break;
      case CallPhase.cancelled:
        msg = 'Call cancelled.';
        break;
      case CallPhase.timeout:
        msg = 'The dispatcher did not answer in time.';
        break;
      case CallPhase.ended:
        msg = 'Call ended.';
        break;
      case CallPhase.error:
        msg = CallController.instance.errorMessage;
        break;
      default:
        msg = null;
    }
    if (msg != null && msg.isNotEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(msg)));
    }
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
              const Positioned.fill(child: ActiveCallScreen()),
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
