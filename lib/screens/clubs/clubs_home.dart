import 'package:flutter/material.dart';
import '../../models/club.dart';
import '../../utils/constants.dart';
import '../../widgets/responsive_container.dart';
import '../../widgets/club_card.dart';
import 'club_details.dart';
import 'club_hub_deep_link.dart';
import 'create_club_form.dart';
import 'my_memberships.dart';

class ClubsHome extends StatefulWidget {
  /// When true, this widget is embedded in [ClubManagementHub] (no outer scaffold chrome).
  final bool embeddedInHub;

  /// Hub-controlled: Discover vs My clubs (only used when [embeddedInHub] is true).
  final ClubsHomePane clubsPane;

  final ValueChanged<ClubsHomePane>? onClubsPaneChanged;

  final int myClubsInnerTabIndex;
  final String? applicationsClubNameFilter;

  /// When set (hub mode), opening a club uses this instead of pushing [ClubDetails] directly.
  final Future<void> Function(Club club)? onClubOpen;

  const ClubsHome({
    super.key,
    this.embeddedInHub = false,
    this.clubsPane = ClubsHomePane.browse,
    this.onClubsPaneChanged,
    this.myClubsInnerTabIndex = 0,
    this.applicationsClubNameFilter,
    this.onClubOpen,
  });

  @override
  State<ClubsHome> createState() => _ClubsHomeState();
}

class _ClubsHomeState extends State<ClubsHome> {
  // ── Directory state ───────────────────────────────────────────────
  String searchQuery = '';
  String selectedCategory = 'All';
  final FocusNode _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchFocus.dispose();
    super.dispose();
  }

  static const _categories = [
    'All',
    'Technology',
    'Arts',
    'Business',
    'Academic',
    'Social',
    'Sports',
  ];

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
      shortDescription:
          'A student-led hub for gaming, digital media, and esports — open to everyone who wants to learn, compete, and create together.',
      mainGoals:
          '• Host semester tournaments and viewing events\n• Weekly workshops on content creation and game dev\n• Build mentorship between experienced members and newcomers',
      contactEmail: 'digital_entertainment@ada.edu.az',
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
      shortDescription:
          'Explore photography as art and craft — from campus walks to exhibitions and peer critique.',
      mainGoals:
          '• Monthly photo walks and themed challenges\n• Editing labs using Lightroom and Photoshop\n• End-of-semester gallery showcase',
      contactEmail: 'photo_club@ada.edu.az',
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
      shortDescription:
          'Learn how online businesses work — from stores and ads to analytics and side projects.',
      mainGoals:
          '• Guest talks from founders and marketers\n• Hands-on store setup workshops\n• Pitch nights for student business ideas',
      contactEmail: 'ecommerce_club@ada.edu.az',
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
      shortDescription:
          'Practice diplomacy, public speaking, and research through realistic UN-style committees.',
      mainGoals:
          '• Weekly resolution drafting sessions\n• Regional competition prep\n• Collaboration with debate and IR courses',
      contactEmail: 'adamun@ada.edu.az',
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
      shortDescription:
          'Friendly over-the-board play, tactics lessons, and rapid tournaments for all ratings.',
      mainGoals:
          '• Weekly ladder nights and puzzle rush\n• Guest coach sessions\n• Inter-university friendly matches',
      contactEmail: 'chess_club@ada.edu.az',
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
      shortDescription:
          'Perform, jam, or simply enjoy live music with peers across genres and skill levels.',
      mainGoals:
          '• Open mic and acoustic nights each term\n• Instrument skill circles (guitar, keys, vocals)\n• Collaboration with theater and cultural events',
      contactEmail: 'music_club@ada.edu.az',
    ),
  ];

  Future<void> _onClubCardTap(BuildContext context, Club club) async {
    final opener = widget.onClubOpen;
    if (opener != null) {
      await opener(club);
      return;
    }
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => ClubDetails(club: club),
      ),
    );
  }

  List<Club> get filteredClubs {
    return mockClubs.where((club) {
      final matchesSearch =
          club.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
              club.tags.any((tag) =>
                  tag.toLowerCase().contains(searchQuery.toLowerCase()));
      final matchesCategory =
          selectedCategory == 'All' || club.category == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final body = ResponsiveContainer(
      backgroundColor: AppColors.backgroundLight,
      padding: widget.embeddedInHub ? EdgeInsets.zero : null,
      child: Column(
        children: [
          if (!widget.embeddedInHub) _buildStandaloneHeader(context),
          Expanded(
            child: widget.embeddedInHub
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildPaneSwitcher(context),
                      Expanded(
                        child: widget.clubsPane == ClubsHomePane.browse
                            ? _buildBrowsePane(context)
                            : MyMemberships(
                                key: ValueKey(
                                  'mc-${widget.myClubsInnerTabIndex}-${widget.applicationsClubNameFilter}',
                                ),
                                embeddedInHub: true,
                                embeddedInClubsTab: true,
                                initialPrimaryTabIndex: widget.myClubsInnerTabIndex,
                                applicationsClubNameFilter: widget.applicationsClubNameFilter,
                              ),
                      ),
                    ],
                  )
                : _buildBrowsePane(context),
          ),
        ],
      ),
    );

    if (widget.embeddedInHub) {
      return body;
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(child: body),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateClubForm()),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _buildPaneSwitcher(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 2),
      child: Row(
          children: [
            Expanded(
              child: _paneToggle(
                label: 'Discover',
                icon: Icons.travel_explore_outlined,
                selected: widget.clubsPane == ClubsHomePane.browse,
                onTap: () => widget.onClubsPaneChanged?.call(ClubsHomePane.browse),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _paneToggle(
                label: 'My clubs',
                icon: Icons.folder_special_outlined,
                selected: widget.clubsPane == ClubsHomePane.myClubs,
                onTap: () => widget.onClubsPaneChanged?.call(ClubsHomePane.myClubs),
              ),
            ),
        ],
      ),
    );
  }

  Widget _paneToggle({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary.withOpacity(0.08) : AppColors.gray50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? AppColors.primary.withOpacity(0.35) : AppColors.gray200,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? AppColors.primary : AppColors.gray600,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected ? AppColors.primary : AppColors.gray600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrowsePane(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildCompactSearchAndCategories(context),
        Expanded(child: _buildClubsList(context)),
      ],
    );
  }

  // ── Header (standalone: full chrome; embedded: subtitle only) ─────
  Widget _buildStandaloneHeader(BuildContext context) {
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
                  '${filteredClubs.length} clubs',
                  style: const TextStyle(fontSize: 12, color: AppColors.gray500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactSearchAndCategories(BuildContext context) {
    final hasFilter = selectedCategory != 'All';
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      color: AppColors.backgroundLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 40,
            child: TextField(
              focusNode: _searchFocus,
              onChanged: (value) => setState(() => searchQuery = value),
              style: const TextStyle(fontSize: 14, color: AppColors.gray900),
              decoration: InputDecoration(
                hintText: 'Search by name or tag…',
                hintStyle: const TextStyle(fontSize: 13, color: AppColors.gray400),
                prefixIcon:
                    const Icon(Icons.search, size: 20, color: AppColors.gray400),
                prefixIconConstraints:
                    const BoxConstraints(minWidth: 40, minHeight: 0),
                suffixIcon: GestureDetector(
                  onTap: () => _openCategoryFilterSheet(context),
                  child: Container(
                    width: 34,
                    height: 34,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.tune, size: 17, color: AppColors.primary),
                  ),
                ),
                suffixIconConstraints:
                    const BoxConstraints(minWidth: 40, minHeight: 0),
                filled: true,
                fillColor: AppColors.gray50,
                contentPadding: EdgeInsets.zero,
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
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${filteredClubs.length} club${filteredClubs.length == 1 ? '' : 's'}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.gray500),
              ),
              if (hasFilter) ...[
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => setState(() => selectedCategory = 'All'),
                  child: const Text(
                    'Clear filters',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondary),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _openCategoryFilterSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        var tmp = selectedCategory;
        return StatefulBuilder(
          builder: (ctx, setModal) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                14,
                20,
                MediaQuery.of(ctx).padding.bottom + 20,
              ),
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
                      const Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gray900,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: const Icon(Icons.close, size: 22, color: AppColors.gray500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((c) {
                      final sel = tmp == c;
                      return GestureDetector(
                        onTap: () => setModal(() => tmp = c),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: sel ? AppColors.primary : AppColors.gray100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            c,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: sel ? AppColors.white : AppColors.gray700,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => selectedCategory = tmp);
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
                      child: const Text(
                        'Apply',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
      itemCount: filteredClubs.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ClubCard(
            club: filteredClubs[index],
            onTap: () => _onClubCardTap(context, filteredClubs[index]),
          ),
        );
      },
    );
  }
}