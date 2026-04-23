import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/club.dart';
import '../../services/club_api_service.dart';
import '../../utils/constants.dart';
import '../../widgets/responsive_container.dart';
import 'club_details.dart';
import 'club_hub_deep_link.dart';
import 'club_hub_scope.dart';

enum MembershipStatus {
  active,
  pending,
  declined,
}

class Membership {
  final Club club;
  final MembershipStatus status;
  final String? role;
  final String? sinceDate;
  final String? declinedReason;
  final String? submittedDate;

  Membership({
    required this.club,
    required this.status,
    this.role,
    this.sinceDate,
    this.declinedReason,
    this.submittedDate,
  });
}

class MyMemberships extends StatefulWidget {
  final bool embeddedInHub;
  final bool embeddedInClubsTab;
  final int initialPrimaryTabIndex;
  final String? applicationsClubNameFilter;

  const MyMemberships({
    super.key,
    this.embeddedInHub = false,
    this.embeddedInClubsTab = false,
    this.initialPrimaryTabIndex = 0,
    this.applicationsClubNameFilter,
  });

  @override
  State<MyMemberships> createState() => _MyMembershipsState();
}

class _MyMembershipsState extends State<MyMemberships> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ClubApiService _api = ClubApiService();
  List<Membership> memberships = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialPrimaryTabIndex.clamp(0, 2),
    );
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {});
    });
    _loadMemberships();
  }

  Future<void> _loadMemberships() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final raw = await _api.fetchMyMemberships();
      final results = <Membership>[];
      for (final m in raw) {
        final clubId = (m['clubId'] ?? '').toString();
        final role = (m['role'] ?? 'Member') as String;
        final statusRaw = (m['status'] ?? 'active').toString().toLowerCase();
        MembershipStatus status;
        if (statusRaw == 'pending' || statusRaw == 'applied') {
          status = MembershipStatus.pending;
        } else if (statusRaw == 'declined' || statusRaw == 'rejected') {
          status = MembershipStatus.declined;
        } else {
          status = MembershipStatus.active;
        }
        Club club;
        try {
          club = await _api.fetchClubDetail(clubId);
        } catch (_) {
          club = Club(
            id: clubId, name: 'Club $clubId', logo: '', banner: '',
            category: '', tags: [], memberCount: 0, status: ClubStatus.open,
            about: '', officers: [], events: [],
          );
        }
        results.add(Membership(
          club: club,
          status: status,
          role: role,
          sinceDate: (m['memberSince'] ?? m['joinedAt'] ?? '').toString().length >= 7
              ? (m['memberSince'] ?? m['joinedAt'] ?? '').toString().substring(0, 7)
              : null,
        ));
      }
      if (mounted) setState(() { memberships = results; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Membership> get _active => memberships.where((m) => m.status == MembershipStatus.active).toList();
  List<Membership> get _pending => memberships.where((m) => m.status == MembershipStatus.pending).toList();
  List<Membership> get _declined => memberships.where((m) => m.status == MembershipStatus.declined).toList();

  Future<void> _openClub(BuildContext context, Club club) async {
    final link = await Navigator.push<ClubHubDeepLink?>(
      context,
      MaterialPageRoute<ClubHubDeepLink?>(builder: (_) => ClubDetails(club: club)),
    );
    if (!context.mounted || link == null) return;
    ClubHubScope.maybeOf(context)?.applyDeepLink(link);
  }

  Future<void> _emailClub(Membership m) async {
    final email = m.club.contactEmail ?? 'clubs@ada.edu.az';
    final uri = Uri(scheme: 'mailto', path: email, queryParameters: {'subject': 'Question about ${m.club.name}'});
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Email: $email')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final inner = ResponsiveContainer(
      backgroundColor: AppColors.backgroundLight,
      padding: widget.embeddedInClubsTab ? EdgeInsets.zero : null,
      child: Column(
        children: [
          if (!widget.embeddedInClubsTab) _buildHeader(context),
          _buildSegmentedTabs(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildList(_active, 'active'),
                _buildList(_pending, 'pending'),
                _buildList(_declined, 'declined'),
              ],
            ),
          ),
        ],
      ),
    );

    if (widget.embeddedInClubsTab) {
      return ColoredBox(color: AppColors.backgroundLight, child: inner);
    }

    return Scaffold(backgroundColor: AppColors.backgroundLight, body: SafeArea(child: inner));
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(widget.embeddedInHub ? 16 : 8, 4, 16, 8),
      color: AppColors.white,
      child: Row(
        children: [
          if (!widget.embeddedInHub)
            IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.gray700), onPressed: () => Navigator.pop(context)),
          Expanded(
            child: Text(
              widget.embeddedInHub ? 'My clubs' : 'My Memberships',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedTabs() {
    final tabs = [
      (_active.length, 'Active', Icons.verified_outlined),
      (_pending.length, 'Pending', Icons.hourglass_empty_rounded),
      (_declined.length, 'Declined', Icons.cancel_outlined),
    ];

    return Material(
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: AppColors.gray100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: List.generate(3, (i) {
              final sel = _tabController.index == i;
              final (count, label, icon) = tabs[i];
              return Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _tabController.animateTo(i),
                    borderRadius: BorderRadius.circular(8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: sel
                            ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 1))]
                            : null,
                      ),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(icon, size: 15, color: sel ? AppColors.primary : AppColors.gray500),
                              const SizedBox(width: 5),
                              Text(
                                label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                                  color: sel ? AppColors.primary : AppColors.gray600,
                                ),
                              ),
                              Text(
                                ' $count',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: sel ? AppColors.secondary : AppColors.gray400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildList(List<Membership> items, String type) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: AppColors.gray300),
            const SizedBox(height: 12),
            const Text('Failed to load', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.gray700)),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _loadMemberships,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ],
        ),
      );
    }
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: AppColors.gray300),
            const SizedBox(height: 12),
            Text('No $type memberships', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.gray700)),
            const SizedBox(height: 4),
            const Text('Nothing to show here yet', style: TextStyle(fontSize: 13, color: AppColors.gray500)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMemberships,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _card(context, items[i]),
      ),
    );
  }

  Widget _card(BuildContext context, Membership m) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: _statusColor(m.status),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
          ),
          InkWell(
            onTap: () => _openClub(context, m.club),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          m.club.logo,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(width: 48, height: 48, color: AppColors.gray100);
                          },
                          errorBuilder: (_, __, ___) => Container(
                            width: 48,
                            height: 48,
                            color: AppColors.primary.withValues(alpha: 0.08),
                            child: const Icon(Icons.groups, color: AppColors.primary, size: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m.club.name,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.gray900),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            if (m.status == MembershipStatus.active)
                              _activeSubtitle(m)
                            else if (m.status == MembershipStatus.pending)
                              _pendingSubtitle(m)
                            else
                              _declinedSubtitle(m),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _statusBadge(m.status),
                      const Spacer(),
                      Tooltip(
                        message: 'Email club',
                        child: Material(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            onTap: () => _emailClub(m),
                            borderRadius: BorderRadius.circular(10),
                            child: const Padding(
                              padding: EdgeInsets.all(10),
                              child: Icon(Icons.mail_outline, size: 20, color: AppColors.primary),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (m.status == MembershipStatus.declined && m.declinedReason != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.red.shade400),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        m.declinedReason!,
                        style: TextStyle(fontSize: 12, height: 1.45, color: Colors.red.shade800),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _activeSubtitle(Membership m) {
    final parts = <String>[];
    if (m.role != null) parts.add(m.role!);
    if (m.sinceDate != null) parts.add('Since ${m.sinceDate}');
    return Text(
      parts.join(' · '),
      style: const TextStyle(fontSize: 12, color: AppColors.gray600, height: 1.35),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _pendingSubtitle(Membership m) {
    final t = m.submittedDate != null ? 'Submitted ${m.submittedDate}' : 'Under review';
    return Text(
      t,
      style: TextStyle(fontSize: 12, color: Colors.orange.shade800, height: 1.35),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _declinedSubtitle(Membership m) {
    final t = m.submittedDate != null ? 'Submitted ${m.submittedDate}' : 'Application declined';
    return Text(
      t,
      style: const TextStyle(fontSize: 12, color: AppColors.gray600, height: 1.35),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _statusBadge(MembershipStatus status) {
    final (Color bg, Color fg, String label, IconData icon) = switch (status) {
      MembershipStatus.active => (const Color(0xFFECFDF5), const Color(0xFF059669), 'Active', Icons.check_circle_outline),
      MembershipStatus.pending => (const Color(0xFFFFFBEB), const Color(0xFFD97706), 'Pending', Icons.schedule),
      MembershipStatus.declined => (const Color(0xFFFEF2F2), const Color(0xFFDC2626), 'Declined', Icons.cancel_outlined),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
        ],
      ),
    );
  }

  Color _statusColor(MembershipStatus s) => switch (s) {
    MembershipStatus.active => const Color(0xFF059669),
    MembershipStatus.pending => const Color(0xFFD97706),
    MembershipStatus.declined => const Color(0xFFDC2626),
  };
}
