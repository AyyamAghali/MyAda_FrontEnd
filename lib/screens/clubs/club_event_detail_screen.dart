import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/club_public_event.dart';
import '../../models/event_tickets_models.dart';
import '../../services/club_api_service.dart';
import '../../services/remote_event_tickets_repository.dart';
import '../../services/event_tickets_repository.dart';
import '../../utils/constants.dart';
import 'event_ticket_screen.dart';

Color _eventCatColor(String category) {
  switch (category) {
    case 'Technology': return const Color(0xFF2563EB);
    case 'Social': return const Color(0xFF8B5CF6);
    case 'Academic': return const Color(0xFF059669);
    case 'Sports': return const Color(0xFFEA580C);
    case 'Arts': return const Color(0xFFDB2777);
    case 'Business': return const Color(0xFF0D9488);
    default: return AppColors.primary;
  }
}

class ClubEventDetailScreen extends StatefulWidget {
  final int eventId;

  const ClubEventDetailScreen({super.key, required this.eventId});

  @override
  State<ClubEventDetailScreen> createState() => _ClubEventDetailScreenState();
}

class _ClubEventDetailScreenState extends State<ClubEventDetailScreen> {
  bool _loading = true;
  bool _registered = false;
  bool _full = false;
  EventSnapshot? _snapshot;
  ClubPublicEvent? _event;
  final EventTicketsRepository _repo = RemoteEventTicketsRepository();
  final ClubApiService _api = ClubApiService();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final eventId = widget.eventId.toString();
    final event = await _api.fetchEventById(widget.eventId);
    EventSnapshot? snap;
    var registered = false;
    try {
      snap = await _repo.getEventSnapshot(eventId);
      registered = false;
      try {
        await _repo.getTicket(eventId);
        registered = true;
      } catch (_) {}
    } catch (_) {
      snap = event != null
          ? EventSnapshot(
              id: event.id.toString(),
              name: event.title,
              imageUrl: event.imageAsset,
              startTime: event.time,
              endTime: event.endTime,
              location: event.location,
              seatLimit: 0,
              registeredCount: 0,
            )
          : null;
    }
    final full = snap != null && snap.seatLimit > 0 && snap.registeredCount >= snap.seatLimit;
    if (!mounted) return;
    setState(() {
      _event = event;
      _snapshot = snap;
      _registered = registered;
      _full = full;
      _loading = false;
    });
  }

  String _fmtDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    final trimmed = dateStr.length >= 10 ? dateStr.substring(0, 10) : dateStr;
    final dt = DateTime.tryParse(trimmed) ?? DateTime.tryParse(dateStr);
    if (dt == null) return dateStr;
    return DateFormat('MMMM d, yyyy').format(dt);
  }

  String _fmtTime(String? t) {
    if (t == null || t.isEmpty) return '';
    final parts = t.split(':');
    if (parts.length < 2) return t;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return t;
    final period = h >= 12 ? 'PM' : 'AM';
    final hour = h % 12 == 0 ? 12 : h % 12;
    return '$hour:${m.toString().padLeft(2, '0')} $period';
  }

  String _fmtTimeRange(String? start, String? end) {
    if (start == null || start.isEmpty) return '';
    if (end == null || end.isEmpty) return _fmtTime(start);
    return '${_fmtTime(start)} - ${_fmtTime(end)}';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Event')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final event = _event;
    if (event == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Event')),
        body: const Center(child: Text('Event not found.')),
      );
    }

    final catColor = _eventCatColor(event.category);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // Hero header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, catColor.withValues(alpha: 0.85)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -40, top: -20,
                      child: Container(width: 160, height: 160, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.white.withValues(alpha: 0.06))),
                    ),
                    Positioned(
                      left: -20, bottom: 20,
                      child: Container(width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.white.withValues(alpha: 0.04))),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: AppColors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                              child: Text(event.category.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.white, letterSpacing: 0.5)),
                            ),
                            const SizedBox(height: 10),
                            Text(event.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.white)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Key details section with icons - prominent, not tag-like
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                children: [
                  _detailRow(Icons.calendar_today_outlined, 'Date', _fmtDate(event.date)),
                  const Divider(height: 20, color: AppColors.gray100),
                  _detailRow(Icons.schedule, 'Time', _fmtTimeRange(event.time, event.endTime)),
                  const Divider(height: 20, color: AppColors.gray100),
                  _detailRow(Icons.place_outlined, 'Location', event.location),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 10)),

          // Description
          if (event.description != null)
            SliverToBoxAdapter(
              child: _sectionCard(
                icon: Icons.info_outline,
                title: 'Purpose / Objectives of the Event',
                child: Text(event.description!, style: const TextStyle(fontSize: 14, height: 1.6, color: AppColors.gray700)),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 10)),

          // Entry Fee + Slots — use IntrinsicHeight to equalize
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _miniCard(
                        label: 'ENTRY FEE',
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Free', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.gray900)),
                            const SizedBox(height: 2),
                            Text('for students', style: TextStyle(fontSize: 12, color: AppColors.gray500)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _miniCard(
                        label: 'REMAINING SLOTS',
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Builder(
                              builder: (context) {
                                final snap = _snapshot;
                                final count = snap?.registeredCount ?? 0;
                                final limit = snap?.seatLimit ?? 0;
                                final remaining = (limit - count).clamp(0, limit);
                                return Text(
                                  '$remaining / $limit',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.gray900,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: Builder(
                                builder: (context) {
                                  final snap = _snapshot;
                                  final count = snap?.registeredCount ?? 0;
                                  final limit = snap?.seatLimit ?? 0;
                                  final safeLimit = limit == 0 ? 1 : limit;
                                  return LinearProgressIndicator(
                                    value: (count / safeLimit).clamp(0, 1),
                                    minHeight: 5,
                                    backgroundColor: AppColors.gray200,
                                    color: AppColors.primary,
                                  );
                                },
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

          const SliverToBoxAdapter(child: SizedBox(height: 10)),

          // Hosted by
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: catColor.withValues(alpha: 0.12),
                    child: Text(event.clubName[0], style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: catColor)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('HOSTED BY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.gray400, letterSpacing: 0.5)),
                        const SizedBox(height: 2),
                        Text(event.clubName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.gray900)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.gray400, size: 20),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      bottomNavigationBar: _loading
          ? null
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, -3))],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _registered
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => EventTicketScreen(eventId: event.id),
                              ),
                            );
                          }
                        : (_full
                            ? null
                            : () async {
                                try {
                                  await _repo.registerForEvent(event.id.toString());
                                  final snap = await _repo.getEventSnapshot(event.id.toString());
                                  if (!context.mounted) return;
                                  setState(() {
                                    _snapshot = snap;
                                    _registered = true;
                                    _full = snap.registeredCount >= snap.seatLimit;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Registered. Ticket created.')),
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder: (_) => EventTicketScreen(eventId: event.id),
                                    ),
                                  );
                                } catch (e) {
                                  if (!context.mounted) return;
                                  if (e is RegistrationConflict) {
                                    setState(() => _full = true);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.message)),
                                    );
                                    return;
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Could not register.')),
                                  );
                                }
                              }),
                    icon: Icon(
                      _registered
                          ? Icons.qr_code_2
                          : (_full ? Icons.event_busy : Icons.event_available),
                      size: 20,
                    ),
                    label: Text(
                      _registered ? 'View Ticket' : (_full ? 'Event Full' : 'Register'),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.gray300,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.gray400)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray900)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionCard({required IconData icon, required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(width: 30, height: 30, decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 16, color: AppColors.primary)),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.gray900))),
          ]),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _miniCard({required String label, required Widget content}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.gray400, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          content,
        ],
      ),
    );
  }
}
