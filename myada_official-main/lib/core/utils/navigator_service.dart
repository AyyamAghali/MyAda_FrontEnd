import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A service that provides navigation methods for the app
class NavigatorService {
  /// Global navigator key
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Navigate to specified route name
  static void pushNamed(String routeName, {Object? arguments}) {
    Get.toNamed(routeName, arguments: arguments);
  }

  /// Replace current route with specified route name
  static void pushReplacementNamed(String routeName, {Object? arguments}) {
    Get.offNamed(routeName, arguments: arguments);
  }

  /// Navigate to specified route name and remove all previous routes
  static void pushNamedAndRemoveUntil(String routeName, {Object? arguments}) {
    Get.offAllNamed(routeName, arguments: arguments);
  }

  /// Navigate back to previous screen
  static void pop() {
    Get.back();
  }

  /// Returns true if can navigate back
  static bool canPop() {
    return Get.key.currentState?.canPop() ?? false;
  }

  /// Show a snackbar message
  static void showSnackBar(String message, {bool isError = false}) {
    Get.snackbar(
      isError ? 'Error' : 'Message',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor:
          isError ? Colors.red.withOpacity(0.8) : Colors.green.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
}
