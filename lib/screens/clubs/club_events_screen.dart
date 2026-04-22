import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/club_events_discovery_mock.dart';
import '../../models/club_public_event.dart';
import '../../models/event_tickets_models.dart';
import '../../services/event_tickets_local_repository.dart';
import '../../services/event_tickets_repository.dart';
import '../../utils/constants.dart';
import 'club_event_detail_screen.dart';
import 'entrance_scan_flow.dart';
import 'event_ticket_screen.dart';

const _kCategories = ['All', 'Technology', 'Social', 'Academic', 'Sports', 'Arts', 'Business'];

class ClubEventsScreen extends StatefulWidget {
  final bool embedInHub;
  final int? filterClubId;

  const ClubEventsScreen({
    super.key,
    this.embedInHub = false,
    this.filterClubId,
  });

  @override
  State<ClubEventsScreen> createState() => _ClubEventsScreenState();
}

enum _EventsPane { discover, myRegistrations }

class _ClubEventsScreenState extends State<ClubEventsScreen> {
  String _search = '';
  String _category = 'All';
  _EventsPane _pane = _EventsPane.discover;
  final _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchFocus.dispose();
    super.dispose();
  }

  bool get _hasFilter => _category != 'All';

  List<ClubPublicEvent> get _filtered {
    var list = List<ClubPublicEvent>.from(kClubDiscoveryEvents);
    final hubClub = widget.filterClubId;
    if (hubClub != null) {
      list = list.where((e) => e.clubId == hubClub).toList();
    }
    if (_pane == _EventsPane.myRegistrations) {
      // Tickets pane uses its own data source (mock registrations). Keep this list empty.
      list = const <ClubPublicEvent>[];
    }
    if (_category != 'All') {
      list = list.where((e) => e.category.toLowerCase() == _category.toLowerCase()).toList();
    }
    final q = _search.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((e) {
        return e.title.toLowerCase().contains(q) ||
            e.clubName.toLowerCase().contains(q) ||
            (e.description ?? '').toLowerCase().contains(q);
      }).toList();
    }
    return list;
  }

  String _fmtDate(String dateStr) => DateFormat.yMMMd().format(DateTime.parse(dateStr));

  String _fmtTime(String? t) {
    if (t == null || t.isEmpty) return '';
    final parts = t.split(':');
    final h = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    final period = h >= 12 ? 'PM' : 'AM';
    final hour = h % 12 == 0 ? 12 : h % 12;
    return '$hour:${m.toString().padLeft(2, '0')} $period';
  }

  void _openFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        var tmp = _category;
        return StatefulBuilder(
          builder: (ctx, setModal) {
            Widget chip(String value, String label) {
              final sel = tmp == value;
              return GestureDetector(
                onTap: () => setModal(() => tmp = value),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primary : AppColors.gray100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: sel ? AppColors.white : AppColors.gray700)),
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.fromLTRB(20, 14, 20, MediaQuery.of(ctx).padding.bottom + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.gray300, borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Filters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.gray900)),
                      GestureDetector(onTap: () => Navigator.pop(ctx), child: const Icon(Icons.close, size: 22, color: AppColors.gray500)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gray600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _kCategories.map((c) => chip(c, c)).toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => _category = tmp);
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

  @override
  Widget build(BuildContext context) {
    final list = _filtered;

    final body = Column(
      children: [
        _buildPaneSwitcher(),
        if (_pane == _EventsPane.discover) ...[
          _buildSearchRow(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
            child: Row(
              children: [
                Text(
                  '${list.length} event${list.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray500,
                  ),
                ),
                if (_hasFilter) ...[
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => setState(() => _category = 'All'),
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
          ),
          Expanded(
            child: list.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.event_busy,
                            size: 48, color: AppColors.gray300),
                        SizedBox(height: 12),
                        Text('No events found',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.gray700)),
                        SizedBox(height: 4),
                        Text('Try adjusting your search or filters',
                            style:
                                TextStyle(fontSize: 13, color: AppColors.gray500)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _EventListItem(
                      event: list[i],
                      formatDate: _fmtDate,
                      formatTime: _fmtTime,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                ClubEventDetailScreen(eventId: list[i].id),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ] else ...[
          Expanded(child: _TicketsPane(filterClubId: widget.filterClubId)),
        ],
      ],
    );

    if (widget.embedInHub) return body;

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
        title: const Text('Club Events'),
      ),
      body: body,
    );
  }

  Widget _buildPaneSwitcher() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 2),
      child: Row(
        children: [
          Expanded(child: _paneToggle('Discover', Icons.travel_explore_outlined, _pane == _EventsPane.discover, () => setState(() => _pane = _EventsPane.discover))),
          const SizedBox(width: 8),
          Expanded(child: _paneToggle('Tickets', Icons.confirmation_number_outlined, _pane == _EventsPane.myRegistrations, () => setState(() => _pane = _EventsPane.myRegistrations))),
        ],
      ),
    );
  }

  Widget _paneToggle(String label, IconData icon, bool selected, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.gray50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: selected ? AppColors.primary.withValues(alpha: 0.35) : AppColors.gray200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: selected ? AppColors.primary : AppColors.gray600),
              const SizedBox(width: 6),
              Flexible(
                child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, fontWeight: selected ? FontWeight.w600 : FontWeight.w500, color: selected ? AppColors.primary : AppColors.gray600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchRow() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      color: AppColors.backgroundLight,
      child: SizedBox(
        height: 40,
        child: TextField(
          focusNode: _searchFocus,
          onChanged: (v) => setState(() => _search = v),
          style: const TextStyle(fontSize: 14, color: AppColors.gray900),
          decoration: InputDecoration(
            hintText: 'Search events or clubs…',
            hintStyle: const TextStyle(fontSize: 13, color: AppColors.gray400),
            prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.gray400),
            prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 0),
            suffixIcon: GestureDetector(
              onTap: _openFilterSheet,
              child: Container(
                width: 34, height: 34,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.tune, size: 17, color: AppColors.primary),
              ),
            ),
            suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 0),
            filled: true,
            fillColor: AppColors.gray50,
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.gray200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.gray200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
          ),
        ),
      ),
    );
  }
}

class _TicketsPane extends StatefulWidget {
  final int? filterClubId;

  const _TicketsPane({this.filterClubId});

  @override
  State<_TicketsPane> createState() => _TicketsPaneState();
}

class _TicketsPaneState extends State<_TicketsPane> {
  late Future<List<MyRegistrationItem>> _future;
  final EventTicketsRepository _repo = LocalEventTicketsRepository();

  @override
  void initState() {
    super.initState();
    _future = _repo.listMyRegistrations();
  }

  Future<void> _reload() async {
    setState(() {
      _future = _repo.listMyRegistrations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _reload,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 90),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const SelectClubForScanScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.qr_code_scanner, size: 18),
                label: const Text(
                  'Scan at entrance',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          FutureBuilder<List<MyRegistrationItem>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final items = (snap.data ?? []);

              if (items.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.confirmation_number_outlined,
                          size: 52, color: AppColors.gray300),
                      SizedBox(height: 12),
                      Text(
                        'No tickets yet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gray900,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Register for an event to generate a ticket.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: AppColors.gray600),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  for (final t in items) ...[
                    _TicketCard(ticket: t),
                    const SizedBox(height: 10),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final MyRegistrationItem ticket;

  const _TicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final e = ticket.event;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: (e.imageUrl == null || e.imageUrl!.isEmpty)
                      ? Container(
                          width: 62,
                          height: 62,
                          color: AppColors.primary.withValues(alpha: 0.08),
                          child: const Icon(Icons.event,
                              color: AppColors.primary),
                        )
                      : Image.asset(
                          e.imageUrl!,
                          width: 62,
                          height: 62,
                          fit: BoxFit.cover,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.gray900,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.schedule,
                              size: 14, color: AppColors.gray500),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${e.startTime ?? ''}${(e.endTime != null && e.endTime!.isNotEmpty) ? ' - ${e.endTime}' : ''}',
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.gray600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.place_outlined,
                              size: 14, color: AppColors.gray500),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              e.location ?? '',
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.gray600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => EventTicketScreen(eventId: int.tryParse(ticket.eventId) ?? 0),
                        ),
                      );
                    },
                    icon: const Icon(Icons.qr_code_2, size: 18),
                    label: const Text('View Ticket'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.gray300),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => ClubEventDetailScreen(eventId: int.tryParse(ticket.eventId) ?? 0),
                      ),
                    );
                  },
                  icon: const Icon(Icons.open_in_new,
                      color: AppColors.gray600),
                  tooltip: 'Event details',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EventListItem extends StatelessWidget {
  final ClubPublicEvent event;
  final String Function(String) formatDate;
  final String Function(String?) formatTime;
  final VoidCallback onTap;

  const _EventListItem({required this.event, required this.formatDate, required this.formatTime, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gray200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.event, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.gray900), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 3),
                      Text(event.clubName, style: const TextStyle(fontSize: 13, color: AppColors.gray500), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.gray400),
                          const SizedBox(width: 4),
                          Text(formatDate(event.date), style: const TextStyle(fontSize: 11, color: AppColors.gray500)),
                          const SizedBox(width: 10),
                          const Icon(Icons.schedule, size: 13, color: AppColors.gray400),
                          const SizedBox(width: 4),
                          Text(formatTime(event.time), style: const TextStyle(fontSize: 11, color: AppColors.gray500)),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.gray400, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
