import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:myada_official/core/network/api_service.dart';
import 'package:myada_official/core/services/apdu_service.dart';
import 'package:myada_official/core/services/auth_service.dart';
import 'package:myada_official/core/utils/navigation_provider.dart';
import 'package:myada_official/core/utils/navigator_service.dart';
import 'package:myada_official/presentation/features/my_room_screen/my_room_screen.dart';
import 'package:myada_official/routes/app_routes.dart';
import 'package:myada_official/theme/theme_helper.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// Splash Screen (St Screen)
class StScreen extends StatefulWidget {
  @override
  _StScreenState createState() => _StScreenState();

  static Widget builder(BuildContext context) => StScreen();
}

class _StScreenState extends State<StScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to next screen after 3 seconds
    Future.delayed(Duration(milliseconds: 3000), () {
      NavigatorService.pushReplacementNamed(AppRoutes.onboardingScreen1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ADA logo from assets
              Image.asset(
                'assets/images/logo 1.png',
                height: 180,
                width: 180,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Onboarding Screen 1 (Nd Screen)
class NdScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Dismiss keyboard when this screen is shown
    FocusScope.of(context).unfocus();

    return Scaffold(
      // Add this to prevent bottom inset issues with keyboard
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with logo
            SizedBox(height: 24),
            Image.asset(
              'assets/images/logo 1.png',
              height: 66,
              width: 104,
              fit: BoxFit.contain,
            ),

            // Main content
            Expanded(
              child: Container(
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Actual image from assets
                    Align(
                      alignment: Alignment.topCenter,
                      child: Image.asset(
                        'assets/images/Smartcards for schools.png',
                        height: 288,
                        width: 312,
                        fit: BoxFit.contain,
                      ),
                    ),

                    // Background image
                    Image.asset(
                      'assets/images/background simple.png',
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),

                    // White container with content
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Page indicator
                          SmoothPageIndicator(
                            controller: PageController(initialPage: 0),
                            count: 3,
                            effect: ScrollingDotsEffect(
                              spacing: 8,
                              activeDotColor: Theme.of(context).primaryColor,
                              dotColor: Colors.grey.shade400,
                              dotHeight: 8,
                              dotWidth: 8,
                            ),
                          ),
                          SizedBox(height: 26),

                          // Title
                          Text(
                            'My ADA Cards',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF3A6381),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 18),

                          // Description
                          Text(
                            'Access your university ID anytime, anywhere. No more worrying about forgetting your card-it\'s always in your pocket.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFFA54D66),
                            ),
                          ),
                          SizedBox(height: 32),

                          // Buttons
                          Container(
                            width: 335,
                            height: 56,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3A6381),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                NavigatorService.pushReplacementNamed(
                                  AppRoutes.onboardingScreen2,
                                );
                              },
                              child: Text(
                                'Get Started',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 28),

                          // Skip button
                          GestureDetector(
                            onTap: () {
                              NavigatorService.pushReplacementNamed(
                                AppRoutes.loginScreen,
                              );
                            },
                            child: Text(
                              'Skip',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFFA54D66),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget builder(BuildContext context) => NdScreen();
}

// Onboarding Screen 2 (Rd Screen)
class RdScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Dismiss keyboard when this screen is shown
    FocusScope.of(context).unfocus();

    return Scaffold(
      // Add this to prevent bottom inset issues with keyboard
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Background image
              Image.asset(
                'assets/images/background simple.png',
                width: double.infinity,
                fit: BoxFit.cover,
              ),

              // Frame image
              Image.asset(
                'assets/images/frame.png',
                width: double.infinity,
                fit: BoxFit.contain,
              ),

              // Logo at top
              Positioned(
                top: 24,
                child: Image.asset(
                  'assets/images/logo 1.png',
                  height: 66,
                  width: 104,
                  fit: BoxFit.contain,
                ),
              ),

              // White container with content
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Page indicator
                    SmoothPageIndicator(
                      controller: PageController(initialPage: 1),
                      count: 3,
                      effect: ScrollingDotsEffect(
                        spacing: 8,
                        activeDotColor: Theme.of(context).primaryColor,
                        dotColor: Colors.grey.shade400,
                        dotHeight: 8,
                        dotWidth: 8,
                      ),
                    ),
                    SizedBox(height: 26),

                    // Title
                    Text(
                      'Effortless Campus Access',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF3A6381),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 18),

                    // Description
                    Text(
                      'Scan your digital card at gates, libraries, and labs for quick and secure entry.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFFA54D66),
                      ),
                    ),
                    SizedBox(height: 50),

                    // Buttons
                    Container(
                      width: 335,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3A6381),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          NavigatorService.pushReplacementNamed(
                            AppRoutes.onboardingScreen3,
                          );
                        },
                        child: Text(
                          'Get Started',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 28),

                    // Skip button
                    GestureDetector(
                      onTap: () {
                        NavigatorService.pushReplacementNamed(
                          AppRoutes.loginScreen,
                        );
                      },
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFA54D66),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget builder(BuildContext context) => RdScreen();
}

// Onboarding Screen 3 (Th Screen)
class ThScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with logo
            SizedBox(height: 24),
            Image.asset(
              'assets/images/logo 1.png',
              height: 66,
              width: 104,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 26),

            // Main image
            Image.asset(
              'assets/images/frame2.png',
              height: 298,
              width: double.infinity,
              fit: BoxFit.contain,
            ),

            // White container with content
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Page indicator
                    SmoothPageIndicator(
                      controller: PageController(initialPage: 2),
                      count: 3,
                      effect: ScrollingDotsEffect(
                        spacing: 8,
                        activeDotColor: Theme.of(context).primaryColor,
                        dotColor: Colors.grey.shade400,
                        dotHeight: 8,
                        dotWidth: 8,
                      ),
                    ),
                    SizedBox(height: 26),

                    // Title
                    Text(
                      'Ready to Begin?',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF3A6381),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 14),

                    // Description
                    Text(
                      'Log in with your university credentials and explore all the app has to offer!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFFA54D66),
                      ),
                    ),
                    SizedBox(height: 80),

                    // Get Started button
                    Container(
                      width: 335,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3A6381),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Get.offAllNamed(AppRoutes.loginScreen,
                              predicate: (_) => false);
                        },
                        child: Text(
                          'Get Started',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget builder(BuildContext context) => ThScreen();
}

// Student home screen with ID card and APDU toggle
class PlaceholderStudentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final apduService = Provider.of<ApduService>(context);

    // Set user UID in APDU service when screen loads
    if (authService.currentUser?.uid != null &&
        apduService.uid != authService.currentUser?.uid) {
      apduService.setUid(authService.currentUser!.uid);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Image.asset(
          'assets/images/logo 1.png',
          height: 40,
          fit: BoxFit.contain,
        ),
        centerTitle: false,
        actions: [
          // Settings icon
          IconButton(
            icon: Icon(Icons.settings, color: const Color(0xFF3A6381)),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
          // Notification icon with badge
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon:
                    Icon(Icons.email_outlined, color: const Color(0xFF3A6381)),
                onPressed: () {
                  // TODO: Navigate to notifications
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ID Card - using exact dimensions from Figma
              Container(
                width: 352,
                height: 213,
                margin: EdgeInsets.only(bottom: 24),
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
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Student photo
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 100,
                              height: 130,
                              color: Colors.grey.shade200,
                              child: Icon(Icons.person, size: 50),
                            ),
                          ),
                          SizedBox(width: 16),
                          // Student info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'ADA UNIVERSITY',
                                      style: TextStyle(
                                        color: const Color(0xFF3A6381),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Image.asset(
                                      'assets/images/logo 1.png',
                                      height: 20,
                                      fit: BoxFit.contain,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                _buildInfoRow('Name:',
                                    authService.currentUser?.name ?? ''),
                                SizedBox(height: 8),
                                // Extract surname from full name if possible
                                _buildInfoRow(
                                    'Surname:',
                                    authService.currentUser?.personalInformation
                                                    .fullName !=
                                                null &&
                                            authService
                                                    .currentUser!
                                                    .personalInformation
                                                    .fullName
                                                    .split(' ')
                                                    .length >
                                                1
                                        ? authService.currentUser!
                                            .personalInformation.fullName
                                            .split(' ')
                                            .last
                                        : ''),
                                SizedBox(height: 8),
                                _buildInfoRow('Status:', 'Student'),
                                SizedBox(height: 8),
                                // Use myRoomID for class if available
                                _buildInfoRow('Class:',
                                    'V${authService.currentUser?.personalInformation.myRoomId ?? ''}'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // NFC indicator
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: Row(
                        children: [
                          // APDU toggle button (using group 2.png if available)
                          GestureDetector(
                            onTap: () {
                              apduService.toggleService(!apduService.isActive);
                            },
                            child: Image.asset(
                              'assets/images/group 2.png',
                              height: 24,
                              width: 24,
                              color: apduService.isActive
                                  ? Colors.green
                                  : const Color(0xFFA54D66),
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.contactless_rounded,
                                  size: 24,
                                  color: apduService.isActive
                                      ? Colors.green
                                      : const Color(0xFFA54D66),
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 8),
                          // ID number from backend
                          Text(
                            'ID: ${authService.currentUser?.uid ?? ""}',
                            style: TextStyle(
                              color: const Color(0xFF3A6381),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // More section
              Text(
                'More',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 16),

              // Features grid
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildFeatureCard(
                    context,
                    imageAsset: 'assets/images/assign_12691866 1.png',
                    title: 'attendance\ncheck',
                    onTap: () {},
                  ),
                  _buildFeatureCard(
                    context,
                    imageAsset: 'assets/images/booking-online_10992406 1.png',
                    title: 'room\nreservation',
                    onTap: () {},
                  ),
                  _buildFeatureCard(
                    context,
                    icon: Icons.add,
                    title: '',
                    onTap: () {},
                    showTitleText: false,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      // Tab bar at bottom
      bottomNavigationBar: _buildTabBar(context),
    );
  }

  // Helper method to build info rows in the ID card
  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF3A6381),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            color: const Color(0xFF3A6381),
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // Feature card widget with exact dimensions from Figma
  Widget _buildFeatureCard(
    BuildContext context, {
    String? imageAsset,
    IconData? icon,
    required String title,
    required VoidCallback onTap,
    bool showTitleText = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 100,
        height: 100,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFA54D66)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imageAsset != null)
              Image.asset(
                imageAsset,
                height: 40,
                width: 40,
                fit: BoxFit.contain,
                color: const Color(0xFFA54D66),
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    icon ?? Icons.error,
                    size: 40,
                    color: const Color(0xFFA54D66),
                  );
                },
              )
            else if (icon != null)
              Icon(
                icon,
                size: 40,
                color: const Color(0xFFA54D66),
              ),
            if (showTitleText) SizedBox(height: 8),
            if (showTitleText)
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xFF3A6381),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Tab bar widget using the tab bar image from assets if available
  Widget _buildTabBar(BuildContext context) {
    return Container(
      height: 70,
      child: Stack(
        children: [
          Image.asset(
            'assets/images/tab bar.png',
            width: double.infinity,
            height: 70,
            fit: BoxFit.fill,
            errorBuilder: (context, error, stackTrace) {
              // Fallback UI if image doesn't load
              return BottomNavigationBar(
                currentIndex: 0,
                backgroundColor: const Color(0xFF3A6381),
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.white70,
                items: [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.home), label: 'Home'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.search), label: 'Search'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.person), label: 'Account'),
                ],
              );
            },
          ),
          // Home indicator
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTabItem(Icons.home, 'Home', isSelected: true),
                _buildTabItem(Icons.search, 'Search'),
                _buildTabItem(Icons.person, 'Account'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tab item for bottom navigation
  Widget _buildTabItem(IconData icon, String label, {bool isSelected = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 12),
        Icon(
          icon,
          color: isSelected ? Colors.white : Colors.white70,
        ),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// Teacher home screen with APDU toggle
class PlaceholderTeacherScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final apduService = Provider.of<ApduService>(context);

    // Set user UID in APDU service when screen loads
    if (authService.currentUser?.uid != null &&
        apduService.uid != authService.currentUser?.uid) {
      apduService.setUid(authService.currentUser!.uid);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Image.asset(
          'assets/images/logo 1.png',
          height: 40,
          fit: BoxFit.contain,
        ),
        centerTitle: false,
        actions: [
          // Settings icon
          IconButton(
            icon: Icon(Icons.settings, color: const Color(0xFF3A6381)),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
          // Notification icon with badge
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon:
                    Icon(Icons.email_outlined, color: const Color(0xFF3A6381)),
                onPressed: () {
                  // TODO: Navigate to notifications
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ID Card - using exact dimensions from Figma (same as student card but with teacher status)
              Container(
                width: 352,
                height: 213,
                margin: EdgeInsets.only(bottom: 24),
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
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Teacher photo
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 100,
                              height: 130,
                              color: Colors.grey.shade200,
                              child: Icon(Icons.person, size: 50),
                            ),
                          ),
                          SizedBox(width: 16),
                          // Teacher info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'ADA UNIVERSITY',
                                      style: TextStyle(
                                        color: const Color(0xFF3A6381),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Image.asset(
                                      'assets/images/logo 1.png',
                                      height: 20,
                                      fit: BoxFit.contain,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                _buildInfoRow('Name:',
                                    authService.currentUser?.name ?? ''),
                                SizedBox(height: 8),
                                // Extract surname from full name if possible
                                _buildInfoRow(
                                    'Surname:',
                                    authService.currentUser?.personalInformation
                                                    .fullName !=
                                                null &&
                                            authService
                                                    .currentUser!
                                                    .personalInformation
                                                    .fullName
                                                    .split(' ')
                                                    .length >
                                                1
                                        ? authService.currentUser!
                                            .personalInformation.fullName
                                            .split(' ')
                                            .last
                                        : ''),
                                SizedBox(height: 8),
                                _buildInfoRow('Status:', 'Teacher'),
                                SizedBox(height: 8),
                                // Use myRoomID for class
                                _buildInfoRow('Class:',
                                    'A${authService.currentUser?.personalInformation.myRoomId ?? ''}'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // NFC indicator
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: Row(
                        children: [
                          // APDU toggle button (using group 2.png if available)
                          GestureDetector(
                            onTap: () {
                              apduService.toggleService(!apduService.isActive);
                            },
                            child: Image.asset(
                              'assets/images/group 2.png',
                              height: 24,
                              width: 24,
                              color: apduService.isActive
                                  ? Colors.green
                                  : const Color(0xFFA54D66),
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.contactless_rounded,
                                  size: 24,
                                  color: apduService.isActive
                                      ? Colors.green
                                      : const Color(0xFFA54D66),
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 8),
                          // ID number from backend
                          Text(
                            'ID: ${authService.currentUser?.uid ?? ""}',
                            style: TextStyle(
                              color: const Color(0xFF3A6381),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // More section
              Text(
                'More',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 16),

              // Features grid - teacher specific
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildFeatureCard(
                    context,
                    imageAsset: 'assets/images/assign_12691866 1.png',
                    title: 'Student\nattendance check',
                    onTap: () {},
                  ),
                  _buildFeatureCard(
                    context,
                    imageAsset: 'assets/images/booking-online_10992406 1.png',
                    title: 'Room\nreservation',
                    onTap: () {},
                  ),
                  _buildFeatureCard(
                    context,
                    imageAsset: 'assets/images/talk_16097781 1.png',
                    title: 'My room',
                    onTap: () {
                      // Navigate to My Room screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyRoomScreen(roomId: 'A120'),
                        ),
                      );
                    },
                  ),
                  _buildFeatureCard(
                    context,
                    icon: Icons.add,
                    title: '',
                    onTap: () {},
                    showTitleText: false,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      // Tab bar at bottom
      bottomNavigationBar: _buildTabBar(context),
    );
  }

  // Helper method to build info rows in the ID card
  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF3A6381),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            color: const Color(0xFF3A6381),
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // Feature card widget with exact dimensions from Figma
  Widget _buildFeatureCard(
    BuildContext context, {
    String? imageAsset,
    IconData? icon,
    required String title,
    required VoidCallback onTap,
    bool showTitleText = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 100,
        height: 100,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFA54D66)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imageAsset != null)
              Image.asset(
                imageAsset,
                height: 40,
                width: 40,
                fit: BoxFit.contain,
                color: const Color(0xFFA54D66),
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    icon ?? Icons.error,
                    size: 40,
                    color: const Color(0xFFA54D66),
                  );
                },
              )
            else if (icon != null)
              Icon(
                icon,
                size: 40,
                color: const Color(0xFFA54D66),
              ),
            if (showTitleText) SizedBox(height: 8),
            if (showTitleText)
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xFF3A6381),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Tab bar widget using the tab bar image from assets if available
  Widget _buildTabBar(BuildContext context) {
    return Container(
      height: 70,
      child: Stack(
        children: [
          Image.asset(
            'assets/images/tab bar.png',
            width: double.infinity,
            height: 70,
            fit: BoxFit.fill,
            errorBuilder: (context, error, stackTrace) {
              // Fallback UI if image doesn't load
              return BottomNavigationBar(
                currentIndex: 0,
                backgroundColor: const Color(0xFF3A6381),
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.white70,
                items: [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.home), label: 'Home'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.search), label: 'Search'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.person), label: 'Account'),
                ],
              );
            },
          ),
          // Home indicator
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTabItem(Icons.home, 'Home', isSelected: true),
                _buildTabItem(Icons.search, 'Search'),
                _buildTabItem(Icons.person, 'Account'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tab item for bottom navigation
  Widget _buildTabItem(IconData icon, String label, {bool isSelected = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 12),
        Icon(
          icon,
          color: isSelected ? Colors.white : Colors.white70,
        ),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// Login Screen with updated design
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    // Dismiss keyboard when this screen loads
    FocusScope.of(context).unfocus();

    return Scaffold(
      // Handle bottom overflow with keyboard
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        // Wrap with GestureDetector to dismiss keyboard on tap
        child: GestureDetector(
          onTap: () {
            // Dismiss keyboard when tapping outside text fields
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            // Add padding that adjusts with keyboard
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 24.0, bottom: 80.0),
                        child: Image.asset(
                          'assets/images/logo 1.png',
                          height: 66,
                          width: 104,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    if (_errorMessage != null)
                      Padding(
                        padding: EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),

                    // Email field - using exact dimensions from Figma
                    Container(
                      width: 335,
                      height: 60,
                      margin: EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'EMAIL',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          suffixIcon: Icon(Icons.check, color: Colors.green),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              !value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                    ),

                    // Password field - using exact dimensions from Figma
                    Container(
                      width: 335,
                      height: 60,
                      margin: EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'PASSWORD',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          suffixIcon:
                              Icon(Icons.visibility_off, color: Colors.grey),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                    ),

                    // Remember me checkbox - using exact dimensions from Figma
                    Container(
                      width: 138,
                      height: 27,
                      child: Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          Text(
                            'Remember me',
                            style: TextStyle(
                              color: const Color(0xFF3A6381),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 30),

                    // Login button - using exact dimensions from Figma
                    Container(
                      width: 335,
                      height: 50,
                      child: _isLoading
                          ? Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _login,
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3A6381),
                                padding: EdgeInsets.symmetric(vertical: 13),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        final user = await authService.login(
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (user != null) {
          // Use the role-based navigation from AppRoutes
          final homeRoute = AppRoutes.getHomeRoute(user.role);
          Navigator.of(context).pushReplacementNamed(homeRoute);
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API service
  final apiService = ApiService();
  await apiService.initialize();

  // Initialize and register APDU service with GetX
  final apduService = ApduService();
  Get.put<ApduService>(apduService, permanent: true);

  // Add this to ensure keyboard is dismissed at app start
  SystemChannels.textInput.invokeMethod('TextInput.hide');

  runApp(const MyApp());
}

/// MyADA main application
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => NavigationProvider()),
            // Add AuthService to providers for proper initialization
            ChangeNotifierProvider<AuthService>(create: (_) => AuthService()),
            // Provide ApiService as a singleton
            Provider<ApiService>(create: (_) => ApiService()),
            // Add ApduService for NFC functionality
            ChangeNotifierProvider<ApduService>(create: (_) => ApduService()),
          ],
          child: GetMaterialApp(
            title: 'MyADA Official',
            debugShowCheckedModeBanner: false,
            theme: ThemeHelper.lightTheme,
            darkTheme: ThemeHelper.darkTheme,
            themeMode: ThemeMode.light,
            locale: const Locale('en', 'US'),
            fallbackLocale: const Locale('en', 'US'),
            initialRoute: AppRoutes.splash,
            getPages: AppRoutes.pages,
          ),
        );
      },
    );
  }
}
