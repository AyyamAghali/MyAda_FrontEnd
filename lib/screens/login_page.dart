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
    final bottomPad = MediaQuery.paddingOf(context).bottom +
        MediaQuery.viewInsetsOf(context).bottom;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: AnimatedBuilder(
        animation: _bgAnim,
        builder: (context, child) {
          final t = _bgAnim.value;
          final cyan = Color.lerp(
            const Color(0xFF5EEAD4),
            const Color(0xFF2DD4BF),
            t,
          )!;
          final mid = Color.lerp(
            const Color(0xFF3FB8D0),
            AppColors.primary,
            Curves.easeInOut.transform(t),
          )!;
          final deep = Color.lerp(
            AppColors.primaryDark,
            const Color(0xFF0C3D4D),
            t * 0.5,
          )!;
          return Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-1.0 + t * 0.35, -1.1),
                end: Alignment(1.05 - t * 0.2, 1.15),
                colors: [
                  cyan,
                  mid,
                  deep,
                  const Color(0xFF082F3A),
                ],
                stops: [0.0, 0.28 + t * 0.08, 0.72 - t * 0.06, 1.0],
              ),
            ),
            child: child,
          );
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Decorative shapes
            ..._buildDecoShapes(size),

            // Main content
            SafeArea(
              child: ResponsiveContainer(
                backgroundColor: Colors.transparent,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final minH = constraints.maxHeight.isFinite
                        ? constraints.maxHeight
                        : 0.0;
                    return SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: EdgeInsets.only(bottom: 24 + bottomPad),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: minH),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
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
        top: -size.height * 0.14,
        right: -size.width * 0.12,
        child: _DecoCircle(
          size: size.width * 0.72,
          color: Colors.white.withValues(alpha: 0.07),
        ),
      ),
      Positioned(
        bottom: size.height * 0.02,
        left: -size.width * 0.22,
        child: _DecoCircle(
          size: size.width * 0.58,
          color: AppColors.secondary.withValues(alpha: 0.12),
        ),
      ),
      Positioned(
        top: size.height * 0.52,
        right: -28,
        child: _DecoCircle(
          size: 96,
          color: Colors.white.withValues(alpha: 0.05),
        ),
      ),
    ];
  }

  Widget _buildLogoSection() {
    final w = MediaQuery.sizeOf(context).width;
    final logoWidth = (w * 0.46).clamp(148.0, 220.0);
    final logoHeight = logoWidth * 0.64;

    return Column(
      children: [
        // Crisp logo in a soft frosted frame — no circular "spotlight" blob.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.28),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: RepaintBoundary(
            child: Image.asset(
              'assets/images/ada_login_logo.png',
              width: logoWidth,
              height: logoHeight,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              gaplessPlayback: true,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
          ),
          child: Text(
            'ADA UNIVERSITY',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.2,
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Sign in to campus tools & services',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.78),
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 36,
            offset: const Offset(0, 18),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: double.infinity,
              height: 5,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF2DD4BF),
                    AppColors.primary,
                    AppColors.secondary,
                  ],
                ),
              ),
            ),
            Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 26, 24, 26),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primary.withValues(alpha: 0.12),
                                  const Color(0xFF2DD4BF)
                                      .withValues(alpha: 0.12),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.login_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Welcome back',
                                  style: TextStyle(
                                    fontSize: 23,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.4,
                                    color: AppColors.gray900,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Use your ADA username & password',
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.3,
                                    color: AppColors.gray600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 26),
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
                      const SizedBox(height: 24),
                      _buildSignInButton(),
                    ],
                  ),
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
              child: Icon(icon,
                  size: 20, color: AppColors.primary.withValues(alpha: 0.65)),
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  const BorderSide(color: AppColors.secondary, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
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
      crossAxisAlignment: CrossAxisAlignment.center,
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
        const SizedBox(width: 6),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _rememberMe = !_rememberMe),
            child: Text(
              'Remember me',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.gray600,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ForgotPasswordScreen()),
                ),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Text(
                    'Forgot password?',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: _isSubmitting
            ? null
            : const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF0F766E),
                  AppColors.primary,
                  Color(0xFF256C84),
                ],
                stops: [0.0, 0.48, 1.0],
              ),
        color: _isSubmitting ? AppColors.gray300 : null,
        boxShadow: _isSubmitting
            ? null
            : [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.45),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                  spreadRadius: -2,
                ),
                BoxShadow(
                  color: const Color(0xFF2DD4BF).withValues(alpha: 0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isSubmitting ? null : _submit,
          borderRadius: BorderRadius.circular(16),
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
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward_rounded,
                          size: 22, color: Colors.white),
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
          height: 1.55,
          fontWeight: FontWeight.w500,
          color: Colors.white.withValues(alpha: 0.72),
          letterSpacing: 0.15,
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
      unawaited(
          NotificationController.instance.initialize().catchError((_) {}));

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
