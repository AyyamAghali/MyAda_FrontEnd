import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/club.dart';
import '../../models/club_public_event.dart';
import '../../models/event_tickets_models.dart';
import '../../services/club_api_service.dart';
import '../../services/remote_event_tickets_repository.dart';
import '../../services/event_tickets_repository.dart';
import '../../utils/constants.dart';
import '../../widgets/app_back_button.dart';
import 'club_details.dart';
import 'event_ticket_screen.dart';

bool _isHttpUrl(String s) =>
    s.startsWith('http://') || s.startsWith('https://');

/// Brand CTA: vibrant blue → app primary → red (matches vacancy detail).
const LinearGradient _kBrandGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    ClubUiColors.ctaBlue,
    AppColors.primary,
    AppColors.secondary,
  ],
  stops: [0.0, 0.48, 1.0],
);

class ClubEventDetailScreen extends StatefulWidget {
  final int eventId;

  /// When opening from a list, pass the row so the hero layout shows immediately
  /// (no intermediate "Event" loading AppBar).
  final ClubPublicEvent? initialEvent;

  const ClubEventDetailScreen({
    super.key,
    required this.eventId,
    this.initialEvent,
  });

  @override
  State<ClubEventDetailScreen> createState() => _ClubEventDetailScreenState();
}

class _ClubEventDetailScreenState extends State<ClubEventDetailScreen> {
  bool _loading = true;
  bool _registered = false;
  bool _full = false;
  EventSnapshot? _snapshot;
  ClubPublicEvent? _event;
  int? _registrationCount;
  String? _hostName;
  Club? _hostClub;
  final EventTicketsRepository _repo = RemoteEventTicketsRepository();
  final ClubApiService _api = ClubApiService();

  @override
  void initState() {
    super.initState();
    final preview = widget.initialEvent;
    if (preview != null && preview.id == widget.eventId) {
      _event = preview;
      _hostName = _cleanHostName(preview.clubName);
    }
    _load();
  }

  Widget _minimalChromeScaffold({required Widget body}) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Center(
            child: AppBackButton(onPressed: () => Navigator.pop(context)),
          ),
        ),
      ),
      body: body,
    );
  }

  Future<void> _load() async {
    final eventId = widget.eventId.toString();
    var event = await _api.fetchEventById(widget.eventId) ?? _event;
    Club? hostClub;
    if (event != null && event.clubId > 0) {
      try {
        hostClub = await _api.fetchClubDetail(event.clubId.toString());
      } catch (_) {}
    }
    final hostName = event == null
        ? _hostName
        : _cleanHostName(hostClub?.name) ??
            _cleanHostName(event.clubName) ??
            _hostName;

    EventSnapshot? snap = event != null ? _snapshotFromEvent(event) : null;
    var registered = false;
    try {
      final ticket = await _repo.getTicket(eventId);
      registered = true;
      snap = ticket.event;
      // Ticket nested `event` often returns `registeredCount: 0`; refresh from
      // `GET /api/v1/events/{id}` (canonical per CLUB_API_DOC).
      final refreshed = await _api.fetchEventById(widget.eventId);
      if (refreshed != null) event = refreshed;
    } catch (_) {
      // Not registered yet or ticket unavailable; event detail still carries capacity.
    }
    int? registrationCount;
    try {
      registrationCount = await _api.fetchEventRegistrationCount(eventId);
    } catch (_) {
      // Fall back to the event/ticket counts below if the anonymous listing fails.
    }
    final mergedLimit = _mergedSeatLimitValues(
      snap?.seatLimit,
      event?.seatLimit,
    );
    final mergedBooked = _bookedCountValues(
      event?.registeredCount,
      snap?.registeredCount ?? 0,
      registrationCount,
      registered,
    );
    final full = mergedLimit > 0 && mergedBooked >= mergedLimit;
    if (!mounted) return;
    setState(() {
      _event = event;
      _snapshot = snap;
      _registrationCount = registrationCount;
      _hostClub = hostClub;
      _hostName = hostName;
      _registered = registered;
      _full = full;
      _loading = false;
    });
  }

  String? _cleanHostName(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  /// Ticket payloads often send `seatLimit: 0` while the club event API has the real cap.
  static int _mergedSeatLimitValues(int? snapLimit, int? eventLimit) {
    final s = snapLimit ?? 0;
    final e = eventLimit ?? 0;
    return s > 0 ? s : e;
  }

  /// Prefer the registrations endpoint from the docs, then event/ticket snapshots.
  static int _bookedCountValues(
    int? eventRegistered,
    int snapshotRegistered,
    int? registrationEndpointCount,
    bool isCurrentUserRegistered,
  ) {
    final counts = <int>[
      if (registrationEndpointCount != null) registrationEndpointCount,
      if (eventRegistered != null) eventRegistered,
      snapshotRegistered,
      if (isCurrentUserRegistered) 1,
    ];
    return counts.fold<int>(0, (max, count) => count > max ? count : max);
  }

  int _mergedSeatLimit(ClubPublicEvent event) {
    return _mergedSeatLimitValues(_snapshot?.seatLimit, event.seatLimit);
  }

  int _bookedCount(ClubPublicEvent event) {
    return _bookedCountValues(
      event.registeredCount,
      _snapshot?.registeredCount ?? 0,
      _registrationCount,
      _registered,
    );
  }

  EventSnapshot _snapshotFromEvent(ClubPublicEvent event) {
    return EventSnapshot(
      id: event.id.toString(),
      name: event.title,
      imageUrl: event.imageAsset,
      startTime: event.time,
      endTime: event.endTime,
      location: event.location,
      seatLimit: event.seatLimit ?? 0,
      registeredCount: event.registeredCount ?? 0,
    );
  }

  String _fmtDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return dateStr;
    return DateFormat('MMMM d, yyyy').format(dt);
  }

  String _fmtTime(String? t) {
    if (t == null || t.isEmpty) return '';
    final parsed = DateTime.tryParse(t);
    if (parsed != null) return DateFormat('h:mm a').format(parsed);
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

  static const TextStyle _kMetaCaps = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.gray400,
    letterSpacing: 0.5,
  );

  Widget _registrationAndSpotsSection(ClubPublicEvent event) {
    final booked = _bookedCount(event);
    final limit = _mergedSeatLimit(event);
    final remaining = limit <= 0 ? null : (limit - booked).clamp(0, limit);
    final progress = limit <= 0 ? 0.0 : (booked / limit).clamp(0, 1).toDouble();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('REGISTERED', style: _kMetaCaps),
                    const SizedBox(height: 8),
                    Text(
                      '$booked',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.gray900,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('REMAINING SPOTS', style: _kMetaCaps),
                    const SizedBox(height: 8),
                    Text(
                      remaining == null
                          ? 'No limit set'
                          : '$remaining of $limit left',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gray900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.gray200,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: _registrationCta(event),
          ),
        ],
      ),
    );
  }

  Widget _registrationCta(ClubPublicEvent event) {
    final enabled = !_loading && (_registered || !_full);
    final borderRadius = BorderRadius.circular(12);
    final label = _registered
        ? 'View Ticket'
        : (_full ? 'Event Full' : 'Register');

    if (!enabled) {
      return Material(
        color: AppColors.gray300,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: null,
          borderRadius: borderRadius,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.gray600,
              ),
            ),
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: _kBrandGradient,
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: ClubUiColors.ctaBlue.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: _registered
              ? () => _openTicket(event)
              : () => _registerForEvent(event),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openTicket(ClubPublicEvent event) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => EventTicketScreen(eventId: event.id),
      ),
    );
  }

  Future<void> _registerForEvent(ClubPublicEvent event) async {
    try {
      await _repo.registerForEvent(event.id.toString());
      final snap = await _repo.getEventSnapshot(event.id.toString());
      final refreshed = await _api.fetchEventById(event.id);
      int? registrationCount;
      try {
        registrationCount =
            await _api.fetchEventRegistrationCount(event.id.toString());
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _snapshot = snap;
        if (refreshed != null) _event = refreshed;
        _registrationCount = registrationCount;
        _registered = true;
        final ev = _event;
        final cap = ev != null
            ? _mergedSeatLimitValues(snap.seatLimit, ev.seatLimit)
            : snap.seatLimit;
        final booked = _bookedCountValues(
          ev?.registeredCount,
          snap.registeredCount,
          registrationCount,
          true,
        );
        _full = cap > 0 && booked >= cap;
      });
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registered. Ticket created.')),
      );
      await Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (_) => EventTicketScreen(eventId: event.id),
        ),
      );
    } catch (e) {
      if (!mounted) return;
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
  }

  Widget _hostedBySection(ClubPublicEvent event) {
    final club = _hostClub;
    final name = _cleanHostName(club?.name) ??
        _hostName ??
        _cleanHostName(event.clubName);
    if (name == null) return const SizedBox.shrink();

    final rawLogo = (club?.logo ?? '').trim();
    final resolvedLogo = rawLogo.isEmpty
        ? ''
        : (_isHttpUrl(rawLogo) ? rawLogo : resolveMediaUrl(rawLogo));

    final body = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('HOSTED BY', style: _kMetaCaps),
          const SizedBox(height: 12),
          Row(
            children: [
              _hostedByAvatar(resolvedLogo, name),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gray900,
                      ),
                    ),
                  ],
                ),
              ),
              if (club != null)
                const Icon(Icons.chevron_right,
                    color: AppColors.gray400, size: 22),
            ],
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: club != null
              ? InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => ClubDetails(club: club),
                      ),
                    );
                  },
                  child: body,
                )
              : body,
        ),
      ),
    );
  }

  Widget _hostedByAvatar(String resolvedLogo, String name) {
    const size = 52.0;
    final initial = name.characters.first.toUpperCase();
    if (resolvedLogo.isEmpty) {
      return CircleAvatar(
        radius: 26,
        backgroundColor: AppColors.primary.withValues(alpha: 0.12),
        child: Text(
          initial,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: AppColors.primary,
          ),
        ),
      );
    }
    return ClipOval(
      child: Image.network(
        resolvedLogo,
        width: size,
        height: size,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => CircleAvatar(
          radius: 26,
          backgroundColor: AppColors.primary.withValues(alpha: 0.12),
          child: Text(
            initial,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final event = _event;
    if (event == null && _loading) {
      return _minimalChromeScaffold(
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (event == null) {
      return _minimalChromeScaffold(
        body: const Center(child: Text('Event not found.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          if (_loading)
            SliverToBoxAdapter(
              child: LinearProgressIndicator(
                minHeight: 2,
                backgroundColor: AppColors.gray200,
                color: AppColors.primary,
              ),
            ),
          // Hero header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            automaticallyImplyLeading: false,
            leading: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Center(
                child: AppBackButton(onPressed: () => Navigator.pop(context)),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _heroBackground(
                imageUrl: event.imageAsset,
                child: Stack(
                  children: [
                    Positioned(
                      right: -40,
                      top: -20,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.white.withValues(alpha: 0.06),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -20,
                      bottom: 20,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.white.withValues(alpha: 0.04),
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              event.title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.white,
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

          // Key details section with icons - prominent, not tag-like
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                children: [
                  _detailRow(
                    Icons.calendar_today_outlined,
                    'Date',
                    _fmtDate(event.date),
                  ),
                  const Divider(height: 20, color: AppColors.gray100),
                  _detailRow(
                    Icons.schedule,
                    'Time',
                    _fmtTimeRange(event.time, event.endTime),
                  ),
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
                child: Text(
                  event.description!,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: AppColors.gray700,
                  ),
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 10)),

          SliverToBoxAdapter(child: _registrationAndSpotsSection(event)),

          const SliverToBoxAdapter(child: SizedBox(height: 10)),

          SliverToBoxAdapter(child: _hostedBySection(event)),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _heroBackground({required String? imageUrl, required Widget child}) {
    Widget gradient() => Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.secondary],
            ),
          ),
        );

    final raw = imageUrl?.trim();
    if (raw == null || raw.isEmpty) {
      return Stack(fit: StackFit.expand, children: [gradient(), child]);
    }
    final resolved = _isHttpUrl(raw) ? raw : resolveMediaUrl(raw);
    final image = _isHttpUrl(resolved)
        ? Image.network(
            resolved,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          )
        : Image.asset(
            raw,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          );

    return Stack(
      fit: StackFit.expand,
      children: [
        gradient(),
        image,
        Container(color: Colors.black.withValues(alpha: 0.34)),
        child,
      ],
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray400)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionCard(
      {required IconData icon, required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 16, color: AppColors.primary)),
            const SizedBox(width: 10),
            Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gray900))),
          ]),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
