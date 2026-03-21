import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/clubs/clubs_top_nav.dart';
import '../../widgets/responsive_container.dart';
import 'club_module_nav.dart';
import 'clubs_home.dart';
import 'my_memberships.dart';

/// Mirrors web `ClubNotifications.jsx` (simplified content).
class ClubNotificationsScreen extends StatefulWidget {
  const ClubNotificationsScreen({super.key});

  @override
  State<ClubNotificationsScreen> createState() => _ClubNotificationsScreenState();
}

class _ClubNotificationsScreenState extends State<ClubNotificationsScreen> {
  String _tab = 'all';

  static const _tabs = [
    ('all', 'All'),
    ('proposals', 'Proposals'),
    ('membership', 'Membership'),
    ('vacancies', 'Vacancies'),
    ('events', 'Events'),
  ];

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
                active: ClubsNavSection.none,
                onVacanciesTap: () => ClubModuleNav.openVacancies(context),
                onMyApplicationsTap: () => ClubModuleNav.openMyVacancyApplications(context),
                onEventsTap: () => ClubModuleNav.openEvents(context),
                onClubsTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(builder: (_) => const ClubsHome()),
                  );
                },
                onProposeTap: () => ClubModuleNav.openProposeClub(context),
                onNotificationsTap: () {},
                onProfileTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(builder: (_) => const MyMemberships()),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notification Center',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Club proposals, membership, applications, and campus events.',
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _tabs.map((t) {
                          final sel = _tab == t.$1;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(t.$2),
                              selected: sel,
                              onSelected: (_) => setState(() => _tab = t.$1),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    if (_show('proposals'))
                      _notifCard(
                        title: 'Your proposal for ADA Robotics has been approved!',
                        body:
                            'Your club proposal completed all reviews. You can configure your club dashboard and schedule events.',
                        pill: 'Club Proposals',
                        pillColor: const Color(0xFF2563EB),
                        time: '2 hours ago',
                      ),
                    if (_show('proposals'))
                      _notifCard(
                        title: 'Revision requested for club constitution',
                        body: 'Please upload an updated constitution document with section 3 clarified.',
                        pill: 'Club Proposals',
                        pillColor: const Color(0xFFF59E0B),
                        time: '5 hours ago',
                      ),
                    if (_show('membership'))
                      _notifCard(
                        title: 'Membership approved',
                        body: 'You are now an active member of ADA Photo Club.',
                        pill: 'Membership',
                        pillColor: const Color(0xFF16A34A),
                        time: '5 hours ago',
                      ),
                    if (_show('vacancies'))
                      _notifCard(
                        title: 'Interview scheduled',
                        body: 'Your vacancy application — review the time slot in your email.',
                        pill: 'Vacancies',
                        pillColor: const Color(0xFF8B5CF6),
                        time: 'Yesterday',
                      ),
                    if (_show('events'))
                      _notifCard(
                        title: 'Event reminder',
                        body: 'Open Mic Night starts at 7:00 PM tonight at the Student Lounge.',
                        pill: 'Events',
                        pillColor: const Color(0xFF4F46E5),
                        time: 'Today',
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _show(String type) {
    if (_tab == 'all') return true;
    return _tab == type;
  }

  Widget _notifCard({
    required String title,
    required String body,
    required String pill,
    required Color pillColor,
    required String time,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: pillColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    pill,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: pillColor),
                  ),
                ),
                const Spacer(),
                Text(time, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
              ],
            ),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
            const SizedBox(height: 6),
            Text(body, style: const TextStyle(height: 1.45, color: Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }
}
