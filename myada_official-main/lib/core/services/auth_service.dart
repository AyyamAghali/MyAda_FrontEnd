import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../network/api_service.dart';
import '../services/apdu_service.dart';

/// Service for managing authentication to the app
class AuthService extends ChangeNotifier {
  static const String _userKey = 'user_data';

  // API service instance
  final ApiService _apiService = ApiService();
  final ApduService _apduService = ApduService();

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    // Check login status
    _checkLoginStatus();
  }

  // Current user
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  // Properties to track authentication state
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  // Initialize and load user from local storage
  Future<void> initialize() async {
    await _loadUserFromStorage();
  }

  // Check if user is already logged in
  Future<void> _checkLoginStatus() async {
    try {
      final userData = await _apiService.getUserData();
      _isLoggedIn = userData != null;
      notifyListeners();
    } catch (e) {
      print('Error checking login status: $e');
      _isLoggedIn = false;
      notifyListeners();
    }
  }

  // Login with email and password using the API
  Future<UserModel?> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password cannot be empty');
    }

    try {
      // Call the API login
      final response = await _apiService.login(email, password);

      // Get the user data from the response
      final userData = response['user'];
      userData['uid'] = response['uid']; // Add UID from the response

      // Create user model from response
      final user = UserModel.fromJson(userData);

      // Set current user and save to storage
      _currentUser = user;
      await _saveUserToStorage(user);

      // Auto-start HCE service with user's UID
      if (userData.containsKey('uid')) {
        final uid = userData['uid'];
        if (uid != null && uid.isNotEmpty) {
          print('Activating HCE service with UID: $uid');
          try {
            final result = await _apduService.onUserLogin(uid.toString());

            // Also start the service directly
            if (!_apduService.isActive) {
              print('Auto-starting HCE service after login');
              await _apduService.toggleService(true);
            }

            print('HCE service activated: $result');
          } catch (e) {
            print('Error activating HCE service: $e');
          }
        }
      }

      notifyListeners();

      return user;
    } catch (e) {
      rethrow;
    }
  }

  // Get user data from the API
  Future<UserModel?> getUserData() async {
    try {
      final userData = await _apiService.getUserData();
      // Create user model from response
      final user = UserModel.fromJson(userData!);

      // Set current user and save to storage
      _currentUser = user;
      await _saveUserToStorage(user);
      notifyListeners();

      return user;
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      // Stop HCE service on logout
      print('Stopping HCE service during logout');
      await _apduService.onUserLogout();

      // Then proceed with normal logout
      await _apiService.logout();
      _currentUser = null;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      notifyListeners();
    } catch (e) {
      print('Error during logout: $e');
      // Still consider user logged out even on error
      _currentUser = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      notifyListeners();
      rethrow;
    }
  }

  // Check if user is a teacher
  bool isTeacher() {
    return _currentUser?.role == UserRole.teacher;
  }

  // Check if user is a student
  bool isStudent() {
    return _currentUser?.role == UserRole.student;
  }

  // Load user from storage
  Future<void> _loadUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      try {
        _currentUser = UserModel.fromJson(jsonDecode(userData));
        notifyListeners();
      } catch (e) {
        print('Error parsing user data: $e');
      }
    }
  }

  // Save user to storage
  Future<void> _saveUserToStorage(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  // Get the user's UID
  String? getUserUid() {
    return _currentUser?.uid;
  }
}
