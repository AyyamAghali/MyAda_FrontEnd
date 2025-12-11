import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for handling APDU communication with card readers
class ApduService extends ChangeNotifier {
  static const MethodChannel _channel = MethodChannel('az.edu.ada.myada/apdu');

  // Singleton pattern
  static final ApduService _instance = ApduService._internal();
  factory ApduService() => _instance;
  ApduService._internal();

  // State variables
  bool _isActive = false;
  bool get isActive => _isActive;

  // UID for current user
  String? _uid;
  String? get uid => _uid;

  // Method to set the user's UID
  void setUid(String uid) {
    _uid = uid;
    notifyListeners();
  }

  // Toggle the APDU service on or off
  Future<void> toggleService(bool value) async {
    // Set state first so UI can update immediately
    _isActive = value;
    notifyListeners();

    if (_isActive) {
      await _activateService();
    } else {
      await _deactivateService();
    }
  }

  // Activate the APDU/HCE service
  Future<void> _activateService() async {
    if (kDebugMode) {
      print('APDU Service activation requested with UID: $_uid');
    }

    if (_uid == null || _uid!.isEmpty) {
      if (kDebugMode) {
        print('Cannot activate APDU service: No UID available');
      }
      return;
    }

    try {
      // Save the active state in shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_hce_active', true);
      // Always make sure the UID is up to date in SharedPreferences
      await prefs.setString('uid', _uid!);

      // Call the native method to start the HCE service
      final result =
          await _channel.invokeMethod<bool>('startHceService', {'uid': _uid});

      if (kDebugMode) {
        print('HCE service activation result: $result');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error activating HCE service: $e');
      }
      // Reset state if there was an error
      _isActive = false;
      notifyListeners();
    }
  }

  // Deactivate the APDU/HCE service
  Future<void> _deactivateService() async {
    if (kDebugMode) {
      print('APDU Service deactivation requested');
    }

    try {
      // Save the inactive state in shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_hce_active', false);

      // Call the native method to stop the HCE service
      final result = await _channel.invokeMethod<bool>('stopHceService');

      if (kDebugMode) {
        print('HCE service deactivation result: $result');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deactivating HCE service: $e');
      }
    }
  }

  // Check if device supports NFC and HCE
  Future<bool> isHceSupported() async {
    try {
      final result = await _channel.invokeMethod<bool>('isHceSupported');
      return result ?? false;
    } catch (e) {
      print('Error checking HCE support: $e');
      return false;
    }
  }

  // Start the HCE service for emulating an ID card
  Future<bool> startHceService(String uid) async {
    try {
      // Update local value and notify listeners
      _uid = uid;
      _isActive = true;
      notifyListeners();

      // Save UID in shared preferences (will be accessible by Java code)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('uid', uid);
      await prefs.setBool('is_hce_active', true);
      await prefs.setBool(
          'is_logged_in', true); // Ensure we're marked as logged in

      // Call the native method to start the HCE service
      final result =
          await _channel.invokeMethod<bool>('startHceService', {'uid': uid});

      // If failed, update UI state
      if (!(result ?? false)) {
        _isActive = false;
        notifyListeners();
      }

      return result ?? false;
    } catch (e) {
      print('Error starting HCE service: $e');
      _isActive = false;
      notifyListeners();
      return false;
    }
  }

  // Stop the HCE service
  Future<bool> stopHceService() async {
    try {
      final result = await _channel.invokeMethod<bool>('stopHceService');
      return result ?? false;
    } catch (e) {
      print('Error stopping HCE service: $e');
      return false;
    }
  }

  // Settings for HCE behavior
  Future<void> setStopHceOnExit(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('stop_hce_on_exit', value);
  }

  Future<bool> getStopHceOnExit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('stop_hce_on_exit') ?? true; // Default to true
  }

  Future<void> setAutoRestartHce(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_restart_hce', value);
  }

  Future<bool> getAutoRestartHce() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('auto_restart_hce') ?? true; // Default to true
  }

  // Auto-start HCE service when user logs in
  Future<bool> onUserLogin(String uid) async {
    try {
      _uid = uid;
      _isActive = true;

      // Save login state and UID
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('uid', uid);
      await prefs.setBool('is_hce_active', true); // Mark HCE as active

      // Set default preferences if they don't exist yet
      if (!prefs.containsKey('stop_hce_on_exit')) {
        await prefs.setBool('stop_hce_on_exit', true);
      }
      if (!prefs.containsKey('auto_restart_hce')) {
        await prefs.setBool('auto_restart_hce', true);
      }

      // Call native method to handle login and start HCE
      final result =
          await _channel.invokeMethod<bool>('userLoggedIn', {'uid': uid});

      notifyListeners();
      return result ?? false;
    } catch (e) {
      print('Error handling user login for HCE: $e');
      return false;
    }
  }

  // Stop HCE service when user logs out
  Future<bool> onUserLogout() async {
    try {
      _uid = null;
      _isActive = false;

      // Clear login and active state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', false);
      await prefs.setBool('is_hce_active', false);

      // Call native method to handle logout and stop HCE
      final result = await _channel.invokeMethod<bool>('userLoggedOut');

      notifyListeners();
      return result ?? false;
    } catch (e) {
      print('Error handling user logout for HCE: $e');
      return false;
    }
  }

  // Explicit method to restart the HCE service regardless of current state
  Future<bool> restartHceService() async {
    try {
      // First stop any existing service
      await _deactivateService();

      // Only try to restart if we have a UID
      if (_uid == null || _uid!.isEmpty) {
        if (kDebugMode) {
          print('Cannot restart HCE service: No UID available');
        }
        return false;
      }

      // Set active state
      _isActive = true;
      notifyListeners();

      // Start the service
      final result =
          await _channel.invokeMethod<bool>('startHceService', {'uid': _uid});
      return result ?? false;
    } catch (e) {
      if (kDebugMode) {
        print('Error restarting HCE service: $e');
      }
      return false;
    }
  }
}
