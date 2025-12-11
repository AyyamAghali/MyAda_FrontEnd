import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://task.bazarlook.com/api';
  static const String _tokenKey = 'auth_token';

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _authToken;
  String? get authToken => _authToken;

  // Initialize and load token from storage
  Future<void> initialize() async {
    await _loadTokenFromStorage();
  }

  // Login API call
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('Attempting login to $baseUrl/login_app');
      print('Request body: ${jsonEncode({
            'email': email,
            'password': password,
          })}');

      final response = await http.post(
        Uri.parse('$baseUrl/login_app'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['token'] == null) {
          // Some APIs return 200 with error messages in the body
          throw Exception(data['message'] ?? 'Login failed: No token received');
        }

        _authToken = data['token'];
        await _saveTokenToStorage(_authToken!);

        // Mark that the user has successfully logged in
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('has_logged_in_before', true);
        await prefs.setBool('first_time', false);

        // Make sure we handle user data safely
        if (data.containsKey('user') && data['user'] != null) {
          final user = data['user'];
          // Debug logging for user ID fields
          print('DEBUG: User data structure:');
          print('User ID (id): ${user['id']}');
          print('User ID (user_id): ${user['user_id']}');
          if (user.containsKey('personal_informations') &&
              user['personal_informations'] != null) {
            print(
                'Personal Information User ID: ${user['personal_informations']['user_id']}');
            print(
                'Personal Information UID: ${user['personal_informations']['uid']}');
          }

          await _saveUserDataToStorage(user);
        } else {
          print('Warning: No user data found in the response');
        }

        return data;
      } else if (response.statusCode == 401) {
        // Special handling for authentication errors
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Invalid credentials');
      } else {
        throw Exception(
            'Login failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Login error please check your email and password $e');
      throw Exception('Failed to login: $e');
    }
  }

  // Get user data
  Future<Map<String, dynamic>?> getUserData() async {
    // Try to retrieve from shared preferences first
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');

    if (userData != null) {
      return json.decode(userData);
    }

    return null;
  }

  // Logout (clear token)
  Future<void> logout() async {
    // Print auth token before clearing for debugging
    print('Clearing auth token: $_authToken');

    // Clear the token in memory
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();

    try {
      // Mark that the user has logged in before - this prevents showing onboarding again
      await prefs.setBool('has_logged_in_before', true);

      // Clear ALL authentication and user related data
      await prefs.remove(_tokenKey);
      await prefs.remove('user_data');
      await prefs.remove('current_user');
      await prefs.remove('user_profile');
      await prefs.remove('login_state');
      await prefs.remove('auth_data');
      await prefs.remove('uid');
      await prefs.remove('role');

      // Reset any navigation preferences
      await prefs.setBool('first_time', false);
      await prefs.setBool('is_logged_in', false);

      // For debugging, verify token is cleared
      print('Auth token after clearing: $_authToken');
      final remainingToken = prefs.getString(_tokenKey);
      print('Token in SharedPreferences after clearing: $remainingToken');
    } catch (e) {
      print('Error clearing preferences: $e');
    }
  }

  // Save token to storage
  Future<void> _saveTokenToStorage(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Load token from storage
  Future<void> _loadTokenFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString(_tokenKey);
  }

  // Save user data to storage
  Future<void> _saveUserDataToStorage(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(userData));
  }

  // Get attendance logs for a room
  Future<List<Map<String, dynamic>>> getAttendanceLogs(
      Map<String, String> dateRange) async {
    if (_authToken == null) {
      throw Exception('Not authenticated');
    }

    try {
      // Debug log the token format
      print(
          'Using auth token: ${_authToken!.substring(0, math.min(15, _authToken!.length))}...');

      // Convert parameters to query string
      final queryParams = Uri(queryParameters: dateRange).query;
      final url = Uri.parse('$baseUrl/whoEnteredMyRoom?$queryParams');

      print('Making GET request to: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authToken!.trim()}',
          'Accept': 'application/json',
        },
      );

      // Debug response info
      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print(
          'Response first 100 chars: ${response.body.substring(0, math.min(100, response.body.length))}');

      // Check content type to ensure we're handling JSON
      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.contains('application/json') &&
              response.body.trim().startsWith('<!DOCTYPE') ||
          response.body.trim().startsWith('<html')) {
        // Response is HTML instead of JSON
        throw Exception(
            'Received HTML response instead of JSON. Server error occurred.');
      }

      try {
        final data = jsonDecode(response.body);

        if (response.statusCode == 200) {
          if (data['success'] == true &&
              data['data'] != null &&
              data['data'] is List) {
            return List<Map<String, dynamic>>.from(data['data']);
          }
          // API returned success: false or empty data array
          return [];
        } else if (response.statusCode == 400) {
          // Handle bad request
          throw Exception(
              data['message'] ?? 'Bad request. Please check date parameters.');
        } else if (response.statusCode == 401) {
          throw Exception('Unauthorized: Token may be expired');
        } else {
          throw Exception(
              'Failed to load attendance logs: ${response.statusCode} - ${data['message'] ?? "Unknown error"}');
        }
      } catch (e) {
        if (e is FormatException) {
          // JSON parsing error
          throw Exception(
              'Server returned invalid format: ${e.message}. Response: ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}...');
        }
        rethrow;
      }
    } catch (e) {
      throw Exception('Error fetching attendance logs: $e');
    }
  }

  // For authenticated requests
  Future<http.Response> get(String endpoint) async {
    if (_authToken == null) {
      throw Exception('Not authenticated');
    }

    return http.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_authToken',
      },
    );
  }

  // Get all reservation logs with filter parameters
  Future<http.Response> getAllReservationLogs({
    int? buildingID,
    int? roomID,
    int? userID,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (_authToken == null) {
      throw Exception('Not authenticated');
    }

    // Format dates to expected format: "YYYY-MM-DD HH:MM"
    final String formattedStartDate =
        "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')} ${startDate.hour.toString().padLeft(2, '0')}:${startDate.minute.toString().padLeft(2, '0')}";
    final String formattedEndDate =
        "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')} ${endDate.hour.toString().padLeft(2, '0')}:${endDate.minute.toString().padLeft(2, '0')}";

    // Create query parameters
    Map<String, String> queryParams = {
      "start_date": formattedStartDate,
      "end_date": formattedEndDate,
    };

    // Add optional parameters if provided
    if (buildingID != null) queryParams["buildingID"] = buildingID.toString();
    if (roomID != null) queryParams["roomID"] = roomID.toString();
    if (userID != null) queryParams["userID"] = userID.toString();

    // Construct the URI with query parameters
    final uri =
        Uri.parse('https://task.bazarlook.com/api/getAllReservationLogs')
            .replace(queryParameters: queryParams);

    print('GET request for reservation logs: ${uri.toString()}');
    print('Query parameters: $queryParams');
    print('Start date: $startDate (${startDate.toIso8601String()})');
    print('End date: $endDate (${endDate.toIso8601String()})');
    print('Auth token available: ${_authToken != null}');

    try {
      // Send GET request instead of POST
      return await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_authToken',
        },
      );
    } catch (e) {
      print('Error in getAllReservationLogs: $e');
      rethrow;
    }
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    if (_authToken == null) {
      throw Exception('Not authenticated');
    }

    return http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_authToken',
      },
      body: jsonEncode(data),
    );
  }
}
