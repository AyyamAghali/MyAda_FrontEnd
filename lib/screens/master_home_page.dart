import 'package:flutter/material.dart';
import '../rbac/app_home_access.dart';
import '../services/auth_service.dart';
import '../services/call/call_controller.dart';
import '../utils/constants.dart';
import '../utils/responsive.dart';
import '../widgets/id_card.dart';
import 'lost_found/home_screen.dart';
import 'clubs/club_management_hub.dart';
import 'support/support_module.dart';
import 'attendance/attendance_home.dart';
import 'account_page.dart';
import 'admin/module_admin_screen.dart';
import 'admin/support_staff_dashboard.dart';
import 'login_page.dart';

class MasterHomePage extends StatefulWidget {
  const MasterHomePage({super.key});

  @override
  State<MasterHomePage> createState() => _MasterHomePageState();
}

class _MasterHomePageState extends State<MasterHomePage> {
  int _selectedIndex = 0;
  late final Future<AuthUserProfile?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadSignedInProfile();
  }

  Future<AuthUserProfile?> _loadSignedInProfile() async {
    final auth = AuthService.instance;
    await auth.loadSession();
    final userId = auth.studentId;
    if (userId == null || userId.trim().isEmpty) return null;
    return auth.fetchUserById(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _selectedIndex == 0
          ? AppColors.background
          : AppColors.backgroundLight,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _selectedIndex == 0
                      ? _buildHeader(context)
                      : _buildAccountHeader(context),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: _selectedIndex == 0
                        ? _buildHomeContent(context)
                        : _buildAccountContent(context),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomNavigation(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    return SingleChildScrollView(
      key: const ValueKey('home-content'),
      padding: EdgeInsets.only(
        left: isMobile ? 8 : 24,
        right: isMobile ? 8 : 24,
        top: isMobile ? 8 : 16,
        bottom: 80,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIdCard(context),
          SizedBox(height: isMobile ? 16 : 24),
          _buildMoreSection(context),
        ],
      ),
    );
  }

  Widget _buildAccountContent(BuildContext context) {
    return KeyedSubtree(
      key: const ValueKey('account-content'),
      child: const AccountPage(embedded: true),
    );
  }

  String _homeGreetingName(AuthUserProfile? profile) {
    if (profile != null) {
      final fn = profile.firstName?.trim();
      final ln = profile.lastName?.trim();
      if (fn != null &&
          fn.isNotEmpty &&
          ln != null &&
          ln.isNotEmpty) {
        return '$fn $ln';
      }
      if (fn != null && fn.isNotEmpty) return fn;
      if (ln != null && ln.isNotEmpty) return ln;
      final un = profile.userName.trim();
      if (un.isNotEmpty) {
        return un
            .split(RegExp(r'\s+'))
            .where((p) => p.isNotEmpty)
            .map(_titleCaseToken)
            .join(' ');
      }
    }
    final u = AuthService.instance.username?.trim();
    if (u != null && u.isNotEmpty) {
      return u
          .split(RegExp(r'\s+'))
          .where((p) => p.isNotEmpty)
          .map(_titleCaseToken)
          .join(' ');
    }
    return 'Student';
  }

  String _titleCaseToken(String raw) {
    if (raw.isEmpty) return raw;
    final lower = raw.toLowerCase();
    return lower[0].toUpperCase() + (lower.length > 1 ? lower.substring(1) : '');
  }

  Widget _buildHeader(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final iconSize = isMobile ? 20.0 : 22.0;
    final topInset = MediaQuery.of(context).padding.top;

    return FutureBuilder<AuthUserProfile?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        final displayLine = _homeGreetingName(snapshot.data);

        return Container(
          key: const ValueKey('home-header'),
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
            padding: EdgeInsets.only(
              left: isMobile ? 20 : 28,
              right: isMobile ? 20 : 28,
              top: topInset + (isMobile ? 12 : 14),
              bottom: isMobile ? 14 : 18,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Welcome back',
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.gray500,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        displayLine,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isMobile ? 22 : 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.gray900,
                          letterSpacing: -0.6,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Material(
                      color: AppColors.gray100,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: IconButton(
                        icon: Icon(Icons.notifications_none_rounded,
                            color: AppColors.gray700, size: iconSize - 2),
                        onPressed: () {
                          _showSnackBar(context,
                              'Notifications are mocked in this prototype.');
                        },
                        padding: const EdgeInsets.all(10),
                        constraints: const BoxConstraints(),
                      ),
                    ),
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: isMobile ? 8 : 10),
                Material(
                  color: AppColors.gray100,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: IconButton(
                    icon: Icon(Icons.logout_rounded,
                        color: AppColors.primary, size: iconSize - 2),
                    onPressed: () async {
                      await CallController.instance.disconnect();
                      await AuthService.instance.clearSession();
                      if (!context.mounted) return;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                        (route) => false,
                      );
                    },
                    padding: const EdgeInsets.all(10),
                    constraints: const BoxConstraints(),
                  ),
                ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccountHeader(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final topInset = MediaQuery.of(context).padding.top;

    return Container(
      key: const ValueKey('account-header'),
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
        padding: EdgeInsets.only(
          left: isMobile ? 20 : 28,
          right: isMobile ? 20 : 28,
          top: topInset + (isMobile ? 12 : 14),
          bottom: isMobile ? 14 : 18,
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

  Widget _buildIdCard(BuildContext context) {
    final auth = AuthService.instance;
    return FutureBuilder<AuthUserProfile?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        final profile = snapshot.data;
        final fallbackName = auth.username?.trim();
        final organizationalId = profile?.organizationalId?.trim();

        return Stack(
          children: [
            IdCard(
              name: profile?.displayFirstName ??
                  (fallbackName == null || fallbackName.isEmpty
                      ? 'ADA'
                      : fallbackName),
              surname: profile?.displayLastName ?? 'User',
              status: profile?.displayRoleLabel ?? auth.roleLabel,
              idNumber: organizationalId == null || organizationalId.isEmpty
                  ? 'Not assigned'
                  : organizationalId,
              photoUrl: profile?.profileImage,
            ),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Positioned(
                right: 16,
                bottom: 16,
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeading(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) {
    final isMobile = Responsive.isMobile(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 3,
          height: isMobile ? 32 : 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.primary, AppColors.secondary],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subtitle.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: isMobile ? 1.35 : 1.55,
                  color: AppColors.gray400,
                  height: 1.0,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: isMobile ? 20 : 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.gray900,
                  letterSpacing: -0.5,
                  height: 1.05,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMoreSection(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final roles = AuthService.instance.roles;
    final access = AppHomeAccess.fromRoles(roles);
    final auth = AuthService.instance;

    final services = <_HomeAction>[
      if (access.showAttendanceCheck)
        _HomeAction(
          label: 'Attendance\nCheck',
          icon: Icons.assignment_turned_in,
          onTap: (context) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AttendanceHome()),
            );
          },
        ),
      if (access.showLostFound)
        _HomeAction(
          label: 'Lost &\nFound',
          icon: Icons.inventory_2_outlined,
          onTap: (context) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
        ),
      if (access.showAdaClubs)
        _HomeAction(
          label: 'ADA\nClubs',
          icon: Icons.groups,
          onTap: (context) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ClubManagementHub()),
            );
          },
        ),
      if (access.showSupportCenter)
        _HomeAction(
          label: 'IT & FM\nSupport',
          icon: Icons.build,
          onTap: (context) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SupportModule()),
            );
          },
        ),
      if (access.showSupportDispatcherConsole)
        _HomeAction(
          label: 'Support\nDispatcher',
          icon: Icons.headset_mic_outlined,
          onTap: (context) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const SupportAdminScreen()),
            );
          },
        ),
      if (access.showStaffPortal)
        _HomeAction(
          label: 'Staff\nPortal',
          icon: Icons.badge_outlined,
          onTap: (context) {
            final name = auth.username?.trim();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SupportStaffDashboard(
                  staffName:
                      (name != null && name.isNotEmpty) ? name : 'Staff',
                  roleType: AppHomeAccess.staffRoleTypeFor(roles),
                ),
              ),
            );
          },
        ),
    ];
    final roleTools = _adminToolsFor(access);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        top: isMobile ? 20 : 24,
        left: isMobile ? 4 : 0,
        right: isMobile ? 4 : 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeading(
            context,
            title: 'Services',
            subtitle: 'Campus tools',
          ),
          const SizedBox(height: 10),
          if (services.isEmpty && roleTools.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'No services are assigned to your roles yet.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.gray600,
                  height: 1.35,
                ),
              ),
            )
          else ...[
            _buildActionGrid(context, services),
            if (roleTools.isNotEmpty) ...[
              const SizedBox(height: 22),
              _buildSectionHeading(
                context,
                title: 'Role tools',
                subtitle: 'Administration',
              ),
              const SizedBox(height: 10),
              _buildActionGrid(context, roleTools),
            ],
          ],
        ],
      ),
    );
  }

  List<_HomeAction> _adminToolsFor(AppHomeAccess access) {
    final tools = <_HomeAction>[];
    if (access.showSupportAdminModule) {
      tools.add(
        _adminAction(
          label: 'Support\nAdmin',
          icon: Icons.support_agent_outlined,
          module: AdminModule.support,
        ),
      );
    }
    if (access.showLostFoundAdmin) {
      tools.add(
        _adminAction(
          label: 'Lost & Found\nAdmin',
          icon: Icons.manage_search_outlined,
          module: AdminModule.lostFound,
        ),
      );
    }
    return tools;
  }

  _HomeAction _adminAction({
    required String label,
    required IconData icon,
    required AdminModule module,
  }) {
    return _HomeAction(
      label: label,
      icon: icon,
      onTap: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ModuleAdminScreen(module: module)),
        );
      },
    );
  }

  Widget _buildActionGrid(BuildContext context, List<_HomeAction> actions) {
    final isMobile = Responsive.isMobile(context);
    final crossAxisCount = isMobile ? 2 : 4;
    final spacing = isMobile ? 12.0 : 16.0;

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
      childAspectRatio: isMobile ? 1.05 : 1.12,
      children: [
        for (final action in actions)
          _buildMoreButton(
            context,
            action.label,
            action.icon,
            0,
            onTap: () => action.onTap(context),
          ),
      ],
    );
  }

  Widget _buildMoreButton(
    BuildContext context,
    String label,
    IconData icon,
    double width, {
    VoidCallback? onTap,
  }) {
    final isMobile = Responsive.isMobile(context);
    final iconBg = AppColors.primary.withValues(alpha: 0.09);
    final iconColor = AppColors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          width: width == 0 ? null : width,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.gray200,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 10 : 14,
              vertical: isMobile ? 16 : 18,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(isMobile ? 12 : 14),
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: isMobile ? 26 : 28,
                    color: iconColor,
                  ),
                ),
                SizedBox(height: isMobile ? 12 : 14),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
                    height: 1.2,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static const Color _navPillTeal1 = Color(0xFF356F88);
  static const Color _navPillTeal2 = Color(0xFF1E3D4D);
  static const Color _navHighlight1 = Color(0xFFFF6B83);
  static const Color _navHighlight2 = Color(0xFFC73E5C);
  static const Color _navOnHighlight = Color(0xFFFFFFFF);
  static const Color _navOnTrack = Color(0xFFB8C9D4);

  Widget _buildBottomNavigation(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isMobile = Responsive.isMobile(context);
    final barHeight = isMobile ? 48.0 : 52.0;
    final bottomGap = bottomPadding > 0 ? bottomPadding - 4 : 4.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottomGap.clamp(4.0, 24.0)),
      child: Container(
        width: double.infinity,
        height: barHeight,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_navPillTeal1, _navPillTeal2],
          ),
          borderRadius: BorderRadius.circular(barHeight / 2),
          boxShadow: [
            BoxShadow(
              color: _navPillTeal2.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(4),
        child: SizedBox(
          height: barHeight - 8,
        child: LayoutBuilder(
          builder: (context, constraints) {
            const gap = 8.0;
            final segmentW = (constraints.maxWidth - gap) / 2;
            final innerRadius = (barHeight - 8) / 2;
            return Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  left: _selectedIndex == 0 ? 0 : segmentW + gap,
                  top: 0,
                  bottom: 0,
                  width: segmentW,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(innerRadius),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_navHighlight1, _navHighlight2],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _navHighlight2.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    SizedBox(
                      width: segmentW,
                      child: _buildNavItem(
                        context,
                        Icons.home_rounded,
                        'Home',
                        0,
                        isMobile,
                      ),
                    ),
                    const SizedBox(width: gap),
                    SizedBox(
                      width: segmentW,
                      child: _buildNavItem(
                        context,
                        Icons.person_rounded,
                        'Account',
                        1,
                        isMobile,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
    bool isMobile,
  ) {
    final isActive = _selectedIndex == index;
    final iconSize = isMobile ? 18.0 : 20.0;
    final fontSize = isMobile ? 12.0 : 13.0;
    final color = isActive ? _navOnHighlight : _navOnTrack;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _selectTab(index),
        splashColor: Colors.white.withValues(alpha: 0.12),
        highlightColor: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: iconSize, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                  letterSpacing: -0.15,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectTab(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _HomeAction {
  final String label;
  final IconData icon;
  final void Function(BuildContext context) onTap;

  const _HomeAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });
}
