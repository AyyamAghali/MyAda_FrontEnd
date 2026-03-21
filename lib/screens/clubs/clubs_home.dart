import 'package:flutter/material.dart';
import '../../models/club.dart';
import '../../utils/constants.dart';
import '../../widgets/responsive_container.dart';
import '../../widgets/club_card.dart';
import '../../widgets/clubs/clubs_top_nav.dart';
import 'club_details.dart';
import 'club_module_nav.dart';
import 'create_club_form.dart';
import 'my_memberships.dart';

class ClubsHome extends StatefulWidget {
  const ClubsHome({super.key});

  @override
  State<ClubsHome> createState() => _ClubsHomeState();
}

class _ClubsHomeState extends State<ClubsHome> {
  String searchQuery = '';
  String selectedCategory = 'All';
  String selectedStatus = 'all';
  bool isGrid = false;

  final List<Club> mockClubs = [
    Club(
      id: '1',
      name: 'ADA Digital Entertainment Club',
      logo: 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=200&h=200&fit=crop',
      banner: 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=800&h=300&fit=crop',
      category: 'Technology',
      establishedYear: 2019,
      location: 'Student Center, Room 201',
      tags: ['Gaming', 'Digital Media', 'Content Creation', 'Esports'],
      memberCount: 156,
      status: ClubStatus.open,
      about: 'The ADA Digital Entertainment Club is a vibrant community for gaming enthusiasts, content creators, and digital entertainment lovers. We organize esports tournaments, game development workshops, streaming sessions, and digital content creation bootcamps.',
      officers: [
        ClubOfficer(name: 'Rəşad Məmmədov', role: 'President', photo: 'https://i.pravatar.cc/150?img=12'),
        ClubOfficer(name: 'Leyla Həsənova', role: 'Vice President', photo: 'https://i.pravatar.cc/150?img=5'),
      ],
      events: [
        ClubEvent(
          id: '1',
          title: 'ADA Gaming Tournament 2025',
          date: '2025-11-25',
          location: 'Computer Lab, Building A',
          description: 'Competitive esports tournament featuring League of Legends, CS2, and FIFA',
          time: '02:00 PM',
        ),
        ClubEvent(
          id: '2',
          title: 'Game Development Workshop',
          date: '2025-11-22',
          location: 'Tech Hub, Building B',
          description: 'Learn Unity basics and create your first 2D game. No prior experience required.',
          time: '10:00 AM',
        ),
        ClubEvent(
          id: '3',
          title: 'Streaming & Content Creation Masterclass',
          date: '2025-12-05',
          location: 'Media Studio, Building C',
          description: 'Tips and tricks for building your gaming content channel. Learn about OBS, editing, and audience engagement.',
          time: '03:00 PM',
        ),
        ClubEvent(
          id: '4',
          title: 'Esports Strategy Session',
          date: '2025-12-10',
          location: 'Computer Lab, Building A',
          description: 'Advanced tactics and team coordination for competitive gaming.',
          time: '06:00 PM',
        ),
      ],
    ),
    Club(
      id: '2',
      name: 'ADA Photo Club',
      logo: 'https://images.unsplash.com/photo-1606216794074-735e91aa2c92?w=200&h=200&fit=crop',
      banner: 'https://images.unsplash.com/photo-1542038784456-1ea8e935640e?w=800&h=300&fit=crop',
      category: 'Arts',
      tags: ['Photography', 'Visual Arts', 'Editing', 'Exhibitions'],
      memberCount: 89,
      status: ClubStatus.paused,
      about: 'The ADA Photo Club celebrates the art of photography and visual storytelling.',
      officers: [
        ClubOfficer(name: 'Aynur Məmmədova', role: 'President', photo: 'https://i.pravatar.cc/150?img=45'),
      ],
      events: [
        ClubEvent(
          id: '5',
          title: 'Portrait Photography Workshop',
          date: '2025-11-28',
          location: 'Art Studio, Building D',
          description: 'Master the art of portrait photography. Learn lighting, composition, and posing techniques.',
          time: '02:00 PM',
        ),
        ClubEvent(
          id: '6',
          title: 'Photo Walk: Campus Architecture',
          date: '2025-12-08',
          location: 'Main Campus (Meet at Library)',
          description: 'Explore and capture the beautiful architecture of ADA University campus.',
          time: '10:00 AM',
        ),
        ClubEvent(
          id: '7',
          title: 'Photo Editing with Lightroom',
          date: '2025-12-15',
          location: 'Computer Lab, Building A',
          description: 'Learn professional photo editing techniques using Adobe Lightroom.',
          time: '04:00 PM',
        ),
      ],
    ),
    Club(
      id: '3',
      name: 'E-Commerce Club',
      logo: 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=200&h=200&fit=crop',
      banner: 'https://images.unsplash.com/photo-1542744173-8e7e53415bb0?w=800&h=300&fit=crop',
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
          description: 'Introduction to online business models, platforms, and getting started with e-commerce.',
          time: '11:00 AM',
        ),
        ClubEvent(
          id: '9',
          title: 'Digital Marketing Strategies',
          date: '2025-12-12',
          location: 'Business Hall, Building E',
          description: 'Learn SEO, social media marketing, and paid advertising for your online store.',
          time: '02:00 PM',
        ),
        ClubEvent(
          id: '10',
          title: 'Shopify Store Setup Session',
          date: '2025-12-18',
          location: 'Computer Lab, Building A',
          description: 'Hands-on workshop: Build your first online store using Shopify.',
          time: '03:00 PM',
        ),
      ],
    ),
    Club(
      id: '4',
      name: 'ADAMUN',
      logo: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=200&h=200&fit=crop',
      banner: 'https://images.unsplash.com/photo-1526547687448-5923a3b0e6cb?w=800&h=300&fit=crop',
      category: 'Academic',
      tags: ['Diplomacy', 'Politics', 'Debate'],
      memberCount: 112,
      status: ClubStatus.open,
      about: 'ADA Model United Nations (ADAMUN) is a prestigious club that simulates UN committee sessions.',
      officers: [],
      events: [
        ClubEvent(
          id: '11',
          title: 'ADAMUN Conference 2025',
          date: '2025-12-01',
          location: 'Conference Hall, Main Building',
          description: 'Annual Model UN conference with multiple committees. Registration required.',
          time: '09:00 AM',
        ),
        ClubEvent(
          id: '12',
          title: 'Diplomacy & Negotiation Workshop',
          date: '2025-12-07',
          location: 'Seminar Room 201, Building B',
          description: 'Learn effective negotiation techniques and diplomatic communication skills.',
          time: '03:00 PM',
        ),
        ClubEvent(
          id: '13',
          title: 'Current Affairs Debate Session',
          date: '2025-12-14',
          location: 'Debate Hall, Building C',
          description: 'Engage in structured debates on current global issues and international relations.',
          time: '05:00 PM',
        ),
      ],
    ),
    Club(
      id: '5',
      name: 'ADA Chess Club',
      logo: 'https://images.unsplash.com/photo-1560174038-da43ac74f01b?w=200&h=200&fit=crop',
      banner: 'https://images.unsplash.com/photo-1528819622765-d6bcf132f793?w=800&h=300&fit=crop',
      category: 'Sports',
      tags: ['Chess', 'Strategy', 'Competition'],
      memberCount: 67,
      status: ClubStatus.open,
      about: 'The ADA Chess Club is dedicated to the timeless game of chess and strategic thinking.',
      officers: [],
      events: [
        ClubEvent(
          id: '14',
          title: 'Chess Tournament: Rapid Championship',
          date: '2025-11-29',
          location: 'Student Lounge, Building A',
          description: 'Rapid chess tournament with prizes for top 3 players. All skill levels welcome.',
          time: '01:00 PM',
        ),
        ClubEvent(
          id: '15',
          title: 'Chess Strategy Masterclass',
          date: '2025-12-06',
          location: 'Study Room 305, Building B',
          description: 'Learn advanced opening theory, middle game tactics, and endgame techniques.',
          time: '04:00 PM',
        ),
        ClubEvent(
          id: '16',
          title: 'Blitz Chess Night',
          date: '2025-12-13',
          location: 'Student Lounge, Building A',
          description: 'Casual blitz chess games and friendly matches. Pizza and refreshments provided.',
          time: '06:00 PM',
        ),
      ],
    ),
    Club(
      id: '6',
      name: 'Music Club',
      logo: 'https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=200&h=200&fit=crop',
      banner: 'https://images.unsplash.com/photo-1501612780327-45045538702b?w=800&h=300&fit=crop',
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
          description: 'Showcase your musical talent! Sign up to perform or come to enjoy live music.',
          time: '07:00 PM',
        ),
        ClubEvent(
          id: '18',
          title: 'Guitar Workshop for Beginners',
          date: '2025-12-09',
          location: 'Music Room, Building D',
          description: 'Learn basic chords, strumming patterns, and play your first song. Guitars provided.',
          time: '03:00 PM',
        ),
        ClubEvent(
          id: '19',
          title: 'Music Production Basics',
          date: '2025-12-16',
          location: 'Media Studio, Building C',
          description: 'Introduction to music production using DAW software. Create your first track.',
          time: '05:00 PM',
        ),
        ClubEvent(
          id: '20',
          title: 'Winter Concert 2025',
          date: '2025-12-20',
          location: 'Auditorium, Main Building',
          description: 'Annual winter concert featuring performances from club members and guest artists.',
          time: '07:30 PM',
        ),
      ],
    ),
  ];

  List<Club> get filteredClubs {
    final q = searchQuery.trim().toLowerCase();
    return mockClubs.where((club) {
      final matchesSearch = q.isEmpty ||
          club.name.toLowerCase().contains(q) ||
          club.category.toLowerCase().contains(q) ||
          club.tags.any((tag) => tag.toLowerCase().contains(q));
      final matchesCategory = selectedCategory == 'All' || club.category == selectedCategory;
      final matchesStatus = selectedStatus == 'all' || club.statusString == selectedStatus;
      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClubUiColors.pageBg,
      body: SafeArea(
        child: ResponsiveContainer(
          backgroundColor: ClubUiColors.pageBg,
          child: Column(
            children: [
              _buildClubsNav(context),
              _buildSearchBar(context),
              _buildFilters(context),
              Expanded(
                child: _buildClubsList(context),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateClubForm()),
          );
        },
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _buildClubsNav(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, top: 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.gray700),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        ClubsTopNav(
          active: ClubsNavSection.clubs,
          onVacanciesTap: () => ClubModuleNav.openVacancies(context),
          onMyApplicationsTap: () => ClubModuleNav.openMyVacancyApplications(context),
          onEventsTap: () => ClubModuleNav.openEvents(context),
          onClubsTap: () {},
          onProposeTap: () => ClubModuleNav.openProposeClub(context),
          onNotificationsTap: () => ClubModuleNav.openNotifications(context),
          onProfileTap: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const MyMemberships()),
            );
          },
        ),
      ],
    );
  }


  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      color: AppColors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search clubs, categories, tags...',
                hintStyle: TextStyle(color: AppColors.gray400),
                prefixIcon: const Icon(Icons.search, color: AppColors.gray400, size: 22),
                filled: true,
                fillColor: AppColors.gray50,
                contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.gray200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.gray200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: ClubNavColors.activeText, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: () => setState(() => isGrid = !isGrid),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.gray200),
                ),
                child: Icon(
                  isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded,
                  color: AppColors.gray600,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    final categories = ['All', 'Technology', 'Arts', 'Business', 'Academic', 'Sports'];
    final statuses = ['all', 'Open', 'Closed', 'Paused', 'Disabled', 'By Invitation'];
    
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
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.gray200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.gray200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: ClubNavColors.activeText, width: 1.5),
                ),
                filled: true,
                fillColor: AppColors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              items: categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(
                    category,
                    overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedCategory = value);
                }
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
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.gray200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.gray200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: ClubNavColors.activeText, width: 1.5),
                ),
                filled: true,
                fillColor: AppColors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              items: statuses.map((status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(
                    status == 'all' ? 'All Status' : status,
                    overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedStatus = value);
                }
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
            const Text(
              'No clubs match your search.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.gray700),
            ),
            const SizedBox(height: 8),
            Text(
              'Try different keywords or filters.',
              style: TextStyle(fontSize: 14, color: AppColors.gray500),
            ),
          ],
        ),
      );
    }

    void openClub(int index) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ClubDetails(club: filteredClubs[index]),
        ),
      );
    }

    if (isGrid) {
      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.52,
        ),
        itemCount: filteredClubs.length,
        itemBuilder: (context, index) {
          return ClubCard(
            club: filteredClubs[index],
            onTap: () => openClub(index),
          );
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
      itemCount: filteredClubs.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ClubCard(
            club: filteredClubs[index],
            onTap: () => openClub(index),
          ),
        );
      },
    );
  }
}
