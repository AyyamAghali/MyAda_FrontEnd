import 'package:flutter/material.dart';

/// Root [Navigator] key so overlays built in [MaterialApp.builder] (above the
/// navigator) can still present dialogs and routes.
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();
