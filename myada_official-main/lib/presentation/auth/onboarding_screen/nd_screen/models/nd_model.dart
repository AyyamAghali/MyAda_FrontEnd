import 'package:myada_official/core/app_export.dart';

/// Model class for ND (onboarding) screen
class NDModel {
  /// List of onboarding items
  final List<OnboardingItem> items = [
    OnboardingItem(
      title: 'Welcome to My ADA',
      description: 'Your digital student ID and attendance system',
      imagePath: ImageConstant.imgLogo1,
    ),
    OnboardingItem(
      title: 'Access Control',
      description: 'Use your phone to access rooms and facilities',
      imagePath: ImageConstant.imgSmartcards,
    ),
    OnboardingItem(
      title: 'Track Attendance',
      description: 'View your attendance records and classroom history',
      imagePath: ImageConstant.imgFrame2,
    ),
  ];

  /// Current page index
  int currentPageIndex = 0;

  /// Page controller for the onboarding slider
  final PageController pageController = PageController();

  /// Check if it's the last page
  bool get isLastPage => currentPageIndex == items.length - 1;

  /// Dispose resources
  void dispose() {
    pageController.dispose();
  }
}

/// Model for each onboarding item
class OnboardingItem {
  final String title;
  final String description;
  final String imagePath;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}
