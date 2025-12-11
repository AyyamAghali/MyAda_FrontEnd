import 'package:myada_official/core/app_export.dart';
import 'package:myada_official/presentation/auth/onboarding_screen/nd_screen/models/nd_model.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// ND Screen (Onboarding screen)
class NDScreen extends StatefulWidget {
  const NDScreen({Key? key}) : super(key: key);

  @override
  State<NDScreen> createState() => _NDScreenState();
}

class _NDScreenState extends State<NDScreen> {
  final NDModel _model = NDModel();

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  /// Navigate to next page or next onboarding screen
  void _onNext() {
    if (_model.isLastPage) {
      // Go to login screen
      NavigatorService.pushReplacementNamed(AppRoutes.loginScreen);
    } else {
      // Go to next page in PageView
      _model.pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Skip onboarding and go to login screen
  void _onSkip() {
    NavigatorService.pushReplacementNamed(AppRoutes.loginScreen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _model.pageController,
                itemCount: _model.items.length,
                onPageChanged: (index) {
                  setState(() {
                    _model.currentPageIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final item = _model.items[index];
                  return _buildOnboardingPage(item);
                },
              ),
            ),
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  /// Build onboarding page content
  Widget _buildOnboardingPage(OnboardingItem item) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20.h),
          // For the first page, set precise dimensions
          item.title == 'Welcome to My ADA'
              ? Padding(
                  padding: EdgeInsets.only(top: 30.h),
                  child: Container(
                    width: 277.w,
                    height: 178.h,
                    margin: EdgeInsets.symmetric(
                        horizontal: 10.w), // Center the logo
                    child: Image.asset(
                      item.imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholderImage();
                      },
                    ),
                  ),
                )
              : Image.asset(
                  item.imagePath,
                  height: 250.h,
                  width: 250.w,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholderImage();
                  },
                ),
          SizedBox(height: 40.h),
          Text(
            item.title,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          Text(
            item.description,
            style: TextStyle(
              fontSize: 16.sp,
              color: theme.colorScheme.onBackground,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build bottom navigation with indicators and buttons
  Widget _buildBottomNavigation() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Column(
        children: [
          SmoothPageIndicator(
            controller: _model.pageController,
            count: _model.items.length,
            effect: ExpandingDotsEffect(
              dotHeight: 8.h,
              dotWidth: 8.w,
              activeDotColor: theme.colorScheme.primary,
              dotColor: theme.colorScheme.primary.withOpacity(0.3),
              spacing: 8.w,
            ),
          ),
          SizedBox(height: 32.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _model.isLastPage
                  ? const SizedBox.shrink()
                  : TextButton(
                      onPressed: _onSkip,
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
              ElevatedButton(
                onPressed: _onNext,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.w,
                    vertical: 12.h,
                  ),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  _model.isLastPage ? 'Get Started' : 'Next',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  // Create a placeholder widget for when images fail to load
  Widget _buildPlaceholderImage() {
    return Container(
      height: 180.h,
      width: 180.w,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported,
              size: 60.sp,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 8.h),
            Text(
              'Image not available',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
