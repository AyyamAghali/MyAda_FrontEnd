import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/call/call_api.dart';
import '../../services/call/call_controller.dart';
import '../../services/call/call_history_controller.dart';
import '../../utils/constants.dart';
import '../../widgets/support_call_link_ui.dart';

/// Call history list styled consistently with the IT support "immediate help"
/// gradient card and the clubs home search + tune filter pattern.
class CallHistoryScreen extends StatefulWidget {
  const CallHistoryScreen({super.key});

  @override
  State<CallHistoryScreen> createState() => _CallHistoryScreenState();
}

class _CallHistoryScreenState extends State<CallHistoryScreen> {
  final CallHistoryController _history = CallHistoryController.instance;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _history.addListener(_onHistoryChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _history.load(showLoading: _history.items.isEmpty);
    });
  }

  @override
  void dispose() {
    _history.removeListener(_onHistoryChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onHistoryChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _openStatusFilterSheet(BuildContext context) {
    var temp = _history.filter;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            const options = [
              CallHistoryStatus.all,
              CallHistoryStatus.accepted,
              CallHistoryStatus.rejected,
              CallHistoryStatus.cancelled,
              CallHistoryStatus.timedOut,
            ];
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    const Text(
                      'Filter by status',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: options.map((s) {
                        final selected = temp == s;
                        return FilterChip(
                          label: Text(s.label),
                          selected: selected,
                          onSelected: (_) => setModalState(() => temp = s),
                          selectedColor:
                              AppColors.primary.withValues(alpha: 0.14),
                          checkmarkColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: selected
                                ? AppColors.primary
                                : AppColors.gray700,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
                          ),
                          side: BorderSide(
                            color: selected
                                ? AppColors.primary
                                : AppColors.gray200,
                          ),
                        );
                      }).toList(growable: false),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _history.setFilter(temp);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('Apply'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.gray900,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.gray900),
        title: const Text('Call History'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ImmediateHelpStyleHeader(),
          _SearchAndMetaRow(
            controller: _searchController,
            onSearchChanged: _history.setSearchQuery,
            onTuneTap: () => _openStatusFilterSheet(context),
            visibleCount: _history.visibleItems.length,
            hasActiveFilters: _history.hasActiveFilters,
            onClearFilters: () async {
              _searchController.clear();
              await _history.clearFilters();
            },
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _history.load(),
              child: _buildBody(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_history.isLoading && _history.items.isEmpty) {
      return const _CenteredState(
        icon: Icons.history_rounded,
        title: 'Loading call history...',
        showSpinner: true,
      );
    }

    final error = _history.errorMessage;
    if (error != null && _history.items.isEmpty) {
      return _CenteredState(
        icon: Icons.error_outline_rounded,
        title: 'Could not load calls',
        message: error,
        actionLabel: 'Retry',
        onAction: () => _history.load(),
      );
    }

    if (_history.items.isEmpty) {
      return const _CenteredState(
        icon: Icons.call_outlined,
        title: 'No calls yet',
        message:
            'Accepted, rejected, cancelled, and timed-out calls will appear here.',
      );
    }

    final visible = _history.visibleItems;
    if (visible.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32),
        children: const [
          SizedBox(height: 48),
          Icon(Icons.search_off_rounded, size: 48, color: AppColors.gray400),
          SizedBox(height: 12),
          Text(
            'No matching calls',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.gray900,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Try another search or clear filters.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.gray600),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      itemBuilder: (context, index) {
        return _CallHistoryListCard(
          item: visible[index],
          onTap: () => _showDetails(visible[index].callId),
          onCallBack: () => _callBackFromHistory(context, visible[index]),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: visible.length,
    );
  }

  Future<void> _callBackFromHistory(
    BuildContext context,
    CallHistoryItem item,
  ) async {
    await AuthService.instance.loadSession();
    final self = AuthService.instance.studentId?.trim();
    if (self == null || self.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in to place a call.')),
      );
      return;
    }

    final callerId = item.caller.userId.trim();
    final dispatcherId = item.dispatcher.userId.trim();

    String? targetId;
    String? targetLabel;
    if (self == callerId) {
      targetId = dispatcherId;
      targetLabel = item.dispatcher.displayName;
    } else if (self == dispatcherId) {
      targetId = callerId;
      targetLabel = item.caller.displayName;
    }

    if (targetId == null || targetId.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can only call back the other participant.'),
        ),
      );
      return;
    }

    var resolvedName = (targetLabel ?? '').trim();
    final idLower = targetId.toLowerCase();
    if (resolvedName.isEmpty ||
        resolvedName.toLowerCase() == idLower ||
        _looksLikeUuid(resolvedName)) {
      try {
        final profile = await AuthService.instance.fetchUserById(targetId);
        final full =
            '${profile.firstName ?? ''} ${profile.lastName ?? ''}'.trim();
        if (full.isNotEmpty) {
          resolvedName = full;
        } else if (profile.userName.trim().isNotEmpty) {
          resolvedName = profile.userName.trim();
        }
      } catch (_) {}
    }
    if (resolvedName.isEmpty) resolvedName = targetId;

    try {
      await CallController.instance.requestCall(
        targetId,
        dispatcherDisplayName: resolvedName,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
  }

  Future<void> _showDetails(String callId) async {
    final future = _history.fetchItem(callId);
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return FutureBuilder<CallHistoryItem>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline,
                          color: AppColors.gray500, size: 28),
                      const SizedBox(height: 10),
                      Text(
                        snapshot.error?.toString() ??
                            'Could not load call details.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }
            return _CallDetailsSheet(item: snapshot.data!);
          },
        );
      },
    );
  }
}

bool _looksLikeUuid(String value) {
  final v = value.trim();
  final re = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );
  return re.hasMatch(v);
}

class _ImmediateHelpStyleHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: SupportCallLinkedSurface(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your support calls',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray900,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'See who you spoke with, outcomes, and timings in one place.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: AppColors.gray600,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const SupportCallLeadingIcon(icon: Icons.history_rounded),
          ],
        ),
      ),
    );
  }
}

class _SearchAndMetaRow extends StatelessWidget {
  const _SearchAndMetaRow({
    required this.controller,
    required this.onSearchChanged,
    required this.onTuneTap,
    required this.visibleCount,
    required this.hasActiveFilters,
    required this.onClearFilters,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onTuneTap;
  final int visibleCount;
  final bool hasActiveFilters;
  final Future<void> Function() onClearFilters;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundLight,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 40,
            child: TextField(
              controller: controller,
              onChanged: onSearchChanged,
              style: const TextStyle(fontSize: 14, color: AppColors.gray900),
              decoration: InputDecoration(
                hintText: 'Search by name, id, or reason…',
                hintStyle:
                    const TextStyle(fontSize: 13, color: AppColors.gray400),
                prefixIcon: const Icon(Icons.search,
                    size: 20, color: AppColors.gray400),
                prefixIconConstraints:
                    const BoxConstraints(minWidth: 40, minHeight: 0),
                suffixIcon: GestureDetector(
                  onTap: onTuneTap,
                  child: Container(
                    width: 34,
                    height: 34,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.tune,
                        size: 17, color: AppColors.primary),
                  ),
                ),
                suffixIconConstraints:
                    const BoxConstraints(minWidth: 40, minHeight: 0),
                filled: true,
                fillColor: AppColors.gray50,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.gray200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.gray200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '$visibleCount call${visibleCount == 1 ? '' : 's'}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray500,
                ),
              ),
              if (hasActiveFilters) ...[
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => onClearFilters(),
                  child: const Text(
                    'Clear filters',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _CallHistoryListCard extends StatelessWidget {
  const _CallHistoryListCard({
    required this.item,
    required this.onTap,
    required this.onCallBack,
  });

  final CallHistoryItem item;
  final VoidCallback onTap;
  final VoidCallback onCallBack;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: SupportCallLinkedSurface(
          padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onCallBack,
                    child: const SupportCallLeadingIcon(
                      icon: Icons.call_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item.caller.displayName} · ${item.dispatcher.displayName}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.gray900,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _requestedText(item),
                          style: const TextStyle(
                            color: AppColors.gray600,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatusBadge(status: item.status),
                ],
              ),
              if (_hasMetaChips(item)) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _metaChips(item),
                ),
              ],
              if (_reasonText(item) != null) ...[
                const SizedBox(height: 10),
                Text(
                  _reasonText(item)!,
                  style: const TextStyle(
                    color: AppColors.gray700,
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

bool _hasMetaChips(CallHistoryItem item) {
  return item.acceptedAtUtc != null ||
      item.endedAtUtc != null ||
      item.durationSeconds != null;
}

List<Widget> _metaChips(CallHistoryItem item) {
  final chips = <Widget>[];
  if (item.acceptedAtUtc != null) {
    chips.add(_MetaChip(
      icon: Icons.login_rounded,
      text: 'Accepted ${_shortDate(item.acceptedAtUtc)}',
    ));
  }
  if (item.endedAtUtc != null) {
    chips.add(_MetaChip(
      icon: Icons.logout_rounded,
      text: 'Ended ${_shortDate(item.endedAtUtc)}',
    ));
  }
  if (item.durationSeconds != null) {
    chips.add(_MetaChip(
      icon: Icons.timer_outlined,
      text: _formatDuration(item.durationSeconds!),
    ));
  }
  return chips;
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.gray500),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.gray700,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final CallHistoryStatus status;

  @override
  Widget build(BuildContext context) {
    final v = _statusVisual(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(v.icon, size: 15, color: v.iconTint),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: const TextStyle(
              color: AppColors.gray900,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusVisual {
  const _StatusVisual(this.icon, this.iconTint);

  final IconData icon;
  final Color iconTint;
}

_StatusVisual _statusVisual(CallHistoryStatus status) {
  switch (status) {
    case CallHistoryStatus.accepted:
      return const _StatusVisual(
        Icons.check_circle_outline_rounded,
        Color(0xFF0F766E),
      );
    case CallHistoryStatus.rejected:
      return const _StatusVisual(
        Icons.call_missed_outgoing_rounded,
        Color(0xFF64748B),
      );
    case CallHistoryStatus.cancelled:
      return const _StatusVisual(
        Icons.block_rounded,
        Color(0xFF78716C),
      );
    case CallHistoryStatus.timedOut:
      return const _StatusVisual(
        Icons.schedule_rounded,
        Color(0xFF475569),
      );
    case CallHistoryStatus.pending:
      return const _StatusVisual(
        Icons.pending_actions_outlined,
        Color(0xFF64748B),
      );
    case CallHistoryStatus.all:
      return _StatusVisual(Icons.filter_list_rounded, AppColors.gray500);
  }
}

class _CallDetailsSheet extends StatelessWidget {
  const _CallDetailsSheet({required this.item});

  final CallHistoryItem item;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
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
            const SizedBox(height: 18),
            const Text(
              'Call details',
              style: TextStyle(
                color: AppColors.gray900,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            _DetailRow(
              label: 'Between',
              value:
                  '${item.caller.displayName} and ${item.dispatcher.displayName}',
            ),
            _DetailRow(label: 'Status', value: item.status.label),
            _DetailRow(
              label: 'Requested',
              value: _formatDateTime(item.requestedAtUtc),
            ),
            _DetailRow(
              label: 'Accepted',
              value: _formatDateTime(item.acceptedAtUtc),
            ),
            _DetailRow(
              label: 'Ended',
              value: _formatDateTime(item.endedAtUtc),
            ),
            _DetailRow(
              label: 'Duration',
              value: item.durationSeconds == null
                  ? 'Not available'
                  : _formatDuration(item.durationSeconds!),
            ),
            if (item.resolveReason != null)
              _DetailRow(label: 'Resolve reason', value: item.resolveReason!),
            if (item.endReason != null)
              _DetailRow(label: 'End reason', value: item.endReason!),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.gray500,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.gray900,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CenteredState extends StatelessWidget {
  const _CenteredState({
    required this.icon,
    required this.title,
    this.message,
    this.showSpinner = false,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? message;
  final bool showSpinner;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.18),
        Icon(icon, size: 42, color: AppColors.gray400),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.gray900,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.gray600, fontSize: 13),
            ),
          ),
        ],
        if (showSpinner) ...[
          const SizedBox(height: 16),
          const Center(child: CircularProgressIndicator()),
        ],
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: 14),
          Center(
            child: TextButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ),
        ],
      ],
    );
  }
}

String _requestedText(CallHistoryItem item) {
  final requested = _formatDateTime(item.requestedAtUtc);
  if (item.hasFinishedAcceptedCall) {
    return 'Accepted · finished';
  }
  return requested == 'Not available'
      ? 'Requested time unavailable'
      : 'Requested $requested';
}

String? _reasonText(CallHistoryItem item) {
  if (item.resolveReason != null) return 'Reason: ${item.resolveReason}';
  if (item.endReason != null) return 'End reason: ${item.endReason}';
  return null;
}

String _formatDateTime(DateTime? value) {
  if (value == null) return 'Not available';
  final local = value.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(local.day)}/${two(local.month)}/${local.year} ${two(local.hour)}:${two(local.minute)}';
}

String _shortDate(DateTime? value) {
  if (value == null) return '';
  final local = value.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(local.day)}/${two(local.month)} ${two(local.hour)}:${two(local.minute)}';
}

String _formatDuration(int totalSeconds) {
  final duration = Duration(seconds: totalSeconds);
  String two(int n) => n.toString().padLeft(2, '0');
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);
  if (hours > 0) return '${hours}h ${two(minutes)}m ${two(seconds)}s';
  if (minutes > 0) return '${minutes}m ${two(seconds)}s';
  return '${seconds}s';
}
