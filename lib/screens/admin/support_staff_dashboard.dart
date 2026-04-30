import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/support_ticket.dart';
import '../../services/auth_service.dart';
import '../../services/support_service.dart';
import '../../utils/constants.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/responsive_container.dart';
import 'staff_job_detail.dart';
import '../login_page.dart';

enum StaffRoleType {
  it,
  fm,
}

class SupportStaffDashboard extends StatefulWidget {
  const SupportStaffDashboard({
    super.key,
    required this.staffName,
    required this.roleType,
  });

  final String staffName;
  final StaffRoleType roleType;

  @override
  State<SupportStaffDashboard> createState() => _SupportStaffDashboardState();
}

class _SupportStaffDashboardState extends State<SupportStaffDashboard> {
  int _tabIndex = 0;
  int _historyPeriod = 1;
  bool _activeDuty = true;
  int _availabilityIndex = 0; // 0=available, 1=break

  final SupportService _supportService = SupportService();
  final DateFormat _fullDateFormat = DateFormat('MMM d, yyyy, h:mm a');

  List<SupportTicket> _tickets = const [];
  bool _isLoading = true;
  String? _staffId;
  String? _error;

  static const Color _pillActiveBg = Color(0xFFE8EEF5);
  static const Color _slateLabel = Color(0xFF334155);

  @override
  void initState() {
    super.initState();
    _loadStaffPortal();
  }

  List<SupportTicket> get _assignedJobs => _tickets
      .where((ticket) =>
          ticket.status != TicketStatus.completed &&
          ticket.status != TicketStatus.cancelled)
      .toList(growable: false);

  List<SupportTicket> get _historyItems {
    final cutoff = _historyCutoff();
    return _tickets.where((ticket) {
      if (ticket.status != TicketStatus.completed) return false;
      if (cutoff == null) return true;
      final completed = DateTime.tryParse(ticket.completedAt ?? '');
      final created = DateTime.tryParse(ticket.createdAt);
      final when = completed ?? created;
      return when == null || !when.isBefore(cutoff);
    }).toList(growable: false);
  }

  DateTime? _historyCutoff() {
    final now = DateTime.now();
    switch (_historyPeriod) {
      case 0:
        return now.subtract(const Duration(days: 7));
      case 1:
        return now.subtract(const Duration(days: 30));
      case 2:
        return DateTime(now.year, now.month - 3, now.day);
      default:
        return null;
    }
  }

  Future<void> _loadStaffPortal() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await AuthService.instance.loadSession();
      final staffId = AuthService.instance.studentId;
      if (staffId == null || staffId.trim().isEmpty) {
        throw const SupportServiceException(
          message: 'Authentication required. Please sign in again.',
        );
      }

      final tickets =
          await _supportService.fetchStaffRequests(staffId: staffId);

      if (!mounted) return;
      setState(() {
        _staffId = staffId;
        _tickets = tickets;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClubUiColors.pageBg,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Center(
            child: AppBackButton(onPressed: () => Navigator.maybePop(context)),
          ),
        ),
        leadingWidth: 52,
        title: const Text('Staff Portal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded,
                color: AppColors.gray600),
            onPressed: () => _showSnackBar('Notifications will appear here.'),
          ),
          PopupMenuButton<String>(
            icon:
                const Icon(Icons.more_horiz_rounded, color: AppColors.gray600),
            onSelected: (v) {
              if (v == 'logout') _logout();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Text('Sign out'),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          backgroundColor: ClubUiColors.pageBg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: _buildPillTabs(),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? _buildErrorState()
                        : RefreshIndicator(
                            onRefresh: _loadStaffPortal,
                            child: _tabIndex == 0
                                ? _buildDashboardTab()
                                : _buildHistoryTab(),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPillTabs() {
    Widget pill({
      required int index,
      required IconData icon,
      required String label,
    }) {
      final selected = _tabIndex == index;
      return Expanded(
        child: Padding(
          padding: EdgeInsets.only(right: index == 0 ? 10 : 0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _tabIndex = index),
              borderRadius: BorderRadius.circular(999),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? _pillActiveBg : AppColors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: selected
                        ? AppColors.gray300.withValues(alpha: 0.95)
                        : AppColors.gray200,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 20, color: _slateLabel),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _slateLabel,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        pill(
          index: 0,
          icon: Icons.dashboard_customize_outlined,
          label: 'Dashboard',
        ),
        pill(
          index: 1,
          icon: Icons.history_rounded,
          label: 'History',
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 46, color: AppColors.gray300),
            const SizedBox(height: 12),
            const Text(
              'Could not load staff portal',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.gray900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _error ?? 'Please try again.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.gray500,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: _loadStaffPortal,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTab() {
    final weekly = _weeklyPerformance();
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardSection(
            title: 'WEEKLY PERFORMANCE',
            child: Text(
              'Completed ${weekly.completed} of ${weekly.total} tasks this week.',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.gray700,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: 14),
          _buildAvailabilityCard(),
          const SizedBox(height: 18),
          Text(
            'My Assigned Jobs',
            style: AppTextStyles.moduleAppBarTitle.copyWith(
              fontSize: 20,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Priority queue for campus maintenance',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.gray500,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          if (_assignedJobs.isEmpty)
            _buildEmptyJobs()
          else
            ..._assignedJobs.map(_buildJobCard),
        ],
      ),
    );
  }

  ({int completed, int total}) _weeklyPerformance() {
    DateTime? parseLocal(String? iso) =>
        iso == null ? null : DateTime.tryParse(iso)?.toLocal();

    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));

    final total = _tickets.where((t) {
      final created = parseLocal(t.createdAt);
      return created == null || !created.isBefore(startOfWeek);
    }).length;

    final completed = _tickets.where((t) {
      if (t.status != TicketStatus.completed) return false;
      final doneAt = parseLocal(t.completedAt) ?? parseLocal(t.createdAt);
      return doneAt == null || !doneAt.isBefore(startOfWeek);
    }).length;

    return (completed: completed, total: total);
  }

  Widget _buildAvailabilityCard() {
    return _buildCardSection(
      title: 'AVAILABILITY',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Active Duty',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.gray900,
                  ),
                ),
              ),
              Switch.adaptive(
                value: _activeDuty,
                onChanged: (v) => setState(() {
                  _activeDuty = v;
                  if (!v) _availabilityIndex = 1;
                }),
                activeColor: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'When you need to pause briefly, choose a status below.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.gray500,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          _availabilityOption(
            index: 0,
            label: 'Available for assignments',
            dotColor: const Color(0xFF16A34A),
            activeBg: const Color(0xFFEFF6FF),
            activeBorder: AppColors.primary.withValues(alpha: 0.55),
          ),
          const SizedBox(height: 10),
          _availabilityOption(
            index: 1,
            label: 'On break',
            dotColor: const Color(0xFFF59E0B),
            activeBg: const Color(0xFFF0FDF4),
            activeBorder: const Color(0xFFBBF7D0),
          ),
        ],
      ),
    );
  }

  Widget _availabilityOption({
    required int index,
    required String label,
    required Color dotColor,
    required Color activeBg,
    required Color activeBorder,
  }) {
    final selected = _availabilityIndex == index;
    final enabled = _activeDuty || index == 1;
    final bg = selected ? activeBg : AppColors.gray50;
    final border = selected ? activeBorder : AppColors.gray200;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: !enabled ? null : () => setState(() => _availabilityIndex = index),
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: enabled ? dotColor : AppColors.gray300,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: enabled ? AppColors.gray700 : AppColors.gray400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardSection({
    required String title,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.gray200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: AppColors.gray400,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyJobs() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 40, color: AppColors.gray300),
          const SizedBox(height: 12),
          Text(
            'No assigned jobs',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.gray700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'New requests will show here when dispatched.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.gray500),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(SupportTicket job) {
    final status = job.statusString;
    final inProgress = job.status == TicketStatus.inProgress;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (context) => StaffJobDetail(
                  job: _ticketToJobMap(job),
                  staffId: _staffId,
                  onChanged: _loadStaffPortal,
                ),
              ),
            );
          },
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border:
                  Border.all(color: AppColors.gray200.withValues(alpha: 0.9)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
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
                      _buildLabelChip('${job.type} SUPPORT'),
                      const Spacer(),
                      Text(
                        _formatRelativeTime(job.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.gray400,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    job.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray900,
                      height: 1.25,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.place_outlined,
                          size: 18, color: AppColors.gray400),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          job.location,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.gray600,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if ((job.assignedTo ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      _shortStaff(job.assignedTo!),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.gray500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    inProgress ? 'In Progress' : status,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: inProgress ? AppColors.primary : AppColors.gray600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _shortStaff(String raw) {
    final t = raw.trim();
    if (t.length <= 28) return t;
    return '${t.substring(0, 25)}…';
  }

  String _formatFullDate(String iso) {
    final date = DateTime.tryParse(iso);
    if (date == null) return iso;
    return _fullDateFormat.format(date.toLocal());
  }

  String _formatRelativeTime(String iso) {
    final date = DateTime.tryParse(iso);
    if (date == null) return '';
    final diff = DateTime.now().difference(date.toLocal());
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return _fullDateFormat.format(date.toLocal());
  }

  Map<String, String> _ticketToJobMap(SupportTicket ticket) {
    return {
      if (ticket.requestId != null) 'requestId': ticket.requestId.toString(),
      'label': '${ticket.type} SUPPORT',
      'id': '#${ticket.id}',
      'time': _formatRelativeTime(ticket.createdAt),
      'title': ticket.title,
      'location': ticket.location,
      'category': ticket.categoryString,
      'status': ticket.statusString,
      'priority': ticket.priorityString,
      'created': _formatFullDate(ticket.createdAt),
      if (ticket.completedAt != null)
        'completed': _formatFullDate(ticket.completedAt!),
      if ((ticket.assignedTo ?? '').trim().isNotEmpty)
        'assignedTo': ticket.assignedTo!,
      'description': ticket.description,
    };
  }

  Widget _buildLabelChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: AppColors.gray600,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ticket History',
            style: AppTextStyles.moduleAppBarTitle.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 4),
          Text(
            'Past tickets you\'ve completed',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.gray500,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Time period:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.gray500,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _historyPeriodChip('Last 7 days', 0),
                const SizedBox(width: 8),
                _historyPeriodChip('Last 30 days', 1),
                const SizedBox(width: 8),
                _historyPeriodChip('Last 3 months', 2),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_historyItems.isEmpty)
            _buildEmptyHistory()
          else
            ..._historyItems.map(_buildHistoryTicketCard),
        ],
      ),
    );
  }

  Widget _historyPeriodChip(String label, int index) {
    final active = _historyPeriod == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() => _historyPeriod = index);
        },
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF2563EB) : AppColors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active ? const Color(0xFF2563EB) : AppColors.gray200,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: active ? AppColors.white : AppColors.gray600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        children: [
          Icon(Icons.history_rounded, size: 40, color: AppColors.gray300),
          const SizedBox(height: 12),
          Text(
            'No completed tickets',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.gray700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Completed tickets for this period will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.gray500),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTicketCard(SupportTicket item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (context) => StaffJobDetail(
                  job: _ticketToJobMap(item),
                  staffId: _staffId,
                  isHistoryTicket: true,
                ),
              ),
            );
          },
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border:
                  Border.all(color: AppColors.gray200.withValues(alpha: 0.85)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
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
                      _buildLabelChip('${item.type} SUPPORT'),
                      const Spacer(),
                      Text(
                        _formatFullDate(item.completedAt ?? item.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.gray400,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.place_outlined,
                          size: 18, color: AppColors.gray400),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.location,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.gray600,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.statusString,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF059669),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute<void>(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }
}
