import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/lost_item.dart';
import '../../utils/constants.dart';
import '../../widgets/responsive_container.dart';
import '../../utils/responsive.dart';
import '../../widgets/item_card.dart';
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
      imageUrl: 'https://images.unsplash.com/photo-1592286927505-c1f69a8a0b3c?w=400&h=300&fit=crop',
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
            _buildHeader(context),
            _buildStatsCards(context, stats),
            _buildSearchBar(context),
            _buildCategoryFilter(context),
            _buildSortOptions(context),
            Expanded(
              child: _buildItemsList(context),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ReportItemForm()),
          );
        },
        backgroundColor: AppColors.secondary,
        icon: const Icon(Icons.add, color: AppColors.white),
        label: const Text('Report Item', style: TextStyle(color: AppColors.white)),
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: AppColors.white,
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard('Total', stats['total']!, AppColors.primary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard('Active', stats['active']!, Colors.green),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard('Pending', stats['pending']!, Colors.orange),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 20,
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
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.gray200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.gray200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context) {
    final categories = [
      null,
      ItemCategory.electronics,
      ItemCategory.documents,
      ItemCategory.clothing,
      ItemCategory.accessories,
      ItemCategory.other,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      color: AppColors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((category) {
            final isSelected = selectedCategory == category;
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
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(label),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => selectedCategory = selected ? category : null);
                },
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.white : AppColors.gray700,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSortOptions(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: 12,
      ),
      color: AppColors.white,
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${filteredItems.length} ${filteredItems.length == 1 ? 'item' : 'items'} found',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    color: AppColors.gray600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildSortButton('newest', 'Newest'),
                    _buildSortButton('oldest', 'Oldest'),
                    _buildSortButton('location', 'Location'),
                  ],
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    '${filteredItems.length} ${filteredItems.length == 1 ? 'item' : 'items'} found',
                    style: const TextStyle(fontSize: 14, color: AppColors.gray600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSortButton('newest', 'Newest'),
                      const SizedBox(width: 8),
                      _buildSortButton('oldest', 'Oldest'),
                      const SizedBox(width: 8),
                      _buildSortButton('location', 'Location'),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSortButton(String value, String label) {
    final isSelected = sortBy == value;
    return InkWell(
      onTap: () => setState(() => sortBy = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.gray100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? AppColors.white : AppColors.gray600,
          ),
        ),
      ),
    );
  }

  void _openFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        bool tempOnlyActive = onlyActive;
        String tempSortBy = sortBy;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Show only active items'),
                    value: tempOnlyActive,
                    onChanged: (value) {
                      setModalState(() => tempOnlyActive = value);
                    },
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sort by',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Newest'),
                        selected: tempSortBy == 'newest',
                        onSelected: (_) => setModalState(() => tempSortBy = 'newest'),
                      ),
                      ChoiceChip(
                        label: const Text('Oldest'),
                        selected: tempSortBy == 'oldest',
                        onSelected: (_) => setModalState(() => tempSortBy = 'oldest'),
                      ),
                      ChoiceChip(
                        label: const Text('Location'),
                        selected: tempSortBy == 'location',
                        onSelected: (_) => setModalState(() => tempSortBy = 'location'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          onlyActive = tempOnlyActive;
                          sortBy = tempSortBy;
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Apply'),
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

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
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
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
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
            color: isActive ? AppColors.secondary : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              setState(() => _activeTab = key);
              if (key == 'search') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Search tab is a visual element only in this prototype.')),
                );
              } else if (key == 'account') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Account tab is a visual element only in this prototype.')),
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
}

