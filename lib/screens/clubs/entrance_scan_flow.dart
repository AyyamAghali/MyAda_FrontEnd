import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../models/club_public_event.dart';
import '../../models/event_tickets_models.dart';
import '../../services/auth_service.dart';
import '../../services/club_api_service.dart';
import '../../services/remote_event_tickets_repository.dart';
import '../../services/event_tickets_repository.dart';
import '../../utils/constants.dart';

class SelectClubForScanScreen extends StatefulWidget {
  const SelectClubForScanScreen({super.key});

  @override
  State<SelectClubForScanScreen> createState() =>
      _SelectClubForScanScreenState();
}

class _SelectClubForScanScreenState extends State<SelectClubForScanScreen> {
  final ClubApiService _api = ClubApiService();
  List<(int, String)> _clubs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final events = await _api.fetchEvents();
      final map = <int, String>{};
      for (final e in events) {
        map[e.clubId] ??= e.clubName;
      }
      final out = map.entries.map((e) => (e.key, e.value)).toList();
      out.sort((a, b) => a.$2.compareTo(b.$2));
      if (mounted) {
        setState(() {
          _clubs = out;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.gray900,
        elevation: 0,
        title: const Text('Scan'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _clubs.isEmpty
              ? const Center(child: Text('No clubs found.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _clubs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final c = _clubs[i];
                    return Material(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => SelectEventForScanScreen(
                                clubId: c.$1,
                                clubName: c.$2,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    c.$2.isNotEmpty
                                        ? c.$2.substring(0, 1).toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.$2,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.gray900,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    const Text(
                                      'Choose event to scan at entrance',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.gray600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right,
                                  color: AppColors.gray400),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class SelectEventForScanScreen extends StatefulWidget {
  final int clubId;
  final String clubName;

  const SelectEventForScanScreen({
    super.key,
    required this.clubId,
    required this.clubName,
  });

  @override
  State<SelectEventForScanScreen> createState() =>
      _SelectEventForScanScreenState();
}

class _SelectEventForScanScreenState extends State<SelectEventForScanScreen> {
  final ClubApiService _api = ClubApiService();
  List<ClubPublicEvent> _events = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final events = await _api.fetchEvents(clubId: widget.clubId);
      if (mounted) {
        setState(() {
          _events = events;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.gray900,
        elevation: 0,
        title: Text(widget.clubName),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _events.isEmpty
              ? const Center(child: Text('No upcoming events found.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _events.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _EventPickCard(event: _events[i]),
                ),
    );
  }
}

class _EventPickCard extends StatelessWidget {
  final ClubPublicEvent event;

  const _EventPickCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => EntranceScannerScreen(eventId: event.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.primary.withValues(alpha: 0.08),
                ),
                child: const Icon(Icons.qr_code_scanner,
                    color: AppColors.primary, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gray900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${event.date} • ${event.time}${event.endTime != null ? ' - ${event.endTime}' : ''}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.gray600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      event.location,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.gray600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.gray400),
            ],
          ),
        ),
      ),
    );
  }
}

class EntranceScannerScreen extends StatefulWidget {
  final int eventId;

  const EntranceScannerScreen({super.key, required this.eventId});

  @override
  State<EntranceScannerScreen> createState() => _EntranceScannerScreenState();
}

class _EntranceScannerScreenState extends State<EntranceScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  bool _busy = false;
  bool _cameraActive = true;
  CheckInResponse? _last;
  final EventTicketsRepository _repo = RemoteEventTicketsRepository();
  final AuthService _auth = AuthService.instance;
  final ClubApiService _api = ClubApiService();
  ClubPublicEvent? _event;
  AuthUserProfile? _attendeeProfile;
  bool _isResolvingAttendee = false;
  int _scanNonce = 0;

  @override
  void initState() {
    super.initState();
    _api.fetchEventById(widget.eventId).then((e) {
      if (mounted) setState(() => _event = e);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleToken(String token) async {
    if (_busy) return;
    final nonce = ++_scanNonce;
    setState(() {
      _busy = true;
      _cameraActive = false;
      _attendeeProfile = null;
      _isResolvingAttendee = false;
    });

    await _controller.stop();

    try {
      final res = await _repo.checkIn(
        eventId: widget.eventId.toString(),
        token: token,
        scannerDeviceId: 'flutter-mobile',
        gateId: 'main-entrance',
      );
      if (!mounted || nonce != _scanNonce) return;

      setState(() {
        _last = res;
        _busy = false;
      });

      final attendeeId = res.attendee?.userId.trim() ?? '';
      if (res.success && attendeeId.isNotEmpty) {
        setState(() => _isResolvingAttendee = true);
        try {
          final profile = await _auth.fetchUserById(attendeeId);
          if (!mounted || nonce != _scanNonce) return;
          setState(() {
            _attendeeProfile = profile;
            _isResolvingAttendee = false;
          });
        } catch (_) {
          if (!mounted || nonce != _scanNonce) return;
          setState(() => _isResolvingAttendee = false);
        }
      }
    } catch (e) {
      if (!mounted || nonce != _scanNonce) return;
      setState(() {
        _last = CheckInResponse(
          success: false,
          status: 'error',
          message: e.toString().replaceFirst('Exception: ', ''),
          eventId: widget.eventId.toString(),
          ticketId: '',
          attendee: null,
        );
        _busy = false;
      });
    }
  }

  Future<void> _scanNext() async {
    if (_busy) return;
    setState(() {
      _last = null;
      _attendeeProfile = null;
      _isResolvingAttendee = false;
      _cameraActive = true;
    });
    await _controller.start();
  }

  Future<void> _toggleCamera() async {
    if (_busy) return;
    if (_cameraActive) {
      await _controller.stop();
      if (mounted) setState(() => _cameraActive = false);
    } else {
      setState(() => _cameraActive = true);
      await _controller.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _last;

    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEventCard(),
                    const SizedBox(height: 16),
                    if (result == null)
                      _buildScannerCard()
                    else
                      _buildResultCard(result),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 16,
                color: AppColors.gray700,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Entrance Scanner',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.gray900,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Validate attendee tickets quickly',
                  style: TextStyle(fontSize: 13, color: AppColors.gray500),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _controller.switchCamera(),
            icon: const Icon(Icons.cameraswitch_rounded),
            color: AppColors.gray600,
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard() {
    final event = _event;
    final title = event?.title ?? 'Loading event...';
    final dateLine = event == null
        ? 'Preparing scanner'
        : _formatEventDateTime(event.date, event.time, event.endTime);
    final location = event?.location ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF3D7A96)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.event_available_rounded,
              color: Colors.white,
              size: 25,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateLine,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.82),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (location.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(22)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (_cameraActive)
                    MobileScanner(
                      controller: _controller,
                      onDetect: (capture) {
                        for (final barcode in capture.barcodes) {
                          final value = barcode.rawValue;
                          if (value == null || value.isEmpty) continue;
                          _handleToken(value);
                          break;
                        }
                      },
                    )
                  else
                    Container(
                      color: const Color(0xFF111827),
                      child: Center(
                        child: Icon(
                          Icons.qr_code_scanner_rounded,
                          size: 64,
                          color: Colors.white.withValues(alpha: 0.16),
                        ),
                      ),
                    ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.32),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.35),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: SizedBox(
                      width: 220,
                      height: 220,
                      child: CustomPaint(
                        painter: _ScanFramePainter(
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Row(
                      children: [
                        _CameraActionButton(
                          icon: Icons.flash_on_rounded,
                          onTap: () => _controller.toggleTorch(),
                        ),
                        const SizedBox(width: 8),
                        _CameraActionButton(
                          icon: _cameraActive
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          onTap: _toggleCamera,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Text(
                      _busy
                          ? 'Checking ticket...'
                          : 'Place the attendee ticket QR inside the frame',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  if (_busy)
                    const Center(
                      child: SizedBox(
                        width: 34,
                        height: 34,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.qr_code_2_rounded,
                    color: AppColors.primary,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'The scanner stops after every valid read so staff can verify the result before admitting the next attendee.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.gray600,
                      height: 1.35,
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

  Widget _buildResultCard(CheckInResponse res) {
    final ok = res.success && res.status == 'admitted';
    final dup = res.success && res.status == 'already_scanned';
    final color = ok
        ? const Color(0xFF16A34A)
        : dup
            ? const Color(0xFFF59E0B)
            : const Color(0xFFEF4444);
    final bg = ok
        ? const Color(0xFFF0FDF4)
        : dup
            ? const Color(0xFFFFFBEB)
            : const Color(0xFFFEF2F2);
    final title = ok
        ? 'Entry allowed'
        : dup
            ? 'Ticket already scanned'
            : 'Entry denied';
    final icon = ok
        ? Icons.check_circle_rounded
        : dup
            ? Icons.info_rounded
            : Icons.cancel_rounded;
    final attendeeName = _displayAttendeeName(res);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withValues(alpha: 0.22)),
            ),
            child: Column(
              children: [
                Icon(icon, color: color, size: 46),
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: color,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  res.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.gray600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Attendee',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.gray500,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),
          _InfoTile(
            icon: Icons.person_rounded,
            title: attendeeName,
            subtitle: _attendeeSubtitle(res),
          ),
          if (_isResolvingAttendee) ...[
            const SizedBox(height: 8),
            const LinearProgressIndicator(
              minHeight: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ],
          const SizedBox(height: 16),
          const Text(
            'Event',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.gray500,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),
          _InfoTile(
            icon: Icons.event_rounded,
            title: _event?.title ?? 'Event #${widget.eventId}',
            subtitle: _event == null
                ? 'Event details unavailable'
                : '${_formatEventDateTime(_event!.date, _event!.time, _event!.endTime)}\n${_event!.location}',
          ),
          const SizedBox(height: 16),
          _InfoTile(
            icon: Icons.confirmation_number_rounded,
            title: res.ticketId.isEmpty ? 'Ticket' : 'Ticket ${res.ticketId}',
            subtitle: 'Status: ${res.status.replaceAll('_', ' ')}',
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _scanNext,
            icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
            label: const Text(
              'Scan next attendee',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Change event'),
          ),
        ],
      ),
    );
  }

  String _displayAttendeeName(CheckInResponse res) {
    final profileName = [
      _attendeeProfile?.firstName,
      _attendeeProfile?.lastName,
    ].where((v) => (v ?? '').trim().isNotEmpty).join(' ').trim();
    if (profileName.isNotEmpty) return profileName;

    final attendee = res.attendee;
    if (attendee != null) {
      final name = [
        attendee.name,
        attendee.surname,
      ].where((v) => (v ?? '').trim().isNotEmpty).join(' ').trim();
      if (name.isNotEmpty) return name;
      if (attendee.studentId.isNotEmpty) return attendee.studentId;
    }

    return res.success ? 'Registered attendee' : 'Unknown attendee';
  }

  String _attendeeSubtitle(CheckInResponse res) {
    final parts = <String>[];
    final profile = _attendeeProfile;
    if (profile != null) {
      if (profile.userName.isNotEmpty) parts.add('@${profile.userName}');
      if ((profile.email ?? '').isNotEmpty) parts.add(profile.email!);
    }
    final attendee = res.attendee;
    if (attendee != null) {
      if (attendee.studentId.isNotEmpty) {
        parts.add('Student ID: ${attendee.studentId}');
      }
      if (attendee.userId.isNotEmpty) parts.add('User ID: ${attendee.userId}');
    }
    if (_isResolvingAttendee && parts.isEmpty) {
      return 'Loading attendee details...';
    }
    return parts.isEmpty ? 'No attendee details returned' : parts.join('\n');
  }

  String _formatEventDateTime(String date, String time, String? endTime) {
    final dateTime = _parseEventDateTime(date, time);
    final datePart = dateTime != null
        ? DateFormat('EEE, MMM d, yyyy').format(dateTime)
        : date;
    final startPart =
        dateTime != null ? DateFormat('h:mm a').format(dateTime) : time;
    final endPart = _formatTimeOnly(endTime);

    if (endPart != null && endPart.isNotEmpty) {
      return '$datePart • $startPart - $endPart';
    }
    return '$datePart • $startPart';
  }

  DateTime? _parseEventDateTime(String date, String time) {
    final parsedTime = DateTime.tryParse(time);
    if (parsedTime != null) return parsedTime;
    final datePart = date.split('T').first.split(' ').first;
    final timePart = time.split('.').first;
    return DateTime.tryParse('${datePart}T$timePart') ??
        DateTime.tryParse('$datePart $timePart') ??
        DateTime.tryParse(date);
  }

  String? _formatTimeOnly(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = DateTime.tryParse(value);
    if (parsed != null) return DateFormat('h:mm a').format(parsed);
    final split = value.split(':');
    if (split.length >= 2) return '${split[0]}:${split[1]}';
    return value;
  }
}

class _CameraActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CameraActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.38),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 19, color: AppColors.primary),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.gray500,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanFramePainter extends CustomPainter {
  final Color color;

  const _ScanFramePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const arm = 30.0;
    final w = size.width;
    final h = size.height;

    canvas.drawLine(const Offset(0, arm), Offset.zero, paint);
    canvas.drawLine(Offset.zero, const Offset(arm, 0), paint);
    canvas.drawLine(Offset(w - arm, 0), Offset(w, 0), paint);
    canvas.drawLine(Offset(w, 0), Offset(w, arm), paint);
    canvas.drawLine(Offset(0, h - arm), Offset(0, h), paint);
    canvas.drawLine(Offset(0, h), Offset(arm, h), paint);
    canvas.drawLine(Offset(w - arm, h), Offset(w, h), paint);
    canvas.drawLine(Offset(w, h - arm), Offset(w, h), paint);
  }

  @override
  bool shouldRepaint(_ScanFramePainter oldDelegate) =>
      oldDelegate.color != color;
}
