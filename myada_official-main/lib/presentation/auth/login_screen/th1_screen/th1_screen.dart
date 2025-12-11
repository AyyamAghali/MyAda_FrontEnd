import 'package:myada_official/core/app_export.dart';
import 'package:myada_official/core/network/api_service.dart';
import 'package:myada_official/presentation/auth/login_screen/th1_screen/provider/th1_provider.dart';

/// Login screen for the application
class TH1Screen extends StatefulWidget {
  const TH1Screen({Key? key}) : super(key: key);

  @override
  State<TH1Screen> createState() => _TH1ScreenState();
}

class _TH1ScreenState extends State<TH1Screen> {
  @override
  void initState() {
    super.initState();
    // Check API service initialization
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Ensure keyboard is hidden when screen appears
      FocusScope.of(context).unfocus();

      final apiService = context.read<ApiService>();

      // Force logout when login screen is shown
      print('Login screen loaded, forcing logout...');
      await apiService.logout();

      // Make sure we're the only screen in the stack (no going back)
      if (Navigator.canPop(context)) {
        print('Found previous routes, removing them all');
        Navigator.of(context).popUntil((route) => route.isFirst);
      }

      print('API Service initialized. Base URL: ${ApiService.baseUrl}');
      print('API Auth Token: ${apiService.authToken}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TH1Provider(),
      child: const _LoginScreenContent(),
    );
  }
}

class _LoginScreenContent extends StatelessWidget {
  const _LoginScreenContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TH1Provider>(context);
    final model = provider.th1Model;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        // Wrap with GestureDetector to dismiss keyboard on tap
        child: GestureDetector(
          onTap: () {
            // Dismiss keyboard when tapping outside text fields
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.r).copyWith(
                bottom: MediaQuery.of(context).viewInsets.bottom > 0
                    ? MediaQuery.of(context).viewInsets.bottom + 24.r
                    : 24.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App logo
                Center(
                  child: CustomImageView(
                    imagePath: ImageConstant.imgLogo1,
                    height: 100.r,
                    width: 100.r,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 40.r),

                // Welcome text
                Center(
                  child: Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    'Log in to your account',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: theme.colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                ),
                SizedBox(height: 40.r),

                // Network error message (if any)
                if (provider.networkError != null)
                  Container(
                    padding: EdgeInsets.all(12.r),
                    margin: EdgeInsets.only(bottom: 16.r),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline,
                            color: Colors.red, size: 24.r),
                        SizedBox(width: 8.r),
                        Expanded(
                          child: Text(
                            provider.networkError!,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Email field
                Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.r),
                TextField(
                  controller: model.emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    errorText: model.emailError,
                  ),
                  onChanged: (_) => provider.setEmailError(null),
                ),
                SizedBox(height: 24.r),

                // Password field
                Text(
                  'Password',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.r),
                TextField(
                  controller: model.passwordController,
                  obscureText: !model.isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: theme.colorScheme.primary,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        model.isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: theme.colorScheme.primary,
                      ),
                      onPressed: () => provider.togglePasswordVisibility(),
                    ),
                    errorText: model.passwordError,
                  ),
                  onChanged: (_) => provider.setPasswordError(null),
                ),
                SizedBox(height: 16.r),

                // Remember me checkbox only
                Row(
                  children: [
                    Checkbox(
                      value: model.rememberMe,
                      onChanged: (value) =>
                          provider.toggleRememberMe(value ?? false),
                      activeColor: theme.colorScheme.primary,
                    ),
                    Text(
                      'Remember me',
                      style: TextStyle(
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32.r),

                // Login button
                SizedBox(
                  width: double.infinity,
                  height: 52.r,
                  child: ElevatedButton(
                    onPressed: provider.isLoading
                        ? null // Disable button when loading
                        : () async {
                            if (await provider.login()) {
                              // Navigate to home screen based on user role from API
                              final userRole = provider.userRole;
                              if (userRole == "teacher") {
                                NavigatorService.pushReplacementNamed(
                                    AppRoutes.teacherHomeScreen);
                              } else {
                                NavigatorService.pushReplacementNamed(
                                    AppRoutes.studentHomeScreen);
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: provider.isLoading
                        ? SizedBox(
                            height: 20.r,
                            width: 20.r,
                            child: CircularProgressIndicator(
                              color: theme.colorScheme.onPrimary,
                              strokeWidth: 2.r,
                            ),
                          )
                        : Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 24.r),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
