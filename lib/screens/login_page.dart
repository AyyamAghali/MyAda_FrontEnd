import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/responsive_container.dart';
import 'master_home_page.dart';
import 'admin/module_admin_screen.dart';
import 'admin/support_staff_dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
        ),
        child: SafeArea(
          child: ResponsiveContainer(
            backgroundColor: Colors.transparent,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  _buildLogo(),
                  const SizedBox(height: 40),
                  _buildLoginCard(),
                  const SizedBox(height: 24),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Image.asset(
              'assets/images/ada_logo.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Text(
                    'ADA',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: 2,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'ADA UNIVERSITY',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Sign In',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.gray900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your credentials to continue',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.gray600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildEmailField(),
            const SizedBox(height: 20),
            _buildPasswordField(),
            const SizedBox(height: 16),
            _buildRememberMe(),
            const SizedBox(height: 24),
            _buildLoginButton(),
            const SizedBox(height: 16),
            _buildForgotPassword(),
            const SizedBox(height: 24),
            _buildDivider(),
            const SizedBox(height: 24),
            _buildSocialLogin(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'student@ada.edu.az',
        prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
        filled: true,
        fillColor: AppColors.gray50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.gray200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.gray200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!value.contains('@')) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Enter your password',
        prefixIcon: const Icon(Icons.lock_outlined, color: AppColors.primary),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: AppColors.gray400,
          ),
          onPressed: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
        ),
        filled: true,
        fillColor: AppColors.gray50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.gray200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.gray200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }

  Widget _buildRememberMe() {
    return Row(
      children: [
        Checkbox(
          value: _rememberMe,
          onChanged: (value) {
            setState(() => _rememberMe = value ?? false);
          },
          activeColor: AppColors.primary,
        ),
        const Text(
          'Remember me',
          style: TextStyle(fontSize: 14, color: AppColors.gray700),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          final email = _emailController.text.trim().toLowerCase();
          final staffRole = _resolveStaffRole(email);
          if (staffRole != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => SupportStaffDashboard(
                  staffName: 'Staff User',
                  roleType: staffRole,
                ),
              ),
            );
            return;
          }

          final module = ModuleAdminScreen.resolveModule(email);
          if (module != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ModuleAdminScreen(module: module),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MasterHomePage()),
            );
          }
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
      ),
      child: const Text(
        'Sign In',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildForgotPassword() {
    return TextButton(
      onPressed: () {
        _showInfoSnackBar('Password reset is mocked in this prototype.');
      },
      child: const Text(
        'Forgot Password?',
        style: TextStyle(
          fontSize: 14,
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.gray300,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.gray500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.gray300,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLogin() {
    return Column(
      children: [
        OutlinedButton.icon(
          onPressed: () {
            _showInfoSnackBar('Google login is mocked in this prototype.');
          },
          icon: const Icon(Icons.g_mobiledata, size: 24),
          label: const Text('Continue with Google'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            side: BorderSide(color: AppColors.gray300),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            _showInfoSnackBar('Microsoft login is mocked in this prototype.');
          },
          icon: const Icon(Icons.account_circle_outlined, size: 24),
          label: const Text('Continue with Microsoft'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            side: BorderSide(color: AppColors.gray300),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        'By signing in, you agree to our Terms of Service and Privacy Policy',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.white.withOpacity(0.8),
        ),
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  StaffRoleType? _resolveStaffRole(String email) {
    if (email.contains('staff') && email.contains('it')) {
      return StaffRoleType.it;
    }
    if (email.contains('staff') && email.contains('fm')) {
      return StaffRoleType.fm;
    }
    return null;
  }
}

