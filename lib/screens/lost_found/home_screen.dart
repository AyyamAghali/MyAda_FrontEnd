import 'package:flutter/material.dart';
import '../../models/lost_item.dart';
import '../../utils/constants.dart';
import '../../widgets/item_card.dart';
import 'report_item_form.dart';
import 'item_detail_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  ItemCategory? _selectedCategory;
  String _sortBy = 'newest';
  bool _onlyActive = false;
  String _typeFilter = 'all'; // 'all', 'lost', 'found', 'mine'

  bool _isSpeedDialOpen = false;
  late final AnimationController _fabAnimCtrl;
  late final Animation<double> _fabScale;

  final _searchFocus = FocusNode();

  final List<LostItem> mockItems = [
    LostItem(
      id: '1',
      title: 'Black Leather Wallet',
      category: ItemCategory.accessories,
      location: 'Library - 2nd Floor, near the study pods',
      description:
          'Black leather wallet found near study area. Contains some cards but no ID.',
      dateFound: '2025-11-10',
      status: ItemStatus.active,
      imageUrl:
          'https://images.unsplash.com/photo-1627123424574-724758594e93?w=400&h=300&fit=crop',
    ),
    LostItem(
      id: '2',
      title: 'iPhone 14 Pro',
      category: ItemCategory.electronics,
      location: 'Main Building - Room A120',
      description:
          'Blue iPhone 14 Pro with cracked screen protector. Has a sticker on the back.',
      dateFound: '2025-11-11',
      status: ItemStatus.pendingVerification,
      imageUrl:
          'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=400&h=300&fit=crop',
    ),
    LostItem(
      id: '3',
      title: 'Student ID Card',
      category: ItemCategory.documents,
      location: 'Cafeteria - Lobby near the main entrance',
      description:
          'ADA University student ID card. Found on table near main entrance.',
      dateFound: '2025-11-09',
      status: ItemStatus.active,
      imageUrl:
          'https://images.unsplash.com/photo-1614624532983-4ce03382d63d?w=400&h=300&fit=crop',
    ),
    LostItem(
      id: '4',
      title: 'Navy Blue Jacket',
      category: ItemCategory.clothing,
      location: 'Sports Complex - Men\'s locker room, bench area',
      description: 'Navy blue jacket with ADA logo on left chest. Size M.',
      dateFound: '2025-11-08',
      status: ItemStatus.active,
      imageUrl:
          'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=400&h=300&fit=crop',
    ),
    LostItem(
      id: '5',
      title: 'AirPods Pro Case',
      category: ItemCategory.electronics,
      location: 'Campus - Main yard, on the bench near the fountain',
      description:
          'White AirPods Pro case found on a bench. No name written on it.',
      dateFound: '2025-11-12',
      status: ItemStatus.active,
      imageUrl:
          'https://images.unsplash.com/photo-1600294037681-c80b4cb5b434?w=400&h=300&fit=crop',
    ),
    LostItem(
      id: '6',
      title: 'House Keys',
      category: ItemCategory.other,
      location: 'Campus - Parking Area B, ground level near exit gate',
      description:
          'Set of 3 keys on a red keychain with a small teddy bear charm.',
      dateFound: '2025-11-13',
      status: ItemStatus.pendingVerification,
      imageUrl:
          'https://images.unsplash.com/photo-1582139329536-e7284fece509?w=400&h=300&fit=crop',
    ),
    LostItem(
      id: '7',
      title: 'Prescription Glasses',
      category: ItemCategory.accessories,
      location: 'Main Building - Room A301',
      description:
          'Black-framed prescription glasses in a brown leather case. Found after lecture.',
      dateFound: '2025-11-14',
      status: ItemStatus.active,
      imageUrl:
          'https://images.unsplash.com/photo-1574258495973-f7977603b6d2?w=400&h=300&fit=crop',
    ),
    LostItem(
      id: '8',
      title: 'Silver MacBook Charger',
      category: ItemCategory.electronics,
      location: 'Campus - Outdoor seating area between Block A and Block B',
      description:
          'Apple 67W USB-C charger with a small scratch on the adapter. Was in a transparent ziplock bag.',
      dateFound: '2025-11-15',
      status: ItemStatus.active,
      isLostItem: true,
      imageUrl:
          'https://images.unsplash.com/photo-1611532736597-de2d4265fba3?w=400&h=300&fit=crop',
    ),
    LostItem(
      id: '9',
      title: 'Red Notebook',
      category: ItemCategory.other,
      location: 'Library - 3rd Floor, reading hall near the windows',
      description:
          'Red Moleskine notebook with handwritten notes in Azerbaijani. Has a pen clipped to the cover.',
      dateFound: '2025-11-16',
      status: ItemStatus.active,
      isLostItem: true,
      imageUrl:
          'https://images.unsplash.com/photo-1531346878377-a5be20888e57?w=400&h=300&fit=crop',
    ),
    LostItem(
      id: '10',
      title: 'USB Flash Drive',
      category: ItemCategory.electronics,
      location: 'Building C - Room C203',
      description:
          'SanDisk 64GB flash drive with a blue cap. Contains important project files.',
      dateFound: '2025-11-17',
      status: ItemStatus.pendingVerification,
      isLostItem: true,
      imageUrl:
          'https://images.unsplash.com/photo-1597872200969-2b65d56bd16b?w=400&h=300&fit=crop',
    ),
  ];

  List<LostItem> get _filtered {
    var items = mockItems.where((item) {
      final q = _searchQuery.trim().toLowerCase();
      final matchesSearch = q.isEmpty ||
          item.title.toLowerCase().contains(q) ||
          item.location.toLowerCase().contains(q);
      final matchesCategory =
          _selectedCategory == null || item.category == _selectedCategory;
      final matchesStatus =
          !_onlyActive || item.status == ItemStatus.active;
      final matchesType = _typeFilter == 'all' ||
          (_typeFilter == 'lost' && item.isLostItem) ||
          (_typeFilter == 'found' && !item.isLostItem);
      return matchesSearch && matchesCategory && matchesStatus && matchesType;
    }).toList();

    items.sort((a, b) {
      if (_sortBy == 'newest') {
        return DateTime.parse(b.dateFound)
            .compareTo(DateTime.parse(a.dateFound));
      }
      return DateTime.parse(a.dateFound)
          .compareTo(DateTime.parse(b.dateFound));
    });
    return items;
  }

  @override
  void initState() {
    super.initState();
    _fabAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabScale = CurvedAnimation(
      parent: _fabAnimCtrl,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _fabAnimCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _toggleSpeedDial() {
    setState(() => _isSpeedDialOpen = !_isSpeedDialOpen);
    if (_isSpeedDialOpen) {
      _fabAnimCtrl.forward();
    } else {
      _fabAnimCtrl.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.gray900,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Lost & Found',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchRow(context),
          Expanded(child: _buildList(context, filtered)),
        ],
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  // ── Search + filter button ─────────────────────────────────────────

  Widget _buildSearchRow(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      color: AppColors.white,
      child: SizedBox(
        height: 40,
        child: TextField(
          focusNode: _searchFocus,
          onChanged: (v) => setState(() => _searchQuery = v),
          style: const TextStyle(fontSize: 14, color: AppColors.gray900),
          decoration: InputDecoration(
            hintText: 'Search items or locations...',
            hintStyle:
                const TextStyle(fontSize: 13, color: AppColors.gray400),
            prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.gray400),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 40, minHeight: 0),
            suffixIcon: GestureDetector(
              onTap: () => _openFilterSheet(context),
              child: Container(
                width: 34,
                height: 34,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.tune, size: 17, color: AppColors.primary),
              ),
            ),
            suffixIconConstraints:
                const BoxConstraints(minWidth: 40, minHeight: 0),
            filled: true,
            fillColor: AppColors.gray50,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.gray200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.gray200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ),
    );
  }

  // ── Filter sheet ───────────────────────────────────────────────────

  void _openFilterSheet(BuildContext context) {
    final categories = <ItemCategory?>[
      null,
      ItemCategory.electronics,
      ItemCategory.documents,
      ItemCategory.clothing,
      ItemCategory.accessories,
      ItemCategory.other,
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        var tmpCat = _selectedCategory;
        var tmpSort = _sortBy;
        var tmpActive = _onlyActive;
        var tmpType = _typeFilter;

        return StatefulBuilder(
          builder: (ctx, setModal) {
            Widget chipRow(String value, String label, String groupVal,
                ValueChanged<String> onTap) {
              final sel = value == groupVal;
              return GestureDetector(
                onTap: () => onTap(value),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: sel
                        ? AppColors.primary
                        : AppColors.gray100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: sel ? AppColors.white : AppColors.gray700,
                    ),
                  ),
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.fromLTRB(
                  20, 14, 20, MediaQuery.of(ctx).padding.bottom + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.gray300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Filters',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.gray900)),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: const Icon(Icons.close,
                            size: 22, color: AppColors.gray500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Type
                  const Text('Type',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      chipRow('all', 'All', tmpType,
                          (v) => setModal(() => tmpType = v)),
                      chipRow('found', 'Found Items', tmpType,
                          (v) => setModal(() => tmpType = v)),
                      chipRow('lost', 'Lost Items', tmpType,
                          (v) => setModal(() => tmpType = v)),
                      chipRow('mine', 'My Reports', tmpType,
                          (v) => setModal(() => tmpType = v)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Category
                  const Text('Category',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map((cat) {
                      final sel = tmpCat == cat;
                      final label = cat == null
                          ? 'All'
                          : _catLabel(cat);
                      return GestureDetector(
                        onTap: () =>
                            setModal(() => tmpCat = sel ? null : cat),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: sel
                                ? AppColors.primary
                                : AppColors.gray100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: sel
                                  ? AppColors.white
                                  : AppColors.gray700,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  // Sort
                  const Text('Sort by',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      chipRow('newest', 'Newest first', tmpSort,
                          (v) => setModal(() => tmpSort = v)),
                      chipRow('oldest', 'Oldest first', tmpSort,
                          (v) => setModal(() => tmpSort = v)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Active items only',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                    value: tmpActive,
                    onChanged: (v) => setModal(() => tmpActive = v),
                    activeColor: AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedCategory = tmpCat;
                          _sortBy = tmpSort;
                          _onlyActive = tmpActive;
                          _typeFilter = tmpType;
                        });
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Apply',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
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

  // ── Items list ─────────────────────────────────────────────────────

  Widget _buildList(BuildContext context, List<LostItem> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: AppColors.gray300),
            const SizedBox(height: 12),
            const Text('No items found',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray700)),
            const SizedBox(height: 4),
            const Text('Try adjusting your search or filters',
                style: TextStyle(fontSize: 13, color: AppColors.gray500)),
          ],
        ),
      );
    }

    final hasFilter = _selectedCategory != null || _typeFilter != 'all' || _onlyActive || _sortBy != 'newest';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          child: Row(
            children: [
              Text(
                '${items.length} item${items.length == 1 ? '' : 's'}',
                style: const TextStyle(fontSize: 12, color: AppColors.gray500, fontWeight: FontWeight.w500),
              ),
              if (hasFilter) ...[
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => setState(() {
                    _selectedCategory = null;
                    _typeFilter = 'all';
                    _onlyActive = false;
                    _sortBy = 'newest';
                  }),
                  child: const Text(
                    'Clear filters',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondary),
                  ),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => ItemCard(
              item: items[i],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ItemDetailView(item: items[i])),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── FAB speed dial ─────────────────────────────────────────────────

  Widget _buildFAB(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Options
        ScaleTransition(
          scale: _fabScale,
          alignment: Alignment.bottomRight,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _SpeedDialOption(
                label: 'I lost something',
                icon: Icons.search_off_rounded,
                color: AppColors.secondary,
                onTap: () {
                  _toggleSpeedDial();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const ReportItemForm(isLostItem: true),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _SpeedDialOption(
                label: 'I found something',
                icon: Icons.where_to_vote_outlined,
                color: AppColors.primary,
                onTap: () {
                  _toggleSpeedDial();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const ReportItemForm(isLostItem: false),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
        // Main button
        FloatingActionButton(
          onPressed: _toggleSpeedDial,
          backgroundColor: AppColors.primary,
          elevation: 3,
          child: AnimatedRotation(
            turns: _isSpeedDialOpen ? 0.125 : 0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            child: const Icon(Icons.add, size: 26, color: AppColors.white),
          ),
        ),
      ],
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────

  String _catLabel(ItemCategory c) {
    switch (c) {
      case ItemCategory.electronics:
        return 'Electronics';
      case ItemCategory.documents:
        return 'Documents';
      case ItemCategory.clothing:
        return 'Clothing';
      case ItemCategory.accessories:
        return 'Accessories';
      case ItemCategory.other:
        return 'Other';
    }
  }

}

// ══════════════════════════════════════════════════════════════════════

class _SpeedDialOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SpeedDialOption({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.white, size: 20),
          ),
        ],
      ),
    );
  }
}
