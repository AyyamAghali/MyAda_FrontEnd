import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Utility extension to handle keyboard visibility
extension KeyboardUtils on BuildContext {
  /// Hide the keyboard
  void hideKeyboard() {
    FocusScope.of(this).unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  /// Check if keyboard is visible
  bool get isKeyboardVisible => MediaQuery.of(this).viewInsets.bottom > 0;

  /// Get keyboard height
  double get keyboardHeight => MediaQuery.of(this).viewInsets.bottom;
}

/// Helper function to wrap content with a GestureDetector that dismisses keyboard on tap
Widget dismissKeyboardOnTap(Widget child) {
  return GestureDetector(
    onTap: () {
      // Close keyboard when tapping outside of text fields
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    },
    child: child,
  );
}
