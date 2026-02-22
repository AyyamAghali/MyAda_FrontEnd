import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/responsive.dart';
import '../widgets/responsive_container.dart';
import '../widgets/id_card.dart';
import 'lost_found/home_screen.dart';
import 'clubs/clubs_home.dart';
import 'support/support_module.dart';
import 'account_page.dart';

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
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 12 : 16,
      ),
      color: AppColors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            'assets/images/ada_logo.png',
            height: logoSize,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.school, size: logoSize, color: AppColors.primary);
            },
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.settings, color: AppColors.primary, size: iconSize),
                onPressed: () {
                  _showSnackBar(context, 'Settings are mocked in this prototype.');
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              SizedBox(width: isMobile ? 8 : 16),
              Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications, color: AppColors.secondary, size: iconSize),
                    onPressed: () {
                      _showSnackBar(context, 'Notifications are mocked in this prototype.');
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
            ],
          ),
        ],
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
          Text(
            'More',
            style: TextStyle(
              fontSize: Responsive.isMobile(context) ? 18 : 20,
              fontWeight: FontWeight.w900,
              color: AppColors.gray900,
            ),
          ),
          Container(
            height: 1,
            width: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFA54D66),
            ),
          ),
          const SizedBox(height: 16),
          // First row - 3 buttons
          LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              final buttonSpacing = 16.0;
              final calculatedButtonWidth = (availableWidth - (buttonSpacing * 2)) / 3;
              
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: calculatedButtonWidth,
                    child: _buildMoreButton(
                      context,
                      'attendance check',
                      Icons.assignment_turned_in,
                      calculatedButtonWidth,
                    ),
                  ),
                  SizedBox(width: buttonSpacing),
                  SizedBox(
                    width: calculatedButtonWidth,
                    child: _buildMoreButton(
                      context,
                      'room reservation',
                      Icons.event_seat,
                      calculatedButtonWidth,
                    ),
                  ),
                  SizedBox(width: buttonSpacing),
                  SizedBox(
                    width: calculatedButtonWidth,
                    child: _buildMoreButton(
                      context,
                      'Lost &\nFound',
                      Icons.inventory_2_outlined,
                      calculatedButtonWidth,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          // Second row - 2 buttons
          LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              final buttonSpacing = 16.0;
              final calculatedButtonWidth = (availableWidth - (buttonSpacing * 2)) / 3;
              
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: calculatedButtonWidth,
                    child: _buildMoreButton(
                      context,
                      'Club\nManagement',
                      Icons.groups,
                      calculatedButtonWidth,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ClubsHome()),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: buttonSpacing),
                  SizedBox(
                    width: calculatedButtonWidth,
                    child: _buildMoreButton(
                      context,
                      'IT & FM\nSupport',
                      Icons.build,
                      calculatedButtonWidth,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SupportModule()),
                        );
                      },
                    ),
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
        width: width,
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
    final isMobile = Responsive.isMobile(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: isMobile ? 8 : 12,
          bottom: bottomPadding > 0 ? bottomPadding : (isMobile ? 8 : 12),
          left: 0,
          right: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(context, Icons.home, 'Home', true),
            _buildNavItem(context, Icons.search, 'Search', false),
            _buildNavItem(context, Icons.person, 'Account', false),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, bool isActive) {
    final isMobile = Responsive.isMobile(context);
    final iconSize = isMobile ? 20.0 : 24.0;
    final containerSize = isMobile ? 40.0 : 48.0;
    final fontSize = Responsive.getFontSize(context, 12);
    
    return InkWell(
      onTap: () {
        if (label == 'Account') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AccountPage()),
          );
        } else if (label == 'Search') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Search tab is a visual element only in this prototype.')),
          );
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: containerSize,
            height: containerSize,
            decoration: BoxDecoration(
              color: isActive ? AppColors.secondary : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? AppColors.white : AppColors.white.withOpacity(0.7),
              size: iconSize,
            ),
          ),
          SizedBox(height: isMobile ? 2 : 4),
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              color: isActive ? AppColors.white : AppColors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

}


