import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/support_ticket.dart';
import '../../utils/constants.dart';
import 'ticket_detail_view.dart';

class MyRequests extends StatefulWidget {
  const MyRequests({super.key});

  @override
  State<MyRequests> createState() => _MyRequestsState();
}

class _MyRequestsState extends State<MyRequests> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _typeFilter = 'all'; // all | IT | FM
  String _urgencyFilter = 'all'; // all | urgent | not_urgent
  final FocusNode _searchFocus = FocusNode();

  final List<SupportTicket> mockTickets = [
    SupportTicket(
      id: 'T-1234',
      title: 'Cannot connect to ADA-WiFi network',
      description: 'Unable to connect to the campus WiFi network',
      category: TicketCategory.wifiNetwork,
      status: TicketStatus.inProgress,
      priority: TicketPriority.high,
      location: 'Main Building - Floor 2',
      createdAt: DateTime.now().subtract(const Duration(hours: 11)).toIso8601String(),
      assignedTo: 'Farid Mammadov',
      type: 'IT',
    ),
    SupportTicket(
      id: 'T-1198',
      title: 'Projector not working in Lecture Hall 101',
      description: 'The projector in Lecture Hall 101 is not displaying anything',
      category: TicketCategory.projectorDisplay,
      status: TicketStatus.assigned,
      priority: TicketPriority.low,
      location: 'Lecture Hall 101',
      createdAt: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      assignedTo: 'Leyla Huseynova',
      type: 'FM',
    ),
    SupportTicket(
      id: 'T-1145',
      title: 'Cannot access Outlook email',
      description: 'Unable to log into Outlook email account',
      category: TicketCategory.emailOffice365,
      status: TicketStatus.assigned,
      priority: TicketPriority.low,
      location: 'Dormitory',
      createdAt: DateTime(2025, 11, 15).toIso8601String(),
      assignedTo: 'Support Team',
      type: 'IT',
    ),
    SupportTicket(
      id: 'T-1089',
      title: 'Need password reset for student portal',
      description: 'Forgot password for student portal',
      category: TicketCategory.passwordReset,
      status: TicketStatus.completed,
      priority: TicketPriority.low,
      location: 'Library',
      createdAt: DateTime(2025, 11, 10).toIso8601String(),
      completedAt: DateTime(2025, 11, 14).toIso8601String(),
      assignedTo: 'Aysel Aliyeva',
      rating: 5,
      type: 'IT',
    ),
    SupportTicket(
      id: 'T-0987',
      title: 'Printer not printing in Computer Lab A',
      description: 'Printer in Computer Lab A is not responding',
      category: TicketCategory.printerScanner,
      status: TicketStatus.completed,
      priority: TicketPriority.low,
      location: 'Computer Lab A',
      createdAt: DateTime(2025, 11, 8).toIso8601String(),
      completedAt: DateTime(2025, 11, 10).toIso8601String(),
      assignedTo: 'Rashad Hasanov',
      rating: 5,
      type: 'FM',
    ),
    SupportTicket(
      id: 'T-0856',
      title: 'Need Adobe Creative Suite installed',
      description: 'Request for Adobe Creative Suite installation',
      category: TicketCategory.softwareInstallation,
      status: TicketStatus.cancelled,
      priority: TicketPriority.low,
      location: 'Computer Lab B',
      createdAt: DateTime(2025, 11, 5).toIso8601String(),
      cancelledReason: 'Found alternative solution',
      type: 'IT',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  List<SupportTicket> get openTickets =>
      mockTickets.where((t) => t.status == TicketStatus.assigned || 
                               t.status == TicketStatus.inProgress).toList();

  List<SupportTicket> get completedTickets =>
      mockTickets.where((t) => t.status == TicketStatus.completed).toList();

  List<SupportTicket> get cancelledTickets =>
      mockTickets.where((t) => t.status == TicketStatus.cancelled).toList();

  bool get _hasFilters => _typeFilter != 'all' || _urgencyFilter != 'all';

  List<SupportTicket> _applySearchAndFilters(List<SupportTicket> tickets) {
    final q = _searchQuery.trim().toLowerCase();
    return tickets.where((t) {
      final matchQuery = q.isEmpty ||
          t.id.toLowerCase().contains(q) ||
          t.title.toLowerCase().contains(q) ||
          t.location.toLowerCase().contains(q);

      final matchType = _typeFilter == 'all' || t.type.toLowerCase() == _typeFilter.toLowerCase();

      final matchUrgency = _urgencyFilter == 'all' ||
          (_urgencyFilter == 'urgent' && t.priority == TicketPriority.high) ||
          (_urgencyFilter == 'not_urgent' && t.priority != TicketPriority.high);

      return matchQuery && matchType && matchUrgency;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildSearchRow(context),
            _buildSegmentedTabs(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTicketsList(_applySearchAndFilters(openTickets)),
                  _buildTicketsList(_applySearchAndFilters(completedTickets)),
                  _buildTicketsList(_applySearchAndFilters(cancelledTickets)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: AppColors.white,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.gray900, size: 20),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Requests',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray900,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Track your support tickets',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.gray600,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchRow(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 40,
            child: TextField(
              focusNode: _searchFocus,
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(fontSize: 14, color: AppColors.gray900),
              decoration: InputDecoration(
                hintText: 'Search by name or tag...',
                hintStyle: const TextStyle(fontSize: 13, color: AppColors.gray400),
                prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.gray400),
                prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 0),
                suffixIcon: GestureDetector(
                  onTap: () => _openFilterSheet(context),
                  child: Container(
                    width: 34,
                    height: 34,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.tune, size: 17, color: AppColors.primary),
                  ),
                ),
                suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 0),
                filled: true,
                fillColor: AppColors.gray50,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.gray200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.gray200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${_currentTabTickets.length} ticket${_currentTabTickets.length == 1 ? '' : 's'}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.gray500),
              ),
              if (_hasFilters) ...[
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => setState(() {
                    _typeFilter = 'all';
                    _urgencyFilter = 'all';
                  }),
                  child: const Text(
                    'Clear filters',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondary),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  List<SupportTicket> get _currentTabTickets {
    if (_tabController.index == 1) return _applySearchAndFilters(completedTickets);
    if (_tabController.index == 2) return _applySearchAndFilters(cancelledTickets);
    return _applySearchAndFilters(openTickets);
  }

  void _openFilterSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        var tmpType = _typeFilter;
        var tmpUrg = _urgencyFilter;

        Widget chip(String id, String label, String group, void Function(String) setModal) {
          final sel = id == group;
          return GestureDetector(
            onTap: () => setModal(id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: sel ? AppColors.primary : AppColors.gray100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: sel ? AppColors.white : AppColors.gray700,
                ),
              ),
            ),
          );
        }

        return StatefulBuilder(
          builder: (ctx, setModal) {
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 14, 20, MediaQuery.of(ctx).padding.bottom + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.gray300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filters',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.gray900),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: const Icon(Icons.close, size: 22, color: AppColors.gray500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Type',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gray600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      chip('all', 'All', tmpType, (v) => setModal(() => tmpType = v)),
                      chip('IT', 'IT', tmpType, (v) => setModal(() => tmpType = v)),
                      chip('FM', 'FM', tmpType, (v) => setModal(() => tmpType = v)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Urgency',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gray600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      chip('all', 'All', tmpUrg, (v) => setModal(() => tmpUrg = v)),
                      chip('urgent', 'Urgent', tmpUrg, (v) => setModal(() => tmpUrg = v)),
                      chip('not_urgent', 'Not urgent', tmpUrg, (v) => setModal(() => tmpUrg = v)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _typeFilter = tmpType;
                          _urgencyFilter = tmpUrg;
                        });
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: const Text('Apply', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSegmentedTabs() {
    final tabs = [
      (openTickets.length, 'Open', Icons.settings_outlined),
      (completedTickets.length, 'Completed', Icons.check_circle_outline),
      (cancelledTickets.length, 'Canceled', Icons.cancel_outlined),
    ];

    return Material(
      color: AppColors.backgroundLight,
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
                    onTap: () {
                      _tabController.animateTo(i);
                      setState(() {});
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            children: [
                              Icon(icon, size: 15, color: sel ? AppColors.primary : AppColors.gray500),
                              const SizedBox(width: 5),
                              Text(
                                label,
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

  Widget _buildTicketsList(List<SupportTicket> tickets) {
    if (tickets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: AppColors.gray300),
            const SizedBox(height: 16),
            Text(
              'No tickets',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.gray900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You don\'t have any tickets in this category',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.gray600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      itemCount: tickets.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _buildTicketCard(context, tickets[index]),
    );
  }

  Widget _buildTicketCard(BuildContext context, SupportTicket ticket) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TicketDetailView(ticket: ticket)),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '#${ticket.id}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.gray600),
                  ),
                  const Spacer(),
                  _buildPriorityBadge(ticket.priority),
                  const SizedBox(width: 6),
                  _buildStatusBadge(ticket.status),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Text(
                  'IT SERVICES',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                ticket.title,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.gray900, height: 1.2),
              ),
              const SizedBox(height: 8),
              _meta(Icons.location_on_outlined, ticket.location),
              _meta(Icons.access_time_outlined, 'Opened ${_getTimeAgo(ticket.createdAt)}'),
              _meta(
                Icons.person_outline,
                ticket.assignedTo == null ? 'Pending assignment' : 'Assigned to ${ticket.assignedTo}',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _meta(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.gray400),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: AppColors.gray500, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(TicketStatus status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case TicketStatus.pending:
        // Treat pending as assigned (pending is deprecated for IT/FM requests)
        bgColor = const Color(0xFFEFF6FF); // Soft pastel blue
        textColor = const Color(0xFF2563EB);
        break;
      case TicketStatus.assigned:
        bgColor = const Color(0xFFEFF6FF); // Soft pastel blue
        textColor = const Color(0xFF2563EB);
        break;
      case TicketStatus.inProgress:
        bgColor = const Color(0xFFECFDF5); // Soft pastel green
        textColor = const Color(0xFF059669);
        break;
      case TicketStatus.completed:
        bgColor = const Color(0xFFECFDF5); // Soft pastel green
        textColor = const Color(0xFF10B981);
        break;
      case TicketStatus.cancelled:
        bgColor = AppColors.gray100;
        textColor = AppColors.gray600;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20), // Pill-shaped
      ),
      child: Text(
        status == TicketStatus.pending || status == TicketStatus.assigned
            ? 'Assigned'
            : status == TicketStatus.inProgress
                ? 'In Progress'
                : status == TicketStatus.completed
                    ? 'Completed'
                    : 'Canceled',
        style: TextStyle(
          fontSize: 11,
          color: textColor,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(TicketPriority priority) {
    Color bgColor;
    Color textColor;
    String label;

    switch (priority) {
      case TicketPriority.low:
        bgColor = const Color(0xFFECFDF5); // Soft pastel green
        textColor = const Color(0xFF059669);
        label = 'Not Urgent';
        break;
      case TicketPriority.medium:
        // Map medium to "Not Urgent" since we only have two options now
        bgColor = const Color(0xFFECFDF5); // Soft pastel green
        textColor = const Color(0xFF059669);
        label = 'Not Urgent';
        break;
      case TicketPriority.high:
        bgColor = const Color(0xFFFEE2E2); // Soft pastel red
        textColor = const Color(0xFFDC2626);
        label = 'Urgent';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20), // Pill-shaped
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: textColor,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  String _getTimeAgo(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return DateFormat('MMM d').format(date);
      }
    } catch (e) {
      return dateStr;
    }
  }

}
