import 'package:flutter/material.dart';
import 'club_hub_deep_link.dart';

/// Lets embedded club screens (e.g. [MyMemberships]) refocus hub tabs without importing the hub state (avoids import cycles).
class ClubHubScope extends InheritedWidget {
  final void Function(ClubHubDeepLink link) applyDeepLink;

  const ClubHubScope({
    super.key,
    required this.applyDeepLink,
    required super.child,
  });

  static ClubHubScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ClubHubScope>();
  }

  @override
  bool updateShouldNotify(ClubHubScope oldWidget) => false;
}
