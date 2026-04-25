import 'package:flutter/material.dart';
import '../rbac/app_home_access.dart';
import '../rbac/club_entrance_scan_access.dart';
import '../services/auth_service.dart';
import '../services/call/call_controller.dart';
import '../utils/constants.dart';
import '../utils/responsive.dart';
import '../widgets/id_card.dart';
import 'lost_found/home_screen.dart';
import 'clubs/club_management_hub.dart';
import 'clubs/entrance_scan_flow.dart';
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
        bottom: false,
        child: Column(
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
            _buildBottomNavigation(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('home-content'),
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.isMobile(context) ? 8 : 24,
        vertical: Responsive.isMobile(context) ? 8 : 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIdCard(context),
          SizedBox(height: Responsive.isMobile(context) ? 16 : 24),
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

  Widget _buildHeader(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final logoSize = isMobile ? 36.0 : 48.0;
    final iconSize = isMobile ? 20.0 : 24.0;

    return Container(
      key: const ValueKey('home-header'),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background,
            AppColors.white,
          ],
          stops: [0.0, 1.0],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 24,
          vertical: isMobile ? 10 : 14,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              'assets/images/ada_logo.png',
              height: logoSize,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.school,
                    size: logoSize, color: AppColors.primary);
              },
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.settings,
                      color: AppColors.primary, size: iconSize),
                  onPressed: () {
                    _showSnackBar(
                        context, 'Settings are mocked in this prototype.');
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                SizedBox(width: isMobile ? 8 : 16),
                Stack(
                  children: [
                    IconButton(
                      icon: Icon(Icons.notifications,
                          color: AppColors.secondary, size: iconSize),
                      onPressed: () {
                        _showSnackBar(context,
                            'Notifications are mocked in this prototype.');
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Positioned(
                      right: 4,
                      top: 4,
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
                SizedBox(width: isMobile ? 8 : 16),
                IconButton(
                  icon: Icon(Icons.logout,
                      color: AppColors.primary, size: iconSize),
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
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountHeader(BuildContext context) {
    return Container(
      key: const ValueKey('account-header'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.white,
              size: 20,
            ),
            onPressed: () => _selectTab(0),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Account',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
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

  Widget _buildMoreSection(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final roles = AuthService.instance.roles;
    final access = AppHomeAccess.fromRoles(roles);
    final auth = AuthService.instance;

    final services = <_HomeAction>[
      if (access.showAttendanceCheck)
        _HomeAction(
          label: 'Attendance\ncheck',
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
          label: 'Ada\nClubs',
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
      if (access.showEventScanner)
        _HomeAction(
          label: 'Event\nScanner',
          icon: Icons.qr_code_scanner,
          onTap: (context) async {
            final allowed =
                await ClubEntranceScanAccess.allowedClubIdsForCurrentUser();
            if (!context.mounted) return;
            await Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (context) => SelectClubForScanScreen(
                  allowedClubIds: allowed,
                ),
              ),
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
                  builder: (context) => const SupportAdminMobileScreen()),
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
        top: isMobile ? 30 : 30,
        left: isMobile ? 16 : 0,
        right: isMobile ? 16 : 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Services',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: 12),
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
              const SizedBox(height: 24),
              const Text(
                'Role tools',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray900,
                ),
              ),
              const SizedBox(height: 12),
              _buildActionGrid(context, roleTools),
            ],
          ],
        ],
      ),
    );
  }

  List<_HomeAction> _adminToolsFor(AppHomeAccess access) {
    final tools = <_HomeAction>[];
    if (access.showClubAdminModule) {
      tools.add(
        _adminAction(
          label: 'Club\nAdmin',
          icon: Icons.admin_panel_settings_outlined,
          module: AdminModule.club,
        ),
      );
    }
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
    if (access.showRoomAdmin) {
      tools.add(
        _adminAction(
          label: 'Room\nAdmin',
          icon: Icons.meeting_room_outlined,
          module: AdminModule.room,
        ),
      );
    }
    if (access.showAttendanceAdmin) {
      tools.add(
        _adminAction(
          label: 'Attendance\nAdmin',
          icon: Icons.fact_check_outlined,
          module: AdminModule.attendance,
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
    final spacing = isMobile ? 14.0 : 16.0;

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
      childAspectRatio: isMobile ? 1.35 : 1.45,
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
    const pinkColor = Color(0xFFA54D66);
    const darkBlueColor = Color(0xFF3A6381);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: width == 0 ? null : width,
        height: 100,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 8 : 12,
            vertical: isMobile ? 8 : 12,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: pinkColor,
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: isMobile ? 40 : 44,
                color: pinkColor,
              ),
              SizedBox(height: isMobile ? 6 : 8),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 12,
                    color: darkBlueColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isMobile = Responsive.isMobile(context);
    final navHeight = isMobile ? 44.0 : 50.0;
    const itemGap = 10.0;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 10,
        bottom: (bottomPadding > 0 ? bottomPadding : 10) + 6,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - itemGap) / 2;

              return SizedBox(
                height: navHeight,
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutCubic,
                      left: _selectedIndex == 0 ? 0 : itemWidth + itemGap,
                      top: 0,
                      bottom: 0,
                      width: itemWidth,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: itemWidth,
                          child: _buildNavItem(
                            context,
                            Icons.home,
                            'Home',
                            0,
                          ),
                        ),
                        const SizedBox(width: itemGap),
                        SizedBox(
                          width: itemWidth,
                          child: _buildNavItem(
                            context,
                            Icons.person,
                            'Account',
                            1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, IconData icon, String label, int index) {
    final isMobile = Responsive.isMobile(context);
    final iconSize = isMobile ? 20.0 : 24.0;
    final fontSize = Responsive.getFontSize(context, 12);
    final isActive = _selectedIndex == index;

    return InkWell(
      onTap: () => _selectTab(index),
      borderRadius: BorderRadius.circular(22),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 180),
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: isActive
              ? AppColors.white
              : AppColors.white.withValues(alpha: 0.75),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 10 : 14,
            vertical: isMobile ? 10 : 12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  icon,
                  key: ValueKey('$label-$isActive'),
                  color: isActive
                      ? AppColors.white
                      : AppColors.white.withValues(alpha: 0.75),
                  size: iconSize,
                ),
              ),
              const SizedBox(width: 8),
              Text(label),
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
