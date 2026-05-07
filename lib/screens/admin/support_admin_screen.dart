import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/constants.dart';
import '../../utils/responsive.dart';
import '../../models/support_ticket.dart';
import '../../services/auth_service.dart';
import '../../services/support_service.dart';
import '../../models/user_role.dart';
import '../../widgets/modern_select_sheet.dart';
import '../../widgets/responsive_container.dart';
import '../../widgets/support_location_picker.dart';
import '../login_page.dart';
import 'support_staff_dashboard.dart';
import '../support/ticket_detail_view.dart';

class SupportAdminMobileScreen extends StatefulWidget {
  const SupportAdminMobileScreen({super.key});

  @override
  State<SupportAdminMobileScreen> createState() => _SupportAdminMobileScreenState();
}

class SupportAdminScreen extends StatelessWidget {
  const SupportAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return const SupportAdminMobileScreen();
    }
    return const SupportAdminWebScreen();
  }
}

class _SupportAdminMobileScreenState extends State<SupportAdminMobileScreen> {
  final TextEditingController _globalSearchController = TextEditingController();
  int _staffFilter = 0;

  final SupportService _supportService = SupportService();

  bool _isLoadingStaff = true;
  bool _isLoadingTickets = true;
  bool _isAssigning = false;
  String? _staffError;
  String? _ticketError;

  String _staffQuery = '';
  String _ticketTab = 'all'; // all | it | fm | critical
  String _sortBy = 'newest'; // newest | oldest
  String _ticketModuleFilter = 'all'; // all | IT | FM
  String _ticketStatusFilter = 'all'; // all | open | in_progress | completed
  String _ticketPriorityFilter = 'all'; // all | critical | standard

  List<_SupportStaffEntry> _staff = const [];
  List<SupportTicket> _supportTickets = const [];

  @override
  void initState() {
    super.initState();
    _globalSearchController.addListener(() {
      final v = _globalSearchController.text;
      if (v == _staffQuery) return;
      setState(() => _staffQuery = v);
    });
    _loadStaff();
    _loadTickets();
  }

  @override
  void dispose() {
    _globalSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadStaff() async {
    setState(() {
      _isLoadingStaff = true;
      _staffError = null;
    });
    try {
      await AuthService.instance.loadSession();
      final it = await AuthService.instance.fetchUsersByRole(UserRole.itStaff.apiName);
      final facilities =
          await AuthService.instance.fetchUsersByRole(UserRole.techStaff.apiName);

      final combined = <AuthRoleUser>[
        ...it,
        ...facilities.where((u) => it.every((other) => other.id != u.id)),
      ];

      if (!mounted) return;
      setState(() {
        _staff = combined
            .map((u) => _SupportStaffEntry(
                  id: u.id,
                  name: u.displayName,
                  roleType: it.any((x) => x.id == u.id) ? StaffRoleType.it : StaffRoleType.fm,
                  roleLabel: it.any((x) => x.id == u.id) ? 'IT Support' : 'Facilities',
                ))
            .toList(growable: false);
        _isLoadingStaff = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _staffError = e.toString().replaceFirst('Exception: ', '');
        _isLoadingStaff = false;
      });
    }
  }

  Future<void> _loadTickets() async {
    setState(() {
      _isLoadingTickets = true;
      _ticketError = null;
    });
    try {
      await AuthService.instance.loadSession();
      final tickets = await _supportService.fetchAllRequests();
      if (!mounted) return;
      setState(() {
        _supportTickets = tickets;
        _isLoadingTickets = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _ticketError = e.toString().replaceFirst('Exception: ', '');
        _isLoadingTickets = false;
      });
    }
  }

  List<_SupportStaffEntry> get _filteredStaff {
    final q = _staffQuery.trim().toLowerCase();
    return _staff.where((s) {
      final matchesQuery = q.isEmpty || s.name.toLowerCase().contains(q);
      final matchesFilter = _staffFilter == 0 ||
          (_staffFilter == 1 && s.roleType == StaffRoleType.it) ||
          (_staffFilter == 2 && s.roleType == StaffRoleType.fm);
      return matchesQuery && matchesFilter;
    }).toList(growable: false);
  }

  List<SupportTicket> get _filteredTickets {
    var items = _supportTickets.where((t) {
      final matchModule = _ticketModuleFilter == 'all' ||
          t.type.toLowerCase() == _ticketModuleFilter.toLowerCase();
      final statusKey = t.status == TicketStatus.inProgress
          ? 'in_progress'
          : t.status == TicketStatus.completed
              ? 'completed'
              : 'open';
      final matchStatus =
          _ticketStatusFilter == 'all' || _ticketStatusFilter == statusKey;
      final priorityKey =
          t.priority == TicketPriority.critical ? 'critical' : 'standard';
      final matchPriority =
          _ticketPriorityFilter == 'all' || _ticketPriorityFilter == priorityKey;
      final active = t.status != TicketStatus.cancelled &&
          t.status != TicketStatus.completed;
      if (!(active && matchModule && matchStatus && matchPriority)) return false;

      if (_ticketTab == 'it' && t.type != 'IT') return false;
      if (_ticketTab == 'fm' && t.type != 'FM') return false;
      if (_ticketTab == 'critical' && t.priority != TicketPriority.critical) {
        return false;
      }
      return true;
    }).toList(growable: false);

    int byTime(SupportTicket a, SupportTicket b) {
      final ad = DateTime.tryParse(a.createdAt)?.millisecondsSinceEpoch ?? 0;
      final bd = DateTime.tryParse(b.createdAt)?.millisecondsSinceEpoch ?? 0;
      return _sortBy == 'oldest' ? ad.compareTo(bd) : bd.compareTo(ad);
    }

    items = [...items]..sort(byTime);
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        titleSpacing: 0,
        toolbarHeight: 76,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Dispatcher', style: AppTextStyles.moduleAppBarTitle),
            SizedBox(height: 4),
            const Text(
              'Support Operations',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.gray500,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none_rounded,
                      color: AppColors.gray700),
                  tooltip: 'Notifications',
                  onPressed: _openNotificationsSheet,
                ),
              ],
            ),
          ),
        ],
      ),
      body: _buildTicketsTab(context),
    );
  }

  Widget _buildStaffTab(BuildContext context) {
    return ResponsiveContainer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Staff Directory'),
            const SizedBox(height: 8),
            TextField(
              controller: _globalSearchController,
              decoration: InputDecoration(
                hintText: 'Search staff, skills, or specialization',
                prefixIcon: const Icon(Icons.search, color: AppColors.gray400),
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.gray200),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _buildFilterChip('All Staff', 0),
                _buildFilterChip('IT Support', 1),
                _buildFilterChip('Facilities', 2),
              ],
            ),
            const SizedBox(height: 12),
            if (_isLoadingStaff)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_staffError != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.cloud_off, color: AppColors.gray300, size: 40),
                      const SizedBox(height: 8),
                      Text(
                        _staffError!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.gray600),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _loadStaff,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else ..._filteredStaff.map(_buildStaffCard),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketsTab(BuildContext context) {
    return ResponsiveContainer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'Active Tickets',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        color: AppColors.gray900,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              DispatcherHistoryScreen(tickets: _supportTickets),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(Icons.history_rounded, size: 18),
                    label: const Text(
                      'History',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            _buildDispatcherFilterChips(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _openTicketFilters,
                      icon: const Icon(Icons.tune_rounded, size: 20),
                      label: const Text('Filter'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.gray900,
                        backgroundColor: AppColors.white,
                        side: const BorderSide(color: AppColors.gray200),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _isAssigning ? null : _assignNewTaskFlow,
                      icon: const Icon(Icons.add_task_rounded, size: 20),
                      label: const Text('New task'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        disabledForegroundColor: AppColors.white.withValues(alpha: 0.7),
                        disabledBackgroundColor: AppColors.gray300,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoadingTickets)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_ticketError != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.cloud_off, color: AppColors.gray300, size: 40),
                      const SizedBox(height: 8),
                      Text(
                        _ticketError!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.gray600),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _loadTickets,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_filteredTickets.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.gray100,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(Icons.inbox_outlined,
                            size: 32, color: AppColors.gray400),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No active tickets',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.gray900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'New requests will show up here when available.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: AppColors.gray600),
                      ),
                    ],
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: Column(
                  children: _filteredTickets.map(_buildTicketCard).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDispatcherStatsRow() {
    final open = _supportTickets.where((t) =>
        t.status != TicketStatus.completed && t.status != TicketStatus.cancelled);
    final total = open.length;
    final unassigned =
        open.where((t) => t.status == TicketStatus.newTicket).length;
    final inProgress = open.where((t) => t.status == TicketStatus.inProgress).length;
    final completed = _supportTickets.where((t) => t.status == TicketStatus.completed).length;

    Widget stat({
      required IconData icon,
      required String label,
      required int value,
      required Color color,
    }) {
      return Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.gray200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray600,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$value',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.gray900,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: stat(
                icon: Icons.receipt_long_outlined,
                label: 'Total requests',
                value: total,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: stat(
                icon: Icons.priority_high_rounded,
                label: 'Unassigned',
                value: unassigned,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: stat(
                icon: Icons.timelapse_rounded,
                label: 'In progress',
                value: inProgress,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: stat(
                icon: Icons.check_circle_outline,
                label: 'Completed',
                value: completed,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDispatcherFilterChips() {
    Widget chip(String id, String label) {
      final active = _ticketTab == id;
      return FilterChip(
        selected: active,
        showCheckmark: false,
        label: Text(
          label,
          style: TextStyle(
            color: active ? AppColors.primary : AppColors.gray700,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
        onSelected: (_) => setState(() => _ticketTab = id),
        selectedColor: AppColors.primary.withValues(alpha: 0.12),
        backgroundColor: AppColors.white,
        side: BorderSide(
          color: active ? AppColors.primary.withValues(alpha: 0.45) : AppColors.gray200,
          width: 1,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        labelPadding: const EdgeInsets.symmetric(horizontal: 10),
      );
    }

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          chip('all', 'All'),
          const SizedBox(width: 8),
          chip('it', 'IT'),
          const SizedBox(width: 8),
          chip('fm', 'FM'),
          const SizedBox(width: 8),
          chip('critical', 'Critical'),
          const SizedBox(width: 10),
          Material(
            color: AppColors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: AppColors.gray200),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 4),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _sortBy,
                  isDense: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: AppColors.gray500, size: 22),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'newest', child: Text('Newest')),
                    DropdownMenuItem(value: 'oldest', child: Text('Oldest')),
                  ],
                  onChanged: (v) => setState(() => _sortBy = v ?? 'newest'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.gray900,
      ),
    );
  }

  void _openGlobalSearchSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Global Search',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search staff, tickets, locations...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AppColors.gray50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.gray200),
                  ),
                ),
                onSubmitted: (_) {
                  Navigator.pop(context);
                  _showSnackBar('Search submitted (mock).');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _openNotificationsSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Notifications',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12),
              ListTile(
                leading: Icon(Icons.warning_amber_outlined, color: Colors.orange),
                title: Text('SLA warning'),
                subtitle: Text('Wi-Fi outage pending'),
              ),
              ListTile(
                leading: Icon(Icons.check_circle_outline, color: Colors.green),
                title: Text('Ticket resolved'),
                subtitle: Text('Printer issue closed'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openSettingsSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Session',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _logout();
                },
                icon: const Icon(Icons.logout),
                label: const Text('Log out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: AppColors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isActive = _staffFilter == index;
    return ChoiceChip(
      label: Text(label),
      selected: isActive,
      onSelected: (_) => setState(() => _staffFilter = index),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.gray100,
      labelStyle: TextStyle(
        color: isActive ? AppColors.white : AppColors.gray700,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildStaffCard(_SupportStaffEntry item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: InkWell(
        onTap: () {
          // This screen is an admin directory; the staff portal uses the
          // currently logged-in staff identity, so we keep tap as no-op for now.
        },
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: const Icon(Icons.person, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.roleLabel,
                    style: const TextStyle(fontSize: 12, color: AppColors.gray600),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: _isAssigning
                      ? null
                      : () => _assignTicketToStaffFlow(staff: item),
                  child: const Text('Assign'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketCard(SupportTicket item) {
    final isCritical = item.priority == TicketPriority.critical;
    final badgeColor = isCritical ? const Color(0xFFB91C1C) : AppColors.primary;
    final badgeBg =
        isCritical ? const Color(0xFFFEE2E2) : AppColors.primary.withValues(alpha: 0.1);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.white,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.gray200),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TicketDetailView(ticket: item),
              ),
            );
          },
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                          color: AppColors.gray900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.priorityString,
                        style: TextStyle(
                          fontSize: 11,
                          color: badgeColor,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Icon(
                        Icons.place_outlined,
                        size: 15,
                        color: AppColors.gray400,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.location.trim().isEmpty
                            ? 'Location not specified'
                            : item.location,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          color: item.location.trim().isEmpty
                              ? AppColors.gray400
                              : AppColors.gray600,
                          fontStyle: item.location.trim().isEmpty
                              ? FontStyle.italic
                              : FontStyle.normal,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.tonalIcon(
                    onPressed: _isAssigning
                        ? null
                        : () {
                            _assignTicket(item);
                          },
                    icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
                    label: const Text('Assign'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                      foregroundColor: AppColors.primaryDark,
                      disabledForegroundColor: AppColors.gray400,
                      disabledBackgroundColor: AppColors.gray100,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _openTicketFilters() async {
    final status = await showModernSelectSheet<String>(
      context: context,
      title: 'Filter tickets',
      options: const [
        SelectOption(value: 'all', label: 'All active'),
        SelectOption(value: 'open', label: 'Open'),
        SelectOption(value: 'in_progress', label: 'In Progress'),
      ],
      selectedValue: _ticketStatusFilter,
      accentColor: AppColors.primary,
    );
    if (!mounted || status == null) return;
    final module = await showModernSelectSheet<String>(
      context: context,
      title: 'Filter module',
      options: const [
        SelectOption(value: 'all', label: 'All'),
        SelectOption(value: 'IT', label: 'IT'),
        SelectOption(value: 'FM', label: 'Facilities'),
      ],
      selectedValue: _ticketModuleFilter,
      accentColor: AppColors.primary,
    );
    if (!mounted) return;
    final priority = await showModernSelectSheet<String>(
      context: context,
      title: 'Filter priority',
      options: const [
        SelectOption(value: 'all', label: 'All'),
        SelectOption(value: 'critical', label: 'Critical'),
        SelectOption(value: 'standard', label: 'Standard'),
      ],
      selectedValue: _ticketPriorityFilter,
      accentColor: AppColors.primary,
    );
    if (!mounted) return;
    setState(() {
      _ticketStatusFilter = status;
      if (module != null) _ticketModuleFilter = module;
      if (priority != null) _ticketPriorityFilter = priority;
    });
  }

  Future<void> _assignNewTaskFlow() async {
    final tickets = _filteredTickets;
    if (tickets.isEmpty) {
      _showSnackBar('No active tickets to assign.');
      return;
    }
    final selectedTicket = await showModernSelectSheet<SupportTicket>(
      context: context,
      title: 'Select ticket',
      options: tickets
          .map((t) => SelectOption(
                value: t,
                label: '#${t.id} • ${t.title}',
                icon: Icons.confirmation_number_outlined,
              ))
          .toList(growable: false),
      accentColor: AppColors.primary,
    );
    if (!mounted || selectedTicket == null) return;
    await _assignTicket(selectedTicket);
  }

  Future<void> _assignTicketToStaffFlow({required _SupportStaffEntry staff}) async {
    final tickets = _filteredTickets;
    if (tickets.isEmpty) {
      _showSnackBar('No active tickets to assign.');
      return;
    }
    final selectedTicket = await showModernSelectSheet<SupportTicket>(
      context: context,
      title: 'Select ticket for ${staff.name}',
      options: tickets
          .map((t) => SelectOption(
                value: t,
                label: '#${t.id} • ${t.title}',
                icon: Icons.confirmation_number_outlined,
              ))
          .toList(growable: false),
      accentColor: AppColors.primary,
    );
    if (!mounted || selectedTicket == null) return;
    await _assignTicket(selectedTicket, preselectedStaffId: staff.id);
  }

  Future<void> _assignTicket(
    SupportTicket ticket, {
    String? preselectedStaffId,
  }) async {
    final requestId = ticket.requestId;
    if (requestId == null) {
      _showSnackBar('This ticket has no requestId (cannot assign).');
      return;
    }

    final staffId = preselectedStaffId ??
        await showModernSelectSheet<String>(
          context: context,
          title: 'Assign to staff',
          options: _filteredStaff
              .map((s) => SelectOption(
                    value: s.id,
                    label: s.name,
                    icon: s.roleType == StaffRoleType.it
                        ? Icons.computer_outlined
                        : Icons.home_repair_service_outlined,
                  ))
              .toList(growable: false),
          accentColor: AppColors.primary,
        );
    if (!mounted || staffId == null) return;

    setState(() => _isAssigning = true);
    try {
      await AuthService.instance.loadSession();
      final dispatcherId = AuthService.instance.studentId;
      if (dispatcherId == null || dispatcherId.trim().isEmpty) {
        throw Exception('Authentication required. Please sign in again.');
      }
      await _supportService.assignRequest(
        requestId: requestId,
        dispatcherId: dispatcherId,
        staffId: staffId,
        dispatcherInstructions: '',
      );
      if (!mounted) return;
      _showSnackBar('Ticket assigned.');
      await _loadTickets();
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isAssigning = false);
    }
  }

}

class _SupportStaffEntry {
  final String id;
  final String name;
  final String roleLabel;
  final StaffRoleType roleType;

  const _SupportStaffEntry({
    required this.id,
    required this.name,
    required this.roleLabel,
    required this.roleType,
  });
}

class SupportAdminWebScreen extends StatefulWidget {
  const SupportAdminWebScreen({super.key});

  @override
  State<SupportAdminWebScreen> createState() => _SupportAdminWebScreenState();
}

class _SupportAdminWebScreenState extends State<SupportAdminWebScreen> {
  final SupportService _supportService = SupportService();
  bool _isLoading = true;
  String? _error;

  List<SupportTicket> _tickets = const [];
  List<_SupportStaffEntry> _staff = const [];

  String _moduleFilter = 'all'; // all | IT | FM
  String _priorityFilter = 'all'; // all | critical | standard
  String _statusFilter = 'open'; // open | completed

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await AuthService.instance.loadSession();
      final it =
          await AuthService.instance.fetchUsersByRole(UserRole.itStaff.apiName);
      final facilities =
          await AuthService.instance.fetchUsersByRole(UserRole.techStaff.apiName);
      final combined = <AuthRoleUser>[
        ...it,
        ...facilities.where((u) => it.every((other) => other.id != u.id)),
      ];

      final tickets = await _supportService.fetchAllRequests();
      if (!mounted) return;
      setState(() {
        _staff = combined
            .map((u) => _SupportStaffEntry(
                  id: u.id,
                  name: u.displayName,
                  roleType:
                      it.any((x) => x.id == u.id) ? StaffRoleType.it : StaffRoleType.fm,
                  roleLabel:
                      it.any((x) => x.id == u.id) ? 'IT Support' : 'Facilities',
                ))
            .toList(growable: false);
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

  List<SupportTicket> get _filteredTickets {
    return _tickets.where((t) {
      final matchesModule = _moduleFilter == 'all' ||
          t.type.toLowerCase() == _moduleFilter.toLowerCase();
      final matchesPriority = _priorityFilter == 'all' ||
          (_priorityFilter == 'critical' &&
              t.priority == TicketPriority.critical) ||
          (_priorityFilter == 'standard' &&
              t.priority != TicketPriority.critical);
      final isCompleted = t.status == TicketStatus.completed;
      final matchesStatus = _statusFilter == 'completed' ? isCompleted : !isCompleted;
      return matchesModule && matchesPriority && matchesStatus;
    }).toList(growable: false);
  }

  int get _totalRequests => _filteredTickets.length;
  int get _unassigned =>
      _filteredTickets.where((t) => t.status == TicketStatus.newTicket).length;
  int get _inProgress =>
      _filteredTickets.where((t) => t.status == TicketStatus.inProgress).length;
  int get _completed => _tickets.where((t) => t.status == TicketStatus.completed).length;

  Future<void> _assignTicket(SupportTicket ticket) async {
    final requestId = ticket.requestId;
    if (requestId == null) {
      _snack('Ticket missing requestId.');
      return;
    }

    final staffId = await showModernSelectSheet<String>(
      context: context,
      title: 'Select staff member',
      options: _staff
          .where((s) =>
              _moduleFilter == 'all' ||
              (_moduleFilter == 'IT' && s.roleType == StaffRoleType.it) ||
              (_moduleFilter == 'FM' && s.roleType == StaffRoleType.fm))
          .map((s) => SelectOption(
                value: s.id,
                label: s.name,
                icon: s.roleType == StaffRoleType.it
                    ? Icons.computer_outlined
                    : Icons.home_repair_service_outlined,
              ))
          .toList(growable: false),
      accentColor: AppColors.primary,
    );
    if (!mounted || staffId == null) return;

    try {
      await AuthService.instance.loadSession();
      final dispatcherId = AuthService.instance.studentId;
      if (dispatcherId == null || dispatcherId.trim().isEmpty) {
        throw Exception('Authentication required.');
      }
      await _supportService.assignRequest(
        requestId: requestId,
        dispatcherId: dispatcherId,
        staffId: staffId,
        dispatcherInstructions: '',
      );
      _snack('Assigned.');
      await _load();
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Request Dispatcher',
          style: TextStyle(
            color: AppColors.gray900,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          OutlinedButton.icon(
            onPressed: _openWebStaffDirectory,
            icon: const Icon(Icons.groups_outlined, size: 18),
            label: const Text('Staff'),
          ),
          const SizedBox(width: 10),
          OutlinedButton(
            onPressed: () => setState(() => _statusFilter = 'completed'),
            child: const Text('History'),
          ),
          const SizedBox(width: 10),
          const SizedBox(width: 14),
        ],
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.cloud_off,
                              color: AppColors.gray300, size: 44),
                          const SizedBox(height: 8),
                          Text(_error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.gray700)),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: _load,
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : _buildContent(),
        ),
      ),
    );
  }

  Future<void> _openCreateTaskDialog() async {
    await AuthService.instance.loadSession();
    final dispatcherId = AuthService.instance.studentId;
    if (dispatcherId == null || dispatcherId.trim().isEmpty) {
      _snack('Authentication required.');
      return;
    }

    final staffOptions = _staff;
    String? assigneeId;
    String instructions = '';
    String module = 'IT';
    SupportLocationValue location = const SupportLocationValue(
      type: SupportLocationType.building,
    );
    String description = '';
    TicketPriority urgency = TicketPriority.standard;
    int? categoryId;
    List<SupportCategoryOption> categories = const [];
    bool saving = false;
    String? localError;

    Future<void> loadCats(StateSetter setModal) async {
      try {
        final data = await _supportService.fetchCategories(module: module);
        setModal(() {
          categories = data;
          if (categories.isNotEmpty) categoryId ??= categories.first.id;
        });
      } catch (e) {
        setModal(() => localError = e.toString().replaceFirst('Exception: ', ''));
      }
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            if (categories.isEmpty && localError == null) {
              // One-shot load.
              loadCats(setModal);
            }

            return Dialog(
              insetPadding: const EdgeInsets.all(18),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860, maxHeight: 720),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 14, 14, 6),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: saving ? null : () => Navigator.pop(ctx),
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                          const SizedBox(width: 6),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Assign New Task',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800)),
                                SizedBox(height: 2),
                                Text(
                                  'Create a new IT or Facilities task and assign it to a staff member.',
                                  style: TextStyle(
                                      fontSize: 12, color: AppColors.gray500),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (saving)
                            const Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (localError != null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFFECACA)),
                                ),
                                child: Text(localError!,
                                    style: const TextStyle(
                                        color: Color(0xFF991B1B))),
                              ),
                              const SizedBox(height: 12),
                            ],
                            _webSectionTitle('0  Assigned Staff & Instructions *'),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                SizedBox(
                                  width: 360,
                                  child: DropdownButtonFormField<String>(
                                    value: assigneeId,
                                    items: staffOptions
                                        .map((s) => DropdownMenuItem(
                                              value: s.id,
                                              child: Text(s.name),
                                            ))
                                        .toList(growable: false),
                                    onChanged: saving
                                        ? null
                                        : (v) => setModal(() => assigneeId = v),
                                    decoration: InputDecoration(
                                      labelText: 'Select staff member',
                                      filled: true,
                                      fillColor: AppColors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 440,
                                  child: TextField(
                                    enabled: !saving,
                                    onChanged: (v) => instructions = v,
                                    minLines: 2,
                                    maxLines: 3,
                                    decoration: InputDecoration(
                                      labelText:
                                          'Internal instructions or notes (optional)',
                                      filled: true,
                                      fillColor: AppColors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            _webSectionTitle('1  Issue Category *'),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 10,
                              children: [
                                ChoiceChip(
                                  selected: module == 'IT',
                                  label: const Text('IT & Network'),
                                  onSelected: saving
                                      ? null
                                      : (_) => setModal(() {
                                            module = 'IT';
                                            categories = const [];
                                            categoryId = null;
                                          }),
                                ),
                                ChoiceChip(
                                  selected: module == 'FM',
                                  label: const Text('Facilities (FM)'),
                                  onSelected: saving
                                      ? null
                                      : (_) => setModal(() {
                                            module = 'FM';
                                            categories = const [];
                                            categoryId = null;
                                          }),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: 360,
                              child: DropdownButtonFormField<int>(
                                value: categoryId,
                                items: categories
                                    .map((c) => DropdownMenuItem(
                                          value: c.id,
                                          child: Text(c.name),
                                        ))
                                    .toList(growable: false),
                                onChanged: saving
                                    ? null
                                    : (v) => setModal(() => categoryId = v),
                                decoration: InputDecoration(
                                  labelText: 'Select issue type',
                                  filled: true,
                                  fillColor: AppColors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            _webSectionTitle('2  Location *'),
                            const SizedBox(height: 8),
                            SupportLocationPicker(
                              initialValue: location,
                              accentColor: AppColors.primary,
                              onChanged: (v) => location = v,
                            ),
                            const SizedBox(height: 18),
                            _webSectionTitle('3  Detailed Description *'),
                            const SizedBox(height: 8),
                            TextField(
                              enabled: !saving,
                              minLines: 4,
                              maxLines: 6,
                              onChanged: (v) => description = v,
                              decoration: InputDecoration(
                                hintText:
                                    'Provide as much detail as possible about the task or issue...',
                                filled: true,
                                fillColor: AppColors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            _webSectionTitle('5  Urgency Level *'),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                _urgencyCard(
                                  selected: urgency != TicketPriority.critical,
                                  title: 'Standard',
                                  subtitle:
                                      'Routine work that does not affect safety or critical operations.',
                                  onTap: saving
                                      ? null
                                      : () => setModal(
                                          () => urgency = TicketPriority.standard,
                                        ),
                                ),
                                _urgencyCard(
                                  selected: urgency == TicketPriority.critical,
                                  title: 'Critical',
                                  subtitle:
                                      'Safety hazards, facility-wide outages, or issues preventing essential work.',
                                  onTap: saving
                                      ? null
                                      : () => setModal(
                                          () => urgency = TicketPriority.critical,
                                        ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      child: Row(
                        children: [
                          TextButton(
                            onPressed: saving ? null : () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          const Spacer(),
                          FilledButton(
                            onPressed: saving
                                ? null
                                : () async {
                                    if (!(location.isComplete)) {
                                      setModal(() => localError = 'Location is required.');
                                      return;
                                    }
                                    if ((description.trim()).isEmpty) {
                                      setModal(() => localError = 'Description is required.');
                                      return;
                                    }
                                    if (categoryId == null || categoryId == 0) {
                                      setModal(() => localError = 'Category is required.');
                                      return;
                                    }

                                    setModal(() {
                                      saving = true;
                                      localError = null;
                                    });
                                    try {
                                      final id = await _supportService.createRequest(
                                        memberId: dispatcherId,
                                        area: module,
                                        categoryId: categoryId!,
                                        location: location,
                                        description: description.trim(),
                                        urgency: urgency,
                                        attachmentPaths: const [],
                                      );
                                      if (id <= 0) {
                                        throw Exception('Request creation failed.');
                                      }

                                      if (instructions.trim().isNotEmpty) {
                                        await _supportService.setDispatcherInstructions(
                                          requestId: id,
                                          dispatcherId: dispatcherId,
                                          instructions: instructions.trim(),
                                        );
                                      }

                                      if (assigneeId != null &&
                                          assigneeId!.isNotEmpty) {
                                        await _supportService.assignRequest(
                                          requestId: id,
                                          dispatcherId: dispatcherId,
                                          staffId: assigneeId!,
                                          dispatcherInstructions:
                                              instructions.trim(),
                                        );
                                      }

                                      if (!mounted) return;
                                      Navigator.pop(ctx);
                                      _snack('Task created.');
                                      await _load();
                                    } catch (e) {
                                      setModal(() {
                                        localError =
                                            e.toString().replaceFirst('Exception: ', '');
                                      });
                                    } finally {
                                      setModal(() => saving = false);
                                    }
                                  },
                            child: const Text('Create Task'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openWebStaffDirectory() async {
    if (_staff.isEmpty) {
      _snack('No staff loaded.');
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        String q = '';
        String role = 'all'; // all | it | fm
        return StatefulBuilder(
          builder: (ctx, setModal) {
            final filtered = _staff.where((s) {
              final matchRole = role == 'all' ||
                  (role == 'it' && s.roleType == StaffRoleType.it) ||
                  (role == 'fm' && s.roleType == StaffRoleType.fm);
              final matchQuery =
                  q.trim().isEmpty || s.name.toLowerCase().contains(q.trim().toLowerCase());
              return matchRole && matchQuery;
            }).toList(growable: false);

            Widget chip(String id, String label) {
              final active = id == role;
              return ChoiceChip(
                selected: active,
                label: Text(label),
                onSelected: (_) => setModal(() => role = id),
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.white,
                labelStyle: TextStyle(
                  color: active ? AppColors.white : AppColors.gray700,
                  fontWeight: FontWeight.w700,
                ),
                side: BorderSide(color: AppColors.gray200),
              );
            }

            return Dialog(
              insetPadding: const EdgeInsets.all(18),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760, maxHeight: 650),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 16, 16, 12),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Staff Directory',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.gray900,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(ctx),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            onChanged: (v) => setModal(() => q = v),
                            decoration: InputDecoration(
                              hintText: 'Search staff...',
                              prefixIcon: const Icon(Icons.search_rounded),
                              filled: true,
                              fillColor: AppColors.gray50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppColors.gray200),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppColors.gray200),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            children: [
                              chip('all', 'All'),
                              chip('it', 'IT Support'),
                              chip('fm', 'Facilities'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) {
                          final s = filtered[i];

                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.gray200),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor:
                                      AppColors.primary.withValues(alpha: 0.10),
                                  child: const Icon(Icons.person,
                                      color: AppColors.primary),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        s.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.gray900,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        s.roleLabel,
                                        style: const TextStyle(
                                            fontSize: 12, color: AppColors.gray600),
                                      ),
                                    ],
                                  ),
                                ),
                                FilledButton(
                                  onPressed: () async {
                                    Navigator.pop(ctx);
                                    final tickets = _filteredTickets;
                                    if (tickets.isEmpty) {
                                      _snack('No active tickets to assign.');
                                      return;
                                    }
                                    final selectedTicket =
                                        await showModernSelectSheet<SupportTicket>(
                                      context: context,
                                      title: 'Select ticket for ${s.name}',
                                      options: tickets
                                          .map((t) => SelectOption(
                                                value: t,
                                                label: '#${t.id} • ${t.title}',
                                                icon: Icons
                                                    .confirmation_number_outlined,
                                              ))
                                          .toList(growable: false),
                                      accentColor: AppColors.primary,
                                    );
                                    if (!mounted || selectedTicket == null) return;
                                    await _assignTicket(selectedTicket);
                                  },
                                  child: const Text('Assign'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _webSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: AppColors.gray900,
      ),
    );
  }

  Widget _urgencyCard({
    required bool selected,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    return SizedBox(
      width: 360,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary.withValues(alpha: 0.06) : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.gray200,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, color: AppColors.gray900)),
              const SizedBox(height: 6),
              Text(subtitle,
                  style: const TextStyle(fontSize: 12, color: AppColors.gray600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(
            'Central dashboard for IT and Facilities tickets across campus.',
            style: TextStyle(color: AppColors.gray600),
          ),
          const SizedBox(height: 16),
          _statsRow(),
          const SizedBox(height: 18),
          _filtersRow(),
          const SizedBox(height: 12),
          _ticketsTable(),
        ],
      ),
    );
  }

  Widget _statsRow() {
    Widget card(IconData icon, String label, String value, Color color, String sub) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.gray200),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            color: AppColors.gray600,
                            fontWeight: FontWeight.w600,
                            fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(value,
                        style: const TextStyle(
                            color: AppColors.gray900,
                            fontWeight: FontWeight.w800,
                            fontSize: 20)),
                    const SizedBox(height: 2),
                    Text(sub,
                        style: const TextStyle(
                            color: AppColors.gray500, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        card(Icons.receipt_long_outlined, 'Total Requests', '$_totalRequests',
            AppColors.primary, 'Shown in current view'),
        const SizedBox(width: 12),
        card(Icons.priority_high_rounded, 'Unassigned', '$_unassigned',
            Colors.orange, 'Needs assignment'),
        const SizedBox(width: 12),
        card(Icons.timelapse_rounded, 'In Progress', '$_inProgress', Colors.indigo,
            'Currently active'),
        const SizedBox(width: 12),
        card(Icons.check_circle_outline, 'Completed', '$_completed', Colors.green,
            'Closed in history'),
      ],
    );
  }

  Widget _filtersRow() {
    Widget chip(String id, String label, String group, void Function(String) set) {
      final active = id == group;
      return ChoiceChip(
        selected: active,
        label: Text(label),
        onSelected: (_) => set(id),
        selectedColor: AppColors.gray900,
        backgroundColor: AppColors.white,
        labelStyle: TextStyle(
          color: active ? AppColors.white : AppColors.gray700,
          fontWeight: FontWeight.w700,
        ),
        side: BorderSide(color: AppColors.gray200),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        chip('all', 'All Tickets', _moduleFilter, (v) => setState(() => _moduleFilter = v)),
        chip('IT', 'IT Only', _moduleFilter, (v) => setState(() => _moduleFilter = v)),
        chip('FM', 'FM Only', _moduleFilter, (v) => setState(() => _moduleFilter = v)),
        chip('high', 'High Priority', _priorityFilter, (v) => setState(() => _priorityFilter = v)),
        const SizedBox(width: 14),
        DropdownButton<String>(
          value: _statusFilter,
          items: const [
            DropdownMenuItem(value: 'open', child: Text('All Open')),
            DropdownMenuItem(value: 'completed', child: Text('Completed')),
          ],
          onChanged: (v) => setState(() => _statusFilter = v ?? 'open'),
        ),
      ],
    );
  }

  Widget _ticketsTable() {
    final rows = _filteredTickets;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gray200),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Request Details')),
            DataColumn(label: Text('Location')),
            DataColumn(label: Text('Priority')),
            DataColumn(label: Text('Dispatcher Action')),
          ],
          rows: rows.map((t) {
            final pr =
                t.priority == TicketPriority.critical ? 'Critical' : 'Standard';
            final prColor =
                t.priority == TicketPriority.critical ? Colors.red : Colors.green;
            return DataRow(cells: [
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${t.type} • #${t.id}',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.gray500)),
                    const SizedBox(height: 2),
                    Text(t.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.gray900)),
                  ],
                ),
              ),
              DataCell(Text(t.location.isEmpty ? 'Location not specified' : t.location)),
              DataCell(
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: prColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(pr,
                      style: TextStyle(
                          color: prColor, fontWeight: FontWeight.w700, fontSize: 12)),
                ),
              ),
              DataCell(
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () => _assignTicket(t),
                      child: const Text('Select Technician'),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: () => _assignTicket(t),
                      child: const Text('Confirm →'),
                    ),
                  ],
                ),
              ),
            ]);
          }).toList(growable: false),
        ),
      ),
    );
  }
}

class DispatcherHistoryScreen extends StatefulWidget {
  const DispatcherHistoryScreen({super.key, required this.tickets});

  final List<SupportTicket> tickets;

  @override
  State<DispatcherHistoryScreen> createState() => _DispatcherHistoryScreenState();
}

class _DispatcherHistoryScreenState extends State<DispatcherHistoryScreen>
    with SingleTickerProviderStateMixin {
  int _period = 1; // 0=7d, 1=30d, 2=3m, 3=custom

  DateTime? _cutoff() {
    final now = DateTime.now();
    switch (_period) {
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

  DateTime? _closedAt(SupportTicket t) {
    final raw = t.completedAt ?? t.createdAt;
    return DateTime.tryParse(raw)?.toLocal();
  }

  List<SupportTicket> _filtered(String tab) {
    final cutoff = _cutoff();
    final closed = widget.tickets.where((t) =>
        t.status == TicketStatus.completed || t.status == TicketStatus.cancelled);

    final byTab = closed.where((t) {
      if (tab == 'completed') return t.status == TicketStatus.completed;
      if (tab == 'cancelled') return t.status == TicketStatus.cancelled;
      return true; // all
    });

    final byTime = byTab.where((t) {
      if (cutoff == null) return true;
      final when = _closedAt(t);
      return when == null || !when.isBefore(cutoff);
    }).toList(growable: false);

    byTime.sort((a, b) {
      final ad = _closedAt(a)?.millisecondsSinceEpoch ?? 0;
      final bd = _closedAt(b)?.millisecondsSinceEpoch ?? 0;
      return bd.compareTo(ad);
    });
    return byTime;
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const Text(
            'Dispatcher History',
            style: TextStyle(
              color: AppColors.gray900,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          bottom: const TabBar(
            dividerColor: Colors.transparent,
            tabs: [
              Tab(text: 'All Closed'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Time period',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gray600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Row(
                  children: [
                    _periodChip('Last 7 days', 0),
                    const SizedBox(width: 8),
                    _periodChip('Last 30 days', 1),
                    const SizedBox(width: 8),
                    _periodChip('Last 3 months', 2),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _HistoryList(items: _filtered('all'), closedAt: _closedAt),
                    _HistoryList(
                        items: _filtered('completed'), closedAt: _closedAt),
                    _HistoryList(
                        items: _filtered('cancelled'), closedAt: _closedAt),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _periodChip(String label, int index) {
    final active = _period == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _period = index),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF111827) : AppColors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active ? const Color(0xFF111827) : AppColors.gray200,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: active ? AppColors.white : AppColors.gray600,
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.items, required this.closedAt});

  final List<SupportTicket> items;
  final DateTime? Function(SupportTicket) closedAt;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.history_rounded, size: 44, color: AppColors.gray300),
              const SizedBox(height: 10),
              const Text(
                'No tickets for this period',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final dateFmt = DateFormat('d MMM yyyy • HH:mm');

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final t = items[i];
        final isCompleted = t.status == TicketStatus.completed;
        final pillColor =
            isCompleted ? const Color(0xFF059669) : const Color(0xFFDC2626);
        final closed = closedAt(t);
        final closedStr = closed != null ? dateFmt.format(closed) : '';

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TicketDetailView(
                    ticket: t,
                    showContactStaffAction: true,
                    showCancelAction: false,
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.gray200),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${t.type} SUPPORT',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.gray500,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          t.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.gray900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.place_outlined,
                                size: 16, color: AppColors.gray400),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                t.location.isEmpty
                                    ? 'Location not specified'
                                    : t.location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.gray500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (closedStr.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.access_time_rounded,
                                  size: 16, color: AppColors.gray400),
                              const SizedBox(width: 6),
                              Text(
                                closedStr,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.gray500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: pillColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      t.statusString,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: pillColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
