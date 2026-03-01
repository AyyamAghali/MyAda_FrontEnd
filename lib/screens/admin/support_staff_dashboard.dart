import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/responsive_container.dart';
import 'staff_job_detail.dart';
import '../login_page.dart';

enum StaffRoleType {
  it,
  fm,
}

class SupportStaffDashboard extends StatefulWidget {
  const SupportStaffDashboard({
    super.key,
    required this.staffName,
    required this.roleType,
  });

  final String staffName;
  final StaffRoleType roleType;

  @override
  State<SupportStaffDashboard> createState() => _SupportStaffDashboardState();
}

class _SupportStaffDashboardState extends State<SupportStaffDashboard> {
  bool _onDuty = true;
  int _historyFilter = 0;
  int _inventoryFilter = 0;

  final List<Map<String, String>> _assignedJobs = [
    {
      'label': 'Emergency',
      'id': 'REQ-8812',
      'time': '12m ago',
      'title': 'Server Room AC Unit Failure',
      'location': 'Main Library, Server Room 204',
      'category': 'Facilities Support',
      'status': 'In Progress',
    },
    {
      'label': 'IT Support',
      'id': 'REQ-8945',
      'time': '45m ago',
      'title': 'Dual-Monitor Setup Required',
      'location': 'Admin Building, Office 12',
      'category': 'IT Support',
      'status': 'Queued',
    },
    {
      'label': 'Facilities',
      'id': 'REQ-9012',
      'time': '1h ago',
      'title': 'Desk Lamp Repair',
      'location': 'East Dorm, Room 410',
      'category': 'Facilities',
      'status': 'Queued',
    },
  ];

  final List<Map<String, String>> _teamFeed = [
    {
      'name': 'Maria G.',
      'message': 'marked REQ-8812 as complete',
      'time': '2m ago',
    },
    {
      'name': 'Kevin T.',
      'message': 'is now on break',
      'time': '15m ago',
    },
  ];

  final List<Map<String, String>> _historyItems = [
    {
      'title': 'Server Room AC Unit Failure',
      'location': 'Main Library, Server Room 204',
      'time': 'Yesterday 4:12 PM',
      'status': 'Completed',
      'rating': '5.0',
    },
    {
      'title': 'Wi-Fi Connectivity Issue',
      'location': 'Student Union, Level 2',
      'time': 'Yesterday 11:30 AM',
      'status': 'Completed',
      'rating': '4.8',
    },
    {
      'title': 'Projector Setup',
      'location': 'Hall B',
      'time': 'Mon 09:15 AM',
      'status': 'Resolved',
      'rating': '4.9',
    },
  ];

  final List<Map<String, String>> _inventoryItems = [
    {
      'name': 'HDMI Adapters',
      'count': '12 in stock',
      'status': 'Available',
    },
    {
      'name': 'Projector Bulbs',
      'count': '3 in stock',
      'status': 'Low',
    },
    {
      'name': 'Ethernet Cables',
      'count': '28 in stock',
      'status': 'Available',
    },
    {
      'name': 'Access Cards',
      'count': '2 in stock',
      'status': 'Low',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.white,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.staffName,
                style: const TextStyle(
                  color: AppColors.gray900,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              Text(
                widget.roleType == StaffRoleType.it ? 'IT Specialist' : 'Facilities Specialist',
                style: const TextStyle(
                  color: AppColors.gray500,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: AppColors.gray600),
              onPressed: () => _showSnackBar('Search is mocked.'),
            ),
            IconButton(
              icon: const Icon(Icons.notifications_none, color: AppColors.gray600),
              onPressed: () => _showSnackBar('Notifications are mocked.'),
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: AppColors.gray600),
              onPressed: () => _logout(),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.gray500,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(icon: Icon(Icons.dashboard_outlined, size: 18), text: 'Dashboard'),
              Tab(icon: Icon(Icons.history, size: 18), text: 'History'),
              Tab(icon: Icon(Icons.inventory_2_outlined, size: 18), text: 'Inventory'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildDashboardTab(),
            _buildHistoryTab(),
            _buildInventoryTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTab() {
    return SafeArea(
      child: ResponsiveContainer(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Availability'),
              const SizedBox(height: 12),
              _buildAvailabilityCard(),
              const SizedBox(height: 16),
              _buildSectionHeader('Weekly Performance'),
              const SizedBox(height: 12),
              _buildPerformanceCards(),
              const SizedBox(height: 16),
              _buildSectionHeader('My Assigned Jobs'),
              const SizedBox(height: 12),
              ..._assignedJobs.map(_buildJobCard),
              const SizedBox(height: 16),
              _buildSectionHeader('Team Feed'),
              const SizedBox(height: 12),
              ..._teamFeed.map(_buildTeamFeedCard),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    return SafeArea(
      child: ResponsiveContainer(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Completed Tasks'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  _buildHistoryChip('All', 0),
                  _buildHistoryChip('This Week', 1),
                  _buildHistoryChip('This Month', 2),
                ],
              ),
              const SizedBox(height: 12),
              ..._historyItems.map(_buildHistoryCard),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInventoryTab() {
    return SafeArea(
      child: ResponsiveContainer(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Inventory Overview'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  _buildInventoryChip('All', 0),
                  _buildInventoryChip('Low Stock', 1),
                  _buildInventoryChip('Available', 2),
                ],
              ),
              const SizedBox(height: 12),
              ..._inventoryItems.map(_buildInventoryCard),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _showSnackBar('Request item (mock).'),
                icon: const Icon(Icons.add),
                label: const Text('Request Item'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                ),
              ),
            ],
          ),
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

  Widget _buildAvailabilityCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Active Duty',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _onDuty ? 'Available for assignments' : 'Off duty',
                  style: const TextStyle(fontSize: 12, color: AppColors.gray600),
                ),
              ],
            ),
          ),
          Switch(
            value: _onDuty,
            onChanged: (value) => setState(() => _onDuty = value),
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceCards() {
    return Column(
      children: [
        _buildPerformanceTile('Tasks Completed', '12/15', '+15%'),
        const SizedBox(height: 10),
        _buildPerformanceTile('Avg. Resolution', '42m', '-5%'),
        const SizedBox(height: 10),
        _buildPerformanceTile('Customer Rating', '4.9 ★', 'Stable'),
      ],
    );
  }

  Widget _buildPerformanceTile(String label, String value, String trend) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: AppColors.gray600),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray900,
                  ),
                ),
              ],
            ),
          ),
          Text(
            trend,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(Map<String, String> job) {
    final status = job['status'] ?? 'Queued';
    final isActive = status.toLowerCase().contains('progress');

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StaffJobDetail(job: job),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildLabelChip(job['label'] ?? 'Task'),
              const SizedBox(width: 8),
              Text(
                job['id'] ?? '',
                style: const TextStyle(fontSize: 12, color: AppColors.gray500),
              ),
              const Spacer(),
              Text(
                job['time'] ?? '',
                style: const TextStyle(fontSize: 11, color: AppColors.gray400),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            job['title'] ?? '',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            job['location'] ?? '',
            style: const TextStyle(fontSize: 12, color: AppColors.gray600),
          ),
          const SizedBox(height: 6),
          Text(
            job['category'] ?? '',
            style: const TextStyle(fontSize: 11, color: AppColors.gray500),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildStatusChip(status),
              const Spacer(),
              ElevatedButton(
                onPressed: () => _showSnackBar(isActive ? 'Complete (mock).' : 'Start (mock).'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                ),
                child: Text(isActive ? 'Complete' : 'Mark as Started'),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildTeamFeedCard(Map<String, String> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: const Icon(Icons.person, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['message'] ?? '',
                  style: const TextStyle(fontSize: 12, color: AppColors.gray600),
                ),
              ],
            ),
          ),
          Text(
            item['time'] ?? '',
            style: const TextStyle(fontSize: 11, color: AppColors.gray400),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryChip(String label, int index) {
    final isActive = _historyFilter == index;
    return ChoiceChip(
      label: Text(label),
      selected: isActive,
      onSelected: (_) => setState(() => _historyFilter = index),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.gray100,
      labelStyle: TextStyle(
        color: isActive ? AppColors.white : AppColors.gray700,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildInventoryChip(String label, int index) {
    final isActive = _inventoryFilter == index;
    return ChoiceChip(
      label: Text(label),
      selected: isActive,
      onSelected: (_) => setState(() => _inventoryFilter = index),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.gray100,
      labelStyle: TextStyle(
        color: isActive ? AppColors.white : AppColors.gray700,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, String> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item['title'] ?? '',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item['location'] ?? '',
            style: const TextStyle(fontSize: 12, color: AppColors.gray600),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildStatusChip(item['status'] ?? 'Completed'),
              const Spacer(),
              Text(
                item['time'] ?? '',
                style: const TextStyle(fontSize: 11, color: AppColors.gray400),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.star, size: 14, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                item['rating'] ?? 'N/A',
                style: const TextStyle(fontSize: 12, color: AppColors.gray700),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _showSnackBar('View details (mock).'),
                child: const Text('View Details'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryCard(Map<String, String> item) {
    final status = item['status'] ?? 'Available';
    Color color;
    if (status.toLowerCase().contains('low')) {
      color = Colors.orange;
    } else {
      color = Colors.green;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['count'] ?? '',
                  style: const TextStyle(fontSize: 12, color: AppColors.gray600),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabelChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final normalized = status.toLowerCase();
    Color color;
    if (normalized.contains('progress')) {
      color = Colors.orange;
    } else if (normalized.contains('complete')) {
      color = Colors.green;
    } else {
      color = AppColors.gray500;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }
}
