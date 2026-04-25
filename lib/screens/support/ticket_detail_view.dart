import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/support_ticket.dart';
import '../../services/auth_service.dart';
import '../../services/support_service.dart';
import '../../utils/constants.dart';
import '../../widgets/responsive_container.dart';
import '../../widgets/start_support_call_sheet.dart';

class TicketDetailView extends StatefulWidget {
  final SupportTicket ticket;

  const TicketDetailView({super.key, required this.ticket});

  @override
  State<TicketDetailView> createState() => _TicketDetailViewState();
}

class _TicketDetailViewState extends State<TicketDetailView> {
  late SupportTicket _ticket;
  final SupportService _service = SupportService();
  List<SupportTimelineEvent> _timeline = const [];
  bool _timelineLoading = true;

  @override
  void initState() {
    super.initState();
    _ticket = widget.ticket;
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    final id = _ticket.requestId;
    if (id == null) {
      setState(() => _timelineLoading = false);
      return;
    }
    try {
      final detail = await _service.fetchRequestById(id);
      final timeline = await _service.fetchRequestTimeline(id);
      if (!mounted) return;
      setState(() {
        _ticket = detail;
        _timeline = timeline;
        _timelineLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _timelineLoading = false);
    }
  }

  // ── Accent color helpers ──────────────────────────────────────────────

  Color get _accentColor =>
      _ticket.type == 'IT' ? AppColors.primary : AppColors.secondary;

  Color get _accentDark =>
      _ticket.type == 'IT' ? AppColors.primaryDark : AppColors.secondaryDark;

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        top: false,
        child: ResponsiveContainer(
          backgroundColor: AppColors.white,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroHeader(context),
                      _buildTitleSection(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStatusRow(),
                            _buildDivider(),
                            _buildDetailsSection(),
                            _buildDivider(),
                            _buildDescriptionSection(),
                            if (_ticket.assignedTo != null) ...[
                              _buildDivider(),
                              _buildAssignedSection(),
                            ],
                            if (_ticket.cancelledReason != null) ...[
                              _buildDivider(),
                              _buildCancelReasonSection(),
                            ],
                            _buildDivider(),
                            _buildTimelineSection(),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildBottomActions(context),
            ],
          ),
        ),
      ),
    );
  }

  // ── Hero header ────────────────────────────────────────────────────────

  Widget _buildHeroHeader(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 170 + topPadding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_accentColor, _accentDark],
            ),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(28),
            ),
          ),
        ),
        // Back button
        Positioned(
          top: topPadding + 8,
          left: 16,
          child: _CircleButton(
            icon: Icons.arrow_back_ios_new,
            onTap: () => Navigator.pop(context),
          ),
        ),
        // Type badge + ticket ID at bottom of hero
        Positioned(
          left: 20,
          bottom: 18,
          child: Row(
            children: [
              _HeroChip(
                label: _ticket.type == 'IT' ? 'IT Support' : 'FM Support',
                color: Colors.white.withOpacity(0.25),
              ),
              const SizedBox(width: 8),
              _HeroChip(
                label: '#${_ticket.id}',
                color: Colors.black.withOpacity(0.18),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Title ──────────────────────────────────────────────────────────────

  Widget _buildTitleSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _ticket.categoryString.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _accentColor,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _ticket.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.gray900,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ── Status & Priority row ──────────────────────────────────────────────

  Widget _buildStatusRow() {
    return Row(
      children: [
        _StatusChip(
          label: _ticket.statusString,
          color: _getStatusColor(_ticket.status),
        ),
        const SizedBox(width: 8),
        _StatusChip(
          label: _ticket.priorityString,
          color: _getPriorityColor(_ticket.priority),
          prefix: 'Priority: ',
        ),
      ],
    );
  }

  // ── Details section ────────────────────────────────────────────────────

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Ticket Details'),
        const SizedBox(height: 14),
        _buildDetailRow('Location', _ticket.location,
            icon: Icons.location_on_outlined),
        _buildDetailRow('Created', _formatDateTime(_ticket.createdAt),
            icon: Icons.access_time_outlined),
        if (_ticket.completedAt != null)
          _buildDetailRow('Completed', _formatDateTime(_ticket.completedAt!),
              icon: Icons.check_circle_outline),
      ],
    );
  }

  // ── Description ────────────────────────────────────────────────────────

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Description'),
        const SizedBox(height: 10),
        Text(
          _ticket.description,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.gray600,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  // ── Assigned staff ─────────────────────────────────────────────────────

  Widget _buildAssignedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Assigned Staff'),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _accentColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person_outline, size: 20, color: _accentColor),
            ),
            const SizedBox(width: 12),
            Text(
              _ticket.assignedTo!,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.gray900,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Cancel reason ──────────────────────────────────────────────────────

  Widget _buildCancelReasonSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Cancellation Reason'),
        const SizedBox(height: 10),
        Text(
          _ticket.cancelledReason!,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.gray600,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  // ── Timeline ───────────────────────────────────────────────────────────

  Widget _buildTimelineSection() {
    if (_timelineLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Timeline',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.gray900,
              letterSpacing: -0.2,
            ),
          ),
          SizedBox(height: 12),
          LinearProgressIndicator(minHeight: 2),
        ],
      );
    }

    if (_timeline.isNotEmpty) {
      final sorted = [..._timeline]
        ..sort((a, b) => (a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
            .compareTo(b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)));
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Timeline'),
          const SizedBox(height: 14),
          for (var i = 0; i < sorted.length; i++)
            _buildTimelineItem(
              sorted[i].title,
              sorted[i].description ??
                  (sorted[i].createdAt != null
                      ? DateFormat('MMM d, yyyy • h:mm a')
                          .format(sorted[i].createdAt!)
                      : ''),
              isActive: true,
              isLast: i == sorted.length - 1,
            ),
        ],
      );
    }

    final doneAssigned = _ticket.status.index >= TicketStatus.assigned.index;
    final doneProgress = _ticket.status == TicketStatus.inProgress ||
        _ticket.status == TicketStatus.completed;
    final doneCompleted = _ticket.status == TicketStatus.completed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Timeline'),
        const SizedBox(height: 14),
        _buildTimelineItem(
          'Created',
          _formatDateTime(_ticket.createdAt),
          isActive: true,
        ),
        _buildTimelineItem(
          'Assigned',
          _ticket.assignedTo == null
              ? 'Pending assignment'
              : 'Assigned to ${_ticket.assignedTo}',
          isActive: doneAssigned,
        ),
        _buildTimelineItem(
          'In Progress',
          'Work started on ticket',
          isActive: doneProgress,
        ),
        _buildTimelineItem(
          'Completed',
          'Resolution and closure',
          isActive: doneCompleted,
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildTimelineItem(
    String title,
    String description, {
    required bool isActive,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              child: Column(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: isActive ? _accentColor : AppColors.gray200,
                      shape: BoxShape.circle,
                    ),
                    child: isActive
                        ? const Icon(Icons.check,
                            color: AppColors.white, size: 13)
                        : Center(
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.gray400,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: AppColors.gray200,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isActive ? AppColors.gray900 : AppColors.gray600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.gray500),
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

  // ── Shared helpers ─────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppColors.gray900,
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Divider(color: AppColors.gray200, height: 1),
    );
  }

  Widget _buildDetailRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: AppColors.gray400),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style:
                      const TextStyle(fontSize: 14, color: AppColors.gray500),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom actions ─────────────────────────────────────────────────────

  Widget _buildBottomActions(BuildContext context) {
    if (_ticket.status == TicketStatus.completed) {
      return SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border(top: BorderSide(color: AppColors.gray200, width: 1)),
          ),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showRatingDialog(context),
              icon: const Icon(Icons.star_outline),
              label: const Text(
                'Rate This Ticket',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
      );
    }

    if (_ticket.status == TicketStatus.cancelled) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.gray200, width: 1)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showInAppCallSheet(context),
                icon: const Icon(Icons.call_outlined, size: 17),
                label: const Text(
                  'Call staff',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.45),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showCancelDialog(context),
                icon: const Icon(Icons.close_rounded, size: 17),
                label: const Text(
                  'Cancel ticket',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.gray700,
                  side: const BorderSide(color: AppColors.gray300),
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
    );
  }

  // ── Dialogs ────────────────────────────────────────────────────────────

  void _showInAppCallSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: const StartSupportCallSheet(),
        );
      },
    );
  }

  void _showCancelDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Request'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                  'Please provide a reason for cancelling this request.'),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                minLines: 3,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'Enter reason...',
                  filled: true,
                  fillColor: AppColors.gray50,
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
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back'),
          ),
          ElevatedButton(
            onPressed: () async {
              final reason = controller.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Please enter a cancellation reason'),
                    backgroundColor: Colors.red.shade700,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
                return;
              }
              try {
                await AuthService.instance.loadSession();
                final memberId = AuthService.instance.studentId;
                final requestId = _ticket.requestId;
                if (memberId == null || memberId.isEmpty || requestId == null) {
                  throw Exception('Unable to cancel this ticket.');
                }
                await _service.cancelRequest(
                  requestId: requestId,
                  memberId: memberId,
                  reason: reason,
                );
                if (!mounted) return;
                setState(() {
                  _ticket = SupportTicket(
                    requestId: _ticket.requestId,
                    id: _ticket.id,
                    title: _ticket.title,
                    description: _ticket.description,
                    category: _ticket.category,
                    status: TicketStatus.cancelled,
                    priority: _ticket.priority,
                    location: _ticket.location,
                    createdAt: _ticket.createdAt,
                    assignedTo: _ticket.assignedTo,
                    completedAt: _ticket.completedAt,
                    cancelledReason: reason,
                    rating: _ticket.rating,
                    type: _ticket.type,
                  );
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Request cancelled successfully.'),
                    backgroundColor: Colors.orange,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString().replaceFirst('Exception: ', '')),
                    backgroundColor: Colors.red.shade700,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444)),
            child: const Text('Confirm Cancel'),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(BuildContext context) {
    int rating = _ticket.rating ?? 0;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Rate This Ticket'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('How would you rate the support you received?'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      Icons.star,
                      size: 40,
                      color: index < rating ? Colors.amber : AppColors.gray300,
                    ),
                    onPressed: () {
                      setState(() => rating = index + 1);
                    },
                  );
                }),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Rating submitted: $rating stars (mock)'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Color helpers ──────────────────────────────────────────────────────

  Color _getStatusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.pending:
        return Colors.blue;
      case TicketStatus.assigned:
        return Colors.blue;
      case TicketStatus.inProgress:
        return Colors.green;
      case TicketStatus.completed:
        return Colors.green;
      case TicketStatus.cancelled:
        return AppColors.gray600;
    }
  }

  Color _getPriorityColor(TicketPriority priority) {
    switch (priority) {
      case TicketPriority.low:
        return Colors.green;
      case TicketPriority.medium:
        return Colors.orange;
      case TicketPriority.high:
        return Colors.red;
    }
  }

  String _formatDateTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM d, yyyy • h:mm a').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}

// ══════════════════════════════════════════════════════════════════════
// Private helper widgets
// ══════════════════════════════════════════════════════════════════════

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.22),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  final String label;
  final Color color;

  const _HeroChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final String prefix;

  const _StatusChip({
    required this.label,
    required this.color,
    this.prefix = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        '$prefix$label',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
