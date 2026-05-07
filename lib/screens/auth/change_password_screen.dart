import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import 'forgot_password_screen.dart';

/// Logged-in password change using [AuthService.changePassword]
/// (`PUT /api/auth/change-password`). If no email is on the profile, offers
/// [ForgotPasswordScreen] (`forgot-password` / `reset-password`) instead.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({
    super.key,
    required this.email,
    this.accountLabel,
  });

  /// Account email from profile; may be empty for legacy accounts.
  final String email;
  final String? accountLabel;

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _submitting = false;

  bool get _hasEmail => widget.email.isNotEmpty;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _validateNewPassword(String? v) {
    if (v == null || v.isEmpty) return 'Enter a new password';
    if (v.length < 8) return 'At least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(v)) {
      return 'Include at least one uppercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(v)) {
      return 'Include at least one number';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_hasEmail) return;
    if (!_formKey.currentState!.validate() || _submitting) return;
    setState(() => _submitting = true);
    try {
      await AuthService.instance.changePassword(
        email: widget.email.trim(),
        oldPassword: _currentController.text,
        newPassword: _newController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Password updated successfully.'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.secondary,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _openEmailReset() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const ForgotPasswordScreen(),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String label,
    String? hint,
    VoidCallback? onSuffix,
    bool obscure = false,
    IconData suffixIcon = Icons.visibility_outlined,
    IconData suffixIconOff = Icons.visibility_off_outlined,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: onSuffix == null
          ? null
          : IconButton(
              icon: Icon(
                obscure ? suffixIcon : suffixIconOff,
                color: AppColors.gray400,
                size: 20,
              ),
              onPressed: onSuffix,
            ),
      filled: true,
      fillColor: AppColors.gray50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.gray200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.gray200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.secondary.withValues(alpha: 0.85)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      labelStyle: const TextStyle(fontSize: 14, color: AppColors.gray600),
    );
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.accountLabel?.trim();
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.gray900,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Password',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.gray900,
              ),
            ),
            if (label != null && label.isNotEmpty)
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray500,
                ),
              ),
          ],
        ),
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue.shade50.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.shade200.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _hasEmail
                          ? 'Use your current password to set a new one. '
                              'This calls the same auth service as sign-in.'
                          : 'No email is stored on this profile. Use email-based reset to choose a new password.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (!_hasEmail) ...[
              FilledButton.icon(
                onPressed: _openEmailReset,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.mark_email_unread_outlined, size: 20),
                label: const Text(
                  'Reset password by email',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
            ] else ...[
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.gray200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(18),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Signed-in as',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      SelectableText(
                        widget.email.trim(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _currentController,
                        obscureText: _obscureCurrent,
                        decoration: _fieldDecoration(
                          label: 'Current password',
                          hint: 'Your existing password',
                          obscure: _obscureCurrent,
                          onSuffix: () => setState(
                              () => _obscureCurrent = !_obscureCurrent),
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Enter your current password'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _newController,
                        obscureText: _obscureNew,
                        decoration: _fieldDecoration(
                          label: 'New password',
                          hint: '8+ chars, 1 uppercase, 1 number',
                          obscure: _obscureNew,
                          onSuffix: () =>
                              setState(() => _obscureNew = !_obscureNew),
                        ),
                        textInputAction: TextInputAction.next,
                        validator: _validateNewPassword,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _confirmController,
                        obscureText: _obscureConfirm,
                        decoration: _fieldDecoration(
                          label: 'Confirm new password',
                          obscure: _obscureConfirm,
                          onSuffix: () => setState(
                              () => _obscureConfirm = !_obscureConfirm),
                        ),
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Confirm your new password';
                          }
                          if (v != _newController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 22),
                      FilledButton(
                        onPressed: _submitting ? null : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          disabledBackgroundColor: AppColors.gray300,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _submitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.white,
                                ),
                              )
                            : const Text(
                                'Update password',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (_hasEmail) ...[
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: _openEmailReset,
                icon: const Icon(Icons.mail_outline_rounded, size: 20),
                label: const Text(
                  'Forgot password? Reset using email',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
