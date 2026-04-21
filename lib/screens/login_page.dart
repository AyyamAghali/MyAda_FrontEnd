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
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
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
        child: Stack(
          children: [
            Positioned(
              top: -120,
              left: -90,
              child: _buildAccentBlob(
                size: 240,
                color: AppColors.secondary.withOpacity(0.20),
              ),
            ),
            Positioned(
              bottom: -140,
              right: -110,
              child: _buildAccentBlob(
                size: 280,
                color: AppColors.white.withOpacity(0.10),
              ),
            ),
            SafeArea(
              child: ResponsiveContainer(
                backgroundColor: Colors.transparent,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 18, 0, 12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  _buildLogo(),
                                  const SizedBox(height: 18),
                                  _buildLoginCard(),
                                ],
                              ),
                              _buildFooter(),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccentBlob({required double size, required Color color}) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.16),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
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
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.white,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.white.withOpacity(0.85),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      margin: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 10,
        bottom: bottomInset > 0 ? 10 : 0,
      ),
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withOpacity(0.55)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 26,
            offset: const Offset(0, 14),
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
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.gray900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Use your ADA account to continue',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.gray600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            _buildEmailField(),
            const SizedBox(height: 14),
            _buildPasswordField(),
            const SizedBox(height: 10),
            _buildRememberMe(),
            const SizedBox(height: 16),
            _buildLoginButton(),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String labelText,
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: Icon(icon, color: AppColors.primary),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.gray50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      focusNode: _emailFocus,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.username, AutofillHints.email],
      decoration: _inputDecoration(
        labelText: 'Email',
        hintText: 'student@ada.edu.az',
        icon: Icons.email_outlined,
      ),
      onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
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
      focusNode: _passwordFocus,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.password],
      decoration: _inputDecoration(
        labelText: 'Password',
        hintText: 'Enter your password',
        icon: Icons.lock_outlined,
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: AppColors.gray400,
          ),
          onPressed: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
        ),
      ),
      onFieldSubmitted: (_) => _submit(),
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
        const Text('Remember me',
            style: TextStyle(fontSize: 13, color: AppColors.gray700)),
        const Spacer(),
        TextButton(
          onPressed: () {
            _showInfoSnackBar('Password reset is mocked in this prototype.');
          },
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Forgot?',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  void _submit() {
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
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _submit,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.20),
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

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
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
