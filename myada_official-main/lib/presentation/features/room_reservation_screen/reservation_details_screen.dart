import 'dart:convert';

import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import 'package:intl/intl.dart';
import 'package:myada_official/core/app_export.dart';
import 'package:myada_official/core/network/api_service.dart';

class ReservationDetailsScreen extends StatefulWidget {
  final Map<String, dynamic>? selectedRoom;
  final List<Map<String, dynamic>> buildings;
  final Map<int, List<Map<String, dynamic>>> roomsByBuilding;

  const ReservationDetailsScreen({
    Key? key,
    this.selectedRoom,
    required this.buildings,
    required this.roomsByBuilding,
  }) : super(key: key);

  @override
  _ReservationDetailsScreenState createState() =>
      _ReservationDetailsScreenState();
}

class _ReservationDetailsScreenState extends State<ReservationDetailsScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _participantsController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  // Form values
  String _userName = "Fidan Mardanli"; // Will be loaded from user data
  String? _selectedEventType;
  List<String> _selectedInventory = [];
  Map<String, dynamic>? _selectedRoom;
  int? _selectedRoomId; // Added for dropdown value

  // Date and time values
  DateTime _startDateTime = DateTime.now();
  DateTime _endDateTime =
      DateTime.now().add(Duration(minutes: 90)); // Changed to 1h30m max

  // Constants
  final Duration _maxDuration = Duration(minutes: 90); // 1 hour 30 minutes

  // Loading state
  bool _isLoading = false;
  String? _errorMessage;
  bool _reservationSuccess =
      false; // Added to track if reservation was successful

  // Available options
  final List<String> _eventTypes = ["Lecture", "Exam", "Meeting", "Other"];
  final List<String> _roomInventoryOptions = [
    "Camera and microphone",
    "Speaker",
    "Smartboard or Projector",
    "Computer",
    "TV",
    "Translation"
  ];

  // Filtered rooms
  Map<String, List<Map<String, dynamic>>> _availableRoomsByBuilding = {};
  // Reservations cache to avoid multiple API calls
  Map<int, List<Map<String, dynamic>>> _roomReservations = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadDraftIfExists();

    // Set selected room from props if available
    if (widget.selectedRoom != null) {
      _selectedRoom = widget.selectedRoom;
      // Find room ID for the selected room
      _findRoomIdByName();
    }

    _filterAvailableRooms();

    // Initialize date and time controllers
    _updateDateTimeControllers();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _apiService.getUserData();
      if (userData != null) {
        setState(() {
          _userName =
              "${userData['name'] ?? 'Fidan'} ${userData['surname'] ?? 'Mardanli'}";
        });
      }
    } catch (e) {
      print("Error loading user data: $e");
    }
  }

  void _updateDateTimeControllers() {
    _startDateController.text = DateFormat('MM/dd/yyyy').format(_startDateTime);
    _startTimeController.text = DateFormat('HH:mm').format(_startDateTime);
    _endDateController.text = DateFormat('MM/dd/yyyy').format(_endDateTime);
    _endTimeController.text = DateFormat('HH:mm').format(_endDateTime);
  }

  Future<void> _loadDraftIfExists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draftData = prefs.getString('reservation_draft');

      if (draftData != null) {
        final data = json.decode(draftData);
        final now = DateTime.now();

        // First load date and time without filtering rooms yet
        if (data['start_time'] != null && data['end_time'] != null) {
          DateTime startTime = DateTime.parse(data['start_time'] as String);
          DateTime endTime = DateTime.parse(data['end_time'] as String);

          // Check if the saved times are in the past
          bool timeAdjusted = false;

          // If start time is in the past, adjust both times
          if (startTime.isBefore(now)) {
            // Calculate how long the original reservation was
            final originalDuration = endTime.difference(startTime);

            // Set start time to now
            startTime = now;

            // Set end time to now + original duration (limited by max duration)
            Duration newDuration = originalDuration;
            if (newDuration > _maxDuration) {
              newDuration = _maxDuration;
            }

            endTime = now.add(newDuration);
            timeAdjusted = true;
          }

          // If only the end time is in the past (unusual case but handle it)
          if (endTime.isBefore(now)) {
            endTime = now.add(Duration(minutes: 30));
            if (endTime.difference(startTime) > _maxDuration) {
              endTime = startTime.add(_maxDuration);
            }
            timeAdjusted = true;
          }

          setState(() {
            _startDateTime = startTime;
            _endDateTime = endTime;
            _updateDateTimeControllers();
          });

          // Show notification if times were adjusted
          if (timeAdjusted && mounted) {
            Future.microtask(() {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Reservation times have been adjusted to current time'),
                  backgroundColor: Colors.orange,
                ),
              );
            });
          }

          // Now load other data
          setState(() {
            _selectedEventType = data['event_type'] as String?;
            _descriptionController.text = data['description'] as String? ?? '';
            _selectedInventory =
                List<String>.from(data['room_inventory'] ?? []);
            _participantsController.text =
                (data['participant_number']?.toString() ?? '');
          });

          // Initialize available rooms without filtering
          _filterAvailableRooms();

          // Store the draft room ID to check later
          int? draftRoomId = data['room_id'] as int?;

          // Wait for room filtering to complete
          await _applyRoomAvailabilityFiltering();

          // Set the room if it's available
          if (draftRoomId != null && mounted) {
            // Find the room in available rooms
            bool roomFound = false;

            for (var buildingName in _availableRoomsByBuilding.keys) {
              for (var room in _availableRoomsByBuilding[buildingName] ?? []) {
                if (room["id"] == draftRoomId) {
                  roomFound = true;
                  _findAndSetRoomById(buildingName, draftRoomId);
                  break;
                }
              }
              if (roomFound) break;
            }

            if (!roomFound) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Previously selected room is no longer available at this time'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          }
        } else {
          // If no valid dates, load other data normally and set current time
          setState(() {
            _selectedEventType = data['event_type'] as String?;
            _descriptionController.text = data['description'] as String? ?? '';
            _selectedInventory =
                List<String>.from(data['room_inventory'] ?? []);
            _participantsController.text =
                (data['participant_number']?.toString() ?? '');

            // Set current time as default
            _startDateTime = now;
            _endDateTime = now.add(Duration(minutes: 90));
            _updateDateTimeControllers();
          });

          // Initialize available rooms
          _filterAvailableRooms();
        }
      }
    } catch (e) {
      print("Error loading draft: $e");
    }
  }

  // Find room ID for the selected room name
  void _findRoomIdByName() {
    if (_selectedRoom == null) return;

    String roomName = _selectedRoom!["room_name"] ?? "";
    String buildingName = _selectedRoom!["building_name"] ?? "";

    for (var building in widget.buildings) {
      if (building["building_name"] == buildingName) {
        int buildingId = building["id"];
        for (var room in widget.roomsByBuilding[buildingId] ?? []) {
          if (room["room_name"] == roomName) {
            _selectedRoomId = room["id"];
            return;
          }
        }
      }
    }
  }

  void _saveDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final Map<String, dynamic> draftData = {
        'event_type': _selectedEventType,
        'description': _descriptionController.text,
        'room_inventory': _selectedInventory,
        'participant_number': _participantsController.text.isEmpty
            ? null
            : int.tryParse(_participantsController.text),
        'start_time': _startDateTime.toIso8601String(),
        'end_time': _endDateTime.toIso8601String(),
        'room_id': _selectedRoom?['id'],
      };

      await prefs.setString('reservation_draft', json.encode(draftData));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reservation saved as draft')),
      );
    } catch (e) {
      print("Error saving draft: $e");
    }
  }

  Future<void> _showSaveDraftDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Save Draft?'),
          content: Text('Do you want to save this reservation as a draft?'),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                _saveDraft();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _filterAvailableRooms() {
    // If widget is already disposed, don't continue
    if (!mounted) return;

    // Reset available rooms
    setState(() {
      _availableRoomsByBuilding = {};
    });

    // Apply room filtering asynchronously
    _applyRoomAvailabilityFiltering();
  }

  Future<void> _applyRoomAvailabilityFiltering() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Create a copy of the start date/time for proper filtering
      final DateTime startDateTime = _startDateTime;

      // Create an end date time that ensures we cover the entire day (23:59:59)
      // If checking for all rooms, we want to see all reservations for the full day
      final DateTime endDateTime = DateTime(
          _endDateTime.year, _endDateTime.month, _endDateTime.day, 23, 59, 59);

      print('Fetching room availability:');
      print(
          'Start DateTime: $startDateTime (${startDateTime.toIso8601String()})');
      print('End DateTime: $endDateTime (${endDateTime.toIso8601String()})');

      // Make a single API call to get all available rooms for the selected time period
      // By not specifying roomID, buildingID, or userID, we get ALL available rooms
      final response = await _apiService.getAllReservationLogs(
        startDate: startDateTime,
        endDate: endDateTime,
      );

      print('API response status code: ${response.statusCode}');
      print(
          'API response body preview: ${response.body.length > 100 ? response.body.substring(0, 100) + "..." : response.body}');

      // Check if response is HTML instead of JSON
      if (response.body.trim().startsWith('<!DOCTYPE') ||
          response.body.trim().startsWith('<html')) {
        print('Error: Received HTML response instead of JSON');
        throw Exception('Server returned HTML instead of JSON');
      }

      final responseData = jsonDecode(response.body);
      print('API success: ${responseData["success"]}');

      // Special case for "No reservation logs found" - This means all rooms are available (not an error)
      if (response.statusCode == 404 &&
          responseData["message"] ==
              "No reservation logs found for the provided filters") {
        print(
            'No reservations found for the selected time - all rooms are available');

        // Get all available rooms (which will be all rooms since none are reserved)
        Map<String, List<Map<String, dynamic>>> allRoomsAvailable = {};

        // Iterate through all buildings and their rooms
        for (var building in widget.buildings) {
          int buildingId = building["id"];
          String buildingName = building["building_name"] ?? "";
          List<dynamic> rooms = widget.roomsByBuilding[buildingId] ?? [];

          print(
              'Adding all rooms in building: $buildingName (ID: $buildingId), total rooms: ${rooms.length}');

          if (rooms.isNotEmpty) {
            // Create list for this building if it doesn't exist
            if (!allRoomsAvailable.containsKey(buildingName)) {
              allRoomsAvailable[buildingName] = [];
            }

            // Add all rooms since none are reserved
            for (var room in rooms) {
              int roomId = room["id"];
              allRoomsAvailable[buildingName]!.add({
                "id": roomId,
                "room_name": room["room_name"],
                "building_name": buildingName,
              });
              print('Room ${room["room_name"]} (ID: $roomId) is available');
            }
          }
        }

        // Update state with all rooms available
        if (mounted) {
          setState(() {
            _availableRoomsByBuilding = allRoomsAvailable;
            _isLoading = false;
          });
        }
        return;
      }

      if (response.statusCode != 200) {
        print('Error: Non-200 status code: ${response.statusCode}');
        throw Exception(
            'Failed to load available rooms - status code: ${response.statusCode}');
      }

      // Prepare a map of room IDs that are already reserved during this time
      Set<int> reservedRoomIds = {};
      if (responseData["success"] == true && responseData["data"] is List) {
        List<dynamic> reservedRooms = responseData["data"];
        print('Reserved rooms count: ${reservedRooms.length}');

        for (var room in reservedRooms) {
          if (room["roomID"] != null) {
            int roomId = int.parse(room["roomID"].toString());
            reservedRoomIds.add(roomId);
            print('Room ID ${roomId} is reserved');
          }
        }
      } else {
        print('No reservation data found or success is false');
        if (responseData["message"] != null) {
          print('API message: ${responseData["message"]}');
        }
      }

      // Get all available rooms by filtering out reserved ones
      Map<String, List<Map<String, dynamic>>> filteredRooms = {};

      // Iterate through all buildings and their rooms
      for (var building in widget.buildings) {
        int buildingId = building["id"];
        String buildingName = building["building_name"] ?? "";
        List<dynamic> rooms = widget.roomsByBuilding[buildingId] ?? [];

        print(
            'Checking rooms in building: $buildingName (ID: $buildingId), total rooms: ${rooms.length}');

        if (rooms.isNotEmpty) {
          // Create list for this building if it doesn't exist
          if (!filteredRooms.containsKey(buildingName)) {
            filteredRooms[buildingName] = [];
          }

          // Add all rooms that are not reserved
          for (var room in rooms) {
            int roomId = room["id"];
            if (!reservedRoomIds.contains(roomId)) {
              filteredRooms[buildingName]!.add({
                "id": roomId,
                "room_name": room["room_name"],
                "building_name": buildingName,
              });
              print('Room ${room["room_name"]} (ID: $roomId) is available');
            } else {
              print(
                  'Room ${room["room_name"]} (ID: $roomId) is already reserved');
            }
          }

          // Remove buildings with no available rooms
          if (filteredRooms[buildingName]!.isEmpty) {
            print('No available rooms in building: $buildingName');
            filteredRooms.remove(buildingName);
          } else {
            print(
                'Available rooms in building $buildingName: ${filteredRooms[buildingName]!.length}');
          }
        }
      }

      // Update state with filtered rooms
      if (mounted) {
        setState(() {
          _availableRoomsByBuilding = filteredRooms;
          _isLoading = false;

          // Check if selected room is still available
          if (_selectedRoomId != null) {
            bool stillAvailable = false;
            String? buildingName;

            outerLoop:
            for (var bName in _availableRoomsByBuilding.keys) {
              for (var room in _availableRoomsByBuilding[bName] ?? []) {
                if (room["id"] == _selectedRoomId) {
                  stillAvailable = true;
                  buildingName = bName;
                  print(
                      'Selected room (ID: $_selectedRoomId) is still available in building: $bName');
                  break outerLoop;
                }
              }
            }

            if (!stillAvailable) {
              print(
                  'Selected room (ID: $_selectedRoomId) is no longer available');
              _selectedRoom = null;
              _selectedRoomId = null;

              // Notify user that the room is no longer available
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Selected room is no longer available at this time'),
                  backgroundColor: Colors.orange,
                ),
              );
            } else if (buildingName != null && _selectedRoom != null) {
              // Make sure the building name is updated correctly
              _selectedRoom = {
                "id": _selectedRoomId!,
                "room_name": _selectedRoom!["room_name"] ?? "",
                "building_name": buildingName,
              };
            }
          }
        });
      }
    } catch (e) {
      print('Exception in _applyRoomAvailabilityFiltering: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Show error message if needed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading available rooms: $e'),
              backgroundColor: Colors.red,
            ),
          );
        });
      }
    }
  }

  DateTime _parseDateTime(String date, String time) {
    // Parse a date and time string into a DateTime object
    List<String> timeParts = time.split(":");
    int hour = int.tryParse(timeParts[0]) ?? 0;
    int minute = int.tryParse(timeParts[1]) ?? 0;

    try {
      DateTime dateTime = DateTime.parse(date);
      return DateTime(
          dateTime.year, dateTime.month, dateTime.day, hour, minute);
    } catch (e) {
      // If parsing fails, return current date with given time
      DateTime now = DateTime.now();
      return DateTime(now.year, now.month, now.day, hour, minute);
    }
  }

  bool _isTimeOverlap(
      DateTime start1, DateTime end1, DateTime start2, DateTime end2) {
    // Check if two time periods overlap
    return start1.isBefore(end2) && start2.isBefore(end1);
  }

  void _selectDateTime(bool isStartTime) {
    // Get current date and time for comparison
    final now = DateTime.now();

    picker.DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      // Set minimum time to current date and time
      minTime: now,
      maxTime: DateTime(2030),
      onConfirm: (date) {
        // Extra validation to ensure date is not in the past
        if (date.isBefore(now)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cannot select a time in the past')),
          );
          return;
        }

        if (mounted) {
          setState(() {
            if (isStartTime) {
              // Update start time
              _startDateTime = date;
              _startDateController.text =
                  DateFormat('MM/dd/yyyy').format(_startDateTime);
              _startTimeController.text =
                  DateFormat('HH:mm').format(_startDateTime);

              // Calculate new end time based on max duration
              DateTime maxEndTime = _startDateTime.add(_maxDuration);

              // If current end time is now before start time or exceeds max duration, adjust it
              if (_endDateTime.isBefore(_startDateTime) ||
                  _endDateTime.difference(_startDateTime) > _maxDuration) {
                _endDateTime = maxEndTime;
                _endDateController.text =
                    DateFormat('MM/dd/yyyy').format(_endDateTime);
                _endTimeController.text =
                    DateFormat('HH:mm').format(_endDateTime);
              }
            } else {
              // For end time, ensure it's after start time and within max duration
              if (date.isAfter(_startDateTime)) {
                // Calculate the duration between start and selected time
                Duration selectedDuration = date.difference(_startDateTime);

                // If selected time exceeds max duration, cap it
                if (selectedDuration > _maxDuration) {
                  DateTime cappedEndTime = _startDateTime.add(_maxDuration);
                  _endDateTime = cappedEndTime;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Maximum reservation duration is 1 hour 30 minutes')),
                  );
                } else {
                  _endDateTime = date;
                }

                _endDateController.text =
                    DateFormat('MM/dd/yyyy').format(_endDateTime);
                _endTimeController.text =
                    DateFormat('HH:mm').format(_endDateTime);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('End time must be after start time')),
                );
              }
            }

            // Re-filter available rooms when date/time changes
            _filterAvailableRooms();
          });
        }
      },
      currentTime: isStartTime
          ? (_startDateTime.isBefore(now) ? now : _startDateTime)
          : (_endDateTime.isBefore(now)
              ? now.add(Duration(minutes: 30))
              : _endDateTime),
      locale: picker.LocaleType.en,
    );
  }

  Future<void> _submitReservation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedRoomId == null) {
      setState(() {
        _errorMessage = "Please select a room";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null; // Clear any previous error messages
      _reservationSuccess = false;
    });

    try {
      // Prepare request data
      final Map<String, dynamic> reservationData = {
        "room_id": _selectedRoomId,
        "start_time": _startDateTime.toIso8601String(),
        "end_time": _endDateTime.toIso8601String(),
        "purpose": null, // This will be removed on the backend
        "room_inventory": _selectedInventory.join(", "),
        "participant_number": int.tryParse(_participantsController.text) ?? 0,
        "description": _descriptionController.text,
        "event_type": _selectedEventType,
      };

      // Make API call with authentication (ApiService automatically adds Bearer token)
      // The token is loaded from SharedPreferences during ApiService initialization
      final response = await _apiService.post(
        'reserveRoom', // Updated endpoint - no need to include ID in URL
        reservationData,
      );

      // Process response
      final responseData = jsonDecode(response.body);

      // Ensure we're not holding onto the loading state
      setState(() {
        _isLoading = false;
      });

      // IMPORTANT: The backend sends "Room reserved successfully." in the message field
      // We need to handle this case specifically to avoid showing it in the UI
      if (responseData["success"] == true ||
          (responseData["message"] == "Room reserved successfully." &&
              responseData["reservation"] != null)) {
        // Only show success dialog, don't update UI state to show any text
        // Clear draft when successful
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('reservation_draft');

        // Clear any lingering error message
        if (mounted) {
          setState(() {
            _errorMessage = null;
          });
        }

        // Show success dialog - which will handle navigation when user clicks close
        _showSuccessDialog();
      } else {
        // Show error message from API
        setState(() {
          _errorMessage =
              responseData["message"] ?? "Failed to create reservation";
        });
      }
    } catch (e) {
      // Add mounted check before setState
      if (mounted) {
        setState(() {
          _errorMessage = "Failed to create reservation: $e";
          _isLoading = false;
        });
      }
    }
  }

  // Show success dialog with animation
  Future<void> _showSuccessDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Check mark animation
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Color(0xFF4CAF50).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Color(0xFF4CAF50),
                    size: 60,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  "Room reserved successfully!",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Close dialog
                    Navigator.pop(context);

                    // Reset form
                    _resetForm();

                    // Navigate back to reservation section
                    Navigator.pop(context, true); // true indicates success
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4CAF50),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Close",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Add a method to reset the form
  void _resetForm() {
    setState(() {
      // Reset all form fields to default values
      _selectedEventType = null;
      _descriptionController.clear();
      _selectedInventory = [];
      _participantsController.clear();
      _selectedRoom = null;
      _selectedRoomId = null;

      // Reset date and time to defaults
      _startDateTime = DateTime.now();
      _endDateTime = DateTime.now().add(Duration(minutes: 90));
      _updateDateTimeControllers();

      // Re-filter available rooms for the new time
      _filterAvailableRooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Force remove any stale UI messages that might be showing "Room reserved successfully"
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_reservationSuccess) {
        // Show success dialog if needed but don't display any text at the top of the form
        Future.delayed(Duration.zero, () {
          _showSuccessDialog();
        });
      }
    });

    return WillPopScope(
      onWillPop: () async {
        // Show save draft dialog when back button is pressed
        await _showSaveDraftDialog();
        // Return false to prevent default back navigation
        // since we're handling navigation in the dialog
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.grey),
            onPressed: () => _showSaveDraftDialog(),
          ),
          title: Padding(
            padding:
                EdgeInsets.only(right: 40), // Offset to compensate for actions
            child: Text(
              'Reservation details',
              style: TextStyle(
                color: const Color(0xFFA54D66),
                fontSize: 19, // Reduced font size for better fit
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.visible, // Ensure text doesn't get cut off
              maxLines: 1,
            ),
          ),
          titleSpacing: 0, // Reduce spacing around title
          centerTitle: false, // Left-align title
          actions: [
            IconButton(
              icon: Icon(Icons.settings, color: Colors.grey),
              onPressed: () {},
            ),
            Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  icon: Icon(Icons.email_outlined, color: Colors.grey),
                  onPressed: () {},
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
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Only show error message if there is one and we're not in success state
                      if (_errorMessage != null && !_reservationSuccess)
                        Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                      // Reservation by (read-only)
                      _buildFormSection(
                        "Reservation by",
                        TextField(
                          controller: TextEditingController(text: _userName),
                          enabled: false,
                          decoration: InputDecoration(
                            hintText: "User name auto-filled",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                        ),
                      ),

                      // Event type dropdown
                      _buildFormSection(
                        "Select event type",
                        DropdownButtonFormField<String>(
                          value: _selectedEventType,
                          decoration: InputDecoration(
                            hintText: "Select",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: Icon(Icons.keyboard_arrow_down),
                          items: _eventTypes.map((String type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedEventType = newValue;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select an event type';
                            }
                            return null;
                          },
                        ),
                      ),

                      // Description
                      _buildFormSection(
                        "Description",
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            hintText: "Please add a description (optional)",
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          minLines: 3,
                          maxLines: 5,
                        ),
                      ),

                      // Room inventory multi-select
                      _buildFormSection(
                        "Select room inventory",
                        GestureDetector(
                          onTap: () {
                            _showMultiSelectDialog(
                              "Select Room Inventory",
                              _roomInventoryOptions,
                              _selectedInventory,
                              (selected) {
                                setState(() {
                                  _selectedInventory = selected;
                                });
                              },
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[400]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    _selectedInventory.isEmpty
                                        ? "Type"
                                        : _selectedInventory.join(", "),
                                    style: TextStyle(
                                      color: _selectedInventory.isEmpty
                                          ? Colors.grey[400]
                                          : Colors.black,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                Icon(Icons.keyboard_arrow_down,
                                    color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Number of participants
                      _buildFormSection(
                        "Number of participants",
                        TextFormField(
                          controller: _participantsController,
                          decoration: InputDecoration(
                            hintText: "Please add number of participants",
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter number of participants';
                            }
                            final number = int.tryParse(value);
                            if (number == null || number <= 0) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ),

                      // Date and time pickers
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Start date",
                                  style: TextStyle(
                                    color: Color(0xFFA54D66),
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () => _selectDateTime(true),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 12),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey[400]!),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(_startDateController.text),
                                              SizedBox(width: 8),
                                              Text(_startTimeController.text),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text("–"),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "End date",
                                  style: TextStyle(
                                    color: Color(0xFFA54D66),
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () => _selectDateTime(false),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 12),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey[400]!),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(_endDateController.text),
                                              SizedBox(width: 8),
                                              Text(_endTimeController.text),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),

                      // Room selection
                      _buildFormSection(
                        "Room",
                        _buildRoomDropdownField(),
                      ),

                      SizedBox(height: 24),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _showSaveDraftDialog(),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Color(0xFFA54D66)),
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                "Close",
                                style: TextStyle(
                                  color: Color(0xFFA54D66),
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                // Show confirmation dialog
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Delete Reservation"),
                                      content: Text(
                                          "Are you sure you want to delete this reservation data?"),
                                      actions: [
                                        TextButton(
                                          child: Text("Cancel"),
                                          onPressed: () =>
                                              Navigator.pop(context),
                                        ),
                                        TextButton(
                                          child: Text("Delete"),
                                          onPressed: () {
                                            // Delete draft data
                                            _deleteDraft();
                                            Navigator.pop(
                                                context); // Close dialog
                                            Navigator.pop(
                                                context); // Close reservation screen
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFA54D66),
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                "Delete",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),

                      // Create/Update button
                      ElevatedButton(
                        onPressed: _submitReservation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4CAF50),
                          minimumSize: Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Create/Update",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  String _generateUniqueRoomKey(String buildingName, int roomId) {
    return "$buildingName::$roomId"; // Use :: as separator to avoid conflicts
  }

  List<DropdownMenuItem<String>> _buildRoomDropdownItems() {
    List<DropdownMenuItem<String>> items = [];

    // Used to keep track of keys we've already added to prevent duplicates
    Set<String> addedKeys = {};

    // Check if the list is empty
    if (_availableRoomsByBuilding.isEmpty) {
      return items; // Return empty list to avoid errors
    }

    // Group by building
    _availableRoomsByBuilding.forEach((buildingName, rooms) {
      // Add building header
      items.add(
        DropdownMenuItem<String>(
          enabled: false,
          value:
              "header_$buildingName", // Use a prefix to make headers distinct
          child: Text(
            "Building $buildingName",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
      );

      // Add rooms for this building
      for (var room in rooms) {
        // Create a unique string ID combining building and room IDs
        String uniqueId = _generateUniqueRoomKey(buildingName, room["id"]);

        // Make sure we don't add duplicates
        if (addedKeys.contains(uniqueId)) {
          continue;
        }

        addedKeys.add(uniqueId);

        items.add(
          DropdownMenuItem<String>(
            value: uniqueId,
            alignment: Alignment.centerLeft,
            child: Text(
              "${room['room_name']}",
              textAlign: TextAlign.left,
            ),
          ),
        );
      }
    });

    return items;
  }

  Widget _buildFormSection(String label, Widget field) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: TextStyle(
                color: Color(0xFFA54D66),
                fontSize: 14,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          SizedBox(height: 8),
          field,
        ],
      ),
    );
  }

  void _showMultiSelectDialog(
    String title,
    List<String> options,
    List<String> selectedOptions,
    Function(List<String>) onSelectionDone,
  ) {
    // Create a temp list for current selections
    List<String> tempSelectedOptions = List.from(selectedOptions);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(title),
              content: Container(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final isSelected = tempSelectedOptions.contains(option);

                    return CheckboxListTile(
                      title: Text(option),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            if (!tempSelectedOptions.contains(option)) {
                              tempSelectedOptions.add(option);
                            }
                          } else {
                            tempSelectedOptions.remove(option);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  child: Text("Cancel"),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child: Text("OK"),
                  onPressed: () {
                    onSelectionDone(tempSelectedOptions);
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _findAndSetRoom(int roomId) {
    for (var building in widget.buildings) {
      int buildingId = building["id"];
      List<dynamic> rooms = widget.roomsByBuilding[buildingId] ?? [];

      for (var room in rooms) {
        if (room["id"] == roomId) {
          _findAndSetRoomById(building["building_name"], roomId);
          return;
        }
      }
    }
  }

  // New helper method to find and set room by building name and ID
  void _findAndSetRoomById(String buildingName, int roomId) {
    _selectedRoomId = roomId;

    // Find the room with this ID in the specified building
    for (var building in widget.buildings) {
      // Skip buildings that don't match the name
      if (building["building_name"] != buildingName) continue;

      int buildingId = building["id"];
      List<dynamic> rooms = widget.roomsByBuilding[buildingId] ?? [];

      for (var room in rooms) {
        if (room["id"] == roomId) {
          setState(() {
            _selectedRoom = {
              "id": roomId,
              "room_name": room["room_name"],
              "building_name": buildingName,
            };
          });
          return;
        }
      }
    }
  }

  // Delete draft from SharedPreferences
  Future<void> _deleteDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('reservation_draft');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reservation data deleted')),
      );
    } catch (e) {
      print("Error deleting draft: $e");
    }
  }

  // Update the _buildRoomDropdownField method
  Widget _buildRoomDropdownField() {
    // Get available rooms and check if we have any
    final dropdownItems = _buildRoomDropdownItems();
    final bool noRoomsAvailable = dropdownItems.isEmpty;

    // Create a unique string ID from the selected room if it exists
    String? selectedRoomUniqueId;
    if (_selectedRoom != null && _selectedRoomId != null) {
      selectedRoomUniqueId = _generateUniqueRoomKey(
          _selectedRoom!["building_name"] ?? "", _selectedRoomId!);
    }

    // Check if selected room is in the available items
    bool selectedRoomAvailable = false;
    if (selectedRoomUniqueId != null) {
      for (var item in dropdownItems) {
        if (item.value == selectedRoomUniqueId) {
          selectedRoomAvailable = true;
          break;
        }
      }
    }

    // If selected room is not available, clear it
    if (selectedRoomUniqueId != null && !selectedRoomAvailable) {
      setState(() {
        _selectedRoomId = null;
        _selectedRoom = null;
      });
      selectedRoomUniqueId = null;
    }

    if (noRoomsAvailable) {
      // No rooms available for this time
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                "No rooms available for selected time",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      );
    } else {
      // Rooms are available, show dropdown
      return DropdownButtonFormField<String>(
        value: selectedRoomAvailable ? selectedRoomUniqueId : null,
        decoration: InputDecoration(
          hintText: "Select",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        icon: Icon(Icons.keyboard_arrow_down),
        items: dropdownItems,
        onChanged: (String? newValue) {
          if (newValue != null) {
            // Parse the building and room ID from the unique string ID
            List<String> parts = newValue.split('::');
            if (parts.length == 2) {
              String buildingName = parts[0];
              int? roomId = int.tryParse(parts[1]);
              if (roomId != null) {
                _findAndSetRoomById(buildingName, roomId);
              }
            }
          }
        },
        validator: (value) {
          if (value == null) {
            return 'Please select a room';
          }
          return null;
        },
      );
    }
  }

  @override
  void dispose() {
    // Clean up controllers
    _descriptionController.dispose();
    _participantsController.dispose();
    _startDateController.dispose();
    _startTimeController.dispose();
    _endDateController.dispose();
    _endTimeController.dispose();

    // Cancel any ongoing operations if needed

    super.dispose();
  }
}
