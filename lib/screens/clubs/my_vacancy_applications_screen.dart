import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/constants.dart';
import '../../widgets/clubs/clubs_top_nav.dart';
import '../../widgets/responsive_container.dart';
import 'club_module_nav.dart';
import 'clubs_home.dart';
import 'my_memberships.dart';

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

/// Mirrors web `MyVacancyApplications.jsx`.
class MyVacancyApplicationsScreen extends StatelessWidget {
  const MyVacancyApplicationsScreen({super.key});

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

  Color _statusColor(String s) {
    if (s == 'Accepted') return const Color(0xFF16A34A);
    if (s == 'Under Review') return const Color(0xFFF59E0B);
    if (s == 'Submitted') return const Color(0xFF2563EB);
    return AppColors.gray500;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClubUiColors.pageBg,
      body: SafeArea(
        child: ResponsiveContainer(
          backgroundColor: ClubUiColors.pageBg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.gray700),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              ClubsTopNav(
                active: ClubsNavSection.myApplications,
                onVacanciesTap: () => ClubModuleNav.openVacancies(context),
                onMyApplicationsTap: () {},
                onEventsTap: () => ClubModuleNav.openEvents(context),
                onClubsTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(builder: (_) => const ClubsHome()),
                  );
                },
                onProposeTap: () => ClubModuleNav.openProposeClub(context),
                onNotificationsTap: () => ClubModuleNav.openNotifications(context),
                onProfileTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(builder: (_) => const MyMemberships()),
                  );
                },
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      'DASHBOARD / APPLICATIONS',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 0.08,
                        color: AppColors.gray500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'My Applications',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_apps.length} total applications',
                      style: const TextStyle(color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Track the status of the club vacancies you\'ve applied to across campus.',
                      style: TextStyle(color: Color(0xFF64748B), height: 1.45),
                    ),
                    const SizedBox(height: 20),
                    ..._apps.map((a) => _AppCard(app: a, statusColor: _statusColor(a.status))),
                  ],
                ),
              ),
            ],
          ),
        ),
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
