import 'package:myada_official/core/app_export.dart';

/// RD Screen (Second Onboarding screen)
class RDScreen extends StatelessWidget {
  const RDScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 24),

            // Logo at top
            Center(
              child: Image.asset(
                ImageConstant.imgLogo1,
                height: 70,
                width: 110,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 70,
                    width: 110,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'ADA',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background image
                  Image.asset(
                    ImageConstant.imgBackground,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,
                        width: double.infinity,
                      );
                    },
                  ),

                  // Main content image
                  Image.asset(
                    ImageConstant.imgFrame,
                    height: 300,
                    width: 300,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 300,
                        width: 300,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      );
                    },
                  ),

                  // Bottom content container
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              3,
                              (index) => Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                width: index == 1 ? 24 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: index == 1
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.3),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 26),

                          // Title
                          Text(
                            'Effortless Campus Access',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
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
                              color: codeColors.pink700,
                            ),
                          ),
                          SizedBox(height: 32),

                          // Next button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () {
                                NavigatorService.pushReplacementNamed(
                                    AppRoutes.loginScreen);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Next',
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
                          TextButton(
                            onPressed: () {
                              NavigatorService.pushReplacementNamed(
                                  AppRoutes.loginScreen);
                            },
                            child: Text(
                              'Skip',
                              style: TextStyle(
                                fontSize: 16,
                                color: codeColors.pink700,
                              ),
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
    );
  }
}
