import 'package:myada_official/core/app_export.dart';

/// Splash screen for application startup
class STScreen extends StatefulWidget {
  const STScreen({Key? key}) : super(key: key);

  @override
  State<STScreen> createState() => _STScreenState();
}

class _STScreenState extends State<STScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  /// Navigate to onboarding or login screen after delay
  Future<void> _navigateToNextScreen() async {
    // Simulate some loading or initialization
    await Future.delayed(const Duration(seconds: 2));

    print("Navigating from splash screen to onboarding screen...");
    NavigatorService.pushReplacementNamed(AppRoutes.onboardingScreen1);

    // As a fallback, try direct Get navigation after a short delay
    await Future.delayed(const Duration(milliseconds: 500));
    if (Get.currentRoute == AppRoutes.splash) {
      print("Fallback: Using direct Get navigation");
      Get.offAllNamed(AppRoutes.onboardingScreen1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 50.h), // Add top margin for positioning

            // App logo
            Container(
              width: 277.w,
              height: 178.h,
              margin: EdgeInsets.symmetric(
                  horizontal: 58.w), // Match left position from Figma
              child: CustomImageView(
                imagePath: ImageConstant.imgLogo1,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),

            // App name
            Text(
              'MyADA',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Tagline
            Text(
              'Your Digital Student ID',
              style: TextStyle(
                color: theme.colorScheme.primary.withOpacity(0.8),
                fontSize: 16.sp,
              ),
            ),
            const SizedBox(height: 48),

            // Loading indicator
            CircularProgressIndicator(
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
