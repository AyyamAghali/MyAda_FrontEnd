import 'package:flutter/material.dart';
import '../../models/app_notification.dart';
import '../../services/notification_controller.dart';
import '../../utils/constants.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/responsive_container.dart';
import 'club_module_nav.dart';

class _Notif {
  final String id;
  final String title;
  final String body;
  final String tabKey;
  final String time;
  final bool isRead;
  _Notif({required this.id, required this.title, required this.body, required this.tabKey, required this.time, required this.isRead});
}

class ClubNotificationsScreen extends StatefulWidget {
  const ClubNotificationsScreen({super.key});

  @override
  State<ClubNotificationsScreen> createState() => _ClubNotificationsScreenState();
}

class _ClubNotificationsScreenState extends State<ClubNotificationsScreen> {
  String _tab = 'all';
  List<_Notif> _notifs = [];
  bool _isLoading = false;
  String? _error;

  static const _tabs = [
    ('all', 'All'),
    ('proposals', 'Proposals'),
    ('membership', 'Membership'),
    ('vacancies', 'Vacancies'),
    ('events', 'Events'),
  ];

  @override
  void initState() {
    super.initState();
    NotificationController.instance.addListener(_syncFromController);
    _load();
  }

  @override
  void dispose() {
    NotificationController.instance.removeListener(_syncFromController);
    super.dispose();
  }

  String _categorize(String raw) {
    final s = raw.toLowerCase();
    if (s.contains('proposal')) return 'proposals';
    if (s.contains('member')) return 'membership';
    if (s.contains('vacanc') || s.contains('job')) return 'vacancies';
    if (s.contains('event')) return 'events';
    return 'all';
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      await NotificationController.instance.initialize();
      if (mounted) {
        setState(() {
          _notifs = NotificationController.instance.items.map(_fromApp).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  void _syncFromController() {
    if (!mounted) return;
    final controller = NotificationController.instance;
    setState(() {
      _notifs = controller.items.map(_fromApp).toList();
      _error = controller.error;
      _isLoading = controller.loading;
    });
  }

  _Notif _fromApp(AppNotification n) {
    final type = n.type.trim();
    return _Notif(
      id: n.id,
      title: type.isEmpty ? 'Notification' : type,
      body: n.message,
      tabKey: _categorize(type),
      time: _formatTime(n.createdAt?.toIso8601String()),
      isRead: false,
    );
  }

  String _formatTime(dynamic raw) {
    if (raw == null) return '';
    final dt = DateTime.tryParse(raw.toString());
    if (dt == null) return raw.toString();
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.month}/${dt.day}/${dt.year}';
  }

  Future<void> _delete(_Notif n) async {
    try {
      await NotificationController.instance.deleteNotification(n.id);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  List<_Notif> get _filtered => _tab == 'all' ? _notifs : _notifs.where((n) => n.tabKey == _tab).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClubUiColors.pageBg,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.gray900,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Center(
            child: AppBackButton(onPressed: () => Navigator.pop(context)),
          ),
        ),
        title: const Text('Notifications'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.dashboard_outlined, color: AppColors.gray700),
            tooltip: 'Club hub',
            onSelected: (v) {
              switch (v) {
                case 'openings':
                  ClubModuleNav.openVacancies(context);
                  break;
                case 'events':
                  ClubModuleNav.openEvents(context);
                  break;
                case 'myClubs':
                  ClubModuleNav.openMyClubsPane(context);
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'openings', child: Text('Openings')),
              PopupMenuItem(value: 'events', child: Text('Events')),
              PopupMenuItem(value: 'myClubs', child: Text('My clubs')),
            ],
          ),
        ],
      ),
      body: ResponsiveContainer(
        backgroundColor: ClubUiColors.pageBg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Notification Center', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                  const SizedBox(height: 6),
                  const Text('Club proposals, membership, applications, and campus events.', style: TextStyle(color: Color(0xFF64748B))),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _tabs.map((t) {
                        final sel = _tab == t.$1;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(label: Text(t.$2), selected: sel, onSelected: (_) => setState(() => _tab = t.$1)),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.cloud_off, size: 48, color: AppColors.gray300),
                              const SizedBox(height: 12),
                              const Text('Failed to load', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.gray700)),
                              const SizedBox(height: 12),
                              FilledButton.icon(
                                onPressed: _load,
                                icon: const Icon(Icons.refresh, size: 18),
                                label: const Text('Retry'),
                                style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: _filtered.isEmpty
                              ? ListView(children: const [
                                  SizedBox(height: 80),
                                  Center(child: Text('No notifications', style: TextStyle(color: Color(0xFF64748B), fontSize: 15))),
                                ])
                              : ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                                  itemCount: _filtered.length,
                                  itemBuilder: (_, i) => _notifCard(_filtered[i]),
                                ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  static const _pillColors = {
    'proposals': Color(0xFF2563EB),
    'membership': Color(0xFF16A34A),
    'vacancies': Color(0xFF8B5CF6),
    'events': Color(0xFF4F46E5),
  };

  static const _pillLabels = {
    'proposals': 'Club Proposals',
    'membership': 'Membership',
    'vacancies': 'Vacancies',
    'events': 'Events',
  };

  Widget _notifCard(_Notif n) {
    final pillColor = _pillColors[n.tabKey] ?? AppColors.gray500;
    final pillLabel = _pillLabels[n.tabKey] ?? 'General';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: n.isRead ? null : const Color(0xFFF8FAFF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: n.isRead ? const Color(0xFFE2E8F0) : AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: pillColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
                    child: Text(pillLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: pillColor)),
                  ),
                  if (!n.isRead) ...[
                    const SizedBox(width: 8),
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                  ],
                  const Spacer(),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Delete notification',
                    onPressed: () => _delete(n),
                    icon: const Icon(Icons.delete_outline,
                        size: 18, color: AppColors.gray500),
                  ),
                  Text(n.time, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                ],
              ),
              const SizedBox(height: 10),
              Text(n.title, style: TextStyle(fontSize: 16, fontWeight: n.isRead ? FontWeight.w600 : FontWeight.w700, color: const Color(0xFF0F172A))),
              if (n.body.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(n.body, style: const TextStyle(height: 1.45, color: Color(0xFF64748B))),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
