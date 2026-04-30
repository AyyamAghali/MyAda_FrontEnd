import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/constants.dart';
import '../../utils/responsive.dart';
import '../../models/support_ticket.dart';
import '../../services/auth_service.dart';
import '../../services/support_service.dart';
import '../../models/user_role.dart';
import '../../widgets/modern_select_sheet.dart';
import '../../widgets/responsive_container.dart';
import '../../widgets/support_location_picker.dart';
import '../login_page.dart';
import 'support_staff_dashboard.dart';
import 'club_application_detail.dart';
import '../support/ticket_detail_view.dart';
import '../../rbac/club_entrance_scan_access.dart';
import '../clubs/club_events_screen.dart';
import '../clubs/entrance_scan_flow.dart';

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
      return const SupportAdminScreen();
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

  bool? _canScanEntrance;

  final List<Map<String, String>> _applications = [
    {
      'name': 'Jane Cooper',
      'studentId': '20230045',
      'role': 'Full Membership',
      'date': 'Oct 24, 2023',
      'status': 'Pending',
      'type': 'membership',
    },
    {
      'name': 'Marcus Holloway',
      'studentId': '20231122',
      'role': 'Associate Member',
      'date': 'Oct 23, 2023',
      'status': 'Reviewing',
      'type': 'membership',
    },
    {
      'name': 'Sarah Jenkins',
      'studentId': '20220912',
      'role': 'Full Membership',
      'date': 'Oct 21, 2023',
      'status': 'Pending',
      'type': 'membership',
    },
    {
      'name': 'Alex Johnson',
      'studentId': '20228811',
      'role': 'Event Volunteer',
      'date': 'Oct 20, 2023',
      'status': 'Reviewing',
      'type': 'vacancy',
    },
  ];

  @override
  void initState() {
    super.initState();
    ClubEntranceScanAccess.canOpenEntranceScanner().then((allowed) {
      if (mounted) setState(() => _canScanEntrance = allowed);
    });
  }

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
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.white,
        title: const Text(
          'Club Admin',
          style: TextStyle(
            color: AppColors.gray900,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.gray600),
            onPressed: _logout,
          ),
        ],
      ),
      body: ResponsiveContainer(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          children: [
            _buildSectionTitle('Event Manager Tools'),
            const SizedBox(height: 10),
            if (_canScanEntrance == true)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    final allowed = await ClubEntranceScanAccess
                        .allowedClubIdsForCurrentUser();
                    if (!context.mounted) return;
                    await Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => SelectClubForScanScreen(
                          allowedClubIds: allowed,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.qr_code_scanner, size: 18),
                  label: const Text(
                    'Scan at entrance',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const ClubEventsScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.confirmation_number_outlined, size: 18),
                label: const Text(
                  'Tickets (My Tickets)',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.gray300),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            _buildSectionTitle('Keepable'),
            const SizedBox(height: 10),
            _quickLink(
              context,
              icon: Icons.assignment_outlined,
              title: 'Applications',
              subtitle: 'Review membership/vacancy requests',
              onTap: () => _openApplicationsQuick(context),
            ),
            const SizedBox(height: 10),
            _quickLink(
              context,
              icon: Icons.event_outlined,
              title: 'Events',
              subtitle: 'View upcoming club events',
              onTap: () => _openEventsQuick(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickLink(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: AppColors.gray600),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.gray400),
            ],
          ),
        ),
      ),
    );
  }

  void _openApplicationsQuick(BuildContext context) {
    // Reuse the existing applications tab content in a simple scaffold.
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.gray900,
            elevation: 0,
            title: const Text('Applications'),
          ),
          body: _buildApplicationsTab(context),
        ),
      ),
    );
  }

  void _openEventsQuick(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.gray900,
            elevation: 0,
            title: const Text('Events'),
          ),
          body: _buildEventsTab(context),
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
    final filteredApplications = _applications.where((item) {
      if (_applicationsTab == 0) {
        return item['type'] == 'membership';
      }
      return item['type'] == 'vacancy';
    }).toList();

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
            ...filteredApplications.map(_buildApplicationCard),
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
                        child: GestureDetector(
                          onTap: () async {
                            final result = await showModernSelectSheet<String>(
                              context: context,
                              title: 'Select Category',
                              selectedValue: _vacancyCategory,
                              options: const [
                                SelectOption(value: 'Design', label: 'Design'),
                                SelectOption(value: 'Marketing', label: 'Marketing'),
                                SelectOption(value: 'Tech', label: 'Tech'),
                              ],
                            );
                            if (result != null) {
                              setState(() => _vacancyCategory = result);
                            }
                          },
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: TextEditingController(text: _vacancyCategory == 'Select a category' ? '' : _vacancyCategory),
                              decoration: InputDecoration(
                                labelText: 'Category',
                                hintText: 'Select a category',
                                suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.gray400, size: 22),
                                filled: true,
                                fillColor: AppColors.gray50,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.gray200)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.gray200)),
                              ),
                            ),
                          ),
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
                        child: GestureDetector(
                          onTap: () async {
                            final result = await showModernSelectSheet<String>(
                              context: context,
                              title: 'Venue Preference',
                              selectedValue: _eventVenuePreference,
                              options: const [
                                SelectOption(value: 'Main Auditorium', label: 'Main Auditorium'),
                                SelectOption(value: 'Hall B', label: 'Hall B'),
                                SelectOption(value: 'Lab C', label: 'Lab C'),
                              ],
                            );
                            if (result != null) {
                              setState(() => _eventVenuePreference = result);
                            }
                          },
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: TextEditingController(text: _eventVenuePreference),
                              decoration: InputDecoration(
                                labelText: 'Venue Preference',
                                suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.gray400, size: 22),
                                filled: true,
                                fillColor: AppColors.gray50,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.gray200)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.gray200)),
                              ),
                            ),
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
              child: GestureDetector(
                onTap: () async {
                  final result = await showModernSelectSheet<String>(
                    context: context,
                    title: 'Filter by Status',
                    selectedValue: 'All',
                    options: const [
                      SelectOption(value: 'All', label: 'All'),
                      SelectOption(value: 'Pending', label: 'Pending'),
                      SelectOption(value: 'Reviewing', label: 'Reviewing'),
                    ],
                  );
                  if (result != null) _showSnackBar('Filter is mocked.');
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: TextEditingController(text: 'Status: All'),
                    decoration: InputDecoration(
                      suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.gray400, size: 22),
                      filled: true,
                      fillColor: AppColors.gray50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.gray200)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.gray200)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    style: const TextStyle(fontSize: 14, color: AppColors.gray900),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final result = await showModernSelectSheet<String>(
                    context: context,
                    title: 'Filter by Role',
                    selectedValue: 'All',
                    options: const [
                      SelectOption(value: 'All', label: 'All'),
                      SelectOption(value: 'Member', label: 'Member'),
                      SelectOption(value: 'Officer', label: 'Officer'),
                    ],
                  );
                  if (result != null) _showSnackBar('Filter is mocked.');
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: TextEditingController(text: 'Role: All'),
                    decoration: InputDecoration(
                      suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.gray400, size: 22),
                      filled: true,
                      fillColor: AppColors.gray50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.gray200)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.gray200)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    style: const TextStyle(fontSize: 14, color: AppColors.gray900),
                  ),
                ),
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClubApplicationDetail(application: item),
                      ),
                    );
                  },
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

class SupportAdminScreen extends StatelessWidget {
  const SupportAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return const SupportAdminMobileScreen();
    }
    return const SupportAdminWebScreen();
  }
}

class _SupportAdminMobileScreenState extends State<SupportAdminMobileScreen> {
  final TextEditingController _globalSearchController = TextEditingController();
  int _staffFilter = 0;

  final SupportService _supportService = SupportService();

  bool _isLoadingStaff = true;
  bool _isLoadingTickets = true;
  bool _isAssigning = false;
  String? _staffError;
  String? _ticketError;

  String _staffQuery = '';
  String _ticketTab = 'all'; // all | it | fm | critical
  String _sortBy = 'newest'; // newest | oldest
  String _ticketModuleFilter = 'all'; // all | IT | FM
  String _ticketStatusFilter = 'all'; // all | open | in_progress | completed
  String _ticketPriorityFilter = 'all'; // all | critical | standard

  List<_SupportStaffEntry> _staff = const [];
  List<SupportTicket> _supportTickets = const [];

  @override
  void initState() {
    super.initState();
    _globalSearchController.addListener(() {
      final v = _globalSearchController.text;
      if (v == _staffQuery) return;
      setState(() => _staffQuery = v);
    });
    _loadStaff();
    _loadTickets();
  }

  @override
  void dispose() {
    _globalSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadStaff() async {
    setState(() {
      _isLoadingStaff = true;
      _staffError = null;
    });
    try {
      await AuthService.instance.loadSession();
      final it = await AuthService.instance.fetchUsersByRole(UserRole.itStaff.apiName);
      final facilities =
          await AuthService.instance.fetchUsersByRole(UserRole.techStaff.apiName);

      final combined = <AuthRoleUser>[
        ...it,
        ...facilities.where((u) => it.every((other) => other.id != u.id)),
      ];

      if (!mounted) return;
      setState(() {
        _staff = combined
            .map((u) => _SupportStaffEntry(
                  id: u.id,
                  name: u.displayName,
                  roleType: it.any((x) => x.id == u.id) ? StaffRoleType.it : StaffRoleType.fm,
                  roleLabel: it.any((x) => x.id == u.id) ? 'IT Support' : 'Facilities',
                ))
            .toList(growable: false);
        _isLoadingStaff = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _staffError = e.toString().replaceFirst('Exception: ', '');
        _isLoadingStaff = false;
      });
    }
  }

  Future<void> _loadTickets() async {
    setState(() {
      _isLoadingTickets = true;
      _ticketError = null;
    });
    try {
      await AuthService.instance.loadSession();
      final tickets = await _supportService.fetchAllRequests();
      if (!mounted) return;
      setState(() {
        _supportTickets = tickets;
        _isLoadingTickets = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _ticketError = e.toString().replaceFirst('Exception: ', '');
        _isLoadingTickets = false;
      });
    }
  }

  List<_SupportStaffEntry> get _filteredStaff {
    final q = _staffQuery.trim().toLowerCase();
    return _staff.where((s) {
      final matchesQuery = q.isEmpty || s.name.toLowerCase().contains(q);
      final matchesFilter = _staffFilter == 0 ||
          (_staffFilter == 1 && s.roleType == StaffRoleType.it) ||
          (_staffFilter == 2 && s.roleType == StaffRoleType.fm);
      return matchesQuery && matchesFilter;
    }).toList(growable: false);
  }

  List<SupportTicket> get _filteredTickets {
    var items = _supportTickets.where((t) {
      final matchModule = _ticketModuleFilter == 'all' ||
          t.type.toLowerCase() == _ticketModuleFilter.toLowerCase();
      final statusKey = t.status == TicketStatus.inProgress
          ? 'in_progress'
          : t.status == TicketStatus.completed
              ? 'completed'
              : 'open';
      final matchStatus =
          _ticketStatusFilter == 'all' || _ticketStatusFilter == statusKey;
      final priorityKey =
          t.priority == TicketPriority.critical ? 'critical' : 'standard';
      final matchPriority =
          _ticketPriorityFilter == 'all' || _ticketPriorityFilter == priorityKey;
      final active = t.status != TicketStatus.cancelled &&
          t.status != TicketStatus.completed;
      if (!(active && matchModule && matchStatus && matchPriority)) return false;

      if (_ticketTab == 'it' && t.type != 'IT') return false;
      if (_ticketTab == 'fm' && t.type != 'FM') return false;
      if (_ticketTab == 'critical' && t.priority != TicketPriority.critical) {
        return false;
      }
      return true;
    }).toList(growable: false);

    int byTime(SupportTicket a, SupportTicket b) {
      final ad = DateTime.tryParse(a.createdAt)?.millisecondsSinceEpoch ?? 0;
      final bd = DateTime.tryParse(b.createdAt)?.millisecondsSinceEpoch ?? 0;
      return _sortBy == 'oldest' ? ad.compareTo(bd) : bd.compareTo(ad);
    }

    items = [...items]..sort(byTime);
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        titleSpacing: 0,
        toolbarHeight: 76,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Dispatcher', style: AppTextStyles.moduleAppBarTitle),
            SizedBox(height: 4),
            const Text(
              'Support Operations',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.gray500,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none_rounded,
                      color: AppColors.gray700),
                  tooltip: 'Notifications',
                  onPressed: _openNotificationsSheet,
                ),
              ],
            ),
          ),
        ],
      ),
      body: _buildTicketsTab(context),
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
            if (_isLoadingStaff)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_staffError != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.cloud_off, color: AppColors.gray300, size: 40),
                      const SizedBox(height: 8),
                      Text(
                        _staffError!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.gray600),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _loadStaff,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else ..._filteredStaff.map(_buildStaffCard),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Expanded(child: _buildSectionHeader('Active Tickets')),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              DispatcherHistoryScreen(tickets: _supportTickets),
                        ),
                      );
                    },
                    icon: const Icon(Icons.history_rounded, size: 18),
                    label: const Text('Dispatcher History'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _buildDispatcherFilterChips(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _openTicketFilters,
                    icon: const Icon(Icons.filter_list, size: 18),
                    label: const Text('Filter'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isAssigning ? null : _assignNewTaskFlow,
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
            if (_isLoadingTickets)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_ticketError != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.cloud_off, color: AppColors.gray300, size: 40),
                      const SizedBox(height: 8),
                      Text(
                        _ticketError!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.gray600),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _loadTickets,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_filteredTickets.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 26),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.gray100,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(Icons.inbox_outlined,
                            size: 32, color: AppColors.gray400),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No active tickets',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.gray900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'New requests will show up here when available.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: AppColors.gray600),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._filteredTickets.map(_buildTicketCard),
          ],
        ),
      ),
    );
  }

  Widget _buildDispatcherStatsRow() {
    final open = _supportTickets.where((t) =>
        t.status != TicketStatus.completed && t.status != TicketStatus.cancelled);
    final total = open.length;
    final unassigned =
        open.where((t) => t.status == TicketStatus.newTicket).length;
    final inProgress = open.where((t) => t.status == TicketStatus.inProgress).length;
    final completed = _supportTickets.where((t) => t.status == TicketStatus.completed).length;

    Widget stat({
      required IconData icon,
      required String label,
      required int value,
      required Color color,
    }) {
      return Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.gray200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray600,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$value',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.gray900,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: stat(
                icon: Icons.receipt_long_outlined,
                label: 'Total requests',
                value: total,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: stat(
                icon: Icons.priority_high_rounded,
                label: 'Unassigned',
                value: unassigned,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: stat(
                icon: Icons.timelapse_rounded,
                label: 'In progress',
                value: inProgress,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: stat(
                icon: Icons.check_circle_outline,
                label: 'Completed',
                value: completed,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDispatcherFilterChips() {
    Widget chip(String id, String label) {
      final active = _ticketTab == id;
      return ChoiceChip(
        selected: active,
        label: Text(label),
        onSelected: (_) => setState(() => _ticketTab = id),
        selectedColor: AppColors.gray900,
        backgroundColor: AppColors.white,
        labelStyle: TextStyle(
          color: active ? AppColors.white : AppColors.gray700,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        side: BorderSide(color: AppColors.gray200),
      );
    }

    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        children: [
          chip('all', 'All'),
          const SizedBox(width: 8),
          chip('it', 'IT'),
          const SizedBox(width: 8),
          chip('fm', 'FM'),
          const SizedBox(width: 8),
          chip('critical', 'Critical'),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.gray200),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _sortBy,
                items: const [
                  DropdownMenuItem(value: 'newest', child: Text('Newest')),
                  DropdownMenuItem(value: 'oldest', child: Text('Oldest')),
                ],
                onChanged: (v) => setState(() => _sortBy = v ?? 'newest'),
              ),
            ),
          ),
        ],
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
                'Session',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
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

  Widget _buildStaffCard(_SupportStaffEntry item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: InkWell(
        onTap: () {
          // This screen is an admin directory; the staff portal uses the
          // currently logged-in staff identity, so we keep tap as no-op for now.
        },
        borderRadius: BorderRadius.circular(16),
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
                    item.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.roleLabel,
                    style: const TextStyle(fontSize: 12, color: AppColors.gray600),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: _isAssigning
                      ? null
                      : () => _assignTicketToStaffFlow(staff: item),
                  child: const Text('Assign'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketCard(SupportTicket item) {
    final color =
        item.priority == TicketPriority.critical ? Colors.red : Colors.green;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TicketDetailView(ticket: item),
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
              Expanded(
                child: Text(
                  item.title,
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
                  item.priorityString,
                  style: TextStyle(
                      fontSize: 11, color: color, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.location,
            style: const TextStyle(fontSize: 12, color: AppColors.gray600),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isAssigning ? null : () => _assignTicket(item),
                  child: const Text('Assign'),
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _openTicketFilters() async {
    final status = await showModernSelectSheet<String>(
      context: context,
      title: 'Filter tickets',
      options: const [
        SelectOption(value: 'all', label: 'All active'),
        SelectOption(value: 'open', label: 'Open'),
        SelectOption(value: 'in_progress', label: 'In Progress'),
      ],
      selectedValue: _ticketStatusFilter,
      accentColor: AppColors.primary,
    );
    if (!mounted || status == null) return;
    final module = await showModernSelectSheet<String>(
      context: context,
      title: 'Filter module',
      options: const [
        SelectOption(value: 'all', label: 'All'),
        SelectOption(value: 'IT', label: 'IT'),
        SelectOption(value: 'FM', label: 'Facilities'),
      ],
      selectedValue: _ticketModuleFilter,
      accentColor: AppColors.primary,
    );
    if (!mounted) return;
    final priority = await showModernSelectSheet<String>(
      context: context,
      title: 'Filter priority',
      options: const [
        SelectOption(value: 'all', label: 'All'),
        SelectOption(value: 'critical', label: 'Critical'),
        SelectOption(value: 'standard', label: 'Standard'),
      ],
      selectedValue: _ticketPriorityFilter,
      accentColor: AppColors.primary,
    );
    if (!mounted) return;
    setState(() {
      _ticketStatusFilter = status;
      if (module != null) _ticketModuleFilter = module;
      if (priority != null) _ticketPriorityFilter = priority;
    });
  }

  Future<void> _assignNewTaskFlow() async {
    final tickets = _filteredTickets;
    if (tickets.isEmpty) {
      _showSnackBar('No active tickets to assign.');
      return;
    }
    final selectedTicket = await showModernSelectSheet<SupportTicket>(
      context: context,
      title: 'Select ticket',
      options: tickets
          .map((t) => SelectOption(
                value: t,
                label: '#${t.id} • ${t.title}',
                icon: Icons.confirmation_number_outlined,
              ))
          .toList(growable: false),
      accentColor: AppColors.primary,
    );
    if (!mounted || selectedTicket == null) return;
    await _assignTicket(selectedTicket);
  }

  Future<void> _assignTicketToStaffFlow({required _SupportStaffEntry staff}) async {
    final tickets = _filteredTickets;
    if (tickets.isEmpty) {
      _showSnackBar('No active tickets to assign.');
      return;
    }
    final selectedTicket = await showModernSelectSheet<SupportTicket>(
      context: context,
      title: 'Select ticket for ${staff.name}',
      options: tickets
          .map((t) => SelectOption(
                value: t,
                label: '#${t.id} • ${t.title}',
                icon: Icons.confirmation_number_outlined,
              ))
          .toList(growable: false),
      accentColor: AppColors.primary,
    );
    if (!mounted || selectedTicket == null) return;
    await _assignTicket(selectedTicket, preselectedStaffId: staff.id);
  }

  Future<void> _assignTicket(
    SupportTicket ticket, {
    String? preselectedStaffId,
  }) async {
    final requestId = ticket.requestId;
    if (requestId == null) {
      _showSnackBar('This ticket has no requestId (cannot assign).');
      return;
    }

    final staffId = preselectedStaffId ??
        await showModernSelectSheet<String>(
          context: context,
          title: 'Assign to staff',
          options: _filteredStaff
              .map((s) => SelectOption(
                    value: s.id,
                    label: s.name,
                    icon: s.roleType == StaffRoleType.it
                        ? Icons.computer_outlined
                        : Icons.home_repair_service_outlined,
                  ))
              .toList(growable: false),
          accentColor: AppColors.primary,
        );
    if (!mounted || staffId == null) return;

    setState(() => _isAssigning = true);
    try {
      await AuthService.instance.loadSession();
      final dispatcherId = AuthService.instance.studentId;
      if (dispatcherId == null || dispatcherId.trim().isEmpty) {
        throw Exception('Authentication required. Please sign in again.');
      }
      await _supportService.assignRequest(
        requestId: requestId,
        dispatcherId: dispatcherId,
        staffId: staffId,
        dispatcherInstructions: '',
      );
      if (!mounted) return;
      _showSnackBar('Ticket assigned.');
      await _loadTickets();
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isAssigning = false);
    }
  }

}

class _SupportStaffEntry {
  final String id;
  final String name;
  final String roleLabel;
  final StaffRoleType roleType;

  const _SupportStaffEntry({
    required this.id,
    required this.name,
    required this.roleLabel,
    required this.roleType,
  });
}

class SupportAdminWebScreen extends StatefulWidget {
  const SupportAdminWebScreen({super.key});

  @override
  State<SupportAdminWebScreen> createState() => _SupportAdminWebScreenState();
}

class _SupportAdminWebScreenState extends State<SupportAdminWebScreen> {
  final SupportService _supportService = SupportService();
  bool _isLoading = true;
  String? _error;

  List<SupportTicket> _tickets = const [];
  List<_SupportStaffEntry> _staff = const [];

  String _moduleFilter = 'all'; // all | IT | FM
  String _priorityFilter = 'all'; // all | critical | standard
  String _statusFilter = 'open'; // open | completed

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await AuthService.instance.loadSession();
      final it =
          await AuthService.instance.fetchUsersByRole(UserRole.itStaff.apiName);
      final facilities =
          await AuthService.instance.fetchUsersByRole(UserRole.techStaff.apiName);
      final combined = <AuthRoleUser>[
        ...it,
        ...facilities.where((u) => it.every((other) => other.id != u.id)),
      ];

      final tickets = await _supportService.fetchAllRequests();
      if (!mounted) return;
      setState(() {
        _staff = combined
            .map((u) => _SupportStaffEntry(
                  id: u.id,
                  name: u.displayName,
                  roleType:
                      it.any((x) => x.id == u.id) ? StaffRoleType.it : StaffRoleType.fm,
                  roleLabel:
                      it.any((x) => x.id == u.id) ? 'IT Support' : 'Facilities',
                ))
            .toList(growable: false);
        _tickets = tickets;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  List<SupportTicket> get _filteredTickets {
    return _tickets.where((t) {
      final matchesModule = _moduleFilter == 'all' ||
          t.type.toLowerCase() == _moduleFilter.toLowerCase();
      final matchesPriority = _priorityFilter == 'all' ||
          (_priorityFilter == 'critical' &&
              t.priority == TicketPriority.critical) ||
          (_priorityFilter == 'standard' &&
              t.priority != TicketPriority.critical);
      final isCompleted = t.status == TicketStatus.completed;
      final matchesStatus = _statusFilter == 'completed' ? isCompleted : !isCompleted;
      return matchesModule && matchesPriority && matchesStatus;
    }).toList(growable: false);
  }

  int get _totalRequests => _filteredTickets.length;
  int get _unassigned =>
      _filteredTickets.where((t) => t.status == TicketStatus.newTicket).length;
  int get _inProgress =>
      _filteredTickets.where((t) => t.status == TicketStatus.inProgress).length;
  int get _completed => _tickets.where((t) => t.status == TicketStatus.completed).length;

  Future<void> _assignTicket(SupportTicket ticket) async {
    final requestId = ticket.requestId;
    if (requestId == null) {
      _snack('Ticket missing requestId.');
      return;
    }

    final staffId = await showModernSelectSheet<String>(
      context: context,
      title: 'Select staff member',
      options: _staff
          .where((s) =>
              _moduleFilter == 'all' ||
              (_moduleFilter == 'IT' && s.roleType == StaffRoleType.it) ||
              (_moduleFilter == 'FM' && s.roleType == StaffRoleType.fm))
          .map((s) => SelectOption(
                value: s.id,
                label: s.name,
                icon: s.roleType == StaffRoleType.it
                    ? Icons.computer_outlined
                    : Icons.home_repair_service_outlined,
              ))
          .toList(growable: false),
      accentColor: AppColors.primary,
    );
    if (!mounted || staffId == null) return;

    try {
      await AuthService.instance.loadSession();
      final dispatcherId = AuthService.instance.studentId;
      if (dispatcherId == null || dispatcherId.trim().isEmpty) {
        throw Exception('Authentication required.');
      }
      await _supportService.assignRequest(
        requestId: requestId,
        dispatcherId: dispatcherId,
        staffId: staffId,
        dispatcherInstructions: '',
      );
      _snack('Assigned.');
      await _load();
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Request Dispatcher',
          style: TextStyle(
            color: AppColors.gray900,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          OutlinedButton.icon(
            onPressed: _openWebStaffDirectory,
            icon: const Icon(Icons.groups_outlined, size: 18),
            label: const Text('Staff'),
          ),
          const SizedBox(width: 10),
          OutlinedButton(
            onPressed: () => setState(() => _statusFilter = 'completed'),
            child: const Text('History'),
          ),
          const SizedBox(width: 10),
          const SizedBox(width: 14),
        ],
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.cloud_off,
                              color: AppColors.gray300, size: 44),
                          const SizedBox(height: 8),
                          Text(_error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.gray700)),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: _load,
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : _buildContent(),
        ),
      ),
    );
  }

  Future<void> _openCreateTaskDialog() async {
    await AuthService.instance.loadSession();
    final dispatcherId = AuthService.instance.studentId;
    if (dispatcherId == null || dispatcherId.trim().isEmpty) {
      _snack('Authentication required.');
      return;
    }

    final staffOptions = _staff;
    String? assigneeId;
    String instructions = '';
    String module = 'IT';
    SupportLocationValue location = const SupportLocationValue(
      type: SupportLocationType.building,
    );
    String description = '';
    TicketPriority urgency = TicketPriority.standard;
    int? categoryId;
    List<SupportCategoryOption> categories = const [];
    bool saving = false;
    String? localError;

    Future<void> loadCats(StateSetter setModal) async {
      try {
        final data = await _supportService.fetchCategories(module: module);
        setModal(() {
          categories = data;
          if (categories.isNotEmpty) categoryId ??= categories.first.id;
        });
      } catch (e) {
        setModal(() => localError = e.toString().replaceFirst('Exception: ', ''));
      }
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            if (categories.isEmpty && localError == null) {
              // One-shot load.
              loadCats(setModal);
            }

            return Dialog(
              insetPadding: const EdgeInsets.all(18),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860, maxHeight: 720),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 14, 14, 6),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: saving ? null : () => Navigator.pop(ctx),
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                          const SizedBox(width: 6),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Assign New Task',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800)),
                                SizedBox(height: 2),
                                Text(
                                  'Create a new IT or Facilities task and assign it to a staff member.',
                                  style: TextStyle(
                                      fontSize: 12, color: AppColors.gray500),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (saving)
                            const Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (localError != null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFFECACA)),
                                ),
                                child: Text(localError!,
                                    style: const TextStyle(
                                        color: Color(0xFF991B1B))),
                              ),
                              const SizedBox(height: 12),
                            ],
                            _webSectionTitle('0  Assigned Staff & Instructions *'),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                SizedBox(
                                  width: 360,
                                  child: DropdownButtonFormField<String>(
                                    value: assigneeId,
                                    items: staffOptions
                                        .map((s) => DropdownMenuItem(
                                              value: s.id,
                                              child: Text(s.name),
                                            ))
                                        .toList(growable: false),
                                    onChanged: saving
                                        ? null
                                        : (v) => setModal(() => assigneeId = v),
                                    decoration: InputDecoration(
                                      labelText: 'Select staff member',
                                      filled: true,
                                      fillColor: AppColors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 440,
                                  child: TextField(
                                    enabled: !saving,
                                    onChanged: (v) => instructions = v,
                                    minLines: 2,
                                    maxLines: 3,
                                    decoration: InputDecoration(
                                      labelText:
                                          'Internal instructions or notes (optional)',
                                      filled: true,
                                      fillColor: AppColors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            _webSectionTitle('1  Issue Category *'),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 10,
                              children: [
                                ChoiceChip(
                                  selected: module == 'IT',
                                  label: const Text('IT & Network'),
                                  onSelected: saving
                                      ? null
                                      : (_) => setModal(() {
                                            module = 'IT';
                                            categories = const [];
                                            categoryId = null;
                                          }),
                                ),
                                ChoiceChip(
                                  selected: module == 'FM',
                                  label: const Text('Facilities (FM)'),
                                  onSelected: saving
                                      ? null
                                      : (_) => setModal(() {
                                            module = 'FM';
                                            categories = const [];
                                            categoryId = null;
                                          }),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: 360,
                              child: DropdownButtonFormField<int>(
                                value: categoryId,
                                items: categories
                                    .map((c) => DropdownMenuItem(
                                          value: c.id,
                                          child: Text(c.name),
                                        ))
                                    .toList(growable: false),
                                onChanged: saving
                                    ? null
                                    : (v) => setModal(() => categoryId = v),
                                decoration: InputDecoration(
                                  labelText: 'Select issue type',
                                  filled: true,
                                  fillColor: AppColors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            _webSectionTitle('2  Location *'),
                            const SizedBox(height: 8),
                            SupportLocationPicker(
                              initialValue: location,
                              accentColor: AppColors.primary,
                              onChanged: (v) => location = v,
                            ),
                            const SizedBox(height: 18),
                            _webSectionTitle('3  Detailed Description *'),
                            const SizedBox(height: 8),
                            TextField(
                              enabled: !saving,
                              minLines: 4,
                              maxLines: 6,
                              onChanged: (v) => description = v,
                              decoration: InputDecoration(
                                hintText:
                                    'Provide as much detail as possible about the task or issue...',
                                filled: true,
                                fillColor: AppColors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            _webSectionTitle('5  Urgency Level *'),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                _urgencyCard(
                                  selected: urgency != TicketPriority.critical,
                                  title: 'Standard',
                                  subtitle:
                                      'Routine work that does not affect safety or critical operations.',
                                  onTap: saving
                                      ? null
                                      : () => setModal(
                                          () => urgency = TicketPriority.standard,
                                        ),
                                ),
                                _urgencyCard(
                                  selected: urgency == TicketPriority.critical,
                                  title: 'Critical',
                                  subtitle:
                                      'Safety hazards, facility-wide outages, or issues preventing essential work.',
                                  onTap: saving
                                      ? null
                                      : () => setModal(
                                          () => urgency = TicketPriority.critical,
                                        ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      child: Row(
                        children: [
                          TextButton(
                            onPressed: saving ? null : () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          const Spacer(),
                          FilledButton(
                            onPressed: saving
                                ? null
                                : () async {
                                    if (!(location.isComplete)) {
                                      setModal(() => localError = 'Location is required.');
                                      return;
                                    }
                                    if ((description.trim()).isEmpty) {
                                      setModal(() => localError = 'Description is required.');
                                      return;
                                    }
                                    if (categoryId == null || categoryId == 0) {
                                      setModal(() => localError = 'Category is required.');
                                      return;
                                    }

                                    setModal(() {
                                      saving = true;
                                      localError = null;
                                    });
                                    try {
                                      final id = await _supportService.createRequest(
                                        memberId: dispatcherId,
                                        area: module,
                                        categoryId: categoryId!,
                                        location: location,
                                        description: description.trim(),
                                        urgency: urgency,
                                        attachmentPaths: const [],
                                      );
                                      if (id <= 0) {
                                        throw Exception('Request creation failed.');
                                      }

                                      if (instructions.trim().isNotEmpty) {
                                        await _supportService.setDispatcherInstructions(
                                          requestId: id,
                                          dispatcherId: dispatcherId,
                                          instructions: instructions.trim(),
                                        );
                                      }

                                      if (assigneeId != null &&
                                          assigneeId!.isNotEmpty) {
                                        await _supportService.assignRequest(
                                          requestId: id,
                                          dispatcherId: dispatcherId,
                                          staffId: assigneeId!,
                                          dispatcherInstructions:
                                              instructions.trim(),
                                        );
                                      }

                                      if (!mounted) return;
                                      Navigator.pop(ctx);
                                      _snack('Task created.');
                                      await _load();
                                    } catch (e) {
                                      setModal(() {
                                        localError =
                                            e.toString().replaceFirst('Exception: ', '');
                                      });
                                    } finally {
                                      setModal(() => saving = false);
                                    }
                                  },
                            child: const Text('Create Task'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openWebStaffDirectory() async {
    if (_staff.isEmpty) {
      _snack('No staff loaded.');
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        String q = '';
        String role = 'all'; // all | it | fm
        return StatefulBuilder(
          builder: (ctx, setModal) {
            final filtered = _staff.where((s) {
              final matchRole = role == 'all' ||
                  (role == 'it' && s.roleType == StaffRoleType.it) ||
                  (role == 'fm' && s.roleType == StaffRoleType.fm);
              final matchQuery =
                  q.trim().isEmpty || s.name.toLowerCase().contains(q.trim().toLowerCase());
              return matchRole && matchQuery;
            }).toList(growable: false);

            Widget chip(String id, String label) {
              final active = id == role;
              return ChoiceChip(
                selected: active,
                label: Text(label),
                onSelected: (_) => setModal(() => role = id),
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.white,
                labelStyle: TextStyle(
                  color: active ? AppColors.white : AppColors.gray700,
                  fontWeight: FontWeight.w700,
                ),
                side: BorderSide(color: AppColors.gray200),
              );
            }

            return Dialog(
              insetPadding: const EdgeInsets.all(18),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760, maxHeight: 650),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 16, 16, 12),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Staff Directory',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.gray900,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(ctx),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            onChanged: (v) => setModal(() => q = v),
                            decoration: InputDecoration(
                              hintText: 'Search staff...',
                              prefixIcon: const Icon(Icons.search_rounded),
                              filled: true,
                              fillColor: AppColors.gray50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppColors.gray200),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppColors.gray200),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            children: [
                              chip('all', 'All'),
                              chip('it', 'IT Support'),
                              chip('fm', 'Facilities'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) {
                          final s = filtered[i];

                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.gray200),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor:
                                      AppColors.primary.withValues(alpha: 0.10),
                                  child: const Icon(Icons.person,
                                      color: AppColors.primary),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        s.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.gray900,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        s.roleLabel,
                                        style: const TextStyle(
                                            fontSize: 12, color: AppColors.gray600),
                                      ),
                                    ],
                                  ),
                                ),
                                FilledButton(
                                  onPressed: () async {
                                    Navigator.pop(ctx);
                                    final tickets = _filteredTickets;
                                    if (tickets.isEmpty) {
                                      _snack('No active tickets to assign.');
                                      return;
                                    }
                                    final selectedTicket =
                                        await showModernSelectSheet<SupportTicket>(
                                      context: context,
                                      title: 'Select ticket for ${s.name}',
                                      options: tickets
                                          .map((t) => SelectOption(
                                                value: t,
                                                label: '#${t.id} • ${t.title}',
                                                icon: Icons
                                                    .confirmation_number_outlined,
                                              ))
                                          .toList(growable: false),
                                      accentColor: AppColors.primary,
                                    );
                                    if (!mounted || selectedTicket == null) return;
                                    await _assignTicket(selectedTicket);
                                  },
                                  child: const Text('Assign'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _webSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: AppColors.gray900,
      ),
    );
  }

  Widget _urgencyCard({
    required bool selected,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    return SizedBox(
      width: 360,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary.withValues(alpha: 0.06) : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.gray200,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, color: AppColors.gray900)),
              const SizedBox(height: 6),
              Text(subtitle,
                  style: const TextStyle(fontSize: 12, color: AppColors.gray600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(
            'Central dashboard for IT and Facilities tickets across campus.',
            style: TextStyle(color: AppColors.gray600),
          ),
          const SizedBox(height: 16),
          _statsRow(),
          const SizedBox(height: 18),
          _filtersRow(),
          const SizedBox(height: 12),
          _ticketsTable(),
        ],
      ),
    );
  }

  Widget _statsRow() {
    Widget card(IconData icon, String label, String value, Color color, String sub) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.gray200),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            color: AppColors.gray600,
                            fontWeight: FontWeight.w600,
                            fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(value,
                        style: const TextStyle(
                            color: AppColors.gray900,
                            fontWeight: FontWeight.w800,
                            fontSize: 20)),
                    const SizedBox(height: 2),
                    Text(sub,
                        style: const TextStyle(
                            color: AppColors.gray500, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        card(Icons.receipt_long_outlined, 'Total Requests', '$_totalRequests',
            AppColors.primary, 'Shown in current view'),
        const SizedBox(width: 12),
        card(Icons.priority_high_rounded, 'Unassigned', '$_unassigned',
            Colors.orange, 'Needs assignment'),
        const SizedBox(width: 12),
        card(Icons.timelapse_rounded, 'In Progress', '$_inProgress', Colors.indigo,
            'Currently active'),
        const SizedBox(width: 12),
        card(Icons.check_circle_outline, 'Completed', '$_completed', Colors.green,
            'Closed in history'),
      ],
    );
  }

  Widget _filtersRow() {
    Widget chip(String id, String label, String group, void Function(String) set) {
      final active = id == group;
      return ChoiceChip(
        selected: active,
        label: Text(label),
        onSelected: (_) => set(id),
        selectedColor: AppColors.gray900,
        backgroundColor: AppColors.white,
        labelStyle: TextStyle(
          color: active ? AppColors.white : AppColors.gray700,
          fontWeight: FontWeight.w700,
        ),
        side: BorderSide(color: AppColors.gray200),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        chip('all', 'All Tickets', _moduleFilter, (v) => setState(() => _moduleFilter = v)),
        chip('IT', 'IT Only', _moduleFilter, (v) => setState(() => _moduleFilter = v)),
        chip('FM', 'FM Only', _moduleFilter, (v) => setState(() => _moduleFilter = v)),
        chip('high', 'High Priority', _priorityFilter, (v) => setState(() => _priorityFilter = v)),
        const SizedBox(width: 14),
        DropdownButton<String>(
          value: _statusFilter,
          items: const [
            DropdownMenuItem(value: 'open', child: Text('All Open')),
            DropdownMenuItem(value: 'completed', child: Text('Completed')),
          ],
          onChanged: (v) => setState(() => _statusFilter = v ?? 'open'),
        ),
      ],
    );
  }

  Widget _ticketsTable() {
    final rows = _filteredTickets;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gray200),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Request Details')),
            DataColumn(label: Text('Location')),
            DataColumn(label: Text('Priority')),
            DataColumn(label: Text('Dispatcher Action')),
          ],
          rows: rows.map((t) {
            final pr =
                t.priority == TicketPriority.critical ? 'Critical' : 'Standard';
            final prColor =
                t.priority == TicketPriority.critical ? Colors.red : Colors.green;
            return DataRow(cells: [
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${t.type} • #${t.id}',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.gray500)),
                    const SizedBox(height: 2),
                    Text(t.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.gray900)),
                  ],
                ),
              ),
              DataCell(Text(t.location.isEmpty ? 'Location not specified' : t.location)),
              DataCell(
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: prColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(pr,
                      style: TextStyle(
                          color: prColor, fontWeight: FontWeight.w700, fontSize: 12)),
                ),
              ),
              DataCell(
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () => _assignTicket(t),
                      child: const Text('Select Technician'),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: () => _assignTicket(t),
                      child: const Text('Confirm →'),
                    ),
                  ],
                ),
              ),
            ]);
          }).toList(growable: false),
        ),
      ),
    );
  }
}

class DispatcherHistoryScreen extends StatefulWidget {
  const DispatcherHistoryScreen({super.key, required this.tickets});

  final List<SupportTicket> tickets;

  @override
  State<DispatcherHistoryScreen> createState() => _DispatcherHistoryScreenState();
}

class _DispatcherHistoryScreenState extends State<DispatcherHistoryScreen>
    with SingleTickerProviderStateMixin {
  int _period = 1; // 0=7d, 1=30d, 2=3m, 3=custom

  DateTime? _cutoff() {
    final now = DateTime.now();
    switch (_period) {
      case 0:
        return now.subtract(const Duration(days: 7));
      case 1:
        return now.subtract(const Duration(days: 30));
      case 2:
        return DateTime(now.year, now.month - 3, now.day);
      default:
        return null;
    }
  }

  DateTime? _closedAt(SupportTicket t) {
    final raw = t.completedAt ?? t.createdAt;
    return DateTime.tryParse(raw)?.toLocal();
  }

  List<SupportTicket> _filtered(String tab) {
    final cutoff = _cutoff();
    final closed = widget.tickets.where((t) =>
        t.status == TicketStatus.completed || t.status == TicketStatus.cancelled);

    final byTab = closed.where((t) {
      if (tab == 'completed') return t.status == TicketStatus.completed;
      if (tab == 'cancelled') return t.status == TicketStatus.cancelled;
      return true; // all
    });

    final byTime = byTab.where((t) {
      if (cutoff == null) return true;
      final when = _closedAt(t);
      return when == null || !when.isBefore(cutoff);
    }).toList(growable: false);

    byTime.sort((a, b) {
      final ad = _closedAt(a)?.millisecondsSinceEpoch ?? 0;
      final bd = _closedAt(b)?.millisecondsSinceEpoch ?? 0;
      return bd.compareTo(ad);
    });
    return byTime;
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const Text(
            'Dispatcher History',
            style: TextStyle(
              color: AppColors.gray900,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          bottom: const TabBar(
            dividerColor: Colors.transparent,
            tabs: [
              Tab(text: 'All Closed'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Time period',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gray600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Row(
                  children: [
                    _periodChip('Last 7 days', 0),
                    const SizedBox(width: 8),
                    _periodChip('Last 30 days', 1),
                    const SizedBox(width: 8),
                    _periodChip('Last 3 months', 2),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _HistoryList(items: _filtered('all'), closedAt: _closedAt),
                    _HistoryList(
                        items: _filtered('completed'), closedAt: _closedAt),
                    _HistoryList(
                        items: _filtered('cancelled'), closedAt: _closedAt),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _periodChip(String label, int index) {
    final active = _period == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _period = index),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF111827) : AppColors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active ? const Color(0xFF111827) : AppColors.gray200,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: active ? AppColors.white : AppColors.gray600,
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.items, required this.closedAt});

  final List<SupportTicket> items;
  final DateTime? Function(SupportTicket) closedAt;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.history_rounded, size: 44, color: AppColors.gray300),
              const SizedBox(height: 10),
              const Text(
                'No tickets for this period',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final dateFmt = DateFormat('d MMM yyyy • HH:mm');

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final t = items[i];
        final isCompleted = t.status == TicketStatus.completed;
        final pillColor =
            isCompleted ? const Color(0xFF059669) : const Color(0xFFDC2626);
        final closed = closedAt(t);
        final closedStr = closed != null ? dateFmt.format(closed) : '';

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TicketDetailView(
                    ticket: t,
                    showContactStaffAction: true,
                    showCancelAction: false,
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.gray200),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${t.type} SUPPORT',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.gray500,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          t.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.gray900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.place_outlined,
                                size: 16, color: AppColors.gray400),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                t.location.isEmpty
                                    ? 'Location not specified'
                                    : t.location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.gray500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (closedStr.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.access_time_rounded,
                                  size: 16, color: AppColors.gray400),
                              const SizedBox(width: 6),
                              Text(
                                closedStr,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.gray500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: pillColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      t.statusString,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: pillColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
