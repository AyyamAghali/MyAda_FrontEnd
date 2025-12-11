import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myada_official/core/models/user_model.dart';
import 'package:myada_official/core/services/apdu_service.dart';
import 'package:myada_official/core/services/auth_service.dart';
import 'package:myada_official/core/utils/navigation_provider.dart';
import 'package:myada_official/main.dart';
import 'package:myada_official/presentation/auth/login_screen/th1_screen/th1_screen.dart';
import 'package:myada_official/presentation/auth/onboarding_screen/nd_screen/nd_screen.dart';
import 'package:myada_official/presentation/auth/onboarding_screen/rd_screen/rd_screen.dart';
import 'package:myada_official/presentation/auth/splash_screen/st_screen/st_screen.dart';
import 'package:myada_official/presentation/features/my_room_screen/my_room_screen.dart';
import 'package:myada_official/presentation/features/room_reservation_screen/room_reservation_screen.dart';
import 'package:myada_official/presentation/home/student_home_screen/th2_screen/th2_screen.dart';
import 'package:myada_official/presentation/home/teacher_home_screen/th3_screen/th3_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Temporarily comment out the screens with errors
// import 'package:myada_official/presentation/home/student_home_screen/th2_screen/th2_screen.dart';
// import 'package:myada_official/presentation/home/teacher_home_screen/th3_screen/th3_screen.dart';

// Temporary placeholder screens for testing login only
class PlaceholderStudentScreen extends StatelessWidget {
  const PlaceholderStudentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Student Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Student Dashboard Placeholder'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }

  static Widget builder(BuildContext context) => PlaceholderStudentScreen();
}

class PlaceholderTeacherScreen extends StatelessWidget {
  const PlaceholderTeacherScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Teacher Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Teacher Dashboard Placeholder'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }

  static Widget builder(BuildContext context) => PlaceholderTeacherScreen();
}

/// App routes class for defining navigation routes
class AppRoutes {
  static const String splash = '/';
  static const String onboardingScreen1 = '/onboarding_screen1';
  static const String onboardingScreen2 = '/onboarding_screen2';
  static const String loginScreen = '/login_screen';
  static const String studentHomeScreen = '/student_home_screen';
  static const String teacherHomeScreen = '/teacher_home_screen';
  static const String myRoomScreen = '/my_room_screen';

  /// Definition for initial/onboarding routes (for backward compatibility)
  static const String splashScreen = '/splash';
  static const String onboardingScreen3 = '/onboarding3';
  static const String roomReservation = '/room_reservation';

  /// GetX route pages
  static final List<GetPage<dynamic>> pages = [
    GetPage(
      name: splash,
      page: () => const STScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: onboardingScreen1,
      page: () => const NDScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: onboardingScreen2,
      page: () => const RDScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: loginScreen,
      page: () => const TH1Screen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: studentHomeScreen,
      page: () => const TH2Screen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: teacherHomeScreen,
      page: () => const TH3Screen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: myRoomScreen,
      page: () => MyRoomScreen.builder(Get.context!,
          roomId: Get.arguments != null ? Get.arguments['roomId'] : 'A120'),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: roomReservation,
      page: () => RoomReservationScreen.builder(Get.context!),
      transition: Transition.rightToLeft,
    ),
  ];

  // Student related routes
  static const String studentAttendance = '/student/attendance';
  static const String studentRooms = '/student/rooms';
  static const String studentProfile = '/student/profile';

  // Teacher related routes
  static const String teacherClasses = '/teacher/classes';
  static const String teacherAttendance = '/teacher/attendance';
  static const String teacherProfile = '/teacher/profile';

  // Set initial route to onboarding sequence for first time users, otherwise login
  static const String initialRoute = splashScreen;

  // Helper method to check user role and redirect accordingly
  static String getHomeRoute(UserRole? role) {
    if (role == UserRole.student) {
      return studentHomeScreen;
    } else if (role == UserRole.teacher) {
      return teacherHomeScreen;
    } else {
      return loginScreen;
    }
  }

  // Check if this is the first time the app is opened
  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if there's been a previous login - if so, never show onboarding again
    final hasLoggedInBefore = prefs.getBool('has_logged_in_before') ?? false;
    if (hasLoggedInBefore) {
      return false;
    }

    final isFirstTime = prefs.getBool('first_time') ?? true;

    if (isFirstTime) {
      await prefs.setBool('first_time', false);
      return true;
    }

    return false;
  }

  /// Get route based on selected BottomBarEnum
  static String getRouteFromBottomBar(BottomBarEnum type) {
    switch (type) {
      case BottomBarEnum.home:
        return studentHomeScreen;
      case BottomBarEnum.attendance:
        return myRoomScreen;
      case BottomBarEnum.myRooms:
        return myRoomScreen;
      case BottomBarEnum.profile:
        return studentHomeScreen; // Replace with profile screen when available
      default:
        return studentHomeScreen;
    }
  }

  // Route generator to handle dynamic routing based on role
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashScreen:
        return MaterialPageRoute(builder: (_) => STScreen());

      case onboardingScreen3:
        return MaterialPageRoute(builder: (_) => ThScreen());

      case loginScreen:
        return MaterialPageRoute(builder: (_) => LoginScreen());

      case studentHomeScreen:
        return MaterialPageRoute(builder: (_) => PlaceholderStudentScreen());

      case teacherHomeScreen:
        return MaterialPageRoute(builder: (_) => PlaceholderTeacherScreen());

      case myRoomScreen:
        // Extract roomId from arguments if available
        final args = settings.arguments as Map<String, dynamic>?;
        final roomId = args != null ? args['roomId'] : 'A120';
        return MaterialPageRoute(
          builder: (context) => MyRoomScreen.builder(context, roomId: roomId),
        );

      case roomReservation:
        return MaterialPageRoute(
          builder: (context) => RoomReservationScreen.builder(context),
        );

      // Add future routes as needed

      default:
        // Fallback route
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route not found: ${settings.name}'),
            ),
          ),
        );
    }
  }

  // Route guard to redirect based on authentication status
  static Widget routeGuard(BuildContext context, Widget destination) {
    final authService = Provider.of<AuthService>(context);
    final apduService = Provider.of<ApduService>(context, listen: false);

    // If user is logged in, ensure the APDU service has their UID
    if (authService.isLoggedIn && authService.currentUser?.uid != null) {
      apduService.setUid(authService.currentUser!.uid);
    }

    if (!authService.isLoggedIn) {
      return LoginScreen();
    }

    if (destination is PlaceholderStudentScreen && !authService.isStudent()) {
      return PlaceholderTeacherScreen();
    }

    if (destination is PlaceholderTeacherScreen && !authService.isTeacher()) {
      return PlaceholderStudentScreen();
    }

    return destination;
  }
}
