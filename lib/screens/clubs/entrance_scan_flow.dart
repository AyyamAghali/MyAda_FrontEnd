import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../data/club_events_discovery_mock.dart';
import '../../models/club_public_event.dart';
import '../../models/event_tickets_models.dart';
import '../../services/event_tickets_local_repository.dart';
import '../../services/event_tickets_repository.dart';
import '../../utils/constants.dart';

class SelectClubForScanScreen extends StatelessWidget {
  const SelectClubForScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final clubs = _clubsFromDiscovery(const []);
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.gray900,
        elevation: 0,
        title: const Text('Scan'),
      ),
      body: clubs.isEmpty
          ? const Center(child: Text('No clubs found.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: clubs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final c = clubs[i];
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
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                c.$2.substring(0, 1),
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

  List<(int, String)> _clubsFromDiscovery(List<int> clubIds) {
    final map = <int, String>{};
    for (final e in kClubDiscoveryEvents) {
      if (clubIds.isEmpty || clubIds.contains(e.clubId)) {
        map[e.clubId] ??= e.clubName;
      }
    }
    final out = map.entries.map((e) => (e.key, e.value)).toList();
    out.sort((a, b) => a.$2.compareTo(b.$2));
    return out;
  }
}

class SelectEventForScanScreen extends StatelessWidget {
  final int clubId;
  final String clubName;

  const SelectEventForScanScreen({
    super.key,
    required this.clubId,
    required this.clubName,
  });

  @override
  Widget build(BuildContext context) {
    final events =
        kClubDiscoveryEvents.where((e) => e.clubId == clubId).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.gray900,
        elevation: 0,
        title: Text(clubName),
      ),
      body: events.isEmpty
          ? const Center(child: Text('No upcoming events found.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: events.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _EventPickCard(event: events[i]),
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
  CheckInResponse? _last;
  Timer? _clearTimer;
  final EventTicketsRepository _repo = LocalEventTicketsRepository();

  @override
  void dispose() {
    _clearTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleJwt(String jwt) async {
    if (_busy) return;
    setState(() => _busy = true);
    final res = await _repo.checkIn(
      eventId: widget.eventId.toString(),
      jwt: jwt,
    );
    if (!mounted) return;
    setState(() {
      _last = res;
      _busy = false;
    });

    _clearTimer?.cancel();
    _clearTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() => _last = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final event = getClubPublicEventById(widget.eventId);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(event?.title ?? 'Scanner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              for (final b in barcodes) {
                final v = b.rawValue;
                if (v == null || v.isEmpty) continue;
                _handleJwt(v);
                break;
              }
            },
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.35),
                      Colors.black.withValues(alpha: 0.05),
                      Colors.black.withValues(alpha: 0.55),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.85),
                  width: 2,
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: _last == null ? _hintCard() : _resultCard(_last!),
          ),
          if (_busy)
            const Positioned(
              top: 16,
              right: 16,
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
    );
  }

  Widget _hintCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: const Row(
        children: [
          Icon(Icons.qr_code_2, color: Colors.white, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Scan attendee ticket QR (JWT)',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultCard(CheckInResponse res) {
    final ok = res.success && res.status == 'checked_in';
    final dup = res.success && res.status == 'already_checked_in';
    final color = ok
        ? const Color(0xFF16A34A)
        : dup
            ? const Color(0xFFF59E0B)
            : const Color(0xFFEF4444);
    final title = ok ? 'Entry allowed' : dup ? 'Ticket already used' : 'Denied';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            res.message,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          if (res.attendee != null) ...[
            Text(
              '${res.attendee!.name} ${res.attendee!.surname}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Student ID: ${res.attendee!.studentId}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

