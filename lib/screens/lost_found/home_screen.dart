import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/lost_item.dart';
import '../../utils/constants.dart';
import '../../widgets/responsive_container.dart';
import '../../utils/responsive.dart';
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
  int _selectedNavIndex = 0;
  bool onlyActive = false;
  String _activeTab = 'home';
  bool _isSpeedDialOpen = false;
  final ScrollController _scrollController = ScrollController();
  bool _showStats = true;
  double _lastScrollOffset = 0.0;

  final List<LostItem> mockItems = [
    LostItem(
      id: '1',
      title: 'Black Leather Wallet',
      category: ItemCategory.accessories,
      location: 'Library - 2nd Floor',
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
      location: 'Cafeteria - Near Entrance',
      description: 'ADA University student ID card. Found on table near main entrance.',
      dateFound: '2025-11-09',
      status: ItemStatus.active,
      imageUrl: 'https://images.unsplash.com/photo-1614624532983-4ce03382d63d?w=400&h=300&fit=crop',
    ),
    LostItem(
      id: '4',
      title: 'Navy Blue Jacket',
      category: ItemCategory.clothing,
      location: 'Sports Complex - Locker Room',
      description: 'Navy blue jacket with ADA logo on left chest. Size M.',
      dateFound: '2025-11-08',
      status: ItemStatus.active,
      imageUrl: 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=400&h=300&fit=crop',
    ),
  ];

  List<LostItem> get filteredItems {
    var items = mockItems.where((item) {
      final matchesSearch = item.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.location.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory = selectedCategory == null || item.category == selectedCategory;
      final matchesStatus = !onlyActive || item.status == ItemStatus.active;
      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();

    items.sort((a, b) {
      if (sortBy == 'newest') {
        return DateTime.parse(b.dateFound).compareTo(DateTime.parse(a.dateFound));
      } else if (sortBy == 'oldest') {
        return DateTime.parse(a.dateFound).compareTo(DateTime.parse(b.dateFound));
      } else {
        return a.location.compareTo(b.location);
      }
    });

    return items;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final currentOffset = _scrollController.offset;
    
    // Show stats when scrolling up, hide when scrolling down
    if (currentOffset > _lastScrollOffset && currentOffset > 50) {
      // Scrolling down and past threshold
      if (_showStats) {
        setState(() => _showStats = false);
      }
    } else if (currentOffset < _lastScrollOffset) {
      // Scrolling up
      if (!_showStats) {
        setState(() => _showStats = true);
      }
    }
    
    _lastScrollOffset = currentOffset;
  }

  @override
  Widget build(BuildContext context) {
    final stats = {
      'total': mockItems.length,
      'active': mockItems.where((i) => i.status == ItemStatus.active).length,
      'pending': mockItems.where((i) => i.status == ItemStatus.pendingVerification).length,
    };

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _showStats
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeader(context),
                        _buildStatsCards(context, stats),
                        _buildSearchBar(context),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
            Expanded(
              child: _buildItemsList(context),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildSpeedDial(context),
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: AppColors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.gray700),
                onPressed: () => Navigator.pop(context),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lost & Found',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const Text(
                    'ADA University Campus',
                    style: TextStyle(fontSize: 12, color: AppColors.gray500),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.settings, color: AppColors.gray600),
                onPressed: () {},
              ),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: AppColors.gray600),
                    onPressed: () {},
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, Map<String, int> stats) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: AppColors.white,
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard('Total', stats['total']!, AppColors.primary),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildStatCard('Active', stats['active']!, Colors.green),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildStatCard('Pending', stats['pending']!, Colors.yellow),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int value, Color color) {
    // Use semantic colors only for status meaning: green for Active, yellow for Pending
    Color cardColor;
    if (label == 'Active') {
      cardColor = Colors.green.shade600; // Success/Active color
    } else if (label == 'Pending') {
      cardColor = Colors.yellow.shade700; // Warning/Pending color (yellow as requested)
    } else {
      cardColor = AppColors.primary; // Primary color for Total
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: AppColors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: AppColors.white,
      child: TextField(
        onChanged: (value) => setState(() => searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search by item, location, or description...',
          prefixIcon: const Icon(Icons.search, color: AppColors.gray400),
          suffixIcon: IconButton(
            icon: const Icon(Icons.tune, color: AppColors.gray600),
            onPressed: () {
              _openFilterSheet(context);
            },
          ),
          filled: true,
          fillColor: AppColors.gray50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
            borderSide: BorderSide(color: AppColors.gray200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
            borderSide: BorderSide(color: AppColors.gray200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildSortOptions(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final sortOptions = [
      {'value': 'newest', 'label': 'Newest'},
      {'value': 'oldest', 'label': 'Oldest'},
      {'value': 'location', 'label': 'Location'},
    ];
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: 8,
      ),
      color: AppColors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${filteredItems.length} ${filteredItems.length == 1 ? 'item' : 'items'} found',
            style: TextStyle(
              fontSize: isMobile ? 12 : 13,
              color: AppColors.gray600,
            ),
          ),
          SizedBox(
            width: isMobile ? 120 : 140,
            child: DropdownButtonFormField<String>(
              value: sortBy,
              isExpanded: true,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                filled: true,
                fillColor: AppColors.gray50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  borderSide: BorderSide(color: AppColors.gray200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  borderSide: BorderSide(color: AppColors.gray200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.gray700,
              ),
              icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.gray600),
              items: sortOptions.map((option) {
                return DropdownMenuItem<String>(
                  value: option['value'],
                  child: Text(
                    option['label']!,
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => sortBy = value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

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
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.container)),
      ),
      builder: (context) {
        ItemCategory? tempCategory = selectedCategory;
        bool tempOnlyActive = onlyActive;
        String tempSortBy = sortBy;
        
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                16,
                24,
                MediaQuery.of(context).padding.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gray900,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.gray600),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Category Filter
                  const Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map((category) {
                      final isSelected = tempCategory == category;
                      String label;
                      if (category == null) {
                        label = 'All Items';
                      } else {
                        switch (category) {
                          case ItemCategory.electronics:
                            label = 'Electronics';
                            break;
                          case ItemCategory.documents:
                            label = 'Documents';
                            break;
                          case ItemCategory.clothing:
                            label = 'Clothing';
                            break;
                          case ItemCategory.accessories:
                            label = 'Accessories';
                            break;
                          case ItemCategory.other:
                            label = 'Other';
                            break;
                        }
                      }
                      return ChoiceChip(
                        label: Text(label),
                        selected: isSelected,
                        onSelected: (selected) {
                          setModalState(() {
                            tempCategory = selected ? category : null;
                          });
                        },
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.gray50,
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.white : AppColors.gray700,
                          fontSize: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.small),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  // Sort Options
                  const Text(
                    'Sort by',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Newest'),
                        selected: tempSortBy == 'newest',
                        onSelected: (_) => setModalState(() => tempSortBy = 'newest'),
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.gray50,
                        labelStyle: TextStyle(
                          color: tempSortBy == 'newest' ? AppColors.white : AppColors.gray700,
                          fontSize: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.small),
                        ),
                      ),
                      ChoiceChip(
                        label: const Text('Oldest'),
                        selected: tempSortBy == 'oldest',
                        onSelected: (_) => setModalState(() => tempSortBy = 'oldest'),
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.gray50,
                        labelStyle: TextStyle(
                          color: tempSortBy == 'oldest' ? AppColors.white : AppColors.gray700,
                          fontSize: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.small),
                        ),
                      ),
                      ChoiceChip(
                        label: const Text('Location'),
                        selected: tempSortBy == 'location',
                        onSelected: (_) => setModalState(() => tempSortBy = 'location'),
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.gray50,
                        labelStyle: TextStyle(
                          color: tempSortBy == 'location' ? AppColors.white : AppColors.gray700,
                          fontSize: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.small),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Status Filter
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Show only active items',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    value: tempOnlyActive,
                    onChanged: (value) {
                      setModalState(() => tempOnlyActive = value);
                    },
                    activeColor: AppColors.primary,
                  ),
                  const SizedBox(height: 24),
                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedCategory = tempCategory;
                          onlyActive = tempOnlyActive;
                          sortBy = tempSortBy;
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.medium),
                        ),
                      ),
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  Widget _buildItemsList(BuildContext context) {
    if (filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: AppColors.gray300),
            const SizedBox(height: 16),
            const Text(
              'No items found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filter criteria',
              style: TextStyle(fontSize: 14, color: AppColors.gray500),
            ),
          ],
        ),
      );
    }

    // Calculate bottom padding to account for FAB and navigation bar
    final bottomNavHeight = 80.0; // Approximate nav bar height
    final fabHeight = 56.0;
    final spacing = 16.0;
    final totalBottomPadding = 24 + bottomNavHeight + spacing + fabHeight + spacing;
    
    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: totalBottomPadding,
      ),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ItemCard(
            item: filteredItems[index],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ItemDetailView(item: filteredItems[index]),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.container),
          topRight: Radius.circular(AppRadius.container),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home, 'Home', 'home'),
                _buildNavItem(Icons.search, 'Search', 'search'),
                _buildNavItem(Icons.person, 'Account', 'account'),
              ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, String key) {
    final isActive = _activeTab == key;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.container),
            onTap: () {
              setState(() => _activeTab = key);
              if (key == 'search') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Search tab is a visual element only in this prototype.')),
                );
              } else if (key == 'account') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AccountPage()),
                );
              }
            },
            child: Icon(
              icon,
              color: isActive ? AppColors.white : AppColors.white.withOpacity(0.7),
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? AppColors.white : AppColors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildSpeedDial(BuildContext context) {
    const buttonSpacing = 12.0;
    const buttonSize = 48.0;
    
    return Stack(
      alignment: Alignment.bottomRight,
      clipBehavior: Clip.none,
      children: [
        // Speed dial options - vertical stack
        if (_isSpeedDialOpen) ...[
          // Report Lost Item FAB (top)
          Positioned(
            bottom: buttonSize + buttonSpacing + buttonSize + buttonSpacing,
            right: 16,
            child: _buildSpeedDialButton(
              context,
              label: 'Report Lost Item',
              icon: Icons.search_off,
              onPressed: () {
                setState(() => _isSpeedDialOpen = false);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReportItemForm(isLostItem: true),
                  ),
                );
              },
            ),
          ),
          // Report Found Item FAB (middle)
          Positioned(
            bottom: buttonSize + buttonSpacing,
            right: 16,
            child: _buildSpeedDialButton(
              context,
              label: 'Report Found Item',
              icon: Icons.add_circle_outline,
              onPressed: () {
                setState(() => _isSpeedDialOpen = false);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReportItemForm(isLostItem: false),
                  ),
                );
              },
            ),
          ),
        ],
        // Main FAB - morphs from add to close
        Positioned(
          bottom: 16,
          right: 16,
          child: _buildMainSpeedDialButton(context),
        ),
      ],
    );
  }

  Widget _buildSpeedDialButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    const buttonSize = 48.0;
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: _isSpeedDialOpen ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Label
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: AppColors.gray900,
                      borderRadius: BorderRadius.circular(AppRadius.small),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  // Button
                  Material(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(buttonSize / 2),
                    elevation: 2,
                    shadowColor: Colors.black.withOpacity(0.15),
                    child: InkWell(
                      onTap: onPressed,
                      borderRadius: BorderRadius.circular(buttonSize / 2),
                      child: Container(
                        width: buttonSize,
                        height: buttonSize,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(buttonSize / 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          icon,
                          color: AppColors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainSpeedDialButton(BuildContext context) {
    const buttonSize = 48.0;
    
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(buttonSize / 2),
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.2),
      child: InkWell(
        onTap: () {
          setState(() => _isSpeedDialOpen = !_isSpeedDialOpen);
        },
        borderRadius: BorderRadius.circular(buttonSize / 2),
        child: Container(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(buttonSize / 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: Icon(
              _isSpeedDialOpen ? Icons.close : Icons.add,
              key: ValueKey<bool>(_isSpeedDialOpen),
              color: AppColors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

