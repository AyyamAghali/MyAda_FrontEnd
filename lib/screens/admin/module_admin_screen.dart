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
    if (value.contains('room') || value.contains('reservation')) {
      return AdminModule.room;
    }
    if (value.contains('attendance')) {
      return AdminModule.attendance;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
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
