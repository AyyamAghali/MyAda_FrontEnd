import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/club_events_discovery_mock.dart';
import '../../models/club_public_event.dart';
import '../../services/club_module_prefs.dart';
import '../../utils/constants.dart';
import '../../widgets/responsive_container.dart';
import 'club_event_detail_screen.dart';
import 'club_module_nav.dart';

class MyRegisteredEventsScreen extends StatefulWidget {
  const MyRegisteredEventsScreen({super.key});

  @override
  State<MyRegisteredEventsScreen> createState() => _MyRegisteredEventsScreenState();
}

class _MyRegisteredEventsScreenState extends State<MyRegisteredEventsScreen> {
  Set<int> _ids = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ids = await ClubModulePrefs.registeredEventIds();
    if (mounted) {
      setState(() {
        _ids = ids;
        _loading = false;
      });
    }
  }

  List<ClubPublicEvent> get _events {
    final out = <ClubPublicEvent>[];
    for (final e in kClubDiscoveryEvents) {
      if (_ids.contains(e.id)) out.add(e);
    }
    out.sort((a, b) => a.date.compareTo(b.date));
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final events = _events;
    return Scaffold(
      backgroundColor: ClubUiColors.pageBg,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.gray900,
        elevation: 0,
        title: const Text('My Registrations'),
        actions: [
          TextButton(
            onPressed: () => ClubModuleNav.openEvents(context),
            child: const Text('Browse events'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ResponsiveContainer(
              backgroundColor: ClubUiColors.pageBg,
              child: events.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.event_busy, size: 56, color: Color(0xFFCBD5E1)),
                            const SizedBox(height: 16),
                            const Text(
                              'No registrations yet',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Register for events from the Club Events list — your choices are saved on this device.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 20),
                            FilledButton(
                              onPressed: () {
                                Navigator.pop(context);
                                ClubModuleNav.openEvents(context);
                              },
                              child: const Text('Discover events'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: events.length,
                      itemBuilder: (context, i) {
                        final e = events[i];
                        final d = DateTime.parse(e.date);
                        final formatted = DateFormat.yMMMMEEEEd().format(d);
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: e.imageAsset != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      e.imageAsset!,
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(Icons.event, size: 40),
                            title: Text(e.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                            subtitle: Text('${e.clubName}\n$formatted', style: const TextStyle(height: 1.3)),
                            isThreeLine: true,
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (_) => ClubEventDetailScreen(eventId: e.id),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
