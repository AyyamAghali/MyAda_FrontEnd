import 'package:flutter/material.dart';

import '../models/user_role.dart';
import '../services/auth_service.dart';
import '../services/call/call_controller.dart';
import '../services/notification_controller.dart';
import '../utils/constants.dart';
import '../utils/responsive.dart';
import 'auth/change_password_screen.dart';
import 'login_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key, this.embedded = false});

  /// When true (e.g. home tab), only the scrollable body is built — no [Scaffold] / app bar.
  final bool embedded;

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late Future<AuthUserProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<AuthUserProfile> _loadProfile() async {
    final auth = AuthService.instance;
    await auth.loadSession();
    final id = auth.studentId?.trim();
    if (id == null || id.isEmpty) {
      throw Exception('Missing user id. Please sign in again.');
    }
    return auth.fetchUserById(id);
  }

  void _reload() {
    setState(() {
      _profileFuture = _loadProfile();
    });
  }

  /// Personal Information "Status": student → Student, instructor → Instructor, else Staff.
  String _statusLine(AuthUserProfile profile) {
    final roles = profile.roles;
    if (roles.contains(UserRole.student)) return 'Student';
    if (roles.contains(UserRole.instructor)) return 'Instructor';
    if (roles.isNotEmpty) return 'Staff';

    final t = profile.userType?.toLowerCase() ?? '';
    if (t.contains('student')) return 'Student';
    if (t.contains('instructor')) return 'Instructor';
    return 'Staff';
  }

  String _badgeLabel(AuthUserProfile profile) {
    if (profile.roles.isNotEmpty) return profile.displayRoleLabel;
    final t = profile.userType?.trim();
    if (t != null && t.isNotEmpty) return t;
    return UserRole.student.label;
  }

  String _organizationalIdDisplay(AuthUserProfile profile) {
    final v = profile.organizationalId?.trim();
    if (v != null && v.isNotEmpty) return v;
    return 'Not assigned';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      return _buildBody(context);
    }
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _buildBody(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return FutureBuilder<AuthUserProfile>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasError) {
          return _buildErrorState(context, snapshot.error);
        }
        final profile = snapshot.data!;
        return RefreshIndicator(
          onRefresh: () async {
            _reload();
            await _profileFuture;
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: 80,
            ),
            child: Column(
              children: [
                _buildProfileSection(profile),
                const SizedBox(height: 20),
                _buildPersonalInfoSection(profile),
                const SizedBox(height: 16),
                _buildSettingsSection(context, profile),
                const SizedBox(height: 16),
                _buildSupportSection(context),
                const SizedBox(height: 16),
                _buildLogoutButton(context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context, Object? error) {
    final message = error is Exception
        ? error.toString().replaceFirst('Exception: ', '')
        : error?.toString() ?? 'Something went wrong.';
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.gray400),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.gray700,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _reload,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          isMobile ? 20 : 28,
          isMobile ? 14 : 18,
          isMobile ? 20 : 28,
          isMobile ? 14 : 18,
        ),
        child: SizedBox(
          width: double.infinity,
          child: Text(
            'Account',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 22 : 26,
              fontWeight: FontWeight.w800,
              color: AppColors.gray900,
              letterSpacing: -0.6,
              height: 1.1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection(AuthUserProfile profile) {
    final fullName =
        '${profile.displayFirstName} ${profile.displayLastName}'.trim();
    final email = profile.email?.trim() ?? '';
    final photo = profile.profileImage?.trim();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.gray200, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: photo != null && photo.isNotEmpty
                  ? Image.network(
                      photo,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildPlaceholderAvatar(),
                    )
                  : _buildPlaceholderAvatar(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName.isEmpty ? 'ADA User' : fullName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
                    letterSpacing: -0.3,
                  ),
                ),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.gray600,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _badgeLabel(profile),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderAvatar() {
    return Container(
      color: AppColors.gray200,
      child: const Center(
        child: Icon(
          Icons.person,
          size: 35,
          color: AppColors.gray400,
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection(AuthUserProfile profile) {
    final email = profile.email?.trim() ?? '';
    return _buildSection(
      title: 'Personal Information',
      children: [
        _buildInfoRow(
          icon: Icons.badge_outlined,
          label: 'ID',
          value: _organizationalIdDisplay(profile),
        ),
        const Divider(height: 1, thickness: 1),
        _buildInfoRow(
          icon: Icons.email_outlined,
          label: 'Email',
          value: email.isNotEmpty ? email : '—',
        ),
        const Divider(height: 1, thickness: 1),
        _buildInfoRow(
          icon: Icons.school_outlined,
          label: 'Status',
          value: _statusLine(profile),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    AuthUserProfile profile,
  ) {
    return _buildSection(
      title: 'Settings',
      children: [
        _buildSettingTile(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          subtitle: 'Manage notification preferences',
          onTap: () {
            _showSnackBar(context, 'Notifications settings are mocked.');
          },
        ),
        const Divider(height: 1, thickness: 1),
        _buildSettingTile(
          icon: Icons.lock_reset_rounded,
          title: 'Password',
          subtitle: 'Change password or reset by email',
          onTap: () {
            Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (_) {
                  final name =
                      '${profile.displayFirstName} ${profile.displayLastName}'
                          .trim();
                  return ChangePasswordScreen(
                    email: profile.email?.trim() ?? '',
                    accountLabel: name.isEmpty ? null : name,
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return _buildSection(
      title: 'Help & Support',
      children: [
        _buildSettingTile(
          icon: Icons.info_outline,
          title: 'About',
          subtitle: 'App version and info',
          onTap: () {
            showAboutDialog(
              context: context,
              applicationName: 'ADA University',
              applicationVersion: '1.0.0 (mock)',
              applicationLegalese: 'Prototype build',
            );
          },
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.gray900,
                letterSpacing: -0.2,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.gray500),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.gray500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.gray900,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.gray600,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.gray400, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          _showLogoutDialog(context);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.logout, size: 20, color: Colors.red),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Log Out',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Log Out',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            'Are you sure you want to log out?',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.gray600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.gray600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await NotificationController.instance.disconnect();
                await CallController.instance.disconnect();
                await AuthService.instance.clearSession();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              },
              child: const Text(
                'Log Out',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
