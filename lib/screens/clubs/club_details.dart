import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/club.dart';
import '../../models/club_public_event.dart';
import '../../models/club_vacancy.dart';
import '../../services/auth_service.dart';
import '../../services/club_api_service.dart';
import '../../utils/constants.dart';
import '../../widgets/app_back_button.dart';
import 'join_club_sheet.dart';
import 'club_hub_deep_link.dart';
import 'club_module_nav.dart';

class ClubDetails extends StatefulWidget {
  final Club club;
  const ClubDetails({super.key, required this.club});

  @override
  State<ClubDetails> createState() => _ClubDetailsState();
}

class _ClubAnnouncementItem {
  final ClubPublicEvent? event;
  final ClubVacancy? vacancy;
  const _ClubAnnouncementItem.event(this.event) : vacancy = null;
  const _ClubAnnouncementItem.vacancy(this.vacancy) : event = null;
  bool get isEvent => event != null;
  DateTime get sortDate {
    final raw = isEvent ? event!.date : vacancy!.postedAt;
    return DateTime.tryParse(raw) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }
}

class _ClubDetailsState extends State<ClubDetails> {
  late Club _club;
  final ClubApiService _api = ClubApiService();
  final TextEditingController _memberSearchCtl = TextEditingController();

  List<Map<String, dynamic>> _members = [];
  List<ClubPublicEvent> _clubEvents = [];
  List<ClubVacancy> _clubVacancies = [];
  final Map<String, AuthUserProfile> _userProfiles = {};
  bool _isMember = false;
  String _memberSearch = '';
  int _selectedTab = 0;

  static const _tabs = [
    (icon: Icons.info_outline_rounded, label: 'About'),
    (icon: Icons.campaign_outlined, label: 'Announce'),
    (icon: Icons.groups_outlined, label: 'Members'),
    (icon: Icons.folder_open_outlined, label: 'Resources'),
  ];

  @override
  void initState() {
    super.initState();
    _club = widget.club;
    _loadClubDetail();
    _loadClubActivity();
    _loadMembers();
    _checkMembership();
  }

  @override
  void dispose() {
    _memberSearchCtl.dispose();
    super.dispose();
  }

  Future<void> _loadClubDetail() async {
    try {
      final detailed = await _api.fetchClubDetail(widget.club.id);
      if (!mounted) return;
      setState(() => _club = detailed);
      await _enrichOfficerProfiles(detailed.officers);
    } catch (_) {}
  }

  Future<void> _loadClubActivity() async {
    try {
      final id = int.tryParse(_club.id);
      if (id == null) return;
      final events = await _api.fetchEvents(clubId: id, limit: 100);
      final vacancies = await _api.fetchVacancies(clubId: id, limit: 100);
      if (!mounted) return;
      setState(() {
        _clubEvents = events;
        _clubVacancies = vacancies;
      });
    } catch (_) {}
  }

  Future<void> _loadMembers() async {
    try {
      final byId = <String, Map<String, dynamic>>{};

      void mergeRow(Map<String, dynamic> row) {
        final id = _rowUserId(row);
        if (id.isEmpty) return;
        final existing = byId[id];
        if (existing == null) {
          byId[id] = Map<String, dynamic>.from(row);
          return;
        }
        for (final e in row.entries) {
          final v = e.value;
          if (v == null) continue;
          if (v is String) {
            final t = v.trim();
            if (t.isEmpty || t.toLowerCase() == 'null') continue;
          }
          final cur = existing[e.key];
          final curEmpty = cur == null ||
              (cur is String && cur.trim().isEmpty) ||
              (cur is String && cur.trim().toLowerCase() == 'null');
          if (curEmpty) existing[e.key] = v;
        }
      }

      // Public roster (`GET /api/v1/clubs/{clubId}/members`) + admin projection when permitted.
      final admin =
          await _api.fetchClubAdminMembers(_club.id, page: 1, limit: 200);
      final public = await _api.fetchClubMembers(_club.id);
      for (final r in admin) {
        mergeRow(r);
      }
      for (final r in public) {
        mergeRow(r);
      }

      final merged = byId.values.toList();
      await _enrichMemberProfiles(merged);
      if (mounted) setState(() => _members = merged);
    } catch (_) {}
  }

  Future<void> _checkMembership() async {
    try {
      final memberships = await _api.fetchMyMemberships();
      final found = memberships.any((m) {
        final cid = (m['clubId'] ?? '').toString();
        final status = (m['status'] ?? '').toString().toLowerCase();
        final inactive = status == 'rejected' ||
            status == 'cancelled' ||
            status == 'canceled' ||
            status == 'inactive' ||
            status == 'removed';
        return cid == _club.id && !inactive;
      });
      if (mounted) setState(() => _isMember = found);
    } catch (_) {}
  }

  // ── Helpers ──────────────────────────────────────────────────────────

  int get _displayMemberCount {
    // Prefer the members endpoint since it reflects the current roster.
    // Fall back to the club projection value if the member list hasn't loaded yet.
    if (_members.isNotEmpty) return _members.length;
    return _club.memberCount;
  }

  String get _heroImageUrl {
    final banner = _club.banner.trim();
    final logo = _club.logo.trim();
    if (banner.isNotEmpty) return resolveMediaUrl(banner);
    if (logo.isNotEmpty) return resolveMediaUrl(logo);
    return resolveMediaUrl('/clubs/default.png');
  }

  List<ClubPublicEvent> _upcomingEvents() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return (_effectiveClubEvents.where((e) {
      final d = _parseEventDate(e);
      if (d == null) return true;
      return !DateTime(d.year, d.month, d.day).isBefore(today);
    }).toList()
      ..sort((a, b) {
        final ad = _parseEventDate(a) ?? DateTime(9999);
        final bd = _parseEventDate(b) ?? DateTime(9999);
        return ad.compareTo(bd);
      }));
  }

  List<ClubPublicEvent> get _effectiveClubEvents {
    if (_clubEvents.isNotEmpty) return _clubEvents;
    return _club.events
        .map((e) => ClubPublicEvent(
              id: int.tryParse(e.id) ?? 0,
              clubId: int.tryParse(_club.id) ?? 0,
              clubName: _club.name,
              title: e.title,
              category: _club.category.isNotEmpty ? _club.category : 'General',
              description: e.description,
              date: e.date,
              time: e.time ?? '',
              location: e.location,
            ))
        .toList(growable: false);
  }

  DateTime? _parseEventDate(ClubPublicEvent e) =>
      DateTime.tryParse(e.date) ??
      DateTime.tryParse(e.date.length >= 10 ? e.date.substring(0, 10) : e.date);

  String _shortDate(String raw) {
    final d = DateTime.tryParse(raw) ??
        DateTime.tryParse(raw.length >= 10 ? raw.substring(0, 10) : raw);
    return d == null ? raw : DateFormat('MMM d').format(d);
  }

  String _formatEventSubtitle(ClubPublicEvent event) {
    final parts = <String>[];

    final date = _parseEventDate(event);
    if (date != null) parts.add(DateFormat('MMM d').format(date));

    String? time;
    final rawTime = event.time.trim();
    if (rawTime.isNotEmpty) {
      final iso = DateTime.tryParse(rawTime);
      if (iso != null) {
        time = DateFormat('HH:mm').format(iso.toLocal());
      } else {
        final m = RegExp(r'^\s*(\d{1,2}:\d{2})').firstMatch(rawTime);
        time = m?.group(1) ?? rawTime;
      }
    }
    if (time != null && time.isNotEmpty) parts.add(time);

    final loc = event.location.trim();
    if (loc.isNotEmpty) parts.add(loc);

    return parts.join(' · ');
  }

  Future<void> _enrichOfficerProfiles(List<ClubOfficer> officers) async {
    final ids = officers
        .map((o) => o.userId.trim())
        .where((id) => id.isNotEmpty && !_userProfiles.containsKey(id))
        .toSet()
        .toList(growable: false);
    await _fetchAuthProfiles(ids);
  }

  Future<void> _enrichMemberProfiles(List<Map<String, dynamic>> members) async {
    final ids = members
        .map(_rowUserId)
        .where((id) => id.isNotEmpty && !_userProfiles.containsKey(id))
        .toSet()
        .toList(growable: false);
    await _fetchAuthProfiles(ids);
  }

  Future<void> _fetchAuthProfiles(List<String> ids) async {
    if (ids.isEmpty) return;
    const batchSize = 8;
    for (var i = 0; i < ids.length; i += batchSize) {
      final batch = ids.skip(i).take(batchSize).toList(growable: false);
      final results = await Future.wait(batch.map((id) async {
        try {
          return MapEntry(id, await AuthService.instance.fetchUserById(id));
        } catch (_) {
          return null;
        }
      }));
      if (!mounted) return;
      setState(() {
        for (final entry in results) {
          if (entry == null) continue;
          _userProfiles[entry.key] = entry.value;
        }
      });
    }
  }

  String _rowUserId(Map<String, dynamic> row) {
    final nestedUser = row['user'];
    if (nestedUser is Map<String, dynamic>) {
      final nestedId =
          (nestedUser['id'] ?? nestedUser['userId'])?.toString().trim();
      if (nestedId != null && nestedId.isNotEmpty) return nestedId;
    }
    return (row['userId'] ??
            row['studentId'] ??
            row['memberUserId'] ??
            row['user_id'] ??
            '')
        .toString()
        .trim();
  }

  AuthUserProfile? _profileForUserId(String userId) {
    if (userId.isEmpty) return null;
    return _userProfiles[userId];
  }

  String _profileDisplayName(AuthUserProfile profile) {
    final full = '${profile.firstName ?? ''} ${profile.lastName ?? ''}'.trim();
    if (full.isNotEmpty) return full;
    if (profile.userName.trim().isNotEmpty) return profile.userName.trim();
    final emailPrefix = profile.email?.split('@').first.trim();
    if (emailPrefix != null && emailPrefix.isNotEmpty) return emailPrefix;
    return 'Member';
  }

  List<Map<String, dynamic>> get _filteredMembers {
    final q = _memberSearch.trim().toLowerCase();
    if (q.isEmpty) return _members;
    return _members.where((m) {
      return _mName(m).toLowerCase().contains(q) ||
          _mRole(m).toLowerCase().contains(q);
    }).toList(growable: false);
  }

  String _mName(Map<String, dynamic> m) {
    final profile = _profileForUserId(_rowUserId(m));
    if (profile != null) return _profileDisplayName(profile);

    final nestedUser = m['user'];
    if (nestedUser is Map<String, dynamic>) {
      final first = (nestedUser['firstName'] ?? '').toString().trim();
      final last = (nestedUser['lastName'] ?? '').toString().trim();
      if (first.isNotEmpty || last.isNotEmpty) return '$first $last'.trim();
      final userName = (nestedUser['userName'] ?? '').toString().trim();
      if (userName.isNotEmpty) return userName;
    }

    final first = (m['firstName'] ?? '').toString().trim();
    final last = (m['lastName'] ?? '').toString().trim();
    if (first.isNotEmpty || last.isNotEmpty) return '$first $last'.trim();
    final n = (m['name'] ??
            m['fullName'] ??
            m['displayName'] ??
            m['userName'] ??
            m['studentName'])
        ?.toString()
        .trim();
    if (n != null && n.isNotEmpty) return n;
    return 'Member';
  }

  String _sanitizeRoleLabel(Object? raw) {
    if (raw == null) return '';
    final s = raw.toString().trim();
    if (s.isEmpty || s.toLowerCase() == 'null') return '';
    return s;
  }

  String _mRoleFromRow(Map<String, dynamic> m) {
    final position = m['position'];
    if (position is Map<String, dynamic>) {
      final title = _sanitizeRoleLabel(position['title'] ??
          position['name'] ??
          position['positionTitle'] ??
          position['label']);
      if (title.isNotEmpty) return title;
    }
    return _sanitizeRoleLabel(m['role'] ??
        m['positionTitle'] ??
        m['positionName'] ??
        m['roleName'] ??
        m['clubRole'] ??
        m['memberRole'] ??
        m['title'] ??
        (position is String ? position : null));
  }

  String _mRole(Map<String, dynamic> m) {
    final fromRow = _mRoleFromRow(m);
    if (fromRow.isNotEmpty) return fromRow;
    final uid = _rowUserId(m);
    for (final o in _club.officers) {
      if (o.userId.isNotEmpty && o.userId == uid) {
        final r = o.role.trim();
        if (r.isNotEmpty && r.toLowerCase() != 'null') return r;
      }
    }
    return 'Member';
  }

  Uri? _launchableUri(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return null;
    try {
      final p = Uri.parse(t);
      if (p.hasScheme && (p.scheme == 'http' || p.scheme == 'https')) return p;
    } catch (_) {}
    if (t.startsWith('//')) return Uri.parse('https:$t');
    if (t.contains('.') && !t.contains(' ')) return Uri.parse('https://$t');
    return null;
  }

  Future<void> _openUrl(String raw) async {
    final uri = _launchableUri(raw);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openEmail(String email) async {
    final uri = Uri.parse('mailto:${email.trim()}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  List<_SocialEntry> get _activeSocials {
    final out = <_SocialEntry>[];
    for (final key in const [
      'website',
      'instagram',
      'x',
      'tiktok',
      'facebook',
      'linkedin',
      'youtube',
    ]) {
      final raw = _club.socialLinks[key];
      if (raw == null || raw.trim().isEmpty) continue;
      if (_launchableUri(raw) == null) continue;
      out.add(_SocialEntry(key: key, url: raw.trim()));
    }
    for (final entry in _club.socialLinks.entries) {
      if (out.any((s) => s.key == entry.key)) continue;
      final raw = entry.value.trim();
      if (raw.isEmpty || _launchableUri(raw) == null) continue;
      out.add(_SocialEntry(key: entry.key, url: raw));
    }
    return out;
  }

  IconData _focusIcon(String key) {
    switch (key.toLowerCase()) {
      case 'target':
        return Icons.track_changes_outlined;
      case 'lightbulb':
      case 'idea':
        return Icons.lightbulb_outline;
      case 'people':
      case 'community':
        return Icons.groups_outlined;
      case 'star':
        return Icons.star_outline;
      case 'school':
        return Icons.school_outlined;
      case 'eco':
      case 'leaf':
        return Icons.eco_outlined;
      default:
        return Icons.flag_outlined;
    }
  }

  // ── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          _buildHero(context),
          _buildTabBar(),
          Expanded(
            child: IndexedStack(
              index: _selectedTab,
              children: [
                _tabAbout(),
                _tabAnnouncements(),
                _tabMembers(),
                _tabResources(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Hero header ──────────────────────────────────────────────────────

  Widget _buildHero(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return SizedBox(
      height: 200 + top,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            _heroImageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (_, child, p) =>
                p == null ? child : Container(color: AppColors.gray200),
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.primary,
              child: const Icon(Icons.groups, size: 56, color: AppColors.white),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.35, 1.0],
                colors: [
                  Colors.black.withValues(alpha: 0.50),
                  Colors.black.withValues(alpha: 0.15),
                  Colors.black.withValues(alpha: 0.72),
                ],
              ),
            ),
          ),
          // Back button + notification
          Positioned(
            top: top + 6,
            left: 12,
            right: 12,
            child: Row(
              children: [
                AppBackButton(onPressed: () => Navigator.pop(context)),
                const Spacer(),
                GestureDetector(
                  onTap: () => ClubModuleNav.openNotifications(context),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.notifications_outlined,
                        size: 18, color: AppColors.gray700),
                  ),
                ),
              ],
            ),
          ),
          // Club name + chips
          Positioned(
            left: 16,
            right: 16,
            bottom: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _club.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                    shadows: [
                      Shadow(
                          color: Colors.black.withValues(alpha: 0.7),
                          blurRadius: 16),
                      Shadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 6),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (_club.category.isNotEmpty) _heroPill(_club.category),
                    const SizedBox(width: 6),
                    _heroPill('$_displayMemberCount members',
                        icon: Icons.groups_outlined),
                    if (_isMember) ...[
                      const SizedBox(width: 6),
                      _heroPill('Enrolled', icon: Icons.verified_outlined),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroPill(String text, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: Colors.white.withValues(alpha: 0.9)),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.95),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab bar (icon + label, full width, Events-style toggles) ─────────

  Widget _buildTabBar() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final selected = _selectedTab == i;
          final tab = _tabs[i];
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOutCubic,
                margin: EdgeInsets.only(
                  left: i == 0 ? 0 : 3,
                  right: i == _tabs.length - 1 ? 0 : 3,
                ),
                height: 36,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary.withValues(alpha: 0.08)
                      : AppColors.gray50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: selected
                        ? AppColors.primary.withValues(alpha: 0.35)
                        : AppColors.gray200,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(tab.icon,
                        size: 15,
                        color:
                            selected ? AppColors.primary : AppColors.gray600),
                    const SizedBox(height: 1),
                    Text(
                      tab.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w500,
                        color: selected ? AppColors.primary : AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Tab: About ───────────────────────────────────────────────────────

  Widget _tabAbout() {
    final upcoming = _upcomingEvents();
    final socials = _activeSocials;
    final email = _club.contactEmail?.trim();
    final hasContact =
        (email != null && email.isNotEmpty) || socials.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        if (!_isMember) _buildJoinCta(),
        _vibrantSection(
          title: 'Mission',
          icon: Icons.flag_outlined,
          child: Text(
            _club.effectiveShortDescription.trim().isEmpty
                ? 'No mission statement has been published yet.'
                : _club.effectiveShortDescription.trim(),
            style: _body,
          ),
        ),
        if (_club.mainGoals != null && _club.mainGoals!.trim().isNotEmpty) ...[
          const SizedBox(height: 10),
          _vibrantSection(
            title: 'Goals',
            icon: Icons.track_changes_outlined,
            child: Text(_club.mainGoals!.trim(), style: _body),
          ),
        ],
        if (_club.focusAreas.isNotEmpty) ...[
          const SizedBox(height: 10),
          _vibrantSection(
            title: 'Focus areas',
            icon: Icons.auto_awesome_outlined,
            child: Column(
              children: _club.focusAreas.map(_focusAreaTile).toList(),
            ),
          ),
        ],
        if (upcoming.isNotEmpty) ...[
          const SizedBox(height: 10),
          _vibrantSection(
            title: 'Upcoming events',
            icon: Icons.event_available_outlined,
            trailing: _viewAllButton(ClubHubTabs.events),
            child: Column(children: upcoming.take(4).map(_eventTile).toList()),
          ),
        ],
        if (hasContact) ...[
          const SizedBox(height: 10),
          _vibrantSection(
            title: 'Connect',
            icon: Icons.link_rounded,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (email != null && email.isNotEmpty)
                  _socialChip(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    onTap: () => _openEmail(email),
                  ),
                ...socials.map((s) => _socialChip(
                      icon: _socialIconFor(s.key),
                      label: _socialLabelFor(s.key),
                      onTap: () => _openUrl(s.url),
                    )),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ── Tab: Announcements (mocked when empty) ───────────────────────────

  Widget _tabAnnouncements() {
    final feed = <_ClubAnnouncementItem>[
      ..._clubEvents.map(_ClubAnnouncementItem.event),
      ..._clubVacancies.map(_ClubAnnouncementItem.vacancy),
    ]..sort((a, b) => b.sortDate.compareTo(a.sortDate));

    final items = feed.isNotEmpty ? feed : _mockAnnouncements;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      itemCount: items.length + (feed.isEmpty ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (ctx, i) {
        if (feed.isEmpty && i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              'Sample announcements — real data coming soon.',
              style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: AppColors.gray500),
            ),
          );
        }
        final idx = feed.isEmpty ? i - 1 : i;
        return _announcementTile(ctx, items[idx]);
      },
    );
  }

  List<_ClubAnnouncementItem> get _mockAnnouncements => [
        _ClubAnnouncementItem.event(ClubPublicEvent(
          id: 0,
          clubId: int.tryParse(_club.id) ?? 0,
          clubName: _club.name,
          title: 'Welcome Meeting — New Members Orientation',
          category: _club.category,
          date: DateTime.now().add(const Duration(days: 5)).toIso8601String(),
          time: '17:00',
          location: 'Room B-204',
        )),
        _ClubAnnouncementItem.vacancy(ClubVacancy(
          id: 0,
          clubId: int.tryParse(_club.id) ?? 0,
          clubName: _club.name,
          position: 'Social Media Manager',
          category: 'Marketing',
          categoryTag: 'ACTIVE',
          postedAt: DateTime.now()
              .subtract(const Duration(days: 2))
              .toIso8601String(),
          employmentType: 'Club Position',
          location: 'ADA University',
          aboutRole: const ['Manage club social media channels.'],
          responsibilities: const [],
          benefits: const [],
          deadline: DateTime.now()
              .add(const Duration(days: 14))
              .toIso8601String()
              .substring(0, 10),
          applicants: '',
          requirements: const [],
        )),
        _ClubAnnouncementItem.event(ClubPublicEvent(
          id: 0,
          clubId: int.tryParse(_club.id) ?? 0,
          clubName: _club.name,
          title: 'Workshop: Introduction to ${_club.category}',
          category: _club.category,
          date: DateTime.now().add(const Duration(days: 12)).toIso8601String(),
          time: '14:00',
          location: 'Innovation Lab',
        )),
      ];

  // ── Tab: Members ─────────────────────────────────────────────────────

  Widget _tabMembers() {
    final filtered = _filteredMembers;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      children: [
        _searchField(),
        const SizedBox(height: 6),
        if (_club.officers.isNotEmpty) ...[
          _label('Club officers'),
          const SizedBox(height: 6),
          ..._club.officers.map(_officerTile),
          const SizedBox(height: 10),
        ],
        if (_members.isEmpty)
          _emptyInline(Icons.groups_outlined, 'No members listed yet.')
        else if (filtered.isEmpty)
          _emptyInline(Icons.search_off_rounded, 'No matching members.')
        else ...[
          _label('Members'),
          const SizedBox(height: 6),
          ...filtered.map(_memberTile),
        ],
      ],
    );
  }

  // ── Tab: Resources ───────────────────────────────────────────────────

  Widget _tabResources() {
    final docs = _club.documents;
    final res = _club.resources;
    if (docs.isEmpty && res.isEmpty) {
      return _emptyState(
          Icons.folder_open_outlined, 'No resources shared yet.');
    }

    final items = <({String title, String url})>[];
    final seen = <String>{};
    void addUnique(String title, String url) {
      final t = title.trim();
      final u = url.trim();
      final key = '${t.toLowerCase()}|$u';
      if (seen.contains(key)) return;
      if (t.isEmpty && u.isEmpty) return;
      seen.add(key);
      final label = t.isNotEmpty ? title.trim() : (u.isNotEmpty ? u : 'Item');
      items.add((title: label, url: u));
    }

    for (final d in docs) {
      addUnique(d.title, d.url);
    }
    for (final r in res) {
      addUnique(r.title, r.url);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      children: [
        _label('Resources'),
        const SizedBox(height: 6),
        ...items.map((e) => _unifiedResourceTile(e.title, e.url)),
      ],
    );
  }

  // ── Shared widgets ───────────────────────────────────────────────────

  static const _body =
      TextStyle(fontSize: 14, height: 1.5, color: AppColors.gray700);

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.gray900,
          letterSpacing: -0.15,
        ),
      );

  Widget _buildJoinCta() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: FilledButton.icon(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => JoinClubSheet(club: _club)),
        ),
        icon: const Icon(Icons.person_add_outlined, size: 18),
        label: const Text('Join club'),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _viewAllButton(int tabIndex) {
    return GestureDetector(
      onTap: () => Navigator.pop(
        context,
        ClubHubDeepLink(tabIndex: tabIndex, clubId: int.tryParse(_club.id)),
      ),
      child: const Text('View all',
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary)),
    );
  }

  Widget _focusAreaTile(ClubFocusArea area) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _iconBox(_focusIcon(area.icon)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(area.title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900)),
                if (area.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(area.description,
                        style: const TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: AppColors.gray600)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _eventTile(ClubPublicEvent event) {
    final date = _parseEventDate(event);
    final month = date != null ? DateFormat('MMM').format(date) : '';
    final day = date?.day.toString() ?? '';
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: () => Navigator.pop(
            context,
            ClubHubDeepLink(
                tabIndex: ClubHubTabs.events, clubId: int.tryParse(_club.id))),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.gray200),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(month.toUpperCase(),
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 9,
                            fontWeight: FontWeight.w700)),
                    Text(day,
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 15,
                            fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray900)),
                    const SizedBox(height: 2),
                    Text(
                      _formatEventSubtitle(event),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.gray500),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  size: 18, color: AppColors.gray400),
            ],
          ),
        ),
      ),
    );
  }

  Widget _socialChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: AppColors.primary),
            const SizedBox(width: 5),
            Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray700)),
          ],
        ),
      ),
    );
  }

  Widget _announcementTile(BuildContext context, _ClubAnnouncementItem item) {
    final isEv = item.isEvent;
    final title = isEv ? item.event!.title : item.vacancy!.position;
    final sub = isEv
        ? [
            'Event',
            if (item.event!.date.isNotEmpty) _shortDate(item.event!.date),
            item.event!.location,
          ].where((s) => s.trim().isNotEmpty).join(' · ')
        : [
            'Vacancy',
            if (item.vacancy!.deadline.isNotEmpty)
              'Deadline ${item.vacancy!.deadline}',
          ].where((s) => s.trim().isNotEmpty).join(' · ');
    return InkWell(
      onTap: () => Navigator.pop(
        context,
        ClubHubDeepLink(
          tabIndex: isEv ? ClubHubTabs.events : ClubHubTabs.openings,
          clubId: int.tryParse(_club.id),
          clubName: _club.name,
        ),
      ),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Row(
          children: [
            _iconBox(
                isEv ? Icons.event_note_outlined : Icons.work_outline_rounded),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray900)),
                  const SizedBox(height: 2),
                  Text(sub,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.gray500)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                size: 18, color: AppColors.gray400),
          ],
        ),
      ),
    );
  }

  Widget _officerTile(ClubOfficer o) {
    final profile = _profileForUserId(o.userId);
    final name = profile != null
        ? _profileDisplayName(profile)
        : o.name.trim().isEmpty
            ? 'Officer'
            : o.name.trim();
    final roleRaw = o.role.trim();
    final role = roleRaw.isEmpty || roleRaw.toLowerCase() == 'null'
        ? 'Leadership'
        : roleRaw;
    final photo = profile?.profileImage?.trim().isNotEmpty == true
        ? profile!.profileImage!
        : o.photo;
    final initial = name.isNotEmpty
        ? name.substring(0, 1).toUpperCase()
        : '•';
    const double avatarR = 20.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.gray200.withValues(alpha: 0.9)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 3,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primary,
                        AppColors.secondary,
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              width: 1.5,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: avatarR,
                            backgroundColor: AppColors.gray50,
                            child: ClipOval(
                              child: photo.trim().isNotEmpty
                                  ? Image.network(
                                      resolveMediaUrl(photo),
                                      width: avatarR * 2,
                                      height: avatarR * 2,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Text(
                                        initial,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      initial,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.gray900,
                                  letterSpacing: -0.2,
                                  height: 1.15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary.withValues(alpha: 0.1),
                                      AppColors.secondary
                                          .withValues(alpha: 0.07),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.14),
                                  ),
                                ),
                                child: Text(
                                  role.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                    letterSpacing: 0.65,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _memberTile(Map<String, dynamic> m) {
    final name = _mName(m);
    final role = _mRole(m);
    final profile = _profileForUserId(_rowUserId(m));
    final photo = profile?.profileImage?.trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withValues(alpha: 0.08),
              backgroundImage: photo != null && photo.isNotEmpty
                  ? NetworkImage(resolveMediaUrl(photo))
                  : null,
              child: photo != null && photo.isNotEmpty
                  ? null
                  : Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary),
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.gray900)),
                  Text(role,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.gray500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _unifiedResourceTile(String title, String url) {
    final hasUrl = url.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: hasUrl ? () => _openUrl(url) : null,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.gray200),
          ),
          child: Row(
            children: [
              _iconBox(Icons.description_outlined),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray900,
                  ),
                ),
              ),
              if (hasUrl)
                const Icon(Icons.open_in_new_rounded,
                    size: 15, color: AppColors.gray400),
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchField() {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: _memberSearchCtl,
        onChanged: (v) => setState(() => _memberSearch = v),
        style: const TextStyle(fontSize: 14, color: AppColors.gray900),
        decoration: InputDecoration(
          hintText: 'Search members…',
          hintStyle: const TextStyle(fontSize: 13, color: AppColors.gray400),
          prefixIcon:
              const Icon(Icons.search, size: 20, color: AppColors.gray400),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 40, minHeight: 0),
          suffixIcon: _memberSearch.trim().isEmpty
              ? null
              : GestureDetector(
                  onTap: () {
                    _memberSearchCtl.clear();
                    setState(() => _memberSearch = '');
                  },
                  child: const Icon(Icons.close,
                      size: 17, color: AppColors.gray400),
                ),
          suffixIconConstraints:
              const BoxConstraints(minWidth: 40, minHeight: 0),
          filled: true,
          fillColor: AppColors.gray50,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.gray200)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.gray200)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5)),
        ),
      ),
    );
  }

  Widget _iconBox(IconData icon) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Icon(icon, size: 17, color: AppColors.primary),
    );
  }

  Widget _emptyState(IconData icon, String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 34, color: AppColors.gray400),
            const SizedBox(height: 6),
            Text(text,
                style: const TextStyle(fontSize: 13, color: AppColors.gray500)),
          ],
        ),
      ),
    );
  }

  Widget _emptyInline(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Icon(icon, size: 30, color: AppColors.gray400),
          const SizedBox(height: 4),
          Text(text,
              style: const TextStyle(fontSize: 13, color: AppColors.gray500)),
        ],
      ),
    );
  }

  // ── Social icon helpers ──────────────────────────────────────────────

  IconData _socialIconFor(String key) {
    switch (key) {
      case 'website':
        return Icons.language_rounded;
      case 'instagram':
        return Icons.camera_alt_outlined;
      case 'x':
        return Icons.alternate_email_rounded;
      case 'tiktok':
        return Icons.music_note_outlined;
      case 'facebook':
        return Icons.facebook_rounded;
      case 'linkedin':
        return Icons.work_outline_rounded;
      case 'youtube':
        return Icons.play_circle_outline_rounded;
      default:
        return Icons.link_rounded;
    }
  }

  String _socialLabelFor(String key) {
    switch (key) {
      case 'website':
        return 'Website';
      case 'instagram':
        return 'Instagram';
      case 'x':
        return 'X';
      case 'tiktok':
        return 'TikTok';
      case 'facebook':
        return 'Facebook';
      case 'linkedin':
        return 'LinkedIn';
      case 'youtube':
        return 'YouTube';
      default:
        return key;
    }
  }
}

class _SocialEntry {
  final String key;
  final String url;
  const _SocialEntry({required this.key, required this.url});
}

extension on _ClubDetailsState {
  Widget _vibrantSection({
    required String title,
    required IconData icon,
    Widget? trailing,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBox(icon),
              const SizedBox(width: 10),
              Expanded(child: _label(title)),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
