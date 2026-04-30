import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/support_service.dart';
import '../../utils/constants.dart';

class StaffJobDetail extends StatelessWidget {
  const StaffJobDetail({
    super.key,
    required this.job,
    this.isHistoryTicket = false,
    this.staffId,
    this.onChanged,
  });

  final Map<String, String> job;
  final bool isHistoryTicket;
  final String? staffId;
  final Future<void> Function()? onChanged;

  static const Color _tealHeader = AppColors.primary;
  static final DateFormat _timelineFormat = DateFormat('MMM d, yyyy, h:mm a');

  bool get _isDone {
    final s = (job['status'] ?? '').toLowerCase();
    return s.contains('complete') || s.contains('resolved');
  }

  int? get _requestId {
    final raw = job['requestId'] ?? job['id'];
    if (raw == null) return null;
    return int.tryParse(raw.replaceAll('#', '').trim());
  }

  @override
  Widget build(BuildContext context) {
    final title = job['title'] ?? 'Task';
    final status = job['status'] ?? 'Queued';
    final desc = (job['description'] ?? '').trim();
    final showDescription =
        desc.isNotEmpty && desc.toLowerCase() != title.toLowerCase();

    final ticketChildren = <Widget>[
      _kv('Location', job['location'] ?? '—'),
      const SizedBox(height: 10),
      _kvRowWithIcon(
        Icons.schedule_rounded,
        'Created',
        job['created'] ?? job['time'] ?? '—',
      ),
    ];
    if ((job['completed'] ?? '').trim().isNotEmpty) {
      ticketChildren.addAll([
        const SizedBox(height: 10),
        _kvRowWithIcon(
          Icons.check_circle_outline_rounded,
          'Completed',
          job['completed']!,
        ),
      ]);
    }

    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: ClubUiColors.pageBg,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(context)),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    24 + (isHistoryTicket ? bottomInset : 0),
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _statusPriorityRow(status),
                      const SizedBox(height: 12),
                      _detailCard(
                        title: 'Ticket details',
                        icon: Icons.place_outlined,
                        children: ticketChildren,
                      ),
                      if (showDescription) ...[
                        const SizedBox(height: 12),
                        _detailCard(
                          title: 'Description',
                          icon: Icons.article_outlined,
                          children: [
                            Text(
                              desc,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.45,
                                color: AppColors.gray700,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 12),
                      _timelineCard(),
                    ]),
                  ),
                ),
              ],
            ),
          ),
          if (!isHistoryTicket) _buildActionBar(context),
        ],
      ),
    );
  }

  static const double _headerBottomRadius = 28;

  Widget _buildHeader(BuildContext context) {
    final id = job['id'] ?? '';
    final category = job['category'] ?? '';
    final headline = job['title'] ?? 'Task';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _tealHeader,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(_headerBottomRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: _tealHeader.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(_headerBottomRadius),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -40,
              top: -30,
              child: IgnorePointer(
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white.withValues(alpha: 0.06),
                  ),
                ),
              ),
            ),
            Positioned(
              left: -24,
              bottom: 8,
              child: IgnorePointer(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white.withValues(alpha: 0.04),
                  ),
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 20, 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Material(
                      color: AppColors.white.withValues(alpha: 0.18),
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => Navigator.maybePop(context),
                        customBorder: const CircleBorder(),
                        child: const SizedBox(
                          width: 44,
                          height: 44,
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 17,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (id.isNotEmpty)
                      Text(
                        id,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                          color: AppColors.white.withValues(alpha: 0.88),
                        ),
                      ),
                    if (id.isNotEmpty) const SizedBox(height: 10),
                    Text(
                      headline,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                        height: 1.28,
                        letterSpacing: -0.4,
                      ),
                    ),
                    if (category.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.white.withValues(alpha: 0.22),
                          ),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.15,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusPriorityRow(String status) {
    final priority = job['priority'] ?? 'Standard';
    final done = _isDone;

    Widget statusValue() {
      if (done) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            status,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF047857),
            ),
          ),
        );
      }
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          status,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2563EB),
          ),
        ),
      );
    }

    Widget cell(String label, Widget value) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gray200.withValues(alpha: 0.9)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray500,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 8),
              value,
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        cell('Status', statusValue()),
        const SizedBox(width: 10),
        cell(
          'Priority',
          Text(
            priority,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.gray900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _detailCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200.withValues(alpha: 0.9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _kv(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.gray500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.gray900,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _kvRowWithIcon(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.gray400),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.gray900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _assignedCard() {
    final assignee = job['assignedTo'] ?? '—';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFBFDBFE).withValues(alpha: 0.9),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline_rounded,
                  size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                'Assigned to',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            assignee,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.gray900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _timelineCard() {
    final requestId = _requestId;
    if (requestId != null) {
      return FutureBuilder<List<SupportTimelineEvent>>(
        future: SupportService().fetchRequestTimeline(requestId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _timelineContainer(
              children: const [
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ],
            );
          }

          final events = snapshot.data ?? const <SupportTimelineEvent>[];
          if (events.isNotEmpty) {
            return _timelineContainer(
              children: List.generate(events.length, (i) {
                final event = events[i];
                final when = event.createdAt == null
                    ? ''
                    : _timelineFormat.format(event.createdAt!.toLocal());
                final description = [
                  if ((event.description ?? '').trim().isNotEmpty)
                    event.description!.trim(),
                  if (when.isNotEmpty) when,
                ].join(' · ');
                return _timelineRow(
                  title: event.title,
                  subtitle: description,
                  showLine: i != events.length - 1,
                );
              }),
            );
          }

          return _fallbackTimelineCard();
        },
      );
    }

    return _fallbackTimelineCard();
  }

  Widget _fallbackTimelineCard() {
    final created = job['created'] ?? job['time'] ?? '';
    final assignedAt = job['assignedAt'] ?? '';
    final note = (job['dispatchNote'] ?? '').trim();
    final assignee = job['assignedTo'] ?? 'staff';
    final started = job['startedAt'] ?? '';
    final completed = job['completed'] ?? '';

    final items = <Map<String, String>>[
      {'title': 'Created', 'sub': 'Request created · $created'},
      {
        'title': 'Assigned',
        'sub': assignedAt.isNotEmpty
            ? 'Assigned to $assignee · $assignedAt'
            : 'Assigned to staff member $assignee',
      },
    ];

    if (isHistoryTicket || _isDone) {
      if (started.isNotEmpty) {
        items.add({
          'title': 'In progress',
          'sub': 'Work started by assigned staff · $started',
        });
      }
      if (completed.isNotEmpty) {
        items.add({
          'title': 'Completed',
          'sub': 'Request completed · $completed',
        });
      }
    } else if (note.isNotEmpty) {
      items.add({'title': 'Dispatcher instructions', 'sub': note});
    }

    return _timelineContainer(
      children: List.generate(items.length, (i) {
        final it = items[i];
        final last = i == items.length - 1;
        return _timelineRow(
          title: it['title'] ?? '',
          subtitle: it['sub'] ?? '',
          showLine: !last,
        );
      }),
    );
  }

  Widget _timelineContainer({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200.withValues(alpha: 0.9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.view_list_rounded, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                'Timeline',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _timelineRow({
    required String title,
    required String subtitle,
    required bool showLine,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                child: const Icon(Icons.check_rounded,
                    size: 14, color: AppColors.white),
              ),
              if (showLine)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    color: AppColors.primary.withValues(alpha: 0.25),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray900,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.gray600,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const Color _completeGreen = Color(0xFF059669);

  Widget _buildActionBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: () => _runRequestAction(
                context,
                started: true,
              ),
              icon: const Icon(Icons.play_circle_outline_rounded, size: 22),
              label: const Text(
                'Mark as Started',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: () => _runRequestAction(
                context,
                started: false,
              ),
              icon: const Icon(Icons.check_circle_outline_rounded, size: 22),
              label: const Text(
                'Complete',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: _completeGreen,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _runRequestAction(
    BuildContext context, {
    required bool started,
  }) async {
    final requestId = _requestId;
    final staff = staffId;
    if (requestId == null || staff == null || staff.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket or staff id is missing.')),
      );
      return;
    }

    try {
      if (started) {
        await SupportService().startStaffRequest(
          requestId: requestId,
          staffId: staff,
        );
      } else {
        await SupportService().completeStaffRequest(
          requestId: requestId,
          staffId: staff,
        );
      }
      if (onChanged != null) await onChanged!();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(started ? 'Marked as started.' : 'Completed.'),
        ),
      );
      if (!started) Navigator.maybePop(context);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }
}
