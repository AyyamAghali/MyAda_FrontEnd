import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../models/club.dart';
import '../../utils/constants.dart';
import '../../widgets/responsive_container.dart';
import '../../widgets/clubs/clubs_top_nav.dart';
import 'join_club_sheet.dart';
import 'event_registration.dart';
import 'clubs_home.dart';
import 'club_module_nav.dart';
import 'my_memberships.dart';

/// Club profile — aligned with MyAda_Front_Web `ClubDetail.jsx` (hero, tabs, sidebar content folded into scroll).
class ClubDetails extends StatefulWidget {
  final Club club;

  const ClubDetails({super.key, required this.club});

  @override
  State<ClubDetails> createState() => _ClubDetailsState();
}

class _ClubDetailsState extends State<ClubDetails> {
  int _tabIndex = 0;

  static const _tabs = ['About Us', 'Activities', 'Members', 'Resources'];

  Club get club => widget.club;

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  List<ClubEvent> get _upcomingEvents {
    return club.events.where((event) {
      final eventDate = DateTime.parse(event.date);
      return eventDate.isAfter(DateTime.now()) || eventDate.isAtSameMomentAs(DateTime.now());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClubUiColors.pageBg,
      body: SafeArea(
        bottom: false,
        child: ResponsiveContainer(
          backgroundColor: ClubUiColors.pageBg,
          child: Column(
            children: [
              ClubsTopNav(
                active: ClubsNavSection.clubs,
                onVacanciesTap: () => ClubModuleNav.openVacancies(context),
                onMyApplicationsTap: () => ClubModuleNav.openMyVacancyApplications(context),
                onEventsTap: () => ClubModuleNav.openEvents(context),
                onClubsTap: () => Navigator.pop(context),
                onProposeTap: () => ClubModuleNav.openProposeClub(context),
                onNotificationsTap: () => ClubModuleNav.openNotifications(context),
                onProfileTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(builder: (_) => const MyMemberships()),
                  );
                },
                onLogoTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const ClubsHome()),
                    (route) => route.isFirst,
                  );
                },
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHero(context),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildTabs(context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomButton(context),
    );
  }

  Widget _buildHero(BuildContext context) {
    final bannerUrl = club.banner.isNotEmpty ? club.banner : club.logo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 220,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: bannerUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: AppColors.gray300),
                errorWidget: (_, __, ___) => Container(
                  color: const Color(0xFF0EA5E9),
                  child: const Icon(Icons.groups, size: 64, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -40),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Material(
              elevation: 6,
              shadowColor: Colors.black26,
              borderRadius: BorderRadius.circular(16),
              color: AppColors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: club.logo,
                            width: 88,
                            height: 88,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Container(
                              width: 88,
                              height: 88,
                              color: AppColors.gray200,
                              child: const Icon(Icons.groups),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                club.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: ClubUiColors.ctaBlue,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  club.category,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 12,
                                runSpacing: 8,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.people_outline, size: 18, color: ClubNavColors.link),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${club.memberCount} Members',
                                        style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                                      ),
                                    ],
                                  ),
                                  if (club.establishedYear != null)
                                    Text(
                                      'Est. ${club.establishedYear}',
                                      style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                                    ),
                                  if (club.location != null && club.location!.isNotEmpty)
                                    SizedBox(
                                      width: double.infinity,
                                      child: Text(
                                        club.location!,
                                        style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => JoinClubSheet(club: club),
                                ),
                              );
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: ClubUiColors.ctaBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.add, size: 20),
                            label: const Text('Join Club', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _toast(context, 'Follow — prototype only.'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF334155),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.star_outline, size: 20),
                            label: const Text('Follow', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildTabs(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 2)),
          ),
          child: Row(
            children: List.generate(_tabs.length, (i) {
              final active = _tabIndex == i;
              return Expanded(
                child: InkWell(
                  onTap: () => setState(() => _tabIndex = i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: active ? ClubNavColors.activeText : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      _tabs[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: active ? ClubNavColors.activeText : ClubNavColors.link,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 20),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: KeyedSubtree(
            key: ValueKey<int>(_tabIndex),
            child: _tabBody(context),
          ),
        ),
      ],
    );
  }

  Widget _tabBody(BuildContext context) {
    switch (_tabIndex) {
      case 0:
        return _buildAboutTab(context);
      case 1:
        return _buildActivitiesTab(context);
      case 2:
        return _buildMembersTab(context);
      default:
        return _buildResourcesTab(context);
    }
  }

  Widget _buildAboutTab(BuildContext context) {
    final tags = club.tags;
    return Column(
      key: const ValueKey('about'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Our Mission',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          club.about,
          style: const TextStyle(
            fontSize: 15,
            height: 1.5,
            color: Color(0xFF475569),
          ),
        ),
        if (tags.length >= 2) ...[
          const SizedBox(height: 24),
          const Text(
            'Key Focus Areas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(2, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      i == 0 ? Icons.dashboard_customize_outlined : Icons.code_outlined,
                      color: ClubNavColors.activeText,
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tags[i],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Explore activities and projects around ${tags[i].toLowerCase()} with the club community.',
                      style: const TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
        if (club.officers.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Text(
            'Club Officers',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          ...club.officers.map((o) => _officerRow(o)),
        ],
        const SizedBox(height: 24),
        const Text(
          'Contact',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Reach the club leadership via official ADA channels or the email shared during onboarding.',
          style: TextStyle(fontSize: 14, height: 1.45, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  Widget _officerRow(ClubOfficer o) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage: CachedNetworkImageProvider(o.photo),
            onBackgroundImageError: (_, __) {},
            child: const SizedBox.shrink(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  o.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  o.role,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesTab(BuildContext context) {
    final events = _upcomingEvents;
    return Column(
      key: const ValueKey('activities'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (events.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'No upcoming events scheduled.',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          )
        else
          ...events.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildEventCard(context, e),
              )),
      ],
    );
  }

  Widget _buildMembersTab(BuildContext context) {
    return const Column(
      key: ValueKey('members'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Member directory and roles will appear here.',
          style: TextStyle(color: Color(0xFF64748B), height: 1.5),
        ),
      ],
    );
  }

  Widget _buildResourcesTab(BuildContext context) {
    return const Column(
      key: ValueKey('resources'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resources and documents shared by the club will appear here.',
          style: TextStyle(color: Color(0xFF64748B), height: 1.5),
        ),
      ],
    );
  }

  Widget _buildEventCard(BuildContext context, ClubEvent event) {
    final date = DateTime.parse(event.date);
    final month = DateFormat('MMM').format(date);
    final day = date.day.toString();

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventRegistration(event: event, clubName: club.name),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [ClubUiColors.ctaBlue, Color(0xFF1D4ED8)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    month.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    day,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (event.time != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${event.time} · ${event.location}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.gray200)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JoinClubSheet(club: club),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: ClubUiColors.ctaBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Join Club',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
