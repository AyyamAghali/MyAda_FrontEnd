import 'dart:math' as math;

import 'package:intl/intl.dart';
import 'package:myada_official/core/app_export.dart';
import 'package:myada_official/core/network/api_service.dart';
import 'package:myada_official/core/services/auth_service.dart';

class MyRoomScreen extends StatefulWidget {
  final String roomId;

  const MyRoomScreen({Key? key, required this.roomId}) : super(key: key);

  @override
  _MyRoomScreenState createState() => _MyRoomScreenState();

  static Widget builder(BuildContext context, {required String roomId}) {
    return MyRoomScreen(roomId: roomId);
  }
}

class _MyRoomScreenState extends State<MyRoomScreen> {
  final ApiService _apiService = ApiService();
  bool _isCalendarVisible = false;
  DateTime _focusedDay = DateTime.now();
  List<DateTime> _selectedDays = [];

  // State variables
  bool isLoading = true;
  String? error;
  List<AttendanceRecord> _attendanceRecords = [];
  Map<DateTime, List<AttendanceRecord>> _groupedRecords = {};

  // Refresh controller
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _loadAttendanceData();
  }

  // Load attendance data from API
  Future<void> _loadAttendanceData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // Get auth token more safely
      String? token;
      try {
        // Try to get the AuthService through Provider
        final authService = Provider.of<AuthService>(context, listen: false);
        token = _apiService.authToken;
      } catch (providerError) {
        // If Provider fails, try to get token directly from ApiService
        print('Provider error accessing AuthService: $providerError');
        token = _apiService.authToken;

        // If still null, show debug info
        if (token == null) {
          print(
              'Warning: Could not access auth token from AuthService or ApiService');
        }
      }

      if (token == null) {
        // If no token, redirect to login
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please login to view attendance records.'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pushReplacementNamed(AppRoutes.loginScreen);
        return;
      }

      // Calculate date range (default: last 3 days)
      DateTime toDate = DateTime.now();
      // Subtract 10 seconds to avoid potential future timestamp errors
      toDate = toDate.subtract(Duration(seconds: 10));

      // Calculate from date (3 days ago by default or from selected days)
      DateTime fromDate;
      if (_selectedDays.isEmpty) {
        fromDate = toDate.subtract(Duration(days: 3));
      } else {
        // Sort selected days to get first and last (earliest to latest)
        _selectedDays.sort((a, b) => a.compareTo(b));

        // First day will always be the earlier date regardless of selection order
        DateTime earliestDay = _selectedDays.first;
        DateTime latestDay =
            _selectedDays.length > 1 ? _selectedDays.last : earliestDay;

        // Always use start of day (00:00:00) for fromDate
        fromDate = DateTime(
            earliestDay.year, earliestDay.month, earliestDay.day, 0, 0, 0);

        // If multiple days selected, set toDate to end of last selected day
        if (_selectedDays.length > 1) {
          // If latest day is today, use current time minus 10 seconds
          if (_isSameDay(latestDay, DateTime.now())) {
            toDate = DateTime.now().subtract(Duration(seconds: 10));
          } else {
            // Otherwise use 23:59:59 of the latest day for complete day coverage
            toDate = DateTime(
                latestDay.year, latestDay.month, latestDay.day, 23, 59, 59);
          }
        } else {
          // Single day selected - use the full day
          // If selected day is today, use current time minus 10 seconds
          if (_isSameDay(earliestDay, DateTime.now())) {
            toDate = DateTime.now().subtract(Duration(seconds: 10));
          } else {
            // Otherwise use end of the selected day
            toDate = DateTime(earliestDay.year, earliestDay.month,
                earliestDay.day, 23, 59, 59);
          }
        }
      }

      // Format dates for API
      final fromDateStr = DateFormat('yyyy-MM-dd HH:mm').format(fromDate);
      final toDateStr = DateFormat('yyyy-MM-dd HH:mm').format(toDate);

      // Print the date range for debugging
      print('Fetching attendance logs from $fromDateStr to $toDateStr');

      // API request body
      final requestBody = {"from_date": fromDateStr, "to_date": toDateStr};

      // Make API call
      final logs = await _apiService.getAttendanceLogs(requestBody);

      // Parse response data
      List<AttendanceRecord> records = [];

      if (logs.isEmpty) {
        // Handle empty response gracefully
        setState(() {
          _attendanceRecords = [];
          isLoading = false;
          _groupAttendanceRecords();
        });
        return;
      }

      // Process the response data
      records = logs.map((log) {
        try {
          return AttendanceRecord(
            fullName: log["full_name"] ?? "",
            id: log["user_id"]?.toString() ?? "",
            time: DateFormat('HH:mm').format(DateTime.parse(log["entry_time"])),
            date: DateTime.parse(log["entry_time"]),
          );
        } catch (e) {
          print('Error parsing log entry: $e, Entry: $log');
          // Return a placeholder record to avoid crashing
          return AttendanceRecord(
            fullName: "Error parsing name",
            id: "Unknown",
            time: "00:00",
            date: DateTime.now(),
          );
        }
      }).toList();

      setState(() {
        _attendanceRecords = records;
        isLoading = false;
        _groupAttendanceRecords();
      });
    } catch (e) {
      // Check for specific error types
      if (e.toString().contains('401')) {
        // Redirect to login page with expired message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login expired. Please sign in again.'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pushReplacementNamed(AppRoutes.loginScreen);
      } else if (e.toString().contains('400')) {
        setState(() {
          error = 'Invalid date range. Please select different dates.';
          isLoading = false;
        });
      } else if (e.toString().contains('HTML')) {
        // Handle HTML response error
        setState(() {
          error = 'Server error. Please try again later.';
          isLoading = false;
          print('Server returned HTML instead of JSON: $e');
        });
      } else if (e.toString().contains('405')) {
        // Handle method not allowed error
        setState(() {
          error = 'API configuration error. Please contact support.';
          isLoading = false;
          print('Method not allowed error: $e');
        });
      } else if (e.toString().contains('404') ||
          e.toString().contains('Room not found')) {
        // Handle room not found error
        setState(() {
          error =
              'Room not found. Please verify the room ID or try again later.';
          isLoading = false;
          print('Room not found error: $e');
        });
      } else {
        setState(() {
          error = 'Failed to load attendance data. Please try again later.';
          isLoading = false;
          print('Error details: $e');
        });
      }
    }
  }

  // Group attendance records by date
  void _groupAttendanceRecords() {
    _groupedRecords = {};

    // Get range start and end if multiple days are selected
    DateTime? rangeStart, rangeEnd;
    if (_selectedDays.isNotEmpty) {
      List<DateTime> sortedSelectedDays = List.from(_selectedDays)
        ..sort((a, b) => a.compareTo(b));

      rangeStart = sortedSelectedDays.first;
      rangeEnd =
          sortedSelectedDays.length > 1 ? sortedSelectedDays.last : rangeStart;
    }

    for (var record in _attendanceRecords) {
      bool shouldInclude = true;

      // If we have a date range, check if the record is within the range
      if (_selectedDays.isNotEmpty) {
        final recordDate =
            DateTime(record.date.year, record.date.month, record.date.day);

        if (rangeStart != null && rangeEnd != null) {
          // Include record if it's between start and end dates (inclusive)
          shouldInclude = (recordDate.isAtSameMomentAs(rangeStart) ||
                  recordDate.isAfter(rangeStart)) &&
              (recordDate.isAtSameMomentAs(rangeEnd) ||
                  recordDate.isBefore(rangeEnd));
        } else {
          // Single day selection
          shouldInclude = _isSameDay(record.date, _selectedDays.first);
        }
      }

      if (shouldInclude) {
        DateTime dateKey = DateTime(
          record.date.year,
          record.date.month,
          record.date.day,
        );

        if (_groupedRecords[dateKey] == null) {
          _groupedRecords[dateKey] = [];
        }
        _groupedRecords[dateKey]!.add(record);
      }
    }

    // Add debug info
    print('Grouped records for ${_groupedRecords.length} days:');
    _groupedRecords.forEach((date, records) {
      print(
          '  ${DateFormat('yyyy-MM-dd').format(date)}: ${records.length} records');
    });

    setState(() {});
  }

  // Helper method to check if two dates are the same day
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Toggle calendar visibility
  void _toggleCalendar() {
    setState(() {
      _isCalendarVisible = !_isCalendarVisible;
    });
  }

  // Apply calendar filter
  void _applyFilter() {
    _loadAttendanceData();
    setState(() {
      _isCalendarVisible = false;
    });
  }

  // Cancel filter operation
  void _cancelFilter() {
    setState(() {
      _isCalendarVisible = false;
    });
  }

  // Toggle selection for a day
  void _toggleDaySelection(DateTime day) {
    setState(() {
      DateTime dateKey = DateTime(day.year, day.month, day.day);
      bool alreadySelected = _selectedDays.any((d) => _isSameDay(d, dateKey));

      if (alreadySelected) {
        // Remove this date from the selection
        _selectedDays.removeWhere((d) => _isSameDay(d, dateKey));
      } else {
        // Special handling for date range selection
        if (_selectedDays.length == 2) {
          // If we already have 2 dates selected and user selects a third,
          // keep only the earliest date and add the new date
          _selectedDays.sort((a, b) => a.compareTo(b));
          // Keep the earliest date and add the new one
          DateTime earliestDate = _selectedDays.first;
          _selectedDays.clear();
          _selectedDays.add(earliestDate);
          _selectedDays.add(dateKey);
        } else if (_selectedDays.length == 1) {
          // Add the second date
          _selectedDays.add(dateKey);
        } else {
          // First selection
          _selectedDays.add(dateKey);
        }
      }

      // Always ensure dates are sorted (earliest first, latest last)
      if (_selectedDays.length > 1) {
        _selectedDays.sort((a, b) => a.compareTo(b));
      }
    });
  }

  // Pull to refresh functionality
  Future<void> _handleRefresh() async {
    return _loadAttendanceData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Flexible(
              flex: 3,
              child: Text(
                'My Room',
                style: TextStyle(
                  color: const Color(0xFFA54D66),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 12),
            Flexible(
              flex: 2,
              child: Text(
                widget.roomId,
                style: TextStyle(
                  color: const Color(0xFF3A6381),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // Settings icon
          IconButton(
            icon: Image.asset(
              'assets/images/setting.png',
              width: 22,
              height: 22,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.settings, color: const Color(0xFF3A6381));
              },
            ),
            onPressed: () {
              // Settings navigation
            },
          ),
          // Notification icon with badge
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: Image.asset(
                  'assets/images/Group 1.png',
                  width: 26.5,
                  height: 27,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.email_outlined,
                        color: const Color(0xFF3A6381));
                  },
                ),
                onPressed: () {
                  // Notifications navigation
                },
              ),
              Positioned(
                right: 8,
                top: 8,
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
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Main content with pull-to-refresh
          RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: _handleRefresh,
            color: const Color(0xFFA54D66),
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                        color: const Color(0xFFA54D66)))
                : error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFFA54D66).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.error_outline,
                                  color: const Color(0xFFA54D66),
                                  size: 40,
                                ),
                              ),
                              SizedBox(height: 24),
                              Text(
                                error!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF3A6381),
                                ),
                              ),
                              SizedBox(height: 32),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF3A6381),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                    child: InkWell(
                                      onTap: _loadAttendanceData,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.refresh_rounded,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                          SizedBox(width: 12),
                                          Text(
                                            'Retry',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Attendance records grouped by date
                              ..._buildGroupedAttendanceRecords(),
                            ],
                          ),
                        ),
                      ),
          ),

          // Calendar overlay
          if (_isCalendarVisible)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  margin: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Calendar header
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(Icons.chevron_left),
                              onPressed: () {
                                setState(() {
                                  _focusedDay = DateTime(
                                    _focusedDay.year,
                                    _focusedDay.month - 1,
                                    _focusedDay.day,
                                  );
                                });
                              },
                            ),
                            Text(
                              DateFormat('MMMM yyyy').format(_focusedDay),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.chevron_right),
                              onPressed: () {
                                setState(() {
                                  _focusedDay = DateTime(
                                    _focusedDay.year,
                                    _focusedDay.month + 1,
                                    _focusedDay.day,
                                  );
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      // Help text for date selection
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          "Tap to select a day. Select two days to create a range.",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 8),

                      // Selection help text
                      if (_selectedDays.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            _selectedDays.length > 1
                                ? "Selected range: ${_formatRangeText()}"
                                : "Selected day: ${DateFormat('MMM dd').format(_selectedDays.first)}",
                            style: TextStyle(
                              fontSize: 14,
                              color: const Color(0xFF3A6381),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      SizedBox(height: 12),

                      // Simplified calendar - just show the current month
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            // Weekday headers
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                'SUN',
                                'MON',
                                'TUE',
                                'WED',
                                'THU',
                                'FRI',
                                'SAT'
                              ]
                                  .map((day) => Expanded(
                                      child: Center(
                                          child: Text(day,
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                              )))))
                                  .toList(),
                            ),
                            SizedBox(height: 8),
                            // Calendar grid
                            ..._buildCalendarDays(),
                          ],
                        ),
                      ),

                      // Buttons
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: _cancelFilter,
                              child: Text('CANCEL'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFFA54D66),
                                side:
                                    BorderSide(color: const Color(0xFFA54D66)),
                                minimumSize: Size(130, 45),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _applyFilter,
                              child: Text('APPLY'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3A6381),
                                minimumSize: Size(130, 45),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Filter button
          Positioned(
            right: 20,
            bottom: 20,
            child: FloatingActionButton(
              onPressed: _toggleCalendar,
              backgroundColor: const Color(0xFFA54D66),
              child: Icon(Icons.tune),
            ),
          ),
        ],
      ),
    );
  }

  // Build calendar days for the current month
  List<Widget> _buildCalendarDays() {
    List<Widget> calendarRows = [];

    // Get the first day of the month
    DateTime firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);

    // Calculate days in month
    int daysInMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0).day;

    // Calculate starting weekday (0 = Sunday, 6 = Saturday)
    int firstWeekday = firstDay.weekday % 7;

    // Build calendar rows
    List<Widget> currentRow = [];

    // Add empty spaces for days before the 1st of the month
    for (int i = 0; i < firstWeekday; i++) {
      currentRow.add(Expanded(child: Container()));
    }

    // Sort selected days to get range information
    List<DateTime> sortedSelectedDays = List.from(_selectedDays)
      ..sort((a, b) => a.compareTo(b));

    // Always use the earliest date as range start and latest as range end
    DateTime? rangeStart =
        sortedSelectedDays.isNotEmpty ? sortedSelectedDays.first : null;
    DateTime? rangeEnd =
        sortedSelectedDays.length > 1 ? sortedSelectedDays.last : rangeStart;

    // Add all days of the month
    for (int day = 1; day <= daysInMonth; day++) {
      DateTime currentDate = DateTime(_focusedDay.year, _focusedDay.month, day);
      bool isSelected = _selectedDays.any((d) => _isSameDay(d, currentDate));

      // Check if date is in the selection range
      bool isInRange = false;
      if (rangeStart != null && rangeEnd != null) {
        isInRange = (currentDate.isAfter(rangeStart) ||
                _isSameDay(currentDate, rangeStart)) &&
            (currentDate.isBefore(rangeEnd) ||
                _isSameDay(currentDate, rangeEnd));
      }

      // Prioritize endpoints of the range
      bool isRangeStart =
          rangeStart != null && _isSameDay(currentDate, rangeStart);
      bool isRangeEnd = rangeEnd != null && _isSameDay(currentDate, rangeEnd);

      currentRow.add(
        Expanded(
          child: GestureDetector(
            onTap: () => _toggleDaySelection(currentDate),
            child: Container(
              margin: EdgeInsets.all(4),
              height: 36,
              decoration: BoxDecoration(
                color: isRangeStart || isRangeEnd
                    ? const Color(
                        0xFFA54D66) // Full opacity for range endpoints
                    : isInRange
                        ? const Color(0xFFA54D66).withOpacity(
                            0.3) // Light opacity for dates in range
                        : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  day.toString(),
                  style: TextStyle(
                    color: (isRangeStart || isRangeEnd || isInRange)
                        ? Colors.white
                        : Colors.black,
                    fontWeight: (isRangeStart || isRangeEnd)
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Start a new row after Saturday
      if ((firstWeekday + day) % 7 == 0 || day == daysInMonth) {
        // If it's the last day and not Saturday, add empty spaces to complete the row
        if (day == daysInMonth && (firstWeekday + day) % 7 != 0) {
          int remainingDays = 7 - ((firstWeekday + day) % 7);
          for (int i = 0; i < remainingDays; i++) {
            currentRow.add(Expanded(child: Container()));
          }
        }

        calendarRows.add(
          Container(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.from(currentRow),
            ),
          ),
        );

        currentRow = [];
      }
    }

    return calendarRows;
  }

  // Build grouped attendance records for display
  List<Widget> _buildGroupedAttendanceRecords() {
    List<Widget> widgets = [];

    // Sort dates in descending order (most recent first)
    List<DateTime> sortedDates = _groupedRecords.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    if (sortedDates.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 100),
            child: Text(
              'No attendance records found',
              style: TextStyle(
                fontSize: 16,
                color: const Color(0xFF3A6381),
              ),
            ),
          ),
        )
      ];
    }

    for (var date in sortedDates) {
      List<AttendanceRecord> records = _groupedRecords[date]!;

      // Add date header
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
          child: Text(
            _getDateString(date),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF3A6381),
            ),
          ),
        ),
      );

      // Add attendance records for this date
      for (var record in records) {
        widgets.add(
          Container(
            margin: EdgeInsets.only(bottom: 12.0),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFA54D66), width: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  // Student photo
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 60,
                      height: 60,
                      child: _getImageForUserId(record.id),
                    ),
                  ),
                  SizedBox(width: 12),
                  // Student info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: TextStyle(color: Colors.black),
                            children: [
                              TextSpan(
                                text: 'Full name: ',
                                style: TextStyle(
                                  color: const Color(0xFF3A6381),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: record.fullName,
                                style: TextStyle(
                                  color: const Color(0xFF3A6381),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(color: Colors.black),
                            children: [
                              TextSpan(
                                text: 'ID: ',
                                style: TextStyle(
                                  color: const Color(0xFF3A6381),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: record.id,
                                style: TextStyle(
                                  color: const Color(0xFF3A6381),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Time
                  Text(
                    record.time,
                    style: TextStyle(
                      color: const Color(0xFFA54D66),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    return widgets;
  }

  // Format date for display
  String _getDateString(DateTime date) {
    if (_isSameDay(date, DateTime.now())) {
      return 'Today';
    } else if (_isSameDay(date, DateTime.now().subtract(Duration(days: 1)))) {
      return 'Yesterday';
    } else {
      return '${date.day} ${DateFormat('MMMM yyyy').format(date)}';
    }
  }

  // Format range text
  String _formatRangeText() {
    if (_selectedDays.length > 1) {
      return '${DateFormat('MMM dd').format(_selectedDays.first)} - ${DateFormat('MMM dd').format(_selectedDays.last)}';
    } else if (_selectedDays.isNotEmpty) {
      return DateFormat('MMM dd').format(_selectedDays.first);
    } else {
      return '';
    }
  }

  // Get image for user ID
  Widget _getImageForUserId(String userId) {
    // Create a deterministic selection between the two images
    // We'll calculate a simple hash based on the userId
    int hash = 0;
    if (userId.isNotEmpty) {
      // Sum the character codes in the userId
      for (int i = 0; i < userId.length; i++) {
        hash += userId.codeUnitAt(i);
      }
    }

    // Use modulo 2 to select between the two images
    String imagePath = hash % 2 == 0
        ? 'assets/Rectangle 157.png' // Even hash
        : 'assets/Rectangle 158.png'; // Odd hash

    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        // Fallback if images are not found
        print('Failed to load image: $imagePath - Error: $error');
        return Container(
          color: Colors.grey.shade200,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person, size: 28, color: const Color(0xFF3A6381)),
                SizedBox(height: 4),
                Text(
                  'ID: ${userId.substring(0, math.min(4, userId.length))}...',
                  style: TextStyle(
                    fontSize: 8,
                    color: const Color(0xFF3A6381),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class AttendanceRecord {
  final String fullName;
  final String id;
  final String time;
  final DateTime date;

  AttendanceRecord({
    required this.fullName,
    required this.id,
    required this.time,
    required this.date,
  });
}
