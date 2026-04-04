import 'package:flutter/material.dart';
import '../../models/club.dart';
import '../../utils/constants.dart';
import '../../widgets/responsive_container.dart';
import '../../widgets/club_card.dart';
import 'club_details.dart';
import 'my_memberships.dart';
import 'create_club_form.dart';
import 'club_vacancies.dart';

class ClubsHome extends StatefulWidget {
  const ClubsHome({super.key});

  @override
  State<ClubsHome> createState() => _ClubsHomeState();
}

class _ClubsHomeState extends State<ClubsHome>
    with SingleTickerProviderStateMixin {
  // ── Tab controller ────────────────────────────────────────────────
  late TabController _tabController;

  // ── Clubs tab state ───────────────────────────────────────────────
  String searchQuery = '';
  String selectedCategory = 'All';
  String selectedStatus = 'all';
  bool isGrid = false;

  final List<Club> mockClubs = [
    Club(
      id: '1',
      name: 'ADA Digital Entertainment Club',
      logo:
          'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=200&h=200&fit=crop',
      banner:
          'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=800&h=300&fit=crop',
      category: 'Technology',
      tags: ['Gaming', 'Digital Media', 'Content Creation', 'Esports'],
      memberCount: 156,
      status: ClubStatus.open,
      about:
          'The ADA Digital Entertainment Club is a vibrant community for gaming enthusiasts, content creators, and digital entertainment lovers.',
      officers: [
        ClubOfficer(
            name: 'Rəşad Məmmədov',
            role: 'President',
            photo: 'https://i.pravatar.cc/150?img=12'),
        ClubOfficer(
            name: 'Leyla Həsənova',
            role: 'Vice President',
            photo: 'https://i.pravatar.cc/150?img=5'),
      ],
      events: [
        ClubEvent(
          id: '1',
          title: 'ADA Gaming Tournament 2025',
          date: '2025-11-25',
          location: 'Computer Lab, Building A',
          description:
              'Competitive esports tournament featuring League of Legends, CS2, and FIFA',
          time: '02:00 PM',
        ),
        ClubEvent(
          id: '2',
          title: 'Game Development Workshop',
          date: '2025-11-22',
          location: 'Tech Hub, Building B',
          description:
              'Learn Unity basics and create your first 2D game. No prior experience required.',
          time: '10:00 AM',
        ),
      ],
    ),
    Club(
      id: '2',
      name: 'ADA Photo Club',
      logo:
          'https://images.unsplash.com/photo-1606216794074-735e91aa2c92?w=200&h=200&fit=crop',
      banner:
          'https://images.unsplash.com/photo-1542038784456-1ea8e935640e?w=800&h=300&fit=crop',
      category: 'Arts',
      tags: ['Photography', 'Visual Arts', 'Editing', 'Exhibitions'],
      memberCount: 89,
      status: ClubStatus.paused,
      about:
          'The ADA Photo Club celebrates the art of photography and visual storytelling.',
      officers: [
        ClubOfficer(
            name: 'Aynur Məmmədova',
            role: 'President',
            photo: 'https://i.pravatar.cc/150?img=45'),
      ],
      events: [
        ClubEvent(
          id: '5',
          title: 'Portrait Photography Workshop',
          date: '2025-11-28',
          location: 'Art Studio, Building D',
          description:
              'Master the art of portrait photography. Learn lighting, composition, and posing techniques.',
          time: '02:00 PM',
        ),
      ],
    ),
    Club(
      id: '3',
      name: 'E-Commerce Club',
      logo:
          'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=200&h=200&fit=crop',
      banner:
          'https://images.unsplash.com/photo-1542744173-8e7e53415bb0?w=800&h=300&fit=crop',
      category: 'Business',
      tags: ['E-Commerce', 'Digital Marketing', 'Online Business'],
      memberCount: 134,
      status: ClubStatus.open,
      about: 'The E-Commerce Club is your gateway to the world of online business.',
      officers: [],
      events: [
        ClubEvent(
          id: '8',
          title: 'E-Commerce Fundamentals Workshop',
          date: '2025-11-30',
          location: 'Business Hall, Building E',
          description:
              'Introduction to online business models, platforms, and getting started with e-commerce.',
          time: '11:00 AM',
        ),
      ],
    ),
    Club(
      id: '4',
      name: 'ADAMUN',
      logo:
          'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=200&h=200&fit=crop',
      banner:
          'https://images.unsplash.com/photo-1526547687448-5923a3b0e6cb?w=800&h=300&fit=crop',
      category: 'Academic',
      tags: ['Diplomacy', 'Politics', 'Debate'],
      memberCount: 112,
      status: ClubStatus.open,
      about:
          'ADA Model United Nations (ADAMUN) is a prestigious club that simulates UN committee sessions.',
      officers: [],
      events: [
        ClubEvent(
          id: '11',
          title: 'ADAMUN Conference 2025',
          date: '2025-12-01',
          location: 'Conference Hall, Main Building',
          description:
              'Annual Model UN conference with multiple committees. Registration required.',
          time: '09:00 AM',
        ),
      ],
    ),
    Club(
      id: '5',
      name: 'ADA Chess Club',
      logo:
          'https://images.unsplash.com/photo-1560174038-da43ac74f01b?w=200&h=200&fit=crop',
      banner:
          'https://images.unsplash.com/photo-1528819622765-d6bcf132f793?w=800&h=300&fit=crop',
      category: 'Sports',
      tags: ['Chess', 'Strategy', 'Competition'],
      memberCount: 67,
      status: ClubStatus.open,
      about:
          'The ADA Chess Club is dedicated to the timeless game of chess and strategic thinking.',
      officers: [],
      events: [
        ClubEvent(
          id: '14',
          title: 'Chess Tournament: Rapid Championship',
          date: '2025-11-29',
          location: 'Student Lounge, Building A',
          description:
              'Rapid chess tournament with prizes for top 3 players. All skill levels welcome.',
          time: '01:00 PM',
        ),
      ],
    ),
    Club(
      id: '6',
      name: 'Music Club',
      logo:
          'https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=200&h=200&fit=crop',
      banner:
          'https://images.unsplash.com/photo-1501612780327-45045538702b?w=800&h=300&fit=crop',
      category: 'Arts',
      tags: ['Music', 'Performance', 'Instruments'],
      memberCount: 98,
      status: ClubStatus.open,
      about: 'Music Club celebrates the universal language of music and live performance.',
      officers: [],
      events: [
        ClubEvent(
          id: '17',
          title: 'Open Mic Night',
          date: '2025-12-02',
          location: 'Auditorium, Main Building',
          description:
              'Showcase your musical talent! Sign up to perform or come to enjoy live music.',
          time: '07:00 PM',
        ),
      ],
    ),
  ];

  List<Club> get filteredClubs {
    return mockClubs.where((club) {
      final matchesSearch =
          club.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
              club.tags.any((tag) =>
                  tag.toLowerCase().contains(searchQuery.toLowerCase()));
      final matchesCategory =
          selectedCategory == 'All' || club.category == selectedCategory;
      final matchesStatus =
          selectedStatus == 'all' || club.statusString == selectedStatus;
      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: ResponsiveContainer(
          backgroundColor: AppColors.backgroundLight,
          child: Column(
            children: [
              _buildHeader(context),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildClubsTab(context),
                    VacanciesTab(key: const ValueKey('vacancies_tab')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // FAB only visible on Clubs tab
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CreateClubForm()),
                );
              },
              backgroundColor: AppColors.secondary,
              child: const Icon(Icons.add, color: AppColors.white),
            )
          : null,
    );
  }

  // ── Header ─────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      color: AppColors.white,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.gray700),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Club Management',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  _tabController.index == 0
                      ? '${filteredClubs.length} clubs available'
                      : 'Open positions across clubs',
                  style: const TextStyle(fontSize: 12, color: AppColors.gray500),
                ),
              ],
            ),
          ),
          // My Memberships icon — always visible
          IconButton(
            icon: const Icon(Icons.person_outline, color: AppColors.gray600),
            tooltip: 'My Memberships',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyMemberships()),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Tab bar ────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      color: AppColors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.secondary,
        unselectedLabelColor: AppColors.gray500,
        indicatorColor: AppColors.secondary,
        indicatorWeight: 2.5,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        tabs: const [
          Tab(text: 'Clubs'),
          Tab(text: 'Vacancies'),
        ],
      ),
    );
  }

  // ── Clubs tab ──────────────────────────────────────────────────────
  Widget _buildClubsTab(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(context),
        _buildFilters(context),
        Expanded(child: _buildClubsList(context)),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      color: AppColors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search clubs, categories, tags...',
                prefixIcon:
                    const Icon(Icons.search, color: AppColors.gray400),
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
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
                isGrid ? Icons.view_list : Icons.grid_view,
                color: AppColors.gray600),
            onPressed: () => setState(() => isGrid = !isGrid),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    final categories = [
      'All',
      'Technology',
      'Arts',
      'Business',
      'Academic',
      'Social',
      'Sports'
    ];
    final statuses = [
      'all',
      'Open',
      'Closed',
      'Paused',
      'Disabled',
      'By Invitation'
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      color: AppColors.white,
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedCategory,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Category',
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
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
                filled: true,
                fillColor: AppColors.gray50,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              items: categories.map((c) {
                return DropdownMenuItem<String>(
                  value: c,
                  child: Text(c, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) setState(() => selectedCategory = v);
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedStatus,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Status',
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
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
                filled: true,
                fillColor: AppColors.gray50,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              items: statuses.map((s) {
                return DropdownMenuItem<String>(
                  value: s,
                  child: Text(s == 'all' ? 'All Status' : s,
                      overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) setState(() => selectedStatus = v);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClubsList(BuildContext context) {
    if (filteredClubs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.groups, size: 64, color: AppColors.gray300),
            const SizedBox(height: 16),
            const Text('No clubs found',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your search or filter criteria',
              style: TextStyle(fontSize: 14, color: AppColors.gray500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredClubs.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ClubCard(
            club: filteredClubs[index],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ClubDetails(club: filteredClubs[index]),
                ),
              );
            },
          ),
        );
      },
    );
  }
}