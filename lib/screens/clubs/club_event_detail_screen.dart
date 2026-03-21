import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/club_events_discovery_mock.dart';
import '../../services/club_module_prefs.dart';
import '../../utils/constants.dart';

class ClubEventDetailScreen extends StatefulWidget {
  final int eventId;

  const ClubEventDetailScreen({super.key, required this.eventId});

  @override
  State<ClubEventDetailScreen> createState() => _ClubEventDetailScreenState();
}

class _ClubEventDetailScreenState extends State<ClubEventDetailScreen> {
  bool _loading = true;
  bool _registered = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await ClubModulePrefs.isRegisteredForEvent(widget.eventId);
    if (!mounted) return;
    setState(() {
      _registered = r;
      _loading = false;
    });
  }

  String _formatDate(String dateStr) {
    final d = DateTime.parse(dateStr);
    return DateFormat.yMMMMEEEEd().format(d);
  }

  String _formatTimeRange(String? start, String? end) {
    String fmt(String t) {
      final parts = t.split(':');
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final period = h >= 12 ? 'PM' : 'AM';
      final hour = h % 12 == 0 ? 12 : h % 12;
      return '$hour:${m.toString().padLeft(2, '0')} $period';
    }

    if (start == null || start.isEmpty) return '';
    if (end == null || end.isEmpty) return fmt(start);
    return '${fmt(start)} – ${fmt(end)}';
  }

  @override
  Widget build(BuildContext context) {
    final event = getClubPublicEventById(widget.eventId);
    if (event == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Event')),
        body: const Center(child: Text('Event not found.')),
      );
    }

    return Scaffold(
      backgroundColor: ClubUiColors.pageBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.white,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (event.imageAsset != null)
                    Image.asset(
                      event.imageAsset!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: ClubUiColors.ctaBlue),
                    )
                  else
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                        ),
                      ),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.55)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  event.title,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 8),
                Text(event.clubName, style: const TextStyle(fontSize: 16, color: Color(0xFF64748B))),
                const SizedBox(height: 20),
                _row(Icons.calendar_today_outlined, _formatDate(event.date)),
                const SizedBox(height: 8),
                _row(Icons.schedule, _formatTimeRange(event.time, event.endTime)),
                const SizedBox(height: 8),
                _row(Icons.place_outlined, event.location),
                const SizedBox(height: 24),
                if (event.description != null) ...[
                  const Text(
                    'About',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description!,
                    style: const TextStyle(height: 1.5, color: Color(0xFF475569)),
                  ),
                ],
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _loading
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: FilledButton(
                  onPressed: _registered
                      ? null
                      : () async {
                          await ClubModulePrefs.registerForEvent(event.id);
                          if (!context.mounted) return;
                          setState(() => _registered = true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('You are registered (saved on device).')),
                          );
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: ClubUiColors.ctaBlue,
                    disabledBackgroundColor: AppColors.gray300,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    _registered ? 'Registered' : 'Register for event',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _row(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: ClubNavColors.activeText),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(color: Color(0xFF475569)))),
      ],
    );
  }
}
