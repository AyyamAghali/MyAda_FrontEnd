import 'package:flutter/material.dart';
import '../../models/lost_item.dart';
import '../../utils/constants.dart';
import '../../widgets/item_card.dart';
import '../account_page.dart';
import 'report_item_form.dart';
import 'item_detail_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchQuery = '';
  ItemCategory? selectedCategory;
  String sortBy = 'newest';
  bool onlyActive = false;
  String _activeTab = 'home';
  bool _isSpeedDialOpen = false;
  String _typeFilter = 'all'; // 'all', 'lost', 'found', 'mine'

  final List<LostItem> mockItems = [
    LostItem(
      id: '1',
      title: 'Black Leather Wallet',
      category: ItemCategory.accessories,
      location: 'Library - 2nd Floor, near the study pods',
      description: 'Black leather wallet found near study area. Contains some cards but no ID.',
      dateFound: '2025-11-10',
      status: ItemStatus.active,
      imageUrl: 'https://images.unsplash.com/photo-1627123424574-724758594e93?w=400&h=300&fit=crop',
    ),
    LostItem(
      id: '2',
      title: 'iPhone 14 Pro',
      category: ItemCategory.electronics,
      location: 'Main Building - Room A120',
      description: 'Blue iPhone 14 Pro with cracked screen protector. Has a sticker on the back.',
      dateFound: '2025-11-11',
      status: ItemStatus.pendingVerification,
      imageUrl: 'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=400&h=300&fit=crop',
    ),
    LostItem(
      id: '3',
      title: 'Student ID Card',
      category: ItemCategory.documents,
      location: 'Cafeteria - Lobby near the main entrance',
      description: 'ADA University student ID card. Found on table near main entrance.',
      dateFound: '2025-11-09',
      status: ItemStatus.active,
      imageUrl: 'https://images.unsplash.com/photo-1614624532983-4ce03382d63d?w=400&h=300&fit=crop',
    ),
    LostItem(
      id: '4',
      title: 'Navy Blue Jacket',
      category: ItemCategory.clothing,
      location: 'Sports Complex - Men\'s locker room, bench area',
      description: 'Navy blue jacket with ADA logo on left chest. Size M.',
      dateFound: '2025-11-08',
      status: ItemStatus.active,
      imageUrl: 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=400&h=300&fit=crop',
    ),
    LostItem(
      id: '5',
      title: 'AirPods Pro Case',
      category: ItemCategory.electronics,
      location: 'Campus - Main yard, on the bench near the fountain',
      description: 'White AirPods Pro case found on a bench. No name written on it.',
      dateFound: '2025-11-12',
      status: ItemStatus.active,
      imageUrl: 'https://images.unsplash.com/photo-1600294037681-c80b4cb5b434?w=400&h=300&fit=crop',
    ),
    LostItem(
      id: '6',
      title: 'House Keys',
      category: ItemCategory.other,
      location: 'Campus - Parking Area B, ground level near exit gate',
      description: 'Set of 3 keys on a red keychain with a small teddy bear charm.',
      dateFound: '2025-11-13',
      status: ItemStatus.pendingVerification,
      imageUrl: 'https://images.unsplash.com/photo-1582139329536-e7284fece509?w=400&h=300&fit=crop',
    ),
    LostItem(
      id: '7',
      title: 'Prescription Glasses',
      category: ItemCategory.accessories,
      location: 'Main Building - Room A301',
      description: 'Black-framed prescription glasses in a brown leather case. Found after lecture.',
      dateFound: '2025-11-14',
      status: ItemStatus.active,
      imageUrl: 'https://images.unsplash.com/photo-1574258495973-f7977603b6d2?w=400&h=300&fit=crop',
    ),
    LostItem(
      id: '8',
      title: 'Silver MacBook Charger',
      category: ItemCategory.electronics,
      location: 'Campus - Outdoor seating area between Block A and Block B',
      description: 'Apple 67W USB-C charger with a small scratch on the adapter.',
      dateFound: '2025-11-15',
      status: ItemStatus.active,
      isLostItem: true,
      imageUrl: 'https://images.unsplash.com/photo-1611532736597-de2d4265fba3?w=400&h=300&fit=crop',
    ),
    LostItem(
      id: '9',
      title: 'Red Notebook',
      category: ItemCategory.other,
      location: 'Library - 3rd Floor, reading hall near the windows',
      description: 'Red Moleskine notebook with handwritten notes. Has a pen clipped to the cover.',
      dateFound: '2025-11-16',
      status: ItemStatus.active,
      isLostItem: true,
      imageUrl: 'https://images.unsplash.com/photo-1531346878377-a5be20888e57?w=400&h=300&fit=crop',
    ),
    LostItem(
      id: '10',
      title: 'USB Flash Drive',
      category: ItemCategory.electronics,
      location: 'Building C - Room C203',
      description: 'SanDisk 64GB flash drive with a blue cap. Contains important project files.',
      dateFound: '2025-11-17',
      status: ItemStatus.pendingVerification,
      isLostItem: true,
      imageUrl: 'https://images.unsplash.com/photo-1597872200969-2b65d56bd16b?w=400&h=300&fit=crop',
    ),
  ];

  List<LostItem> get filteredItems {
    var items = mockItems.where((item) {
      final matchesSearch = searchQuery.isEmpty ||
          item.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.location.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory =
          selectedCategory == null || item.category == selectedCategory;
      final matchesStatus = !onlyActive || item.status == ItemStatus.active;
      final matchesType = _typeFilter == 'all' ||
          (_typeFilter == 'lost' && item.isLostItem) ||
          (_typeFilter == 'found' && !item.isLostItem);
      return matchesSearch && matchesCategory && matchesStatus && matchesType;
    }).toList();

    items.sort((a, b) {
      if (sortBy == 'newest') {
        return DateTime.parse(b.dateFound).compareTo(DateTime.parse(a.dateFound));
      } else {
        return DateTime.parse(a.dateFound).compareTo(DateTime.parse(b.dateFound));
      }
    });

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildSearchBar(context),
            _buildResultCount(),
            Expanded(child: _buildItemsList(context)),
          ],
        ),
      ),
      floatingActionButton: _buildSpeedDial(context),
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      color: AppColors.backgroundLight,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: AppColors.gray700, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Lost & Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.gray900,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: AppColors.gray600, size: 22),
            onPressed: () => _showSnackBar('Notifications coming soon.'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: SizedBox(
        height: 42,
        child: TextField(
          onChanged: (v) => setState(() => searchQuery = v),
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search items or locations...',
            hintStyle: const TextStyle(fontSize: 13, color: AppColors.gray400),
            prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.gray400),
            suffixIcon: GestureDetector(
              onTap: () => _openFilterSheet(context),
              child: Container(
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.tune, size: 17, color: AppColors.primary),
              ),
            ),
            filled: true,
            fillColor: AppColors.white,
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.gray200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.gray200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultCount() {
    final count = filteredItems.length;
    final hasFilters = selectedCategory != null ||
        onlyActive ||
        _typeFilter != 'all';
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 4),
      child: Row(
        children: [
          Text(
            '$count ${count == 1 ? 'item' : 'items'}',
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.gray500),
          ),
          if (hasFilters) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => setState(() {
                selectedCategory = null;
                onlyActive = false;
                _typeFilter = 'all';
                sortBy = 'newest';
              }),
              child: const Text(
                'Clear filters',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Filter ──────────────────────────────────────────────────────────

  void _openFilterSheet(BuildContext context) {
    final categories = [
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
      builder: (context) {
        ItemCategory? tempCategory = selectedCategory;
        bool tempOnlyActive = onlyActive;
        String tempSortBy = sortBy;
        String tempType = _typeFilter;

        return StatefulBuilder(
          builder: (context, setModalState) {
            Widget chip(String label, bool selected, VoidCallback onTap) {
              return GestureDetector(
                onTap: onTap,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary
                        : AppColors.gray100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color:
                          selected ? AppColors.white : AppColors.gray700,
                    ),
                  ),
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.fromLTRB(
                  20, 16, 20, MediaQuery.of(context).padding.bottom + 20),
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
                              fontWeight: FontWeight.bold,
                              color: AppColors.gray900)),
                      IconButton(
                        icon: const Icon(Icons.close,
                            color: AppColors.gray500, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Type',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray900)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      chip('All', tempType == 'all',
                          () => setModalState(() => tempType = 'all')),
                      chip('Lost items', tempType == 'lost',
                          () => setModalState(() => tempType = 'lost')),
                      chip('Found items', tempType == 'found',
                          () => setModalState(() => tempType = 'found')),
                      chip('My reports', tempType == 'mine',
                          () => setModalState(() => tempType = 'mine')),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Category',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray900)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map((cat) {
                      final isSelected = tempCategory == cat;
                      final label = cat == null
                          ? 'All'
                          : _categoryLabel(cat);
                      return chip(label, isSelected,
                          () => setModalState(() => tempCategory = cat));
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text('Sort by',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray900)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      chip('Newest first', tempSortBy == 'newest',
                          () => setModalState(() => tempSortBy = 'newest')),
                      chip('Oldest first', tempSortBy == 'oldest',
                          () => setModalState(() => tempSortBy = 'oldest')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Active items only',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                    value: tempOnlyActive,
                    onChanged: (v) =>
                        setModalState(() => tempOnlyActive = v),
                    activeColor: AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedCategory = tempCategory;
                          onlyActive = tempOnlyActive;
                          sortBy = tempSortBy;
                          _typeFilter = tempType;
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
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

  String _categoryLabel(ItemCategory cat) {
    switch (cat) {
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

  // ── Items list ──────────────────────────────────────────────────────

  Widget _buildItemsList(BuildContext context) {
    if (filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: AppColors.gray300),
            const SizedBox(height: 12),
            const Text('No items found',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            const Text('Try adjusting your search or filters',
                style: TextStyle(fontSize: 13, color: AppColors.gray500)),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ItemCard(
            item: filteredItems[index],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ItemDetailView(item: filteredItems[index]),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ── Speed dial ──────────────────────────────────────────────────────

  Widget _buildSpeedDial(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Scrim when open
        if (_isSpeedDialOpen) ...[
          _SpeedDialOption(
            label: 'Report Lost Item',
            icon: Icons.help_outline,
            color: AppColors.secondary,
            visible: _isSpeedDialOpen,
            delay: 80,
            onTap: () {
              setState(() => _isSpeedDialOpen = false);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ReportItemForm(isLostItem: true)),
              );
            },
          ),
          const SizedBox(height: 10),
          _SpeedDialOption(
            label: 'Report Found Item',
            icon: Icons.visibility_outlined,
            color: Colors.green.shade600,
            visible: _isSpeedDialOpen,
            delay: 0,
            onTap: () {
              setState(() => _isSpeedDialOpen = false);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        const ReportItemForm(isLostItem: false)),
              );
            },
          ),
          const SizedBox(height: 12),
        ],
        // Main button
        FloatingActionButton(
          onPressed: () => setState(() => _isSpeedDialOpen = !_isSpeedDialOpen),
          backgroundColor: AppColors.primary,
          elevation: 3,
          child: AnimatedRotation(
            turns: _isSpeedDialOpen ? 0.125 : 0,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              _isSpeedDialOpen ? Icons.close : Icons.add,
              color: AppColors.white,
            ),
          ),
        ),
      ],
    );
  }

  // ── Bottom navigation ───────────────────────────────────────────────

  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_outlined, 'Home', 'home'),
              _buildNavItem(Icons.search, 'Search', 'search'),
              _buildNavItem(Icons.person_outline, 'Account', 'account'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, String key) {
    final isActive = _activeTab == key;
    return GestureDetector(
      onTap: () {
        setState(() => _activeTab = key);
        if (key == 'account') {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AccountPage()));
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              color:
                  isActive ? AppColors.white : AppColors.white.withOpacity(0.6),
              size: 24),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                fontSize: 11,
                color: isActive
                    ? AppColors.white
                    : AppColors.white.withOpacity(0.6),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              )),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

// ══════════════════════════════════════════════════════════════════════
// Speed dial option with staggered animation
// ══════════════════════════════════════════════════════════════════════

class _SpeedDialOption extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool visible;
  final int delay;
  final VoidCallback onTap;

  const _SpeedDialOption({
    required this.label,
    required this.icon,
    required this.color,
    required this.visible,
    required this.delay,
    required this.onTap,
  });

  @override
  State<_SpeedDialOption> createState() => _SpeedDialOptionState();
}

class _SpeedDialOptionState extends State<_SpeedDialOption>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 220));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    _slide = Tween<Offset>(
      begin: const Offset(0.3, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: ScaleTransition(
        scale: _scale,
        alignment: Alignment.bottomRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.gray900,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: Text(widget.label,
                  style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: widget.onTap,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: widget.color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3)),
                  ],
                ),
                child: Icon(widget.icon, color: AppColors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
