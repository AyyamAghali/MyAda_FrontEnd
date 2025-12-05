import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/constants.dart';
import '../utils/responsive.dart';
import '../widgets/responsive_container.dart';
import '../widgets/id_card.dart';
import 'lost_found/home_screen.dart';
import 'clubs/clubs_home.dart';
import 'support/support_module.dart';

class MasterHomePage extends StatelessWidget {
  const MasterHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveContainer(
          backgroundColor: AppColors.background,
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: Responsive.getPadding(context),
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
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final logoSize = isMobile ? 36.0 : 48.0;
    final iconSize = isMobile ? 20.0 : 24.0;
    final padding = Responsive.getPadding(context);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: padding.horizontal,
        vertical: isMobile ? 12 : 16,
      ),
      color: AppColors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.network(
            'https://www.ada.edu.az/uploads/images/logo.png',
            height: logoSize,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.school, size: logoSize, color: AppColors.primary);
            },
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.settings, color: AppColors.primary, size: iconSize),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              SizedBox(width: isMobile ? 8 : 16),
              IconButton(
                icon: Icon(Icons.mail, color: AppColors.secondary, size: iconSize),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIdCard(BuildContext context) {
    return IdCard(
      name: 'Fidan',
      surname: 'Mardanli',
      status: 'Teacher',
      className: 'A120',
      dateOfIssue: '20.07.2020',
      validityDate: '01.06.2025',
      idNumber: 'P000011230',
      photoUrl: 'https://i.pravatar.cc/150?img=12',
    );
  }

  Widget _buildMoreSection(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final crossAxisCount = isMobile ? 2 : 3;
    final spacing = isMobile ? 8.0 : 12.0;
    final fontSize = Responsive.getFontSize(context, 18);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'More',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.gray900,
          ),
        ),
        SizedBox(height: isMobile ? 12 : 16),
        GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: isMobile ? 0.9 : 0.85,
          children: [
            _buildDisabledButton(context, 'Student\nattendance check', Icons.calendar_today),
            _buildDisabledButton(context, 'Room\nreservation', Icons.meeting_room),
            _buildDisabledButton(context, 'My room', Icons.home),
            _buildActiveButton(
              context,
              'Lost &\nFound',
              Icons.inventory_2,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
            ),
            _buildActiveButton(
              context,
              'Club\nManagement',
              Icons.groups,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ClubsHome()),
                );
              },
            ),
            _buildActiveButton(
              context,
              'IT &\nSupport',
              Icons.build,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SupportModule()),
                );
              },
            ),
            _buildDisabledButton(context, '', Icons.add),
          ],
        ),
      ],
    );
  }

  Widget _buildDisabledButton(BuildContext context, String label, IconData icon) {
    final isMobile = Responsive.isMobile(context);
    final iconSize = isMobile ? 32.0 : 40.0;
    final fontSize = Responsive.getFontSize(context, 12);
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
      ),
      child: Opacity(
        opacity: 0.5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: iconSize, color: AppColors.secondary),
            if (label.isNotEmpty) ...[
              SizedBox(height: isMobile ? 6 : 8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 4 : 8),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: fontSize,
                    color: AppColors.secondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActiveButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    final isMobile = Responsive.isMobile(context);
    final iconSize = isMobile ? 32.0 : 40.0;
    final fontSize = Responsive.getFontSize(context, 12);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primary, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: iconSize, color: AppColors.primary),
            SizedBox(height: isMobile ? 6 : 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 4 : 8),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    
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
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: isMobile ? 8 : 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, Icons.home, 'Home', true),
              _buildNavItem(context, Icons.search, 'Search', false),
              _buildNavItem(context, Icons.person, 'Account', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, bool isActive) {
    final isMobile = Responsive.isMobile(context);
    final iconSize = isMobile ? 20.0 : 24.0;
    final containerSize = isMobile ? 40.0 : 48.0;
    final fontSize = Responsive.getFontSize(context, 12);
    
    return Column(
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
    );
  }
}

