import 'package:flutter/material.dart';
import '../../utils/constants.dart';

// ════════════════════════════════════════════════════════════════════
// Data model
// ════════════════════════════════════════════════════════════════════

enum ApplicationStatus { underReview, submitted, accepted, rejected }

class ApplicationModel {
  final String id;
  final String position;
  final String clubName;
  final ApplicationStatus status;
  final DateTime appliedOn;

  const ApplicationModel({
    required this.id,
    required this.position,
    required this.clubName,
    required this.status,
    required this.appliedOn,
  });
}

final _mockApplications = [
  ApplicationModel(
    id: 'APP-001',
    position: 'Media & Content Creator',
    clubName: 'Campus Media Club',
    status: ApplicationStatus.underReview,
    appliedOn: DateTime(2024, 3, 1),
  ),
  ApplicationModel(
    id: 'APP-002',
    position: 'Finance Officer',
    clubName: 'Business Leaders Society',
    status: ApplicationStatus.submitted,
    appliedOn: DateTime(2024, 2, 25),
  ),
  ApplicationModel(
    id: 'APP-003',
    position: 'Events Coordinator',
    clubName: 'Student Activities Board',
    status: ApplicationStatus.accepted,
    appliedOn: DateTime(2024, 2, 10),
  ),
];

// ════════════════════════════════════════════════════════════════════
// Screen
// ════════════════════════════════════════════════════════════════════

class MyApplicationsScreen extends StatelessWidget {
  const MyApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.gray900,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Applications',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.gray200, height: 1),
        ),
      ),
      body: _mockApplications.isEmpty
          ? _buildEmpty()
          : CustomScrollView(
              slivers: [
                // ── Summary strip ─────────────────────────────────
                SliverToBoxAdapter(
                  child: Container(
                    color: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_mockApplications.length} total application${_mockApplications.length == 1 ? '' : 's'}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.gray500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildStatusSummary(),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
                // ── Application cards ─────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ApplicationCard(
                            application: _mockApplications[i]),
                      ),
                      childCount: _mockApplications.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
    );
  }

  Widget _buildStatusSummary() {
    final accepted = _mockApplications
        .where((a) => a.status == ApplicationStatus.accepted)
        .length;
    final underReview = _mockApplications
        .where((a) => a.status == ApplicationStatus.underReview)
        .length;
    final submitted = _mockApplications
        .where((a) => a.status == ApplicationStatus.submitted)
        .length;

    return Row(
      children: [
        _StatusStat(
          count: accepted,
          label: 'Accepted',
          color: const Color(0xFF22c55e),
          icon: Icons.check_circle_outline,
        ),
        const SizedBox(width: 10),
        _StatusStat(
          count: underReview,
          label: 'In Review',
          color: const Color(0xFFf59e0b),
          icon: Icons.hourglass_bottom_outlined,
        ),
        const SizedBox(width: 10),
        _StatusStat(
          count: submitted,
          label: 'Submitted',
          color: AppColors.primary,
          icon: Icons.send_outlined,
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 64, color: AppColors.gray300),
          SizedBox(height: 16),
          Text(
            'No applications yet',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Browse open vacancies and apply\nto positions you\'re interested in.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.gray500),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// Application card
// ════════════════════════════════════════════════════════════════════

class _ApplicationCard extends StatelessWidget {
  final ApplicationModel application;

  const _ApplicationCard({required this.application});

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig(application.status);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gray200, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Briefcase icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.work_outline,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application.position,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gray900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        application.clubName,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.gray600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status pill
                _StatusPill(config: config),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.gray100),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 13, color: AppColors.gray400),
                const SizedBox(width: 5),
                Text(
                  'Applied ${_formatDate(application.appliedOn)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.gray500,
                  ),
                ),
                const Spacer(),
                Text(
                  application.id,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.gray400,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

// ════════════════════════════════════════════════════════════════════
// Status helpers
// ════════════════════════════════════════════════════════════════════

class _StatusConfig {
  final String label;
  final Color color;
  final IconData icon;

  const _StatusConfig({
    required this.label,
    required this.color,
    required this.icon,
  });
}

_StatusConfig _statusConfig(ApplicationStatus status) {
  switch (status) {
    case ApplicationStatus.accepted:
      return const _StatusConfig(
        label: 'Accepted',
        color: Color(0xFF22c55e),
        icon: Icons.check_circle_outline,
      );
    case ApplicationStatus.underReview:
      return const _StatusConfig(
        label: 'Under Review',
        color: Color(0xFFf59e0b),
        icon: Icons.hourglass_bottom_outlined,
      );
    case ApplicationStatus.submitted:
      return const _StatusConfig(
        label: 'Submitted',
        color: AppColors.primary,
        icon: Icons.send_outlined,
      );
    case ApplicationStatus.rejected:
      return const _StatusConfig(
        label: 'Rejected',
        color: Color(0xFFef4444),
        icon: Icons.cancel_outlined,
      );
  }
}

class _StatusPill extends StatelessWidget {
  final _StatusConfig config;
  const _StatusPill({required this.config});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 12, color: config.color),
          const SizedBox(width: 5),
          Text(
            config.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: config.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusStat extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  final IconData icon;

  const _StatusStat({
    required this.count,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
