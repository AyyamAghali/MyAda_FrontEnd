import 'package:flutter/material.dart';
import 'package:myada_official/core/app_export.dart';
import 'package:myada_official/core/network/api_service.dart';
import 'package:myada_official/presentation/auth/login_screen/th1_screen/models/th1_model.dart';

/// Provider class for TH1 screen (Login screen)
class TH1Provider extends ChangeNotifier {
  final TH1Model _th1Model = TH1Model();
  final ApiService _apiService = ApiService();
  bool isLoading = false;
  String? userRole;
  String? networkError;

  TH1Model get th1Model => _th1Model;

  /// Toggle password visibility
  void togglePasswordVisibility() {
    _th1Model.isPasswordVisible = !_th1Model.isPasswordVisible;
    notifyListeners();
  }

  /// Toggle remember me
  void toggleRememberMe(bool value) {
    _th1Model.rememberMe = value;
    notifyListeners();
  }

  /// Set email error message
  void setEmailError(String? error) {
    _th1Model.emailError = error;
    notifyListeners();
  }

  /// Set password error message
  void setPasswordError(String? error) {
    _th1Model.passwordError = error;
    notifyListeners();
  }

  /// Set network error message
  void setNetworkError(String? error) {
    networkError = error;
    notifyListeners();
  }

  /// Validate email field
  bool validateEmail() {
    return _th1Model.validateEmail();
  }

  /// Validate password field
  bool validatePassword() {
    return _th1Model.validatePassword();
  }

  /// Validate form
  bool validateForm() {
    bool isValid = _th1Model.validateForm();
    notifyListeners();
    return isValid;
  }

  /// Handle login with API
  Future<bool> login() async {
    if (!validateForm()) {
      return false;
    }

    // Clear any previous network errors
    setNetworkError(null);

    isLoading = true;
    notifyListeners();

    try {
      // Clear any previous errors
      setEmailError(null);
      setPasswordError(null);

      // Trim email and password to remove any accidental spaces
      final email = _th1Model.emailController.text.trim();
      final password = _th1Model.passwordController.text.trim();

      // Call the API service to login
      final userData = await _apiService.login(email, password);

      // Extract user role from response
      final user = userData['user'];

      if (user == null) {
        throw Exception('No user data received from server');
      }

      // Get the group_id and determine user role
      final groupId = user['group_id'];

      // This should match the UserModel.role implementation
      if (groupId == 1) {
        userRole = "teacher";
      } else if (groupId == 2) {
        userRole = "student";
      } else if (groupId == 3) {
        userRole = "staff";
      } else {
        // Default fallback
        userRole = "student";
      }

      // Save the successful login - for debugging purposes
      print('Successfully logged in as $userRole with group_id: $groupId');

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      // Set a generic error message or parse the specific message from the exception
      String errorMessage = 'Invalid credentials. Please try again.';

      if (e is Exception) {
        // Try to extract the specific error message if available
        final message = e.toString();
        if (message.contains('Exception: ')) {
          errorMessage = message.split('Exception: ')[1];
        }
      }

      print('Login failed: $errorMessage');

      // Check if it's a network-related error
      if (errorMessage.toLowerCase().contains('network') ||
          errorMessage.toLowerCase().contains('connect') ||
          errorMessage.toLowerCase().contains('socket') ||
          errorMessage.toLowerCase().contains('host')) {
        setNetworkError(errorMessage);
      } else if (errorMessage.toLowerCase().contains('email')) {
        setEmailError(errorMessage);
      } else {
        // Set error on password field (or you could create a separate login error field)
        setPasswordError(errorMessage);
      }

      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _th1Model.dispose();
    super.dispose();
  }
}
