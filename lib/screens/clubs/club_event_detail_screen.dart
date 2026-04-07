import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/club_events_discovery_mock.dart';
import '../../services/club_module_prefs.dart';
import '../../utils/constants.dart';

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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await ClubModulePrefs.isRegisteredForEvent(widget.eventId);
    if (!mounted) return;
    setState(() { _registered = r; _loading = false; });
  }

  String _fmtDate(String dateStr) => DateFormat('MMMM d, yyyy').format(DateTime.parse(dateStr));

  String _fmtTime(String? t) {
    if (t == null || t.isEmpty) return '';
    final parts = t.split(':');
    final h = int.parse(parts[0]);
    final m = int.parse(parts[1]);
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
    final event = getClubPublicEventById(widget.eventId);
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
                            const Text('42 / 150', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.gray900)),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(value: 42 / 150, minHeight: 5, backgroundColor: AppColors.gray200, color: AppColors.primary),
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
                        ? null
                        : () async {
                            await ClubModulePrefs.registerForEvent(event.id);
                            if (!context.mounted) return;
                            setState(() => _registered = true);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You are registered!')));
                          },
                    icon: Icon(_registered ? Icons.check_circle_outline : Icons.event_available, size: 20),
                    label: Text(_registered ? 'Registered' : 'Register for Event', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
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
