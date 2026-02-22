import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/responsive.dart';
import '../../widgets/responsive_container.dart';
import '../login_page.dart';

enum AdminModule {
  club,
  support,
  lostFound,
  room,
  attendance,
}

class ModuleAdminScreen extends StatelessWidget {
  const ModuleAdminScreen({super.key, required this.module});

  final AdminModule module;

  static AdminModule? resolveModule(String email) {
    final value = email.toLowerCase();
    if (value.contains('club')) {
      return AdminModule.club;
    }
    if (value.contains('support') || value.contains('it') || value.contains('fm')) {
      return AdminModule.support;
    }
    if (value.contains('lost') || value.contains('found')) {
      return AdminModule.lostFound;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (module == AdminModule.club) {
      return const ClubAdminMobileScreen();
    }
    if (module == AdminModule.support) {
      return const SupportAdminMobileScreen();
    }

    final config = _moduleConfig(module);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              config.title,
              style: const TextStyle(
                color: AppColors.gray900,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            Text(
              config.subtitle,
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
              child: Icon(config.icon, color: AppColors.primary, size: 18),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Overview'),
                const SizedBox(height: 12),
                _buildStatsGrid(context, config.stats),
                const SizedBox(height: 20),
                _buildSectionHeader('Action Center'),
                const SizedBox(height: 12),
                _buildActionGrid(context, config.actions),
                const SizedBox(height: 20),
                _buildSectionHeader('Status Breakdown'),
                const SizedBox(height: 12),
                _buildMetricList(config.metrics),
                const SizedBox(height: 20),
                _buildSectionHeader('Queue'),
                const SizedBox(height: 12),
                ...config.queue.map((item) => _buildQueueCard(context, item)),
                const SizedBox(height: 24),
                _buildSectionHeader('Recent Activity'),
                const SizedBox(height: 12),
                ...config.activity.map((item) => _buildActivityTile(context, item)),
                const SizedBox(height: 24),
                _buildLogoutCard(context),
              ],
            ),
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

  Widget _buildStatsGrid(BuildContext context, List<_Stat> stats) {
    final isMobile = Responsive.isMobile(context);
    return GridView.builder(
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
        return _buildStatCard(stat.label, stat.value, stat.trend);
      },
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

  Widget _buildQueueCard(BuildContext context, _QueueItem item) {
    return InkWell(
      onTap: () {
        _showSnackBar(context, 'Opened: ${item.title} (mock)');
      },
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.subtitle,
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
                    item.tag,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.gray700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (item.primaryAction != null || item.secondaryAction != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (item.secondaryAction != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _showSnackBar(context, '${item.secondaryAction} (mock)');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.gray700,
                          side: BorderSide(color: AppColors.gray300),
                        ),
                        child: Text(item.secondaryAction!),
                      ),
                    ),
                  if (item.secondaryAction != null && item.primaryAction != null)
                    const SizedBox(width: 12),
                  if (item.primaryAction != null)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _showSnackBar(context, '${item.primaryAction} (mock)');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                        ),
                        child: Text(item.primaryAction!),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTile(BuildContext context, _ActivityItem item) {
    return InkWell(
      onTap: () {
        _showSnackBar(context, 'Activity: ${item.title} (mock)');
      },
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: Container(
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
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.update, color: AppColors.secondary, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    style: const TextStyle(fontSize: 12, color: AppColors.gray600),
                  ),
                ],
              ),
            ),
            Text(
              item.time,
              style: const TextStyle(fontSize: 11, color: AppColors.gray500),
            ),
          ],
        ),
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
              'Log out',
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
              'Sign out',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context, List<_ActionItem> actions) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: actions.map((action) {
        return ActionChip(
          avatar: Icon(action.icon, size: 18, color: AppColors.primary),
          label: Text(
            action.label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.gray700,
            ),
          ),
          backgroundColor: AppColors.white,
          side: BorderSide(color: AppColors.gray200),
          onPressed: () {
            _showSnackBar(context, '${action.label} (mock)');
          },
        );
      }).toList(),
    );
  }

  Widget _buildMetricList(List<_Metric> metrics) {
    return Column(
      children: metrics.map((metric) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            border: Border.all(color: AppColors.gray200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    metric.label,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.gray700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    metric.valueLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.gray500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: metric.percent,
                  minHeight: 8,
                  backgroundColor: AppColors.gray100,
                  valueColor: AlwaysStoppedAnimation<Color>(metric.color),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  _ModuleConfig _moduleConfig(AdminModule module) {
    switch (module) {
      case AdminModule.club:
        return _ModuleConfig(
          title: 'Club Management',
          subtitle: 'Memberships, requests, and events',
          icon: Icons.groups_outlined,
          stats: const [
            _Stat('Total Clubs', '28', '+1'),
            _Stat('Active Members', '1,140', '+4%'),
            _Stat('Pending Requests', '12', '+2'),
            _Stat('Events', '6', '+1'),
          ],
          actions: const [
            _ActionItem(Icons.group_add_outlined, 'Approve Member'),
            _ActionItem(Icons.event_outlined, 'Create Event'),
            _ActionItem(Icons.visibility_outlined, 'Review Requests'),
            _ActionItem(Icons.edit_outlined, 'Edit Club Info'),
            _ActionItem(Icons.campaign_outlined, 'Post Announcement'),
          ],
          metrics: const [
            _Metric('Membership approvals', '78%', 0.78, Colors.green),
            _Metric('Event readiness', '62%', 0.62, Colors.orange),
            _Metric('New club requests', '34%', 0.34, Colors.blue),
          ],
          queue: const [
            _QueueItem(
              Icons.person_add_alt,
              'Membership request',
              'Data Science Club',
              'New',
              primaryAction: 'Approve',
              secondaryAction: 'Decline',
            ),
            _QueueItem(
              Icons.event,
              'Event proposal',
              'AI Meetup - Hall B',
              'Pending',
              primaryAction: 'Approve',
              secondaryAction: 'Request Changes',
            ),
            _QueueItem(
              Icons.groups,
              'New club request',
              'Robotics Society',
              'Review',
              primaryAction: 'Review',
              secondaryAction: 'Archive',
            ),
          ],
          activity: const [
            _ActivityItem('Member approved', 'Leyla Abbasova joined Robotics', '10m ago'),
            _ActivityItem('Event updated', 'AI Meetup time changed', '1h ago'),
            _ActivityItem('Club suspended', 'Inactive club archived', '3h ago'),
          ],
        );
      case AdminModule.support:
        return _ModuleConfig(
          title: 'IT & FM Support',
          subtitle: 'Tickets, incidents, and updates',
          icon: Icons.support_agent_outlined,
          stats: const [
            _Stat('Open Tickets', '8', '-1'),
            _Stat('In Progress', '5', '+1'),
            _Stat('Resolved Today', '12', '+3'),
            _Stat('Avg. SLA', '3h', '-0.5h'),
          ],
          actions: const [
            _ActionItem(Icons.assignment_ind_outlined, 'Assign Ticket'),
            _ActionItem(Icons.priority_high_outlined, 'Escalate'),
            _ActionItem(Icons.check_circle_outline, 'Resolve Ticket'),
            _ActionItem(Icons.local_activity_outlined, 'Create Incident'),
            _ActionItem(Icons.analytics_outlined, 'SLA Report'),
          ],
          metrics: const [
            _Metric('SLA compliance', '91%', 0.91, Colors.green),
            _Metric('Escalations', '18%', 0.18, Colors.red),
            _Metric('Resolved today', '60%', 0.6, Colors.blue),
          ],
          queue: const [
            _QueueItem(
              Icons.wifi_off,
              'Wi-Fi outage',
              'Dorm C - Floor 2',
              'High',
              primaryAction: 'Assign',
              secondaryAction: 'Escalate',
            ),
            _QueueItem(
              Icons.print,
              'Printer issue',
              'Library - Desk 4',
              'Medium',
              primaryAction: 'Resolve',
              secondaryAction: 'Assign',
            ),
            _QueueItem(
              Icons.lightbulb_outline,
              'Lighting issue',
              'Room A201',
              'Low',
              primaryAction: 'Close',
              secondaryAction: 'Schedule',
            ),
          ],
          activity: const [
            _ActivityItem('Ticket resolved', 'Printer issue closed', '20m ago'),
            _ActivityItem('SLA warning', 'Wi-Fi outage pending', '45m ago'),
            _ActivityItem('Assignment', 'Ticket assigned to FM', '2h ago'),
          ],
        );
      case AdminModule.lostFound:
        return _ModuleConfig(
          title: 'Lost & Found',
          subtitle: 'Reported items and claims',
          icon: Icons.inventory_2_outlined,
          stats: const [
            _Stat('Active Items', '42', '+5'),
            _Stat('Claims', '9', '+1'),
            _Stat('Pending Review', '15', '+2'),
            _Stat('Resolved', '120', '+6'),
          ],
          actions: const [
            _ActionItem(Icons.add_box_outlined, 'Add Item'),
            _ActionItem(Icons.verified_outlined, 'Verify Claim'),
            _ActionItem(Icons.assignment_return_outlined, 'Mark Claimed'),
            _ActionItem(Icons.photo_library_outlined, 'Attach Photos'),
            _ActionItem(Icons.filter_alt_outlined, 'Filter Items'),
          ],
          metrics: const [
            _Metric('Claims verified', '56%', 0.56, Colors.green),
            _Metric('Pending reviews', '36%', 0.36, Colors.orange),
            _Metric('Resolved items', '74%', 0.74, Colors.blue),
          ],
          queue: const [
            _QueueItem(
              Icons.assignment,
              'New report',
              'Black wallet - Library',
              'New',
              primaryAction: 'Review',
              secondaryAction: 'Contact Finder',
            ),
            _QueueItem(
              Icons.assignment_ind,
              'Claim request',
              'iPhone 14 Pro',
              'Review',
              primaryAction: 'Verify',
              secondaryAction: 'Reject',
            ),
            _QueueItem(
              Icons.inventory_2,
              'Item update',
              'ID Card status',
              'Pending',
              primaryAction: 'Update Status',
              secondaryAction: 'Archive',
            ),
          ],
          activity: const [
            _ActivityItem('Item claimed', 'Wallet handed to owner', '30m ago'),
            _ActivityItem('Report added', 'Blue jacket found', '1h ago'),
            _ActivityItem('Verification', 'ID card verified', '4h ago'),
          ],
        );
      case AdminModule.room:
        return _ModuleConfig(
          title: 'Room Reservation',
          subtitle: 'Bookings and approvals queue',
          icon: Icons.event_seat_outlined,
          stats: const [
            _Stat('Today Bookings', '18', '+2'),
            _Stat('Pending', '5', '-1'),
            _Stat('Approved', '22', '+4'),
            _Stat('Declined', '3', '+1'),
          ],
          actions: const [
            _ActionItem(Icons.check_circle_outline, 'Approve Booking'),
            _ActionItem(Icons.cancel_outlined, 'Decline Booking'),
            _ActionItem(Icons.schedule_outlined, 'Reschedule'),
            _ActionItem(Icons.meeting_room_outlined, 'Block Room'),
            _ActionItem(Icons.calendar_today_outlined, 'View Calendar'),
          ],
          metrics: const [
            _Metric('Approval rate', '82%', 0.82, Colors.green),
            _Metric('Conflicts', '12%', 0.12, Colors.red),
            _Metric('Utilization', '68%', 0.68, Colors.blue),
          ],
          queue: const [
            _QueueItem(
              Icons.meeting_room,
              'Room request',
              'Room B102 - 14:00',
              'New',
              primaryAction: 'Approve',
              secondaryAction: 'Decline',
            ),
            _QueueItem(
              Icons.schedule,
              'Schedule change',
              'Room A201 - 16:00',
              'Review',
              primaryAction: 'Reschedule',
              secondaryAction: 'Decline',
            ),
            _QueueItem(
              Icons.event_seat,
              'Bulk booking',
              'Lab C - 3 sessions',
              'Pending',
              primaryAction: 'Review',
              secondaryAction: 'Request Info',
            ),
          ],
          activity: const [
            _ActivityItem('Booking approved', 'Room B102 confirmed', '15m ago'),
            _ActivityItem('Booking declined', 'Room A201 conflict', '1h ago'),
            _ActivityItem('Schedule updated', 'Lab C updated', '5h ago'),
          ],
        );
      case AdminModule.attendance:
        return _ModuleConfig(
          title: 'Attendance Check',
          subtitle: 'Sessions and attendance logs',
          icon: Icons.assignment_turned_in_outlined,
          stats: const [
            _Stat('Sessions Today', '24', '+2'),
            _Stat('Check-ins', '520', '+12%'),
            _Stat('Missing', '16', '-4'),
            _Stat('Late', '9', '+1'),
          ],
          actions: const [
            _ActionItem(Icons.how_to_reg_outlined, 'Mark Present'),
            _ActionItem(Icons.person_off_outlined, 'Mark Absent'),
            _ActionItem(Icons.timer_outlined, 'Mark Late'),
            _ActionItem(Icons.sync_outlined, 'Sync Logs'),
            _ActionItem(Icons.file_download_outlined, 'Export CSV'),
          ],
          metrics: const [
            _Metric('Attendance rate', '88%', 0.88, Colors.green),
            _Metric('Late arrivals', '14%', 0.14, Colors.orange),
            _Metric('Missing records', '8%', 0.08, Colors.red),
          ],
          queue: const [
            _QueueItem(
              Icons.assignment_late,
              'Missing attendance',
              'CS101 - Section A',
              'Review',
              primaryAction: 'Mark Present',
              secondaryAction: 'Mark Absent',
            ),
            _QueueItem(
              Icons.schedule,
              'Late check-in',
              'Math201 - 09:00',
              'New',
              primaryAction: 'Approve',
              secondaryAction: 'Reject',
            ),
            _QueueItem(
              Icons.class_,
              'Session update',
              'Physics Lab',
              'Pending',
              primaryAction: 'Apply Update',
              secondaryAction: 'Review',
            ),
          ],
          activity: const [
            _ActivityItem('Attendance synced', 'CS101 updated', '25m ago'),
            _ActivityItem('Late record', 'Math201 logged', '2h ago'),
            _ActivityItem('Session closed', 'Physics Lab ended', '4h ago'),
          ],
        );
    }
  }
}

class _ModuleConfig {
  const _ModuleConfig({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.stats,
    required this.actions,
    required this.metrics,
    required this.queue,
    required this.activity,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<_Stat> stats;
  final List<_ActionItem> actions;
  final List<_Metric> metrics;
  final List<_QueueItem> queue;
  final List<_ActivityItem> activity;
}

class _Stat {
  const _Stat(this.label, this.value, this.trend);

  final String label;
  final String value;
  final String trend;
}

class _QueueItem {
  const _QueueItem(
    this.icon,
    this.title,
    this.subtitle,
    this.tag, {
    this.primaryAction,
    this.secondaryAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String tag;
  final String? primaryAction;
  final String? secondaryAction;
}

class _ActivityItem {
  const _ActivityItem(this.title, this.subtitle, this.time);

  final String title;
  final String subtitle;
  final String time;
}

class _ActionItem {
  const _ActionItem(this.icon, this.label);

  final IconData icon;
  final String label;
}

class _Metric {
  const _Metric(this.label, this.valueLabel, this.percent, this.color);

  final String label;
  final String valueLabel;
  final double percent;
  final Color color;
}

class ClubAdminMobileScreen extends StatefulWidget {
  const ClubAdminMobileScreen({super.key});

  @override
  State<ClubAdminMobileScreen> createState() => _ClubAdminMobileScreenState();
}

class _ClubAdminMobileScreenState extends State<ClubAdminMobileScreen> {
  final TextEditingController _vacancyTitleController = TextEditingController();
  final TextEditingController _vacancyDeadlineController = TextEditingController();
  final TextEditingController _vacancyDescriptionController = TextEditingController();
  final TextEditingController _requirementController = TextEditingController();
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventDateTimeController = TextEditingController();
  final TextEditingController _eventDurationController = TextEditingController(text: '3');
  final TextEditingController _eventAttendanceController = TextEditingController(text: '250');
  final TextEditingController _eventDescriptionController = TextEditingController();
  final TextEditingController _eventObjectivesController = TextEditingController();
  final TextEditingController _eventSubEventsController = TextEditingController();
  final TextEditingController _eventMediaController = TextEditingController();
  final TextEditingController _eventResourceController = TextEditingController();

  int _applicationsTab = 0;
  String _vacancyCategory = 'Select a category';
  String _eventVenuePreference = 'Main Auditorium';
  bool _logisticsAudio = false;
  bool _logisticsSecurity = true;
  bool _logisticsCatering = false;
  bool _logisticsCleaning = true;
  bool _clubEmailNotifications = true;
  bool _clubAutoApprove = false;
  final List<String> _requirements = [
    'Excellent communication and teamwork skills.',
    'Enthusiasm for university events and student life.',
  ];

  final List<Map<String, String>> _activityFeed = [
    {
      'name': 'Alex Johnson',
      'action': 'Application Submitted',
      'role': 'Lead Designer',
      'status': 'Pending Review',
      'time': '2 mins ago',
    },
    {
      'name': 'Maria Garcia',
      'action': 'Membership Confirmed',
      'role': 'General Member',
      'status': 'Completed',
      'time': '1 hour ago',
    },
    {
      'name': 'James Smith',
      'action': 'Role Application',
      'role': 'Treasurer',
      'status': 'Under Review',
      'time': '3 hours ago',
    },
    {
      'name': 'Sarah Chen',
      'action': 'Event Suggestion',
      'role': 'Annual Gala 2024',
      'status': 'New Proposal',
      'time': '5 hours ago',
    },
  ];

  final List<Map<String, String>> _applications = [
    {
      'name': 'Jane Cooper',
      'studentId': '20230045',
      'role': 'Full Membership',
      'date': 'Oct 24, 2023',
      'status': 'Pending',
    },
    {
      'name': 'Marcus Holloway',
      'studentId': '20231122',
      'role': 'Associate Member',
      'date': 'Oct 23, 2023',
      'status': 'Reviewing',
    },
    {
      'name': 'Sarah Jenkins',
      'studentId': '20220912',
      'role': 'Full Membership',
      'date': 'Oct 21, 2023',
      'status': 'Pending',
    },
  ];

  @override
  void dispose() {
    _vacancyTitleController.dispose();
    _vacancyDeadlineController.dispose();
    _vacancyDescriptionController.dispose();
    _requirementController.dispose();
    _eventNameController.dispose();
    _eventDateTimeController.dispose();
    _eventDurationController.dispose();
    _eventAttendanceController.dispose();
    _eventDescriptionController.dispose();
    _eventObjectivesController.dispose();
    _eventSubEventsController.dispose();
    _eventMediaController.dispose();
    _eventResourceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.white,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Club Admin',
                style: TextStyle(
                  color: AppColors.gray900,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              Text(
                'Command Center',
                style: TextStyle(
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
              onPressed: () => _openSearchSheet(),
            ),
            IconButton(
              icon: const Icon(Icons.notifications_none, color: AppColors.gray600),
              onPressed: () => _openNotificationsSheet(),
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: AppColors.gray600),
              onPressed: () => _openSettingsSheet(),
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
              Tab(icon: Icon(Icons.dashboard_outlined, size: 18), text: 'Overview'),
              Tab(icon: Icon(Icons.assignment_outlined, size: 18), text: 'Applications'),
              Tab(icon: Icon(Icons.event_outlined, size: 18), text: 'Events'),
              Tab(icon: Icon(Icons.work_outline, size: 18), text: 'Vacancies'),
              Tab(icon: Icon(Icons.settings_outlined, size: 18), text: 'Settings'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOverviewTab(context),
            _buildApplicationsTab(context),
            _buildEventsTab(context),
            _buildVacanciesTab(context),
            _buildSettingsTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context) {
    return ResponsiveContainer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildSectionTitle('Dashboard Overview'),
            const SizedBox(height: 12),
            _buildOverviewCards(),
            const SizedBox(height: 20),
            _buildSectionTitle('Recent Activity Feed'),
            const SizedBox(height: 12),
            ..._activityFeed.map(_buildActivityCard),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildTipCard()),
                const SizedBox(width: 12),
                Expanded(child: _buildSystemStatusCard()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationsTab(BuildContext context) {
    return ResponsiveContainer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Application Management'),
            const SizedBox(height: 6),
            const Text(
              'You have 12 pending applications requiring review.',
              style: TextStyle(fontSize: 12, color: AppColors.gray600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showSnackBar('Export CSV (mock).'),
                    icon: const Icon(Icons.file_download_outlined, size: 18),
                    label: const Text('Export CSV'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showSnackBar('New Opening (mock).'),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('New Opening'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildSegmentChip('Membership Requests', 0),
                const SizedBox(width: 8),
                _buildSegmentChip('Job Vacancies', 1),
              ],
            ),
            const SizedBox(height: 12),
            _buildApplicationsFilters(),
            const SizedBox(height: 12),
            ..._applications.map(_buildApplicationCard),
          ],
        ),
      ),
    );
  }

  Widget _buildVacanciesTab(BuildContext context) {
    return ResponsiveContainer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Announce New Vacancy'),
            const SizedBox(height: 6),
            const Text(
              'Recruit talented members by filling out the details below.',
              style: TextStyle(fontSize: 12, color: AppColors.gray600),
            ),
            const SizedBox(height: 16),
            _buildFormCard(
              title: 'Basic Information',
              child: Column(
                children: [
                  TextField(
                    controller: _vacancyTitleController,
                    decoration: const InputDecoration(
                      labelText: 'Role Title',
                      hintText: 'e.g. Marketing Coordinator',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _vacancyCategory,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(
                              value: 'Select a category',
                              child: Text('Select a category'),
                            ),
                            DropdownMenuItem(value: 'Design', child: Text('Design')),
                            DropdownMenuItem(value: 'Marketing', child: Text('Marketing')),
                            DropdownMenuItem(value: 'Tech', child: Text('Tech')),
                          ],
                          onChanged: (value) {
                            setState(() => _vacancyCategory = value ?? 'Select a category');
                          },
                          decoration: const InputDecoration(labelText: 'Category'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _vacancyDeadlineController,
                          decoration: const InputDecoration(
                            labelText: 'Application Deadline',
                            hintText: 'mm/dd/yyyy',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildFormCard(
              title: 'Role Description',
              child: TextField(
                controller: _vacancyDescriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Describe responsibilities and day-to-day tasks...',
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildFormCard(
              title: 'Key Requirements',
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _requirementController,
                          decoration: const InputDecoration(
                            hintText: 'Add a qualification (e.g. Canva experience)',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (_requirementController.text.trim().isEmpty) {
                            return;
                          }
                          setState(() {
                            _requirements.add(_requirementController.text.trim());
                            _requirementController.clear();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                        ),
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._requirements.map((item) => _buildRequirementTile(item)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showSnackBar('Preview vacancy (mock).'),
                    child: const Text('Preview'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showSnackBar('Publish vacancy (mock).'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                    ),
                    child: const Text('Publish Vacancy'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTab(BuildContext context) {
    return ResponsiveContainer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Settings'),
            const SizedBox(height: 12),
            SwitchListTile(
              value: _clubEmailNotifications,
              onChanged: (value) => setState(() => _clubEmailNotifications = value),
              activeColor: AppColors.primary,
              title: const Text('Email notifications'),
              subtitle: const Text('Get updates on applications and events'),
            ),
            SwitchListTile(
              value: _clubAutoApprove,
              onChanged: (value) => setState(() => _clubAutoApprove = value),
              activeColor: AppColors.primary,
              title: const Text('Auto-approve members'),
              subtitle: const Text('Automatically approve new member requests'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _logout(),
              icon: const Icon(Icons.logout),
              label: const Text('Log out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsTab(BuildContext context) {
    return ResponsiveContainer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Suggest New Event'),
            const SizedBox(height: 6),
            const Text(
              'Finalize your event proposal and logistical requirements.',
              style: TextStyle(fontSize: 12, color: AppColors.gray600),
            ),
            const SizedBox(height: 16),
            _buildFormCard(
              title: 'Event Basics',
              child: Column(
                children: [
                  TextField(
                    controller: _eventNameController,
                    decoration: const InputDecoration(
                      labelText: 'Event Name',
                      hintText: 'e.g. Annual Tech Symposium 2024',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _eventDateTimeController,
                          decoration: const InputDecoration(
                            labelText: 'Date & Time',
                            hintText: 'mm/dd/yyyy, --:--',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _eventDurationController,
                          decoration: const InputDecoration(
                            labelText: 'Duration (Hours)',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _eventAttendanceController,
                          decoration: const InputDecoration(
                            labelText: 'Estimated Attendance',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _eventVenuePreference,
                          items: const [
                            DropdownMenuItem(
                              value: 'Main Auditorium',
                              child: Text('Main Auditorium'),
                            ),
                            DropdownMenuItem(
                              value: 'Hall B',
                              child: Text('Hall B'),
                            ),
                            DropdownMenuItem(
                              value: 'Lab C',
                              child: Text('Lab C'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() => _eventVenuePreference = value ?? 'Main Auditorium');
                          },
                          decoration: const InputDecoration(
                            labelText: 'Venue Preference',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildFormCard(
              title: 'Event Media',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.gray200),
                      color: AppColors.gray50,
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.cloud_upload_outlined, color: AppColors.primary, size: 36),
                        const SizedBox(height: 8),
                        const Text(
                          'Click to upload or drag & drop',
                          style: TextStyle(fontSize: 12, color: AppColors.gray600),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () => _showSnackBar('Select file (mock).'),
                          child: const Text('Select File'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _eventMediaController,
                    decoration: const InputDecoration(
                      labelText: 'Media Notes',
                      hintText: 'Optional notes about the cover image',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildFormCard(
              title: 'Event Content',
              child: Column(
                children: [
                  TextField(
                    controller: _eventDescriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Event Description',
                      hintText: 'Briefly describe what happens during the event...',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _eventObjectivesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Purpose & Objectives',
                      hintText: 'What is the goal of this event?',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _eventSubEventsController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Sub-events Included',
                      hintText: 'List workshops, ceremonies, breakout sessions...',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildFormCard(
              title: 'Logistical Requirements',
              child: Column(
                children: [
                  _buildLogisticsTile(
                    'Audio/Visual Setup',
                    'Mics, speakers, projectors',
                    _logisticsAudio,
                    (value) => setState(() => _logisticsAudio = value),
                  ),
                  _buildLogisticsTile(
                    'Security Presence',
                    'Crowd control and check-in',
                    _logisticsSecurity,
                    (value) => setState(() => _logisticsSecurity = value),
                  ),
                  _buildLogisticsTile(
                    'Catering Services',
                    'Refreshments and snacks',
                    _logisticsCatering,
                    (value) => setState(() => _logisticsCatering = value),
                  ),
                  _buildLogisticsTile(
                    'Cleaning Staff',
                    'Pre and post-event cleanup',
                    _logisticsCleaning,
                    (value) => setState(() => _logisticsCleaning = value),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _eventResourceController,
                    decoration: const InputDecoration(
                      labelText: 'Other Resource Requests',
                      hintText: 'Describe any other specific needs...',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showSnackBar('Save draft (mock).'),
                    child: const Text('Save Draft'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showSnackBar('Submit proposal (mock).'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                    ),
                    child: const Text('Submit Proposal'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search members, applications or events...',
        prefixIcon: const Icon(Icons.search, color: AppColors.gray400),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.gray200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.gray200),
        ),
      ),
      onSubmitted: (_) => _showSnackBar('Search is mocked.'),
    );
  }

  Widget _buildOverviewCards() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.4,
      children: const [
        _MiniStatCard(
          icon: Icons.groups_outlined,
          label: 'Active Members',
          value: '124',
          trend: '+5%',
        ),
        _MiniStatCard(
          icon: Icons.work_outline,
          label: 'Open Vacancies',
          value: '3',
          trend: '-2%',
        ),
        _MiniStatCard(
          icon: Icons.description_outlined,
          label: 'New Applications',
          value: '12',
          trend: '+8%',
        ),
        _MiniStatCard(
          icon: Icons.event_outlined,
          label: 'Upcoming Events',
          value: '4',
          trend: 'Stable',
        ),
      ],
    );
  }

  Widget _buildActivityCard(Map<String, String> item) {
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
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: const Icon(Icons.person, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item['name'] ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
                  ),
                ),
              ),
              _buildStatusChip(item['status'] ?? ''),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item['action'] ?? '',
            style: const TextStyle(fontSize: 12, color: AppColors.gray700),
          ),
          const SizedBox(height: 6),
          Text(
            item['role'] ?? '',
            style: const TextStyle(fontSize: 12, color: AppColors.gray500),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item['time'] ?? '',
                style: const TextStyle(fontSize: 11, color: AppColors.gray400),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _showSnackBar('View details (mock).'),
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                  ),
                  IconButton(
                    onPressed: () => _showSnackBar('Approve (mock).'),
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                  ),
                  IconButton(
                    onPressed: () => _showSnackBar('Reject (mock).'),
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.lightbulb_outline, color: AppColors.primary),
          SizedBox(height: 8),
          Text(
            'Admin Tip',
            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.gray900),
          ),
          SizedBox(height: 6),
          Text(
            'Recruitment closes in 14 days. Review pending applications by Friday.',
            style: TextStyle(fontSize: 12, color: AppColors.gray600),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemStatusCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'System Status',
            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.gray900),
          ),
          SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.circle, size: 10, color: Colors.green),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'All services operational',
                  style: TextStyle(fontSize: 12, color: AppColors.gray600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentChip(String label, int index) {
    final isActive = _applicationsTab == index;
    return ChoiceChip(
      label: Text(label),
      selected: isActive,
      onSelected: (_) => setState(() => _applicationsTab = index),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.gray100,
      labelStyle: TextStyle(
        color: isActive ? AppColors.white : AppColors.gray700,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildApplicationsFilters() {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Search by name or student ID',
            prefixIcon: const Icon(Icons.search, color: AppColors.gray400),
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.gray200),
            ),
          ),
          onSubmitted: (_) => _showSnackBar('Search is mocked.'),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: 'All',
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('Status: All')),
                  DropdownMenuItem(value: 'Pending', child: Text('Status: Pending')),
                  DropdownMenuItem(value: 'Reviewing', child: Text('Status: Reviewing')),
                ],
                onChanged: (_) => _showSnackBar('Filter is mocked.'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: 'All',
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('Role: All')),
                  DropdownMenuItem(value: 'Member', child: Text('Role: Member')),
                  DropdownMenuItem(value: 'Officer', child: Text('Role: Officer')),
                ],
                onChanged: (_) => _showSnackBar('Filter is mocked.'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildApplicationCard(Map<String, String> item) {
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
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: const Icon(Icons.person, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item['name'] ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
                  ),
                ),
              ),
              _buildStatusChip(item['status'] ?? ''),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Student ID: ${item['studentId'] ?? ''}',
            style: const TextStyle(fontSize: 12, color: AppColors.gray600),
          ),
          const SizedBox(height: 4),
          Text(
            'Role: ${item['role'] ?? ''}',
            style: const TextStyle(fontSize: 12, color: AppColors.gray600),
          ),
          const SizedBox(height: 4),
          Text(
            'Applied: ${item['date'] ?? ''}',
            style: const TextStyle(fontSize: 12, color: AppColors.gray500),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showSnackBar('View application (mock).'),
                  child: const Text('View'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showSnackBar('Approve application (mock).'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                  ),
                  child: const Text('Approve'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _showSnackBar('Reject application (mock).'),
                icon: const Icon(Icons.cancel_outlined, color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildRequirementTile(String item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.primary, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item,
              style: const TextStyle(fontSize: 12, color: AppColors.gray700),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16, color: AppColors.gray500),
            onPressed: () {
              setState(() => _requirements.remove(item));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogisticsTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: (val) => onChanged(val ?? false),
            activeColor: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: AppColors.gray600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.gray900,
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    if (status.toLowerCase().contains('pending')) {
      color = Colors.orange;
    } else if (status.toLowerCase().contains('review')) {
      color = Colors.blue;
    } else if (status.toLowerCase().contains('completed')) {
      color = Colors.green;
    } else if (status.toLowerCase().contains('proposal')) {
      color = Colors.purple;
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

  void _openSearchSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Search',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search members, applications or events...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AppColors.gray50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.gray200),
                  ),
                ),
                onSubmitted: (_) {
                  Navigator.pop(context);
                  _showSnackBar('Search submitted (mock).');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _openNotificationsSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Notifications',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12),
              ListTile(
                leading: Icon(Icons.check_circle_outline, color: Colors.green),
                title: Text('Membership approved'),
                subtitle: Text('Alex Johnson joined the club'),
              ),
              ListTile(
                leading: Icon(Icons.event_outlined, color: AppColors.primary),
                title: Text('Event proposal'),
                subtitle: Text('AI Meetup - Hall B'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openSettingsSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Settings',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: _clubEmailNotifications,
                onChanged: (value) {
                  setState(() => _clubEmailNotifications = value);
                  _showSnackBar('Notifications updated (mock).');
                },
                title: const Text('Email notifications'),
              ),
              SwitchListTile(
                value: _clubAutoApprove,
                onChanged: (value) {
                  setState(() => _clubAutoApprove = value);
                  _showSnackBar('Auto-approve updated (mock).');
                },
                title: const Text('Auto-approve members'),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _logout();
                },
                icon: const Icon(Icons.logout),
                label: const Text('Log out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: AppColors.white,
                ),
              ),
            ],
          ),
        );
      },
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

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.trend,
  });

  final IconData icon;
  final String label;
  final String value;
  final String trend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.gray600),
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
            style: const TextStyle(fontSize: 11, color: AppColors.gray500),
          ),
        ],
      ),
    );
  }
}

class SupportAdminMobileScreen extends StatefulWidget {
  const SupportAdminMobileScreen({super.key});

  @override
  State<SupportAdminMobileScreen> createState() => _SupportAdminMobileScreenState();
}

class _SupportAdminMobileScreenState extends State<SupportAdminMobileScreen> {
  final TextEditingController _globalSearchController = TextEditingController();
  int _staffFilter = 0;
  bool _supportEmailNotifications = true;
  bool _supportAutoAssign = false;

  final List<Map<String, String>> _staff = [
    {
      'name': 'Alex Rivera',
      'role': 'IT Support • Tier 2',
      'specialization': 'Network Admin',
      'status': 'Online',
      'workload': '3 Active',
    },
    {
      'name': 'Sarah Jenkins',
      'role': 'FM • Maintenance',
      'specialization': 'Electrician',
      'status': 'On Break',
      'workload': '1 Active',
    },
    {
      'name': 'Mark Thompson',
      'role': 'IT Support • Tier 1',
      'specialization': 'Desktop Support',
      'status': 'Online',
      'workload': '5 Active',
    },
    {
      'name': 'Elena Rodriguez',
      'role': 'IT Support • Cloud',
      'specialization': 'System Admin',
      'status': 'Online',
      'workload': '2 Active',
    },
  ];

  final List<Map<String, String>> _tasks = [
    {
      'time': '09:00 AM',
      'title': 'Library workstation upgrade',
      'location': 'North Campus Library, 2nd floor',
      'status': 'Upcoming',
    },
    {
      'time': '11:30 AM',
      'title': 'Network switch replacement',
      'location': 'High Priority Maintenance',
      'status': 'Active',
    },
    {
      'time': '02:00 PM',
      'title': 'Faculty desk side support',
      'location': 'Education Building, Office 304',
      'status': 'Upcoming',
    },
  ];

  final List<Map<String, String>> _tickets = [
    {
      'title': 'Wi-Fi outage',
      'location': 'Dorm C - Floor 2',
      'priority': 'High',
      'status': 'Open',
    },
    {
      'title': 'Printer issue',
      'location': 'Library - Desk 4',
      'priority': 'Medium',
      'status': 'In Progress',
    },
    {
      'title': 'Lighting issue',
      'location': 'Room A201',
      'priority': 'Low',
      'status': 'Open',
    },
  ];

  @override
  void dispose() {
    _globalSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.white,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'IT/FM Admin',
                style: TextStyle(
                  color: AppColors.gray900,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              Text(
                'Staff Workload Overview',
                style: TextStyle(
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
              onPressed: () => _openGlobalSearchSheet(),
            ),
            IconButton(
              icon: const Icon(Icons.notifications_none, color: AppColors.gray600),
              onPressed: () => _openNotificationsSheet(),
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: AppColors.gray600),
              onPressed: () => _openSettingsSheet(),
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
              Tab(icon: Icon(Icons.groups_outlined, size: 18), text: 'Staff'),
              Tab(icon: Icon(Icons.bar_chart_outlined, size: 18), text: 'Workload'),
              Tab(icon: Icon(Icons.confirmation_number_outlined, size: 18), text: 'Tickets'),
              Tab(icon: Icon(Icons.analytics_outlined, size: 18), text: 'Reports'),
              Tab(icon: Icon(Icons.settings_outlined, size: 18), text: 'Settings'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildStaffTab(context),
            _buildWorkloadTab(context),
            _buildTicketsTab(context),
            _buildReportsTab(context),
            _buildSettingsTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffTab(BuildContext context) {
    return ResponsiveContainer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Staff Directory'),
            const SizedBox(height: 8),
            TextField(
              controller: _globalSearchController,
              decoration: InputDecoration(
                hintText: 'Search staff, skills, or specialization',
                prefixIcon: const Icon(Icons.search, color: AppColors.gray400),
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.gray200),
                ),
              ),
              onSubmitted: (_) => _showSnackBar('Search is mocked.'),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _buildFilterChip('All Staff', 0),
                _buildFilterChip('IT Support', 1),
                _buildFilterChip('Facilities', 2),
              ],
            ),
            const SizedBox(height: 12),
            ..._staff.map(_buildStaffCard),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkloadTab(BuildContext context) {
    return ResponsiveContainer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Workload Snapshot'),
            const SizedBox(height: 12),
            _buildWorkloadStats(),
            const SizedBox(height: 20),
            _buildSectionHeader('Today\'s Schedule'),
            const SizedBox(height: 12),
            ..._tasks.map(_buildTaskCard),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showSnackBar('Rebalance task (mock).'),
                    child: const Text('Rebalance Task'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showSnackBar('Full profile (mock).'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                    ),
                    child: const Text('Full Profile'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketsTab(BuildContext context) {
    return ResponsiveContainer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Active Tickets'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showSnackBar('Filter tickets (mock).'),
                    icon: const Icon(Icons.filter_list, size: 18),
                    label: const Text('Filter'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showSnackBar('Assign task (mock).'),
                    icon: const Icon(Icons.assignment_ind_outlined, size: 18),
                    label: const Text('Assign New Task'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._tickets.map(_buildTicketCard),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsTab(BuildContext context) {
    return ResponsiveContainer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Reporting'),
            const SizedBox(height: 12),
            _buildReportCard('Weekly Load', '28h / 40h', Colors.blue),
            const SizedBox(height: 12),
            _buildReportCard('Task Completion', '92%', Colors.green),
            const SizedBox(height: 12),
            _buildReportCard('Open Incidents', '6', Colors.orange),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showSnackBar('Export report (mock).'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Export Report'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTab(BuildContext context) {
    return ResponsiveContainer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Settings'),
            const SizedBox(height: 12),
            SwitchListTile(
              value: _supportEmailNotifications,
              onChanged: (value) => setState(() => _supportEmailNotifications = value),
              activeColor: AppColors.primary,
              title: const Text('Email notifications'),
              subtitle: const Text('Get updates on tickets and SLA alerts'),
            ),
            SwitchListTile(
              value: _supportAutoAssign,
              onChanged: (value) => setState(() => _supportAutoAssign = value),
              activeColor: AppColors.primary,
              title: const Text('Auto-assign tickets'),
              subtitle: const Text('Auto-assign based on workload'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _logout(),
              icon: const Icon(Icons.logout),
              label: const Text('Log out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: AppColors.white,
              ),
            ),
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

  void _openGlobalSearchSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Global Search',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search staff, tickets, locations...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AppColors.gray50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.gray200),
                  ),
                ),
                onSubmitted: (_) {
                  Navigator.pop(context);
                  _showSnackBar('Search submitted (mock).');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _openNotificationsSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Notifications',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12),
              ListTile(
                leading: Icon(Icons.warning_amber_outlined, color: Colors.orange),
                title: Text('SLA warning'),
                subtitle: Text('Wi-Fi outage pending'),
              ),
              ListTile(
                leading: Icon(Icons.check_circle_outline, color: Colors.green),
                title: Text('Ticket resolved'),
                subtitle: Text('Printer issue closed'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openSettingsSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Settings',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: _supportEmailNotifications,
                onChanged: (value) {
                  setState(() => _supportEmailNotifications = value);
                  _showSnackBar('Notifications updated (mock).');
                },
                title: const Text('Email notifications'),
              ),
              SwitchListTile(
                value: _supportAutoAssign,
                onChanged: (value) {
                  setState(() => _supportAutoAssign = value);
                  _showSnackBar('Auto-assign updated (mock).');
                },
                title: const Text('Auto-assign tickets'),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _logout();
                },
                icon: const Icon(Icons.logout),
                label: const Text('Log out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: AppColors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isActive = _staffFilter == index;
    return ChoiceChip(
      label: Text(label),
      selected: isActive,
      onSelected: (_) => setState(() => _staffFilter = index),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.gray100,
      labelStyle: TextStyle(
        color: isActive ? AppColors.white : AppColors.gray700,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildStaffCard(Map<String, String> item) {
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
            radius: 20,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: const Icon(Icons.person, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['role'] ?? '',
                  style: const TextStyle(fontSize: 12, color: AppColors.gray600),
                ),
                const SizedBox(height: 4),
                Text(
                  item['specialization'] ?? '',
                  style: const TextStyle(fontSize: 11, color: AppColors.gray500),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildStatusPill(item['status'] ?? 'Offline'),
              const SizedBox(height: 6),
              Text(
                item['workload'] ?? '',
                style: const TextStyle(fontSize: 11, color: AppColors.gray600),
              ),
              const SizedBox(height: 6),
              OutlinedButton(
                onPressed: () => _showSnackBar('Assign task (mock).'),
                child: const Text('Assign'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkloadStats() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.4,
      children: const [
        _MiniStatCard(
          icon: Icons.timer_outlined,
          label: 'Weekly Load',
          value: '28h',
          trend: '+5%',
        ),
        _MiniStatCard(
          icon: Icons.check_circle_outline,
          label: 'Completion',
          value: '92%',
          trend: '+2%',
        ),
        _MiniStatCard(
          icon: Icons.priority_high_outlined,
          label: 'Open Incidents',
          value: '6',
          trend: '-1',
        ),
        _MiniStatCard(
          icon: Icons.groups_outlined,
          label: 'Staff Online',
          value: '18',
          trend: 'Stable',
        ),
      ],
    );
  }

  Widget _buildTaskCard(Map<String, String> item) {
    final isActive = item['status'] == 'Active';
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
            width: 6,
            height: 50,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.gray300,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['time'] ?? '',
                  style: const TextStyle(fontSize: 11, color: AppColors.gray500),
                ),
                const SizedBox(height: 4),
                Text(
                  item['title'] ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['location'] ?? '',
                  style: const TextStyle(fontSize: 11, color: AppColors.gray600),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showSnackBar('Open task (mock).'),
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(Map<String, String> item) {
    Color color;
    if (item['priority'] == 'High') {
      color = Colors.red;
    } else if (item['priority'] == 'Medium') {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item['title'] ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  item['priority'] ?? '',
                  style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item['location'] ?? '',
            style: const TextStyle(fontSize: 12, color: AppColors.gray600),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showSnackBar('Assign ticket (mock).'),
                  child: const Text('Assign'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showSnackBar('Resolve ticket (mock).'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                  ),
                  child: const Text('Resolve'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(String label, String value, Color color) {
    return Container(
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
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.analytics_outlined, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.gray900,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(String status) {
    Color color;
    if (status.toLowerCase().contains('online')) {
      color = Colors.green;
    } else if (status.toLowerCase().contains('break')) {
      color = Colors.orange;
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
}
