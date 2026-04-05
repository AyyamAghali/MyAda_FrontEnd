import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/club_events_discovery_mock.dart';
import '../../models/club_public_event.dart';
import '../../utils/constants.dart';
import '../../widgets/responsive_container.dart';
import 'club_event_detail_screen.dart';
import 'club_module_nav.dart';

const _kCategories = ['All Events', 'Technology', 'Social', 'Academic', 'Sports', 'Arts', 'Business'];

Color _eventCategoryColor(String category) {
  switch (category) {
    case 'Technology':
      return const Color(0xFF2563EB);
    case 'Social':
      return const Color(0xFF8B5CF6);
    case 'Academic':
      return const Color(0xFF059669);
    case 'Sports':
      return const Color(0xFFEA580C);
    case 'Arts':
      return const Color(0xFFDB2777);
    case 'Business':
      return const Color(0xFF2563EB);
    default:
      return const Color(0xFF64748B);
  }
}

class ClubEventsScreen extends StatefulWidget {
  final bool embedInHub;

  /// When set, only events for this club id (discovery mock) are listed.
  final int? filterClubId;

  const ClubEventsScreen({
    super.key,
    this.embedInHub = false,
    this.filterClubId,
  });

  @override
  State<ClubEventsScreen> createState() => _ClubEventsScreenState();
}

class _ClubEventsScreenState extends State<ClubEventsScreen> {
  String search = '';
  String category = 'All Events';
  bool myClubsOnly = false;
  bool grid = true;

  /// Active memberships (web `mockMemberships` Active).
  static const _myClubIds = {1, 2};

  List<ClubPublicEvent> get _filtered {
    var list = List<ClubPublicEvent>.from(kClubDiscoveryEvents);
    final hubClub = widget.filterClubId;
    if (hubClub != null) {
      list = list.where((e) => e.clubId == hubClub).toList();
    }
    if (myClubsOnly) {
      list = list.where((e) => _myClubIds.contains(e.clubId)).toList();
    }
    if (category != 'All Events') {
      list = list.where((e) => e.category.toLowerCase() == category.toLowerCase()).toList();
    }
    final q = search.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((e) {
        return e.title.toLowerCase().contains(q) ||
            e.clubName.toLowerCase().contains(q) ||
            (e.description ?? '').toLowerCase().contains(q);
      }).toList();
    }
    return list;
  }

  String _formatDate(String dateStr) {
    final d = DateTime.parse(dateStr);
    return DateFormat.yMMMd().format(d);
  }

  String _formatTime(String? t) {
    if (t == null || t.isEmpty) return '';
    final parts = t.split(':');
    final h = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    final period = h >= 12 ? 'PM' : 'AM';
    final hour = h % 12 == 0 ? 12 : h % 12;
    return '$hour:${m.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    final scroll = ResponsiveContainer(
      backgroundColor: ClubUiColors.pageBg,
      child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 12,
                              runSpacing: 8,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Club Events',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    Text(
                                      '${list.length} events discovered',
                                      style: const TextStyle(color: Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                                TextButton.icon(
                                  onPressed: () => ClubModuleNav.openMyRegisteredEvents(context),
                                  icon: const Icon(Icons.calendar_month_outlined, size: 18),
                                  label: const Text('My Registrations'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              onChanged: (v) => setState(() => search = v),
                              decoration: InputDecoration(
                                hintText: 'Find an event...',
                                prefixIcon: const Icon(Icons.search, color: AppColors.gray400),
                                filled: true,
                                fillColor: AppColors.gray50,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: AppColors.gray200),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ChoiceChip(
                                  label: const Text('All events'),
                                  selected: !myClubsOnly,
                                  onSelected: (_) => setState(() => myClubsOnly = false),
                                ),
                                ChoiceChip(
                                  label: const Text('My clubs only'),
                                  selected: myClubsOnly,
                                  onSelected: (_) => setState(() => myClubsOnly = true),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: _kCategories.map((c) {
                                  final sel = category == c;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      label: Text(c.toUpperCase()),
                                      selected: sel,
                                      onSelected: (_) => setState(() => category = c),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                _toggleIcon(Icons.grid_view_rounded, grid, () => setState(() => grid = true)),
                                const SizedBox(width: 8),
                                _toggleIcon(Icons.view_list_rounded, !grid, () => setState(() => grid = false)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (list.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: Text('No events match your filters.')),
                      )
                    else if (grid)
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            // Taller cells: image + text was overflowing at ~0.62.
                            childAspectRatio: 0.46,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, i) => _EventCard(
                              event: list[i],
                              grid: true,
                              formatDate: _formatDate,
                              formatTime: _formatTime,
                              categoryColor: _eventCategoryColor(list[i].category),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (_) => ClubEventDetailScreen(eventId: list[i].id),
                                ),
                              ),
                            ),
                            childCount: list.length,
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, i) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _EventCard(
                                event: list[i],
                                grid: false,
                                formatDate: _formatDate,
                                formatTime: _formatTime,
                                categoryColor: _eventCategoryColor(list[i].category),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (_) => ClubEventDetailScreen(eventId: list[i].id),
                                  ),
                                ),
                              ),
                            ),
                            childCount: list.length,
                          ),
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                ),
    );

    if (widget.embedInHub) {
      return scroll;
    }

    return Scaffold(
      backgroundColor: ClubUiColors.pageBg,
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
      body: SafeArea(child: scroll),
    );
  }

  Widget _toggleIcon(IconData icon, bool active, VoidCallback onTap) {
    return Material(
      color: active ? ClubNavColors.activeBg : AppColors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.gray200),
          ),
          child: Icon(icon, size: 20, color: active ? ClubNavColors.activeText : AppColors.gray600),
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final ClubPublicEvent event;
  final bool grid;
  final String Function(String) formatDate;
  final String Function(String?) formatTime;
  final Color categoryColor;
  final VoidCallback onTap;

  const _EventCard({
    required this.event,
    required this.grid,
    required this.formatDate,
    required this.formatTime,
    required this.categoryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final image = event.imageAsset != null
        ? Image.asset(
            event.imageAsset!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _placeholder(categoryColor),
          )
        : _placeholder(categoryColor);

    final pad = grid ? const EdgeInsets.fromLTRB(8, 8, 8, 10) : const EdgeInsets.all(12);
    final titleSize = grid ? 14.0 : 15.0;

    final body = Padding(
      padding: pad,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              event.category.toUpperCase(),
              style: TextStyle(
                fontSize: grid ? 9 : 10,
                fontWeight: FontWeight.w700,
                color: categoryColor,
              ),
            ),
          ),
          SizedBox(height: grid ? 6 : 8),
          Text(
            event.title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: titleSize,
              color: const Color(0xFF0F172A),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: grid ? 2 : 4),
          Text(
            event.clubName,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: grid ? 6 : 8),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF94A3B8)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  formatDate(event.date),
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.schedule, size: 14, color: Color(0xFF94A3B8)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  formatTime(event.time),
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: grid
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    // Slightly shorter image area so text fits in grid cells.
                    child: AspectRatio(aspectRatio: 1.45, child: image),
                  ),
                  body,
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                    child: SizedBox(width: 112, height: 112, child: image),
                  ),
                  Expanded(child: body),
                  const Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Icon(Icons.chevron_right, color: Color(0xFFCBD5E1)),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _placeholder(Color c) {
    return Container(
      color: c.withOpacity(0.2),
      child: Icon(Icons.event, size: 48, color: c),
    );
  }
}
