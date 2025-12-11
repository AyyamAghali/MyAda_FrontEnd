import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myada_official/core/app_export.dart';
import 'package:myada_official/core/network/api_service.dart';
import 'package:myada_official/presentation/features/room_reservation_screen/reservation_details_screen.dart';

class RoomReservationScreen extends StatefulWidget {
  const RoomReservationScreen({Key? key}) : super(key: key);

  @override
  State<RoomReservationScreen> createState() => _RoomReservationScreenState();

  static Widget builder(BuildContext context) => const RoomReservationScreen();
}

class _RoomReservationScreenState extends State<RoomReservationScreen> {
  final ApiService _apiService = ApiService();
  bool isLoading = true;
  bool isConnectionError = false;
  bool isInitialLoad = true; // Add flag to track if this is the first load
  String? error;
  List<Map<String, dynamic>> reservations = [];
  List<Map<String, dynamic>> buildings = [];
  Map<int, List<Map<String, dynamic>>> roomsByBuilding = {};

  // Filter states
  String _buildingFilter = "ALL"; // ALL, A, B, C, D
  String _todayFilter = "ALL"; // ALL, A, B
  bool _showOnlyMyReservations = false;
  DateTime _selectedDate = DateTime.now();

  // Group reservations by date
  Map<String, List<Map<String, dynamic>>> groupedReservations = {};

  @override
  void initState() {
    super.initState();
    _checkConnectionAndLoadData();

    // Set a short delay to mark initial load as complete
    // This ensures if we click back and return to this screen,
    // it won't show full loading screen
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          isInitialLoad = false;
        });
      }
    });
  }

  // Check network connection before loading data
  Future<void> _checkConnectionAndLoadData() async {
    try {
      // Check internet connection first
      await _checkInternetConnection();

      // If we reach here, connection is good
      await _loadBuildingsAndRooms().then((_) {
        _loadReservations();
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        isConnectionError = true;
        error =
            "Unable to connect to server. Please check your internet connection.";
      });
    }
  }

  // Check if internet connection is available
  Future<void> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('task.bazarlook.com');
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        throw Exception('No internet connection');
      }
    } on SocketException catch (_) {
      throw Exception('No internet connection');
    } catch (e) {
      throw Exception('Connection error');
    }
  }

  // Load building and room data from API
  Future<void> _loadBuildingsAndRooms() async {
    try {
      final response = await _apiService.get('getAllBuildings');

      // Check if response is HTML instead of JSON
      if (response.body.trim().startsWith('<!DOCTYPE html>')) {
        setState(() {
          error =
              "Server returned HTML instead of JSON. Check server configuration.";
        });
        return;
      }

      final responseData = jsonDecode(response.body);

      if (responseData["success"] == true) {
        final List<dynamic> data = responseData["data"] as List;
        buildings = List<Map<String, dynamic>>.from(data);

        // Load rooms for each building
        List<Future> roomFutures = [];
        for (var building in buildings) {
          roomFutures.add(_loadRoomsByBuildingId(building["id"]));
        }

        // Wait for all room data to load
        await Future.wait(roomFutures);
      }
    } catch (e) {
      print("Error loading buildings: $e");
      // Don't set error here, as we'll still try to load reservations
    }
  }

  // Load rooms for a specific building
  Future<void> _loadRoomsByBuildingId(int buildingId) async {
    try {
      final response =
          await _apiService.get('getAllRoomsByBuildingId/$buildingId');

      // Check if response is HTML instead of JSON
      if (response.body.trim().startsWith('<!DOCTYPE html>')) {
        print('Received HTML instead of JSON when loading rooms.');
        return;
      }

      final responseData = jsonDecode(response.body);

      if (responseData["success"] == true) {
        final List<dynamic> data = responseData["data"] as List;
        roomsByBuilding[buildingId] = List<Map<String, dynamic>>.from(data);
      }
    } catch (e) {
      print("Error loading rooms for building $buildingId: $e");
    }
  }

  Future<void> _loadReservations() async {
    // Create start date with time 00:00:00
    final DateTime startDate =
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    // Create end date with time 23:59:59
    final DateTime endDate = DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59, 59);

    // If no specific room is selected but a specific building is selected,
    // we need to find the correct building ID
    if (_todayFilter == "ALL" && _buildingFilter != "ALL") {
      // Find the building ID for the selected building name
      int? buildingId;
      for (var building in buildings) {
        if (building["building_name"] == _buildingFilter) {
          buildingId = building["id"];
          print(
              'Found building ID: $buildingId for building: $_buildingFilter');

          // Get first room from this building to use as reference (just for the API call)
          List<dynamic> rooms = roomsByBuilding[buildingId] ?? [];
          if (rooms.isNotEmpty) {
            int roomId = rooms[0]["id"];
            // Pass the date range to the method for loading reservations
            _loadReservationsWithDateRange(roomId, startDate, endDate);
            return;
          }
          break;
        }
      }
    }

    // Default case - use room ID 1 as before
    _loadReservationsWithDateRange(1, startDate, endDate);
  }

  // New method to load reservations with explicit date range
  Future<void> _loadReservationsWithDateRange(
      int roomId, DateTime startDate, DateTime endDate) async {
    setState(() {
      // Never show full-screen loading after initial load
      isLoading = true;
      error = null;
    });

    print('Loading reservations for room ID: $roomId');
    print('Start date: $startDate');
    print('End date: $endDate');
    print('Building filter: $_buildingFilter');
    print('Room filter: $_todayFilter');
    print('Show only my reservations: $_showOnlyMyReservations');

    try {
      // Get logged in user ID
      int? userId;
      if (_showOnlyMyReservations) {
        final userData = await _apiService.getUserData();
        if (userData != null) {
          userId = userData['id'];
          print('User ID for filtering: $userId');
        } else {
          print('User data is null');
        }
      }

      // Find building ID for the current building filter (not based on room ID)
      int? buildingId;

      // If a specific building is selected (not ALL)
      if (_buildingFilter != "ALL") {
        // Find the building ID for the selected building NAME
        for (var building in buildings) {
          if (building["building_name"] == _buildingFilter) {
            buildingId = building["id"];
            print(
                'Found building ID: $buildingId for building: $_buildingFilter');
            break;
          }
        }
      } else if (_todayFilter != "ALL") {
        // If ALL buildings selected but specific room selected,
        // find the building for this room
        for (var building in buildings) {
          int currentBuildingId = building["id"];
          List<dynamic> rooms = roomsByBuilding[currentBuildingId] ?? [];
          for (var room in rooms) {
            if (room["id"] == roomId) {
              buildingId = currentBuildingId;
              print('Found building ID: $buildingId for room ID: $roomId');
              break;
            }
          }
          if (buildingId != null) break;
        }
      }

      if (buildingId == null && _buildingFilter != "ALL") {
        print(
            'Warning: Building ID not found for building filter: $_buildingFilter');
      }

      print('Making API call with parameters:');
      print('- buildingID: ${_buildingFilter == "ALL" ? "null" : buildingId}');
      print('- roomID: ${_todayFilter == "ALL" ? "null" : roomId}');
      print('- userID: ${_showOnlyMyReservations ? userId : "null"}');

      // Get reservations using the API endpoint with correct building ID
      final response = await _apiService.getAllReservationLogs(
        buildingID: _buildingFilter == "ALL" ? null : buildingId,
        roomID: _todayFilter == "ALL" ? null : roomId,
        userID: _showOnlyMyReservations ? userId : null,
        startDate: startDate,
        endDate: endDate,
      );

      print('API response status code: ${response.statusCode}');
      print(
          'API response body preview: ${response.body.length > 100 ? response.body.substring(0, 100) + "..." : response.body}');

      // Check if response is HTML instead of JSON
      if (response.body.trim().startsWith('<!DOCTYPE') ||
          response.body.trim().startsWith('<html')) {
        setState(() {
          error =
              "Server returned HTML instead of JSON. Check server configuration.";
          isLoading = false;
        });
        return;
      }

      final responseData = jsonDecode(response.body);
      print('API success: ${responseData["success"]}');

      // Special case for "No reservation logs found" - not a real error, just empty data
      if (response.statusCode == 404 &&
          responseData["message"] ==
              "No reservation logs found for the provided filters") {
        print(
            'No reservations found for the selected filters - showing empty state');
        setState(() {
          reservations = []; // Empty the reservations list
          // Group reservations which will be empty
          _groupReservationsByDate();
          isLoading = false;
          isInitialLoad = false;
          isConnectionError = false;
          error = null; // No error, just empty data
        });
        return;
      } else if (responseData["success"] == true) {
        final List<dynamic> data = responseData["data"] as List;
        print('Reservations received: ${data.length}');
        reservations = List<Map<String, dynamic>>.from(data);

        // Process the received reservations - ensure they have building and room names
        for (var reservation in reservations) {
          // Get room information if missing
          if (!reservation.containsKey("building_name") ||
              !reservation.containsKey("room_name") ||
              reservation["building_name"] == null ||
              reservation["room_name"] == null ||
              reservation["building_name"].toString().isEmpty ||
              reservation["room_name"].toString().isEmpty) {
            final int roomId =
                int.tryParse(reservation["roomID"]?.toString() ?? "") ?? 0;
            if (roomId > 0) {
              // Find building and room names for this room ID
              for (var building in buildings) {
                int buildingId = building["id"];
                String buildingName = building["building_name"] ?? "";

                List<dynamic> rooms = roomsByBuilding[buildingId] ?? [];
                for (var room in rooms) {
                  if (room["id"] == roomId) {
                    reservation['room_name'] = room["room_name"] ?? "";
                    reservation['building_name'] = buildingName;
                    print(
                        'Set room info: ${reservation['room_name']} in building: ${reservation['building_name']}');
                    break;
                  }
                }

                // If we found and set room info, no need to continue checking other buildings
                if (reservation.containsKey("room_name") &&
                    reservation["room_name"] != null &&
                    reservation["room_name"].toString().isNotEmpty) {
                  break;
                }
              }
            }
          }
        }

        // Group reservations by date
        _groupReservationsByDate();

        setState(() {
          isLoading = false;
          isInitialLoad = false; // Mark that initial load is complete
          isConnectionError = false;
        });
      } else {
        print('API error message: ${responseData["message"]}');
        setState(() {
          error = responseData["message"] ?? "Failed to load reservations";
          isLoading = false;
          isInitialLoad = false; // Mark that initial load is complete
        });
      }
    } on SocketException catch (e) {
      print('SocketException: $e');
      setState(() {
        isConnectionError = true;
        error =
            "Unable to connect to server. Please check your internet connection.";
        isLoading = false;
        isInitialLoad = false; // Mark that initial load is complete
      });
    } catch (e) {
      print('General exception in _loadReservationsWithDateRange: $e');
      setState(() {
        error = "Something went wrong. Please try again. Error: $e";
        isLoading = false;
        isInitialLoad = false; // Mark that initial load is complete
      });
    }
  }

  // Load reservations for a specific room
  Future<void> _loadReservationsForRoom(int roomId) async {
    // Create start date with time 00:00:00
    final DateTime startDate =
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    // Create end date with time 23:59:59
    final DateTime endDate = DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59, 59);

    // Use the new method with proper date range
    _loadReservationsWithDateRange(roomId, startDate, endDate);
  }

  void _groupReservationsByDate() {
    groupedReservations = {};

    // Apply filters
    var filteredReservations = reservations.where((res) {
      // Date filter - filter by selected date
      try {
        // Check if day field exists, if not extract from datetime_interval
        String dateStr = "";
        if (res.containsKey("day") &&
            res["day"] != null &&
            res["day"].toString().isNotEmpty) {
          dateStr = res["day"].toString();
        } else if (res.containsKey("datetime_interval") &&
            res["datetime_interval"] != null) {
          // Try to extract date from datetime_interval which is like "2025-04-22 10:00 - 11:30"
          String interval = res["datetime_interval"].toString();
          if (interval.contains("-")) {
            // Extract the date part before the first space
            dateStr = interval.split(" ")[0];

            // Also add the day field to the reservation object for later use
            res['day'] = dateStr;
          }
        }

        if (dateStr.isEmpty) {
          print("Warning: Couldn't find valid date in reservation: $res");
          return false;
        }

        print("Parsing date: $dateStr");

        // Try to parse the date string
        DateTime reservationDate;
        try {
          reservationDate = DateTime.parse(dateStr);
        } catch (parseError) {
          print("Date format error, trying alternative format: $parseError");
          // Try alternative format if standard ISO format fails
          // If it's in format like "22/04/2025"
          if (dateStr.contains("/")) {
            List<String> parts = dateStr.split("/");
            if (parts.length == 3) {
              int day = int.tryParse(parts[0]) ?? 1;
              int month = int.tryParse(parts[1]) ?? 1;
              int year = int.tryParse(parts[2]) ?? 2025;
              reservationDate = DateTime(year, month, day);
            } else {
              print("Invalid date parts: $parts");
              return false;
            }
          } else {
            // If all parsing attempts fail
            print("All date parsing attempts failed for: $dateStr");
            return false;
          }
        }

        final reservationDay = DateTime(
            reservationDate.year, reservationDate.month, reservationDate.day);

        final selectedDay = DateTime(
            _selectedDate.year, _selectedDate.month, _selectedDate.day);

        // Only show reservations for the selected date
        if (reservationDay != selectedDay) {
          return false;
        }
      } catch (e) {
        print(
            "Date parsing error: $e for reservation: ${res.toString().substring(0, res.toString().length > 100 ? 100 : res.toString().length)}...");
        return false;
      }

      // Building filter
      if (_buildingFilter != "ALL") {
        String buildingName = res["building_name"] ?? "";
        if (buildingName != _buildingFilter) {
          return false;
        }
      }

      // Room filter
      if (_todayFilter != "ALL") {
        String roomName = res["room_name"] ?? "";
        if (roomName != _todayFilter) {
          return false;
        }
      }

      // My reservations filter
      if (_showOnlyMyReservations) {
        // In a real app, you would check against the logged-in user's name or ID
        // For demo purposes, we're assuming any reservation by "Fidan" is the user's
        String reservationBy = res["reservation_by"] ?? "";
        if (reservationBy.toLowerCase() != "fidan") {
          return false;
        }
      }

      return true;
    }).toList();

    // Sort filtered reservations by room name first, then by time
    filteredReservations.sort((a, b) {
      // First compare by room name
      String roomNameA = a["room_name"] ?? "";
      String roomNameB = b["room_name"] ?? "";

      int roomComparison = roomNameA.compareTo(roomNameB);
      if (roomComparison != 0) {
        return roomComparison;
      }

      // If room names are the same, compare by start time
      String timeIntervalA = a["datetime_interval"] ?? "";
      String timeIntervalB = b["datetime_interval"] ?? "";

      // Extract just start time for comparison
      String startTimeA = _extractStartTime(timeIntervalA);
      String startTimeB = _extractStartTime(timeIntervalB);

      return startTimeA.compareTo(startTimeB);
    });

    // Group by date
    for (var reservation in filteredReservations) {
      String dateKey = reservation["day"] ?? "";
      if (dateKey.isNotEmpty) {
        if (!groupedReservations.containsKey(dateKey)) {
          groupedReservations[dateKey] = [];
        }
        groupedReservations[dateKey]!.add(reservation);
      } else {
        print("Warning: Empty dateKey for reservation: $reservation");
      }
    }
  }

  // Helper method to extract start time from datetime_interval
  String _extractStartTime(String timeInterval) {
    if (timeInterval.isEmpty) return "";

    try {
      // Format is typically like "2025-04-22 10:00 - 11:30" or "10:00 - 11:30"
      List<String> parts = timeInterval.split(" ");
      if (parts.length >= 3) {
        // If format includes date: "2025-04-22 10:00 - 11:30"
        return parts[1]; // Return "10:00"
      } else if (parts.length >= 2) {
        // If format is just time: "10:00 - 11:30"
        return parts[0]; // Return "10:00"
      }
    } catch (e) {
      print("Error extracting start time: $e");
    }

    return timeInterval; // Return original as fallback
  }

  // Format date for display (e.g., "MAY 1")
  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM d').format(date).toUpperCase();
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isConnectionError) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.grey),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Room reservation',
            style: TextStyle(
              color: const Color(0xFFA54D66),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off, size: 64, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text(
                "Connection error",
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  "Unable to connect to server. Please check your internet connection.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _checkConnectionAndLoadData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3A6381),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Retry",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Only show full-screen loading on initial load
    if (isLoading && isInitialLoad) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.grey),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Room reservation',
            style: TextStyle(
              color: const Color(0xFFA54D66),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: const Color(0xFF3A6381),
              ),
              SizedBox(height: 24),
              Text(
                "Loading reservation information...",
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Room reservation',
          style: TextStyle(
            color: const Color(0xFFA54D66),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.grey),
            onPressed: () {/* Settings action */},
          ),
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: Icon(Icons.email_outlined, color: Colors.grey),
                onPressed: () {/* Notifications action */},
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA54D66),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '1',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          // Building filter tabs (horizontal scrollable list)
          Container(
            height: 45,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterTab("ALL", isActive: _buildingFilter == "ALL"),
                  SizedBox(width: 8),
                  // Dynamic building tabs from API
                  ...buildings.map((building) {
                    final buildingName = building["building_name"] ?? "";
                    return Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: _buildFilterTab(buildingName,
                          isActive: _buildingFilter == buildingName),
                    );
                  }).toList(),
                  // Fallback if no buildings loaded
                  if (buildings.isEmpty) ...[
                    _buildFilterTab("A", isActive: _buildingFilter == "A"),
                    SizedBox(width: 8),
                    _buildFilterTab("B", isActive: _buildingFilter == "B"),
                  ]
                ],
              ),
            ),
          ),

          // Today filter with rooms
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Today label with date picker - make more clickable
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: InkWell(
                    onTap: () => _showDatePicker(),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Text(
                            _isSelectedDateToday()
                                ? "Today"
                                : DateFormat('MMM d').format(_selectedDate),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.calendar_today,
                            size: 18,
                            color: const Color(0xFF3A6381),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                // Room filter (horizontal scrollable list)
                Container(
                  height: 38,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildSmallFilterTab("ALL",
                            isActive: _todayFilter == "ALL"),
                        SizedBox(width: 8),
                        // Dynamic room tabs based on selected building
                        if (_buildingFilter != "ALL") ...[
                          // Get rooms for the selected building
                          ...buildings
                              .where(
                                  (b) => b["building_name"] == _buildingFilter)
                              .expand((building) {
                            int buildingId = building["id"];
                            // Get rooms for this building
                            return (roomsByBuilding[buildingId] ?? [])
                                .map((room) {
                              final roomName = room["room_name"] ?? "";
                              return Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: _buildSmallFilterTab(roomName,
                                    isActive: _todayFilter == roomName),
                              );
                            });
                          })
                        ]
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Reservations list
          Expanded(
            child: _buildReservationsList(),
          ),

          // Bottom bar: My Reservations toggle and Create button
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // My Reservations toggle moved to the bottom left
                Row(
                  children: [
                    Text(
                      "My Reservations",
                      style: TextStyle(
                        color: const Color(0xFF3A6381),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 8),
                    Switch(
                      value: _showOnlyMyReservations,
                      onChanged: (value) {
                        setState(() {
                          _showOnlyMyReservations = value;
                          // Instead of just filtering locally, reload from the server
                          // This will use the userID parameter in the API call
                          if (_todayFilter != "ALL") {
                            // If a specific room is selected, reload for that room
                            for (var building in buildings) {
                              List<dynamic> rooms =
                                  roomsByBuilding[building["id"]] ?? [];
                              for (var room in rooms) {
                                if (room["room_name"] == _todayFilter) {
                                  _loadReservationsForRoom(room["id"]);
                                  return;
                                }
                              }
                            }
                          } else {
                            // If no specific room is selected, load default
                            _loadReservations();
                          }
                        });
                      },
                      activeColor: const Color(0xFFA54D66),
                    ),
                  ],
                ),

                SizedBox(width: 16),

                // Create button (on the right)
                ElevatedButton(
                  onPressed: () async {
                    // Navigate to reservation details screen and await result
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReservationDetailsScreen(
                          selectedRoom: _todayFilter != "ALL"
                              ? {
                                  "room_name": _todayFilter,
                                  "building_name": _buildingFilter,
                                }
                              : null,
                          buildings: buildings,
                          roomsByBuilding: roomsByBuilding,
                        ),
                      ),
                    );

                    // If result is true (reservation was created), refresh data
                    if (result == true) {
                      _refreshReservations();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4CAF50), // Green color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(
                    'CREATE',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Building filter tab (larger)
  Widget _buildFilterTab(String title, {required bool isActive}) {
    return InkWell(
      onTap: () {
        setState(() {
          // Store previous filter value to check if we're switching to ALL
          final String previousBuildingFilter = _buildingFilter;

          // Update filter
          _buildingFilter = title;

          // Reset room filter to ALL when changing buildings
          _todayFilter = "ALL";

          // If switching to ALL buildings, we need to fetch all data
          if (title == "ALL") {
            print("Switching to ALL buildings - reloading all reservations");
            // Load all reservations with a fresh API call
            _loadReservations();
            return;
          }
          // If a specific building is selected (not ALL)
          else if (title != "ALL") {
            // Find the building ID for the selected building name
            int? buildingId;
            for (var building in buildings) {
              if (building["building_name"] == title) {
                buildingId = building["id"];
                break;
              }
            }

            // If we found the building ID and it has rooms
            if (buildingId != null && roomsByBuilding.containsKey(buildingId)) {
              final rooms = roomsByBuilding[buildingId] ?? [];
              // If there are rooms for this building, select the first one and load its reservations
              if (rooms.isNotEmpty) {
                _todayFilter = "ALL"; // Show ALL rooms for this building
                // Make fresh API call to load all rooms for this building
                _loadReservations();
                return;
              }
            }
          }

          // Fallback - just update the existing data filtering
          _groupReservationsByDate();
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: title == "ALL"
              ? (isActive ? const Color(0xFFC25B67) : Colors.transparent)
              : (isActive ? const Color(0xFF3A6381) : Colors.transparent),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: title == "ALL"
                ? (isActive ? const Color(0xFFC25B67) : const Color(0xFFC25B67))
                : (isActive
                    ? const Color(0xFF3A6381)
                    : const Color(0xFF3A6381)),
            width: 1,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Text(
          title,
          style: TextStyle(
            color: isActive
                ? Colors.white
                : (title == "ALL"
                    ? const Color(0xFFC25B67)
                    : const Color(0xFF3A6381)),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // Room filter tab (smaller)
  Widget _buildSmallFilterTab(String title, {required bool isActive}) {
    return InkWell(
      onTap: () {
        setState(() {
          // Store previous filter value to check if we're switching to ALL
          final String previousRoomFilter = _todayFilter;

          // Update filter
          _todayFilter = title;

          // If switching to ALL rooms, make a fresh API call
          if (title == "ALL" && previousRoomFilter != "ALL") {
            print(
                "Switching to ALL rooms - reloading all reservations for current building");
            // Reload all reservations for the current building selection
            _loadReservations();
            return;
          }
          // If a specific room is selected (not ALL)
          else if (title != "ALL") {
            // Find the room ID for the selected room name
            int? roomId;

            // Get all rooms for the selected building or all rooms if ALL buildings are selected
            List<dynamic> availableRooms = [];
            if (_buildingFilter == "ALL") {
              // Collect all rooms from all buildings
              roomsByBuilding.values.forEach((rooms) {
                availableRooms.addAll(rooms);
              });
            } else {
              // Find the building ID for the selected building
              int? buildingId;
              for (var building in buildings) {
                if (building["building_name"] == _buildingFilter) {
                  buildingId = building["id"];
                  break;
                }
              }
              // Get rooms for the selected building
              if (buildingId != null) {
                availableRooms = roomsByBuilding[buildingId] ?? [];
              }
            }

            // Find the room with the matching name
            for (var room in availableRooms) {
              if (room["room_name"] == title) {
                roomId = room["id"];
                break;
              }
            }

            // Load reservations for this room if found
            if (roomId != null) {
              _loadReservationsForRoom(roomId);
              return;
            }
          }

          // Fallback - just update the filtering on existing data
          _groupReservationsByDate();
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: title == "ALL"
              ? (isActive ? const Color(0xFFC25B67) : Colors.transparent)
              : (isActive ? const Color(0xFF3A6381) : Colors.transparent),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: title == "ALL"
                ? (isActive ? const Color(0xFFC25B67) : const Color(0xFFC25B67))
                : (isActive
                    ? const Color(0xFF3A6381)
                    : const Color(0xFF3A6381)),
            width: 1,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Text(
          title,
          style: TextStyle(
            color: isActive
                ? Colors.white
                : (title == "ALL"
                    ? const Color(0xFFC25B67)
                    : const Color(0xFF3A6381)),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // Build list of reservations grouped by date
  Widget _buildReservationsList() {
    // Loading state - show spinner in content area
    if (isLoading && !isInitialLoad) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: const Color(0xFF3A6381),
            ),
            SizedBox(height: 16),
            Text(
              "Loading...",
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    // Error state
    if (error != null && !isConnectionError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            SizedBox(height: 16),
            Text(
              "Something went wrong",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Please try again later",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadReservations,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3A6381),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Retry",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (groupedReservations.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshReservations,
        color: const Color(0xFF3A6381),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 48, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    "No reservations found",
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Pull down to refresh",
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Sort dates (most recent first)
    List<String> sortedDates = groupedReservations.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    // Special handling for ALL filter - group by building
    if (_buildingFilter == "ALL") {
      return _buildReservationsGroupedByBuilding(sortedDates);
    } else {
      return _buildReservationsGroupedByDate(sortedDates);
    }
  }

  // Build reservations grouped by date
  Widget _buildReservationsGroupedByDate(List<String> sortedDates) {
    List<Widget> reservationWidgets = [];

    for (var date in sortedDates) {
      // Add date header
      reservationWidgets.add(
        Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            _formatDate(date),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );

      // Add reservations for this date
      for (var reservation in groupedReservations[date]!) {
        reservationWidgets.add(
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: _buildReservationCard(reservation),
          ),
        );
      }
    }

    // If there are no reservations, add a placeholder to make pull-to-refresh work
    if (reservationWidgets.isEmpty) {
      reservationWidgets.add(
        Container(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(
            child: Text(
              "Pull down to refresh",
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 16,
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshReservations,
      color: const Color(0xFF3A6381),
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Container(
          // Min height ensures pull-to-refresh works with little content
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: reservationWidgets,
          ),
        ),
      ),
    );
  }

  // Build reservations grouped by building for ALL filter
  Widget _buildReservationsGroupedByBuilding(List<String> sortedDates) {
    List<Widget> reservationWidgets = [];

    // First, group all reservations by building
    Map<String, List<Map<String, dynamic>>> buildingReservations = {};

    for (var date in sortedDates) {
      for (var reservation in groupedReservations[date]!) {
        String buildingName = reservation["building_name"] ?? "Unknown";

        if (!buildingReservations.containsKey(buildingName)) {
          buildingReservations[buildingName] = [];
        }
        buildingReservations[buildingName]!.add(reservation);
      }
    }

    // Sort buildings alphabetically
    List<String> buildingNames = buildingReservations.keys.toList()..sort();

    // Display reservations grouped by building
    for (var buildingName in buildingNames) {
      // Add building header
      reservationWidgets.add(
        Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            "Building: $buildingName",
            style: TextStyle(
              color: const Color(0xFF3A6381),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );

      // Sort reservations by room within this building, then by time
      List<Map<String, dynamic>> sortedBuildingReservations =
          List.from(buildingReservations[buildingName]!);
      sortedBuildingReservations.sort((a, b) {
        // First compare by room name
        String roomNameA = a["room_name"] ?? "";
        String roomNameB = b["room_name"] ?? "";

        int roomComparison = roomNameA.compareTo(roomNameB);
        if (roomComparison != 0) {
          return roomComparison;
        }

        // If room names are the same, compare by start time
        String timeIntervalA = a["datetime_interval"] ?? "";
        String timeIntervalB = b["datetime_interval"] ?? "";

        // Extract just start time for comparison
        String startTimeA = _extractStartTime(timeIntervalA);
        String startTimeB = _extractStartTime(timeIntervalB);

        return startTimeA.compareTo(startTimeB);
      });

      // Group by room within this building
      Map<String, List<Map<String, dynamic>>> roomReservations = {};
      for (var reservation in sortedBuildingReservations) {
        String roomName = reservation["room_name"] ?? "Unknown Room";
        if (!roomReservations.containsKey(roomName)) {
          roomReservations[roomName] = [];
        }
        roomReservations[roomName]!.add(reservation);
      }

      // Get sorted room names
      List<String> roomNames = roomReservations.keys.toList()..sort();

      // Display reservations for each room
      for (var roomName in roomNames) {
        // Add room header
        reservationWidgets.add(
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              "Room: $roomName",
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );

        // Add reservations for this room (already sorted by time)
        for (var reservation in roomReservations[roomName]!) {
          reservationWidgets.add(
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: _buildReservationCard(reservation),
            ),
          );
        }
      }
    }

    // If there are no reservations, add a placeholder to make pull-to-refresh work
    if (reservationWidgets.isEmpty) {
      reservationWidgets.add(
        Container(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(
            child: Text(
              "Pull down to refresh",
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 16,
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshReservations,
      color: const Color(0xFF3A6381),
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Container(
          // Min height ensures pull-to-refresh works with little content
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: reservationWidgets,
          ),
        ),
      ),
    );
  }

  // Build individual reservation card
  Widget _buildReservationCard(Map<String, dynamic> reservation) {
    // Extract the person's name (and add surname if available)
    String personName = reservation["reservation_by"] ?? "";

    // Get room information
    String roomName = reservation["room_name"] ?? "";
    String buildingName = reservation["building_name"] ?? "";

    // Check if roomName already includes the building name to avoid duplication
    String roomDisplay = "Unknown Room";

    if (roomName.isNotEmpty) {
      // Check if room name already starts with building name
      if (roomName.startsWith(buildingName)) {
        roomDisplay = roomName;
      } else {
        roomDisplay = "$buildingName$roomName";
      }
    } else if (buildingName.isNotEmpty) {
      roomDisplay = buildingName;
    }

    // Extract only the time portion from datetime_interval to prevent overflow
    String timeInterval = "";
    if (reservation["datetime_interval"] != null) {
      String fullInterval = reservation["datetime_interval"].toString();

      // Try to extract only the time part
      try {
        // If format is like "2025-04-22 10:00 - 11:30"
        if (fullInterval.contains("-")) {
          List<String> parts = fullInterval.split(" ");

          // If we have at least 4 parts: date, start time, hyphen, end time
          if (parts.length >= 4) {
            // Just take the start and end time (parts[1] and parts[3])
            timeInterval = "${parts[1]} - ${parts[3]}";
          } else {
            // Fallback to the original if the format is unexpected
            timeInterval = fullInterval;
          }
        } else {
          timeInterval = fullInterval;
        }
      } catch (e) {
        print('Error extracting time from interval: $e');
        timeInterval = fullInterval;
      }
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFA54D66), width: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side: reservation info
          Expanded(
            flex: 2, // Changed from 3 to 2 to give more space to time
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Reservation by: $personName",
                  style: TextStyle(
                    color: const Color(0xFF3A6381),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                SizedBox(height: 6),
                Text(
                  "Room: $roomDisplay",
                  style: TextStyle(
                    color: const Color(0xFF3A6381),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),

          SizedBox(width: 8), // Add spacing between the two columns

          // Right side: time - now with more space and properly aligned
          Container(
            width: 100, // Fixed width to ensure enough space for the time
            alignment: Alignment.centerRight, // Align to the right
            child: Text(
              timeInterval,
              style: TextStyle(
                color: const Color(0xFFA54D66),
                fontSize: 15, // Slightly smaller font size for better fit
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.visible, // Allow text to be fully visible
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to check if selected date is today
  bool _isSelectedDateToday() {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  // Helper function to show date picker
  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // Don't just update filtering, reload the data with the new date
        print('Date changed to: ${_selectedDate.toString()}');
      });

      // Reload reservations with the new date instead of just filtering existing data
      if (_todayFilter != "ALL") {
        // Find room ID for the current room filter
        int? roomId;
        for (var buildingId in roomsByBuilding.keys) {
          for (var room in roomsByBuilding[buildingId] ?? []) {
            if (room["room_name"] == _todayFilter) {
              roomId = room["id"];
              break;
            }
          }
          if (roomId != null) break;
        }

        // If found, load reservations for this room
        if (roomId != null) {
          await _loadReservationsForRoom(roomId);
        } else {
          // Fallback to default room
          await _loadReservations();
        }
      } else {
        // Load all reservations
        await _loadReservations();
      }
    }
  }

  // Refresh function to reload reservations
  Future<void> _refreshReservations() async {
    print('Starting refresh operation...');

    // Show loading indicator
    setState(() {
      isLoading = true;
      isConnectionError = false;
      error = null;
    });

    try {
      // Check internet connection first
      print('Checking internet connection...');
      await _checkInternetConnection();
      print('Internet connection available');

      // Reload buildings and rooms data first
      print('Reloading buildings and rooms data...');
      await _loadBuildingsAndRooms();
      print('Buildings and rooms data loaded successfully');

      // Then reload reservations based on current filters
      if (_todayFilter != "ALL") {
        print('Looking for room ID for filter: $_todayFilter');
        // Find room ID for the current room filter
        int? roomId;
        for (var buildingId in roomsByBuilding.keys) {
          for (var room in roomsByBuilding[buildingId] ?? []) {
            if (room["room_name"] == _todayFilter) {
              roomId = room["id"];
              print('Found room ID: $roomId for room: $_todayFilter');
              break;
            }
          }
          if (roomId != null) break;
        }

        // If found, load reservations for this room
        if (roomId != null) {
          print('Loading reservations for specific room (ID: $roomId)');
          await _loadReservationsForRoom(roomId);
          print('Reservations loaded for room ID: $roomId');
        } else {
          print('Room ID not found, loading default reservations');
          // Fallback to default room
          await _loadReservations();
        }
      } else {
        print('Loading all reservations');
        // Load default reservations
        await _loadReservations();
      }

      // Refresh UI
      setState(() {
        isLoading = false;
        isConnectionError = false;
      });
      print('Refresh completed successfully');
    } catch (e) {
      print('Error during refresh: $e');
      setState(() {
        isLoading = false;
        isConnectionError = true;
        error =
            "Unable to connect to server. Please check your internet connection.";
      });

      // Show a snackbar to notify user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to refresh: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }

    return;
  }
}
