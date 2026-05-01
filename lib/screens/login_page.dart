import 'dart:async';

import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/responsive_container.dart';
import '../services/auth_service.dart';
import '../services/call/call_controller.dart';
import '../services/notification_controller.dart';
import 'master_home_page.dart';
import 'auth/forgot_password_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isSubmitting = false;
  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();

  late final AnimationController _bgAnimCtrl;
  late final Animation<double> _bgAnim;

  @override
  void initState() {
    super.initState();
    _bgAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);
    _bgAnim = CurvedAnimation(parent: _bgAnimCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _bgAnimCtrl.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgAnim,
        builder: (context, child) {
          final t = _bgAnim.value;
          return Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-1.0 + t * 0.4, -1.0),
                end: Alignment(1.0, 1.0 - t * 0.4),
                colors: const [
                  Color(0xFF75AFC0),
                  Color(0xFF3E7890),
                  Color(0xFF25566D),
                ],
                stops: [0.0, 0.5 + t * 0.1, 1.0],
              ),
            ),
            child: child,
          );
        },
        child: Stack(
          children: [
            // Decorative shapes
            ..._buildDecoShapes(size),

            // Main content
            SafeArea(
              child: ResponsiveContainer(
                backgroundColor: Colors.transparent,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minHeight: constraints.maxHeight),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 32),
                            _buildLogoSection(),
                            const SizedBox(height: 36),
                            _buildCard(context),
                            const SizedBox(height: 24),
                            _buildFooter(),
                            const SizedBox(height: 16),
                          ],
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

  List<Widget> _buildDecoShapes(Size size) {
    return [
      Positioned(
        top: -size.height * 0.12,
        right: -size.width * 0.15,
        child: _DecoCircle(
          size: size.width * 0.65,
          color: Colors.white.withOpacity(0.04),
        ),
      ),
      Positioned(
        bottom: -size.height * 0.08,
        left: -size.width * 0.2,
        child: _DecoCircle(
          size: size.width * 0.55,
          color: AppColors.secondary.withOpacity(0.08),
        ),
      ),
      Positioned(
        top: size.height * 0.35,
        left: -40,
        child: _DecoCircle(
          size: 80,
          color: Colors.white.withOpacity(0.03),
        ),
      ),
    ];
  }

  Widget _buildLogoSection() {
    final w = MediaQuery.sizeOf(context).width;
    final logoWidth = (w * 0.48).clamp(150.0, 230.0);
    final logoHeight = logoWidth * 0.64;

    return Column(
      children: [
        SizedBox(
          width: logoWidth + 88,
          height: logoHeight + 64,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.72),
                        const Color(0xFFE8F4F7).withValues(alpha: 0.38),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.56, 1.0],
                    ),
                  ),
                ),
              ),
              RepaintBoundary(
                child: Image.asset(
                  'assets/images/ada_login_logo.png',
                  width: logoWidth,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  gaplessPlayback: true,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Student Portal',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.88),
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            // Accent bar
            Container(
              height: 4,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Welcome back',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sign in with your ADA credentials',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.gray500,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _buildField(
                      controller: _usernameController,
                      focusNode: _usernameFocus,
                      label: 'Username',
                      hint: 'Enter your username',
                      icon: Icons.person_outline_rounded,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.username],
                      onSubmitted: (_) => _passwordFocus.requestFocus(),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      label: 'Password',
                      hint: 'Enter your password',
                      icon: Icons.lock_outline_rounded,
                      obscure: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onSubmitted: (_) => _submit(),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (v.length < 6) return 'At least 6 characters';
                        return null;
                      },
                      suffix: GestureDetector(
                        onTap: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                            color: AppColors.gray400,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildOptionsRow(),
                    const SizedBox(height: 22),
                    _buildSignInButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputAction? textInputAction,
    List<String>? autofillHints,
    void Function(String)? onSubmitted,
    String? Function(String?)? validator,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.gray700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscure,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          onFieldSubmitted: onSubmitted,
          validator: validator,
          style: const TextStyle(fontSize: 15, color: AppColors.gray900),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 14, color: AppColors.gray400),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 14, right: 10),
              child: Icon(icon, size: 20, color: AppColors.gray400),
            ),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
            suffixIcon: suffix,
            suffixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
            filled: true,
            fillColor: AppColors.gray50,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.gray200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.gray200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppColors.secondary, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppColors.secondary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsRow() {
    return Row(
      children: [
        SizedBox(
          width: 22,
          height: 22,
          child: Checkbox(
            value: _rememberMe,
            onChanged: (v) => setState(() => _rememberMe = v ?? false),
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            side: BorderSide(color: AppColors.gray300, width: 1.5),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => setState(() => _rememberMe = !_rememberMe),
          child: Text(
            'Remember me',
            style: TextStyle(fontSize: 13, color: AppColors.gray600),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const ForgotPasswordScreen()),
          ),
          child: Text(
            'Forgot password?',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: _isSubmitting
            ? null
            : const LinearGradient(
                colors: [AppColors.primary, Color(0xFF3D7A96)],
              ),
        color: _isSubmitting ? AppColors.gray300 : null,
        boxShadow: _isSubmitting
            ? null
            : [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isSubmitting ? null : _submit,
          borderRadius: BorderRadius.circular(14),
          child: Center(
            child: _isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded,
                          size: 20, color: Colors.white),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Text(
        'By signing in you agree to the Terms of Service\nand Privacy Policy',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          height: 1.5,
          color: Colors.white.withOpacity(0.55),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) return;

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    setState(() => _isSubmitting = true);
    try {
      await AuthService.instance.login(
        username: username,
        password: password,
      );

      unawaited(CallController.instance.connect().catchError((_) {}));
      unawaited(NotificationController.instance.initialize().catchError((_) {}));

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MasterHomePage()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: AppColors.secondary,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}

class _DecoCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _DecoCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
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
}
