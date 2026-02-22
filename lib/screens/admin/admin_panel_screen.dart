import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/responsive.dart';
import '../../widgets/responsive_container.dart';
import '../login_page.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  int _selectedIndex = 0;

  final List<Map<String, String>> _recentActivities = [
    {
      'title': 'User status updated',
      'subtitle': 'rahim.saad@ada.edu.az was deactivated',
      'time': '2m ago',
    },
    {
      'title': 'New report submitted',
      'subtitle': 'Lost item report #LF-204',
      'time': '12m ago',
    },
    {
      'title': 'Content approved',
      'subtitle': 'Announcement: Library hours',
      'time': '1h ago',
    },
  ];

  final List<Map<String, dynamic>> _modules = [
    {
      'title': 'Club Management',
      'subtitle': 'Memberships, requests, and events',
      'icon': Icons.groups_outlined,
      'count': '12 requests',
    },
    {
      'title': 'IT & FM Support',
      'subtitle': 'Tickets, incidents, and updates',
      'icon': Icons.support_agent_outlined,
      'count': '8 open tickets',
    },
    {
      'title': 'Lost & Found',
      'subtitle': 'Reported items and claims',
      'icon': Icons.inventory_2_outlined,
      'count': '15 pending',
    },
    {
      'title': 'Room Reservation',
      'subtitle': 'Bookings and approvals queue',
      'icon': Icons.event_seat_outlined,
      'count': '5 pending',
    },
    {
      'title': 'Attendance Check',
      'subtitle': 'Sessions and attendance logs',
      'icon': Icons.assignment_turned_in_outlined,
      'count': '24 sessions',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: _buildBody(context),
      ),
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.white,
      title: const Text(
        'Admin Panel',
        style: TextStyle(
          color: AppColors.gray900,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: AppColors.gray600),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notifications are mocked in this prototype.')),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary.withOpacity(0.12),
            child: const Icon(Icons.person, color: AppColors.primary, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard(context);
      case 1:
        return _buildModulesView(context);
      case 2:
        return _buildActivityView(context);
      case 3:
        return _buildProfileView(context);
      default:
        return _buildDashboard(context);
    }
  }

  Widget _buildDashboard(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final stats = [
      {'label': 'Total Users', 'value': '1,248', 'trend': '+6%'},
      {'label': 'Active Cases', 'value': '42', 'trend': '+3'},
      {'label': 'Pending Reviews', 'value': '18', 'trend': '-2'},
      {'label': 'Daily Logins', 'value': '512', 'trend': '+9%'},
    ];

    return ResponsiveContainer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Overview'),
            const SizedBox(height: 12),
            GridView.builder(
              itemCount: stats.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile ? 2 : 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: isMobile ? 1.6 : 1.8,
              ),
              itemBuilder: (context, index) {
                final stat = stats[index];
                return _buildStatCard(
                  stat['label']!,
                  stat['value']!,
                  stat['trend']!,
                );
              },
            ),
            const SizedBox(height: 20),
            _buildSectionHeader('Modules'),
            const SizedBox(height: 12),
            ..._modules.take(3).map(_buildModuleCard),
            const SizedBox(height: 24),
            _buildSectionHeader('Recent Activity'),
            const SizedBox(height: 12),
            ..._recentActivities.map(_buildActivityTile),
          ],
        ),
      ),
    );
  }

  Widget _buildModulesView(BuildContext context) {
    return ResponsiveContainer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Admin Modules'),
            const SizedBox(height: 8),
            const Text(
              'All microservices are available from mobile.',
              style: TextStyle(fontSize: 13, color: AppColors.gray600),
            ),
            const SizedBox(height: 16),
            ..._modules.map(_buildModuleCard),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityView(BuildContext context) {
    return ResponsiveContainer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('System Activity'),
            const SizedBox(height: 8),
            const Text(
              'Recent updates across all modules.',
              style: TextStyle(fontSize: 13, color: AppColors.gray600),
            ),
            const SizedBox(height: 16),
            ..._recentActivities.map(_buildActivityTile),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileView(BuildContext context) {
    return ResponsiveContainer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Admin Profile'),
            const SizedBox(height: 16),
            _buildProfileCard(),
            const SizedBox(height: 16),
            _buildLogoutCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.gray900,
      ),
    );
  }

  Widget _buildStatCard(String label, String value, String trend) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.gray600,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.gray900,
            ),
          ),
          Text(
            trend,
            style: TextStyle(
              fontSize: 11,
              color: trend.startsWith('-') ? Colors.red : Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(Map<String, dynamic> module) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(module['icon'] as IconData, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  module['title'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  module['subtitle'] as String,
                  style: const TextStyle(fontSize: 12, color: AppColors.gray600),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              module['count'] as String,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.gray700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTile(Map<String, String> activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.update, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title']!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity['subtitle']!,
                  style: const TextStyle(fontSize: 12, color: AppColors.gray600),
                ),
              ],
            ),
          ),
          Text(
            activity['time']!,
            style: const TextStyle(fontSize: 11, color: AppColors.gray500),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: const Icon(Icons.person, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Admin User',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'admin@ada.edu.az',
                  style: TextStyle(fontSize: 12, color: AppColors.gray600),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Admin',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: [
          const Icon(Icons.logout, color: Colors.red, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Log out of admin panel',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.gray900,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text(
              'Log out',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() => _selectedIndex = index);
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.gray400,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.apps_outlined),
          label: 'Modules',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history_toggle_off_outlined),
          label: 'Activity',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}
