import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/club_api_service.dart';
import '../../utils/constants.dart';
import '../../widgets/responsive_container.dart';

class _VacancyApp {
  final String id;
  final String position;
  final String clubName;
  final String status;
  final String appliedOn;

  const _VacancyApp({
    required this.id,
    required this.position,
    required this.clubName,
    required this.status,
    required this.appliedOn,
  });
}

/// Shared list UI for vacancy applications (hub "My Clubs" tab and optional standalone screen).
class VacancyApplicationsBody extends StatefulWidget {
  final String? filterClubName;
  final bool showBrowseVacanciesAction;
  final VoidCallback? onBrowseOpenings;

  const VacancyApplicationsBody({
    super.key,
    this.filterClubName,
    this.showBrowseVacanciesAction = false,
    this.onBrowseOpenings,
  });

  static Color statusColor(String s) {
    final lower = s.toLowerCase();
    if (lower == 'accepted' || lower == 'approved') return const Color(0xFF16A34A);
    if (lower.contains('review') || lower == 'pending') return const Color(0xFFF59E0B);
    if (lower == 'submitted' || lower == 'applied') return const Color(0xFF2563EB);
    if (lower.contains('interview')) return const Color(0xFF8B5CF6);
    if (lower == 'rejected' || lower == 'declined' || lower == 'cancelled') return const Color(0xFFDC2626);
    return AppColors.gray500;
  }

  static String _mapStatus(String raw) {
    final lower = raw.toLowerCase();
    if (lower == 'pending') return 'Under Review';
    if (lower == 'reviewing') return 'Called for Interview';
    if (lower.contains('interview') && lower.contains('scheduled')) return 'Interview Scheduled';
    if (lower == 'approved' || lower == 'accepted') return 'Accepted';
    if (lower == 'rejected' || lower == 'cancelled' || lower == 'declined') return 'Declined';
    return raw;
  }

  @override
  State<VacancyApplicationsBody> createState() => _VacancyApplicationsBodyState();
}

class _VacancyApplicationsBodyState extends State<VacancyApplicationsBody> {
  final ClubApiService _api = ClubApiService();
  List<_VacancyApp> _apps = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final raw = await _api.fetchMyVacancyApplications();
      final results = <_VacancyApp>[];
      for (final a in raw) {
        final statusRaw = (a['status'] ?? 'pending').toString();
        final appliedOn = (a['appliedOn'] ?? a['createdAt'] ?? a['submittedAt'] ?? '').toString();
        final date = appliedOn.length >= 10 ? appliedOn.substring(0, 10) : appliedOn;
        results.add(_VacancyApp(
          id: (a['id'] ?? a['applicationId'] ?? '').toString(),
          position: (a['position'] ?? a['vacancyTitle'] ?? a['title'] ?? '') as String,
          clubName: (a['clubName'] ?? '') as String,
          status: VacancyApplicationsBody._mapStatus(statusRaw),
          appliedOn: date,
        ));
      }
      if (mounted) setState(() { _apps = results; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  List<_VacancyApp> get _filteredApps {
    final clubName = widget.filterClubName;
    if (clubName == null || clubName.isEmpty) return _apps;
    final n = clubName.toLowerCase();
    return _apps.where((a) => a.clubName.toLowerCase() == n).toList();
  }

  @override
  Widget build(BuildContext context) {
    final scoped = widget.filterClubName;
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
            const Text('Failed to load applications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.gray700)),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ],
        ),
      );
    }
    final apps = _filteredApps;
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
                  style: const TextStyle(color: Color(0xFF64748B), height: 1.5),
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (widget.showBrowseVacanciesAction && widget.onBrowseOpenings != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: widget.onBrowseOpenings,
                        icon: const Icon(Icons.work_outline, size: 18),
                        label: const Text('Browse openings'),
                      ),
                    ),
                  Text(
                    scoped != null ? 'This club' : 'All clubs',
                    style: const TextStyle(fontSize: 11, letterSpacing: 0.06, color: AppColors.gray500, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text('${apps.length} application${apps.length == 1 ? '' : 's'}', style: const TextStyle(color: Color(0xFF64748B))),
                  const SizedBox(height: 12),
                  if (scoped == null) const Text('Track the status of vacancies you applied to.', style: TextStyle(color: Color(0xFF64748B), height: 1.45)),
                  if (scoped == null) const SizedBox(height: 20),
                  if (scoped != null) const SizedBox(height: 8),
                  ...apps.map((a) => _AppCard(app: a, statusColor: VacancyApplicationsBody.statusColor(a.status))),
                ],
              ),
            ),
    );
  }
}

class _AppCard extends StatelessWidget {
  final _VacancyApp app;
  final Color statusColor;

  const _AppCard({required this.app, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    final d = DateTime.tryParse(app.appliedOn);
    final formatted = d != null ? DateFormat.yMMMd().format(d) : app.appliedOn;
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
              decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12)),
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
                        child: Text(app.position.isNotEmpty ? app.position : 'Position', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
                        child: Text(app.status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(app.clubName.isNotEmpty ? app.clubName : 'Club', style: const TextStyle(color: Color(0xFF64748B))),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 14, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 6),
                      Text('Applied on $formatted', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Application ID: ${app.id}', style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
