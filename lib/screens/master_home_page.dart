import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/call/call_controller.dart';
import '../utils/constants.dart';
import '../utils/responsive.dart';
import '../widgets/id_card.dart';
import 'lost_found/home_screen.dart';
import 'clubs/club_management_hub.dart';
import 'support/support_module.dart';
import 'attendance/qr_scanner_screen.dart';
import 'account_page.dart';
import 'login_page.dart';

class MasterHomePage extends StatelessWidget {
  const MasterHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
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
              ),
            ),
            _buildBottomNavigation(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final logoSize = isMobile ? 36.0 : 48.0;
    final iconSize = isMobile ? 20.0 : 24.0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background,
            AppColors.white,
          ],
          stops: const [0.0, 1.0],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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

  Widget _buildIdCard(BuildContext context) {
    return IdCard(
      name: 'Rəşad',
      surname: 'Mirzəyev',
      status: 'Student',
      idNumber: 'P000011230',
      photoUrl: 'https://i.pravatar.cc/150?img=12',
    );
  }

  Widget _buildMoreSection(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
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
          LayoutBuilder(
            builder: (context, constraints) {
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
                  _buildMoreButton(
                    context,
                    'attendance check',
                    Icons.assignment_turned_in,
                    0,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QrScannerScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMoreButton(
                    context,
                    'Lost &\nFound',
                    Icons.inventory_2_outlined,
                    0,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomeScreen()),
                      );
                    },
                  ),
                  _buildMoreButton(
                    context,
                    'Club\nManagement',
                    Icons.groups,
                    0,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ClubManagementHub()),
                      );
                    },
                  ),
                  _buildMoreButton(
                    context,
                    'IT & FM\nSupport',
                    Icons.build,
                    0,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SupportModule()),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
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
                color: Colors.black.withOpacity(0.05),
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
              color: Colors.black.withOpacity(0.12),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              Expanded(child: _buildNavItem(context, Icons.home, 'Home', true)),
              const SizedBox(width: 10),
              Expanded(
                child: _buildNavItem(context, Icons.person, 'Account', false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, IconData icon, String label, bool isActive) {
    final isMobile = Responsive.isMobile(context);
    final iconSize = isMobile ? 20.0 : 24.0;
    final fontSize = Responsive.getFontSize(context, 12);

    return InkWell(
      onTap: () {
        if (label == 'Account') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AccountPage()),
          );
        }
      },
      borderRadius: BorderRadius.circular(22),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 10 : 14,
          vertical: isMobile ? 10 : 12,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.secondary : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive
                  ? AppColors.white
                  : AppColors.white.withOpacity(0.75),
              size: iconSize,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: isActive
                    ? AppColors.white
                    : AppColors.white.withOpacity(0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
