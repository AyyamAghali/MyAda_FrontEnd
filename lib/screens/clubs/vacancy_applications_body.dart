import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/constants.dart';
import '../../widgets/responsive_container.dart';

class _MockApp {
  final String id;
  final String position;
  final String clubName;
  final String status;
  final String appliedOn;

  const _MockApp({
    required this.id,
    required this.position,
    required this.clubName,
    required this.status,
    required this.appliedOn,
  });
}

/// Shared list UI for vacancy applications (hub "My Clubs" tab and optional standalone screen).
class VacancyApplicationsBody extends StatelessWidget {
  final String? filterClubName;
  final bool showBrowseVacanciesAction;
  final VoidCallback? onBrowseOpenings;

  const VacancyApplicationsBody({
    super.key,
    this.filterClubName,
    this.showBrowseVacanciesAction = false,
    this.onBrowseOpenings,
  });

  static const _apps = [
    _MockApp(
      id: 'APP-001',
      position: 'Media & Content Creator',
      clubName: 'Campus Media Club',
      status: 'Under Review',
      appliedOn: '2024-03-01',
    ),
    _MockApp(
      id: 'APP-002',
      position: 'Finance Officer',
      clubName: 'Business Leaders Society',
      status: 'Submitted',
      appliedOn: '2024-02-25',
    ),
    _MockApp(
      id: 'APP-003',
      position: 'Events Coordinator',
      clubName: 'Student Activities Board',
      status: 'Accepted',
      appliedOn: '2024-02-10',
    ),
  ];

  static Color statusColor(String s) {
    if (s == 'Accepted') return const Color(0xFF16A34A);
    if (s == 'Under Review') return const Color(0xFFF59E0B);
    if (s == 'Submitted') return const Color(0xFF2563EB);
    return AppColors.gray500;
  }

  List<_MockApp> _appsForScope(String? clubName) {
    if (clubName == null || clubName.isEmpty) return _apps;
    final n = clubName.toLowerCase();
    return _apps.where((a) => a.clubName.toLowerCase() == n).toList();
  }

  @override
  Widget build(BuildContext context) {
    final scoped = filterClubName;
    final apps = _appsForScope(scoped);
    return ResponsiveContainer(
      backgroundColor: ClubUiColors.pageBg,
      child: apps.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  scoped != null
                      ? 'You have no applications for this club yet.\nOpen the Openings tab to apply.'
                      : 'No applications to show.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (showBrowseVacanciesAction && onBrowseOpenings != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: onBrowseOpenings,
                      icon: const Icon(Icons.work_outline, size: 18),
                      label: const Text('Browse openings'),
                    ),
                  ),
                Text(
                  scoped != null ? 'This club' : 'All clubs',
                  style: const TextStyle(
                    fontSize: 11,
                    letterSpacing: 0.06,
                    color: AppColors.gray500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${apps.length} application${apps.length == 1 ? '' : 's'}',
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 12),
                if (scoped == null)
                  const Text(
                    'Track the status of vacancies you applied to.',
                    style: TextStyle(color: Color(0xFF64748B), height: 1.45),
                  ),
                if (scoped == null) const SizedBox(height: 20),
                if (scoped != null) const SizedBox(height: 8),
                ...apps.map((a) => _AppCard(app: a, statusColor: VacancyApplicationsBody.statusColor(a.status))),
              ],
            ),
    );
  }
}

class _AppCard extends StatelessWidget {
  final _MockApp app;
  final Color statusColor;

  const _AppCard({required this.app, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    final d = DateTime.parse(app.appliedOn);
    final formatted = DateFormat.yMMMd().format(d);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.work_outline, color: Color(0xFF2563EB)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          app.position,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          app.status,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(app.clubName, style: const TextStyle(color: Color(0xFF64748B))),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 14, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 6),
                      Text('Applied on $formatted', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Application ID: ${app.id}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
