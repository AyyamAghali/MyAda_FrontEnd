import 'package:myada_official/core/app_export.dart';
import 'package:myada_official/core/network/api_service.dart';
import 'package:myada_official/core/services/apdu_service.dart';
import 'package:myada_official/widgets/custom_tab_bar.dart';

/// Student Home Screen
class TH2Screen extends StatefulWidget {
  const TH2Screen({Key? key}) : super(key: key);

  @override
  State<TH2Screen> createState() => _TH2ScreenState();
}

class _TH2ScreenState extends State<TH2Screen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  // Initialize userData with default values to prevent null errors
  Map<String, dynamic> userData = {
    'firstName': 'John',
    'lastName': 'Doe',
    'status': 'Student',
    'className': 'N/A',
    'id': 'Unknown',
    'issueDate': '20.07.2020',
    'validityDate': '01.06.2025',
  };
  bool isLoading = true;
  String? error;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _getUserData();
    _checkNfcSupport();
  }

  // Show sign out confirmation dialog
  Future<bool> _showSignOutConfirmationDialog() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            title: Text(
              "Sign Out",
              style: TextStyle(
                color: const Color(0xFF3A6381),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            content: Text(
              "Are you sure you want to sign out?",
              style: TextStyle(
                color: const Color(0xFF3A6381),
                fontSize: 16,
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF3A6381),
                    ),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: const Color(0xFF3A6381),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop(true);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFA54D66),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Text(
                      "Sign Out",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ) ??
        false;
  }

  // Handle sign out process
  Future<void> _handleSignOut() async {
    final shouldSignOut = await _showSignOutConfirmationDialog();

    if (shouldSignOut) {
      try {
        // Create a new instance directly
        final apduService = Get.find<ApduService>();
        try {
          await apduService.onUserLogout();
          print("HCE service stopped on logout");
        } catch (e) {
          print("Error stopping HCE service: $e");
        }

        // Sign out using API service
        print("Logging out user from TH2Screen...");
        await _apiService.logout();

        // Use both approaches for redundancy
        print("Navigating to login screen...");

        // For apps that restart on route - prevent this behavior
        await Future.delayed(Duration.zero);

        // Force direct navigation to login without animation
        Get.offAllNamed(AppRoutes.loginScreen, predicate: (_) => false);
      } catch (e) {
        print("Error during logout: $e");
        // Fallback if logout fails
        Get.offAllNamed(AppRoutes.loginScreen, predicate: (_) => false);
      }
    }
  }

  /// Load user data from API or storage
  Future<void> _getUserData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // You can either get data from API service or from shared preferences
      final user = await _apiService.getUserData();

      if (user != null) {
        // Process the fullName field correctly
        String firstName = "";
        String lastName = "";

        if (user.containsKey('personal_informations') &&
            user['personal_informations'] != null &&
            user['personal_informations'].containsKey('fullName')) {
          final fullName = user['personal_informations']['fullName'] as String;
          final nameParts = fullName.split(' ');

          // Last word is surname, everything else is first name
          if (nameParts.length > 1) {
            lastName = nameParts.last;
            firstName = nameParts.sublist(0, nameParts.length - 1).join(' ');
          } else if (nameParts.length == 1) {
            firstName = nameParts[0];
            lastName = ""; // No surname available
          }
        }

        // Safely get myRoomID with null handling
        String className = 'N/A';
        if (user.containsKey('personal_informations') &&
            user['personal_informations'] != null &&
            user['personal_informations'].containsKey('myRoomID') &&
            user['personal_informations']['myRoomID'] != null) {
          className = user['personal_informations']['myRoomID'].toString();
        }

        // Safely get uid with null handling
        String id = 'Unknown';
        String realUid = 'Unknown';

        // First try the top-level uid (preferred)
        if (user.containsKey('uid') && user['uid'] != null) {
          realUid = user['uid'].toString();
          // Then try personal_informations.uid
        } else if (user.containsKey('personal_informations') &&
            user['personal_informations'] != null &&
            user['personal_informations'].containsKey('uid') &&
            user['personal_informations']['uid'] != null) {
          realUid = user['personal_informations']['uid'].toString();
        }

        // Get user ID for display purposes only
        if (user.containsKey('id') && user['id'] != null) {
          id = user['id'].toString();
        } else if (user.containsKey('user_id') && user['user_id'] != null) {
          id = user['user_id'].toString();
        }

        // Safely get group_id with null handling
        int? groupId;
        if (user.containsKey('group_id') && user['group_id'] != null) {
          if (user['group_id'] is int) {
            groupId = user['group_id'];
          } else if (user['group_id'] is String) {
            groupId = int.tryParse(user['group_id']);
          }
        }

        // Add processed name values
        Map<String, dynamic> processedUserData = {
          'firstName': firstName.isNotEmpty ? firstName : 'John',
          'lastName': lastName.isNotEmpty ? lastName : 'Doe',
          'status': _getStatusFromGroupId(groupId),
          'className': className,
          'id': id,
          'uid': realUid, // Add the real UID separately
          // Keep these static as they're just decorative
          'issueDate': '20.07.2020',
          'validityDate': '01.06.2025',
        };

        setState(() {
          userData = processedUserData;
          isLoading = false;
        });
      } else {
        setState(() {
          error = "Failed to load user data";
          isLoading = false;
          // Default values already set in initialization
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
        // Default values already set in initialization
      });
    }
  }

  // Helper method to get status text from group_id
  String _getStatusFromGroupId(int? groupId) {
    switch (groupId) {
      case 1:
        return 'Teacher';
      case 2:
        return 'Student';
      case 3:
        return 'Staff';
      default:
        return 'Student';
    }
  }

  // Check NFC support and show message if not supported
  Future<void> _checkNfcSupport() async {
    try {
      // Wait a moment for widget to be fully built
      await Future.delayed(Duration(seconds: 2));

      if (!mounted) return;

      final apduService = Get.find<ApduService>();
      final isSupported = await apduService.isHceSupported();

      // We only want to show a warning if the device actually doesn't have NFC hardware
      // We don't want to show this warning to users with NFC hardware that's just disabled
      if (!isSupported && mounted) {
        // Only show the message once at startup for devices that don't have NFC hardware at all
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('This device does not have NFC hardware support'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Error checking NFC support: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Show confirmation dialog
        final shouldSignOut = await _showSignOutConfirmationDialog();

        // If confirmed, sign out and navigate to login
        if (shouldSignOut) {
          await _handleSignOut();
        }

        // Always return false to prevent the app from closing
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(context),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : error != null
                ? Center(child: Text('Error: $error'))
                : SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Student ID Card
                          _buildStudentCard(context),

                          // Feature Section
                          _buildMoreSection(context),
                        ],
                      ),
                    ),
                  ),
        bottomNavigationBar: _buildBottomNavBar(context),
      ),
    );
  }

  /// Build App Bar with logo, settings, notifications and sign out
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leadingWidth: 80,
      leading: Padding(
        padding: EdgeInsets.only(left: 16.0),
        child: Image.asset(
          ImageConstant.imgLogo1,
          width: 60,
          height: 38,
          fit: BoxFit.contain,
        ),
      ),
      actions: [
        // Settings icon
        IconButton(
          icon: Image.asset(
            ImageConstant.imgSettings,
            width: 24,
            height: 24,
            color: const Color(0xFF3A6381),
          ),
          onPressed: () {
            // Navigate to settings
          },
        ),
        // Notification icon with badge
        Stack(
          alignment: Alignment.topRight,
          children: [
            IconButton(
              icon: Icon(Icons.email_outlined, color: const Color(0xFF3A6381)),
              onPressed: () {
                // Navigate to notifications
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
                constraints: BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  '1',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        // Sign out button
        Padding(
          padding: EdgeInsets.only(right: 16),
          child: ElevatedButton(
            onPressed: _handleSignOut,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA54D66),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: Size(0, 0),
            ),
            child: Text(
              "Sign Out",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build student information card
  Widget _buildStudentCard(BuildContext context) {
    // Create a new instance directly
    final apduService = Get.find<ApduService>();

    // Set user UID from userData as soon as the card is built
    if (userData['uid'] != null && userData['uid'].toString().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          print("Student card: Setting UID to ${userData['uid']}");
          apduService.setUid(userData['uid'].toString());
        } catch (e) {
          print("Error setting UID: $e");
        }
      });
    }

    return Container(
      width: 352,
      height: 213,
      margin: EdgeInsets.only(top: 20, bottom: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFA54D66),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Student photo
          Positioned(
            left: 12,
            top: 30,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 112,
                height: 150,
                child: Image.asset(
                  ImageConstant.imgStudentPhoto,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade200,
                      child: Center(
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Card information
          Padding(
            padding: EdgeInsets.only(left: 140, right: 15, top: 15, bottom: 15),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Use minimum size
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // University name and logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'ADA UNIVERSITY',
                        style: TextStyle(
                          color: const Color(0xFF3A6381),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // ADA Logo only (no background)
                    Container(
                      width: 38,
                      height: 24,
                      child: Image.asset(
                        ImageConstant.imgLogo1,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10), // Reduced spacing

                // Name
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Name: ',
                        style: TextStyle(
                          color: const Color(0xFF3A6381),
                          fontSize: 13, // Slightly smaller font
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: userData['firstName'] ?? 'Fidan',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 13, // Slightly smaller font
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4), // Reduced spacing

                // Surname
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Surname: ',
                        style: TextStyle(
                          color: const Color(0xFF3A6381),
                          fontSize: 13, // Slightly smaller font
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: userData['lastName'] ?? 'Mardanli',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 13, // Slightly smaller font
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4), // Reduced spacing

                // Status
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Status: ',
                        style: TextStyle(
                          color: const Color(0xFF3A6381),
                          fontSize: 13, // Slightly smaller font
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: userData['status'] ?? 'Student',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 13, // Slightly smaller font
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4), // Reduced spacing

                // Class
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Class: ',
                        style: TextStyle(
                          color: const Color(0xFF3A6381),
                          fontSize: 13, // Slightly smaller font
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: userData['className'] ?? 'V413',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 13, // Slightly smaller font
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4), // Reduced spacing

                // Issue date
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Date of issue: ',
                        style: TextStyle(
                          color: const Color(0xFFA54D66),
                          fontSize: 11, // Smaller font
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: userData['issueDate'] ?? '20.07.2020',
                        style: TextStyle(
                          color: const Color(0xFFA54D66),
                          fontSize: 11, // Smaller font
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2),

                // Validity date
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Validity date: ',
                        style: TextStyle(
                          color: const Color(0xFFA54D66),
                          fontSize: 11, // Smaller font
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: userData['validityDate'] ?? '01.06.2025',
                        style: TextStyle(
                          color: const Color(0xFFA54D66),
                          fontSize: 11, // Smaller font
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom section with ID and NFC button - fix height to avoid overflow
                Container(
                  height: 30, // Fixed height to avoid overflow
                  margin: EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ID number with overflow protection
                      Container(
                        constraints: BoxConstraints(maxWidth: 120),
                        child: RichText(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'ID: ',
                                style: TextStyle(
                                  color: const Color(0xFF3A6381),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: userData['id'] ?? 'Unknown',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // APDU toggle button - Larger hitbox without border
                      Padding(
                        padding: EdgeInsets.all(4),
                        child: GestureDetector(
                          behavior:
                              HitTestBehavior.opaque, // Enlarges touch area
                          onTap: () async {
                            print("APDU button tapped");
                            // Get the UID from userData - use the real UID not the user ID
                            final uid = userData['uid']?.toString() ?? '';

                            if (uid.isEmpty || uid == 'Unknown') {
                              print("No UID available");
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('No ID available for NFC'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            print("Using UID: $uid");
                            try {
                              final apduService = Get.find<ApduService>();

                              // First check if NFC is supported at the hardware level
                              final isHardwareSupported =
                                  await apduService.isHceSupported();

                              if (!isHardwareSupported) {
                                // Show dialog for devices that don't have NFC hardware at all
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      title: Text(
                                        'NFC Not Available',
                                        style: TextStyle(
                                          color: const Color(0xFFA54D66),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      content: Text(
                                        'This device does not have NFC hardware support.',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: const Color(0xFF3A6381),
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFFA54D66),
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                return;
                              }

                              // Try to start the service - this could fail if NFC is disabled in settings
                              final success =
                                  await apduService.startHceService(uid);

                              if (!success) {
                                // Show dialog for devices that have NFC hardware but it's disabled in settings
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      title: Text(
                                        'NFC Disabled',
                                        style: TextStyle(
                                          color: const Color(0xFFA54D66),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      content: Text(
                                        'NFC is disabled in your device settings. Please enable NFC and try again.',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: const Color(0xFF3A6381),
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFFA54D66),
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                return;
                              }

                              // Show appropriate message based on toggle action
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('ID Card emulation activated'),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            } catch (e) {
                              print("Error toggling APDU service: $e");
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.contactless_rounded,
                                size: 20,
                                color: Get.find<ApduService>().isActive
                                    ? Colors.green
                                    : const Color(0xFFA54D66),
                              ),
                              SizedBox(width: 4),
                              Text(
                                Get.find<ApduService>().isActive
                                    ? 'Active'
                                    : 'Tap to activate',
                                style: TextStyle(
                                  color: Get.find<ApduService>().isActive
                                      ? Colors.green
                                      : const Color(0xFFA54D66),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
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
    );
  }

  /// Section Widget for the "More" section with feature buttons
  Widget _buildMoreSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "More",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Container(
          height: 1,
          width: 40,
          color: const Color(0xFFA54D66),
          margin: EdgeInsets.only(bottom: 20),
        ),

        // Feature buttons row
        Row(
          children: [
            // Attendance check
            _buildFeatureItem(
              context: context,
              imagePath: ImageConstant.imgAssign,
              title: "attendance check",
              onTap: () {},
            ),
            SizedBox(width: 16),

            // Room reservation
            _buildFeatureItem(
              context: context,
              imagePath: ImageConstant.imgAttendance,
              title: "room reservation",
              onTap: () {
                NavigatorService.pushNamed(AppRoutes.roomReservation);
              },
            ),
            SizedBox(width: 16),

            // Add button
            _buildFeatureItem(
              context: context,
              isAddButton: true,
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  // Build feature item widget with fix for overflow
  Widget _buildFeatureItem({
    required BuildContext context,
    String? imagePath,
    String? title,
    required VoidCallback onTap,
    bool isAddButton = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 110, // Increased height to prevent overflow
        padding: EdgeInsets.all(6), // Reduced padding
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFA54D66),
            width: 0.5,
          ),
        ),
        child: isAddButton
            ? Center(
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFA54D66),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.add,
                    color: const Color(0xFFA54D66),
                    size: 24,
                  ),
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min, // Use minimum space needed
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 40,
                    width: 40,
                    child: imagePath != null
                        ? Image.asset(
                            imagePath,
                            color: const Color(0xFFA54D66),
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.apps,
                                size: 32,
                                color: const Color(0xFFA54D66),
                              );
                            },
                          )
                        : Icon(
                            Icons.apps,
                            size: 32,
                            color: const Color(0xFFA54D66),
                          ),
                  ),
                  SizedBox(height: 6),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Container(
                        width: constraints.maxWidth,
                        child: Text(
                          title ?? "",
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: 11, // Slightly smaller font
                            color: const Color(0xFF3A6381),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
      ),
    );
  }

  /// Build bottom navigation bar with custom tab bar
  Widget _buildBottomNavBar(BuildContext context) {
    return CustomTabBar(
      initialTabIndex: _selectedTabIndex,
      onTabChanged: (index) {
        setState(() {
          _selectedTabIndex = index;
        });
        // Handle tab navigation here if needed
      },
    );
  }
}
