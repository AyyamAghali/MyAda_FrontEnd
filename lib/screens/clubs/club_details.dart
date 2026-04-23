import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/club.dart';
import '../../services/club_api_service.dart';
import '../../utils/constants.dart';
import '../../widgets/responsive_container.dart';
import 'join_club_sheet.dart';
import 'event_registration.dart';
import 'club_hub_deep_link.dart';
import 'club_module_nav.dart';

/// Club profile — single hero image, about + goals, inline events, contact email, join flow.
class ClubDetails extends StatefulWidget {
  final Club club;

  const ClubDetails({super.key, required this.club});

  @override
  State<ClubDetails> createState() => _ClubDetailsState();
}

class _ClubDetailsState extends State<ClubDetails> {
  Club get club => widget.club;
  final ClubApiService _api = ClubApiService();
  int _openRolesCount = 0;
  List<Map<String, dynamic>> _members = [];
  bool _isMember = false;

  @override
  void initState() {
    super.initState();
    _loadVacancyCount();
    _loadMembers();
    _checkMembership();
  }

  Future<void> _loadVacancyCount() async {
    try {
      final id = int.tryParse(club.id);
      if (id == null) return;
      final vacancies = await _api.fetchVacancies(clubId: id);
      if (mounted) setState(() => _openRolesCount = vacancies.length);
    } catch (_) {}
  }

  Future<void> _loadMembers() async {
    try {
      final members = await _api.fetchClubMembers(club.id);
      if (mounted) setState(() => _members = members);
    } catch (_) {}
  }

  Future<void> _checkMembership() async {
    try {
      final memberships = await _api.fetchMyMemberships();
      final found = memberships.any((m) {
        final cid = (m['clubId'] ?? '').toString();
        final status = (m['status'] ?? '').toString().toLowerCase();
        return cid == club.id && (status == 'active' || status == 'approved');
      });
      if (mounted) setState(() => _isMember = found);
    } catch (_) {}
  }

  String get _heroImageUrl => club.banner.isNotEmpty ? club.banner : club.logo;

  List<ClubEvent> get _upcomingEvents {
    return club.events.where((event) {
      final d = DateTime.tryParse(event.date);
      if (d == null) return true;
      return d.isAfter(DateTime.now()) || d.isAtSameMomentAs(DateTime.now());
    }).toList();
  }

  Future<void> _openEmail(String? email) async {
    if (email == null || email.trim().isEmpty) return;
    final uri = Uri.parse('mailto:${email.trim()}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

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
        title: Text(
          club.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.gray900,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_outlined),
            color: AppColors.gray700,
            onPressed: () => ClubModuleNav.openNotifications(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.gray200, height: 1),
        ),
      ),
      body: ResponsiveContainer(
        backgroundColor: AppColors.backgroundLight,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHero(context),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 4),
                    if (!_isMember) _buildJoinCta(context),
                    if (_isMember) _buildMemberBadge(),
                    const SizedBox(height: 20),
                    _buildMetaChips(),
                    const SizedBox(height: 24),
                    _sectionHeading('About'),
                    const SizedBox(height: 10),
                    Text(
                      club.effectiveShortDescription,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.55,
                        color: AppColors.gray700,
                      ),
                    ),
                    if (club.mainGoals != null && club.mainGoals!.trim().isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _sectionHeading('Main goals'),
                      const SizedBox(height: 10),
                      Text(
                        club.mainGoals!.trim(),
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.55,
                          color: AppColors.gray700,
                        ),
                      ),
                    ],
                    if (club.officers.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _sectionHeading('Leadership'),
                      const SizedBox(height: 12),
                      ...club.officers.map((o) => _officerRow(o)),
                    ],
                    if (_members.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _sectionHeading('Members (${_members.length})'),
                      const SizedBox(height: 12),
                      ..._members.take(10).map((m) => _memberRow(m)),
                      if (_members.length > 10)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text('+ ${_members.length - 10} more members',
                            style: const TextStyle(fontSize: 13, color: AppColors.gray500)),
                        ),
                    ],
                    const SizedBox(height: 24),
                    _sectionHeading('Events'),
                    const SizedBox(height: 6),
                    Text(
                      'Upcoming activities hosted by this club.',
                      style: TextStyle(fontSize: 13, color: AppColors.gray500),
                    ),
                    const SizedBox(height: 12),
                    _buildEventsBlock(context),
                    if (_openRolesCount > 0) ...[
                      const SizedBox(height: 24),
                      _sectionHeading('Vacancies'),
                      const SizedBox(height: 10),
                      _buildVacanciesCard(context),
                    ],
                    const SizedBox(height: 24),
                    _sectionHeading('Contact'),
                    const SizedBox(height: 10),
                    _buildContactCard(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      child: SizedBox(
        height: 220,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              _heroImageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(color: AppColors.gray200);
              },
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.primary,
                child: const Icon(Icons.groups, size: 64, color: AppColors.white),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.75),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      club.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        club.category,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinCta(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -18),
      child: Material(
        elevation: 4,
        shadowColor: Colors.black26,
        borderRadius: BorderRadius.circular(14),
        color: AppColors.white,
        child: Padding(
          padding: const EdgeInsets.all(14),
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
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_add_outlined, size: 20),
                SizedBox(width: 8),
                Text('Join club', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetaChips() {
    final chips = <Widget>[];
    if (club.establishedYear != null) {
      chips.add(_metaChip(Icons.flag_outlined, 'Est. ${club.establishedYear}'));
    }
    if (club.location != null && club.location!.isNotEmpty) {
      chips.add(_metaChip(Icons.place_outlined, club.location!));
    }
    chips.add(_metaChip(Icons.groups_outlined, '${club.memberCount} members'));
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips,
    );
  }

  Widget _metaChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.gray700),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeading(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppColors.gray900,
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _officerRow(ClubOfficer o) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.gray100,
            child: ClipOval(
              child: Image.network(
                o.photo,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.person,
                  size: 20,
                  color: AppColors.gray400,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  o.name,
                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.gray900),
                ),
                Text(
                  o.role,
                  style: const TextStyle(fontSize: 13, color: AppColors.gray500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsBlock(BuildContext context) {
    final events = _upcomingEvents;
    if (events.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Column(
          children: [
            Icon(Icons.event_available_outlined, size: 40, color: AppColors.gray400),
            const SizedBox(height: 10),
            Text(
              'No upcoming events yet.',
              style: TextStyle(fontSize: 14, color: AppColors.gray500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return Column(
      children: events
          .map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildEventCard(context, e),
              ))
          .toList(),
    );
  }

  Widget _buildContactCard(BuildContext context) {
    final email = club.contactEmail;
    if (email == null || email.trim().isEmpty) {
      return Text(
        'Contact details will be shared by the club.',
        style: TextStyle(fontSize: 14, height: 1.45, color: AppColors.gray500),
      );
    }
    final trimmed = email.trim();
    const iconColW = 44.0;
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => _openEmail(trimmed),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.gray200),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 26),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: iconColW,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.email_outlined, color: AppColors.primary, size: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Club email',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.gray500),
                          ),
                          const SizedBox(height: 6),
                          SelectableText(
                            trimmed,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Positioned(
                top: 0,
                right: 0,
                child: Icon(Icons.open_in_new, size: 18, color: AppColors.gray400),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVacanciesCard(BuildContext context) {
    final n = _openRolesCount;
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {
          final id = int.tryParse(club.id);
          Navigator.pop(
            context,
            ClubHubDeepLink(
              tabIndex: ClubHubTabs.openings,
              clubId: id,
              clubName: club.name,
            ),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.gray200),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.work_outline, color: AppColors.secondary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Browse openings',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.gray900),
                    ),
                    Text(
                      n == 1 ? '1 vacancy' : '$n vacancies',
                      style: const TextStyle(fontSize: 13, color: AppColors.gray500),
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

  Widget _buildMemberBadge() {
    return Transform.translate(
      offset: const Offset(0, -18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF059669).withValues(alpha: 0.3)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 20, color: Color(0xFF059669)),
            SizedBox(width: 8),
            Text('You are a member', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF059669))),
          ],
        ),
      ),
    );
  }

  Widget _memberRow(Map<String, dynamic> m) {
    final name = (m['name'] ?? m['fullName'] ?? m['userName'] ?? 'Member').toString();
    final role = (m['role'] ?? m['position'] ?? '').toString();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.gray100,
            child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.gray900)),
                if (role.isNotEmpty) Text(role, style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, ClubEvent event) {
    final rawDate = event.date;
    final trimmed = rawDate.length >= 10 ? rawDate.substring(0, 10) : rawDate;
    final date = DateTime.tryParse(trimmed) ?? DateTime.tryParse(rawDate);
    final month = date != null ? DateFormat('MMM').format(date) : '';
    final day = date?.day.toString() ?? '';

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventRegistration(event: event, clubName: club.name),
            ),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.gray200),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      month.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      day,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gray900,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (event.time != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${event.time} · ${event.location}',
                        style: const TextStyle(fontSize: 12, color: AppColors.gray500),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ] else
                      Text(
                        event.location,
                        style: const TextStyle(fontSize: 12, color: AppColors.gray500),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
}
