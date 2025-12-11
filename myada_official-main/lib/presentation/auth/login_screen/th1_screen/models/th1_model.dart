import 'package:flutter/material.dart';

/// Model class for TH1 screen
class TH1Model {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool rememberMe = false;
  bool isPasswordVisible = false;

  String? emailError;
  String? passwordError;

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }

  /// Validates the email field
  bool validateEmail() {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      emailError = 'Email is required';
      return false;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      emailError = 'Enter a valid email';
      return false;
    } else {
      emailError = null;
      return true;
    }
  }

  /// Validates the password field
  bool validatePassword() {
    final password = passwordController.text.trim();
    if (password.isEmpty) {
      passwordError = 'Password is required';
      return false;
    } else if (password.length < 6) {
      passwordError = 'Password must be at least 6 characters';
      return false;
    } else {
      passwordError = null;
      return true;
    }
  }

  /// Validates the entire form
  bool validateForm() {
    final isEmailValid = validateEmail();
    final isPasswordValid = validatePassword();
    return isEmailValid && isPasswordValid;
  }
}
