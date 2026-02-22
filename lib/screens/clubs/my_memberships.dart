import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../utils/constants.dart';
import '../../widgets/responsive_container.dart';
import 'club_details.dart';
import '../../models/club.dart';

enum MembershipStatus {
  active,
  pending,
  declined,
}

class Membership {
  final Club club;
  final MembershipStatus status;
  final String? role;
  final String? sinceDate;
  final String? declinedReason;
  final String? submittedDate;

  Membership({
    required this.club,
    required this.status,
    this.role,
    this.sinceDate,
    this.declinedReason,
    this.submittedDate,
  });
}

class MyMemberships extends StatefulWidget {
  const MyMemberships({super.key});

  @override
  State<MyMemberships> createState() => _MyMembershipsState();
}

class _MyMembershipsState extends State<MyMemberships> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  final List<Membership> memberships = [
    Membership(
      club: Club(
        id: '1',
        name: 'ADA Digital Entertainment Club',
        logo: 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=200&h=200&fit=crop',
        banner: '',
        category: 'Technology',
        tags: [],
        memberCount: 156,
        status: ClubStatus.open,
        about: '',
        officers: [],
        events: [],
      ),
      status: MembershipStatus.active,
      role: 'Member',
      sinceDate: 'Sep 2024',
    ),
    Membership(
      club: Club(
        id: '2',
        name: 'ADA Photo Club',
        logo: 'https://images.unsplash.com/photo-1606216794074-735e91aa2c92?w=200&h=200&fit=crop',
        banner: '',
        category: 'Arts',
        tags: [],
        memberCount: 89,
        status: ClubStatus.paused,
        about: '',
        officers: [],
        events: [],
      ),
      status: MembershipStatus.active,
      role: 'Vice President',
      sinceDate: 'Aug 2024',
    ),
    Membership(
      club: Club(
        id: '3',
        name: 'E-Commerce Club',
        logo: 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=200&h=200&fit=crop',
        banner: '',
        category: 'Business',
        tags: [],
        memberCount: 134,
        status: ClubStatus.open,
        about: '',
        officers: [],
        events: [],
      ),
      status: MembershipStatus.pending,
      submittedDate: 'November 10, 2025',
      role: null,
      sinceDate: null,
    ),
    Membership(
      club: Club(
        id: '4',
        name: 'ADAMUN',
        logo: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=200&h=200&fit=crop',
        banner: '',
        category: 'Academic',
        tags: [],
        memberCount: 112,
        status: ClubStatus.open,
        about: '',
        officers: [],
        events: [],
      ),
      status: MembershipStatus.declined,
      declinedReason: 'Club has reached maximum capacity for this semester. You are welcome to apply again next semester.',
      submittedDate: 'October 28, 2025',
      role: null,
      sinceDate: null,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Membership> get activeMemberships =>
      memberships.where((m) => m.status == MembershipStatus.active).toList();

  List<Membership> get pendingMemberships =>
      memberships.where((m) => m.status == MembershipStatus.pending).toList();

  List<Membership> get declinedMemberships =>
      memberships.where((m) => m.status == MembershipStatus.declined).toList();

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
              _buildTabs(context),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMembershipList(activeMemberships),
                    _buildMembershipList(pendingMemberships),
                    _buildMembershipList(declinedMemberships),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: AppColors.white,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.gray700),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Memberships',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Track all your club memberships',
                  style: TextStyle(fontSize: 12, color: AppColors.gray500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.gray600,
        indicatorColor: AppColors.primary,
        tabs: [
          Tab(text: 'Active (${activeMemberships.length})'),
          Tab(text: 'Pending (${pendingMemberships.length})'),
          Tab(text: 'Declined (${declinedMemberships.length})'),
        ],
      ),
    );
  }

  Widget _buildMembershipList(List<Membership> memberships) {
    if (memberships.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: AppColors.gray300),
            const SizedBox(height: 16),
            Text(
              'No memberships',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.gray900),
            ),
            const SizedBox(height: 8),
            Text(
              'You don\'t have any ${_getStatusText()} memberships',
              style: TextStyle(fontSize: 14, color: AppColors.gray500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: memberships.length,
      itemBuilder: (context, index) {
        return _buildMembershipCard(context, memberships[index]);
      },
    );
  }

  Widget _buildMembershipCard(BuildContext context, Membership membership) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (membership.status == MembershipStatus.pending)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Under Review',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
            )
          else if (membership.status == MembershipStatus.declined)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Icon(Icons.close, size: 16, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Application Declined',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: CachedNetworkImageProvider(membership.club.logo),
                  onBackgroundImageError: (_, __) {},
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        membership.club.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gray900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (membership.status == MembershipStatus.active && membership.role != null && membership.sinceDate != null)
                        Text(
                          '${membership.role} Since ${membership.sinceDate}',
                          style: const TextStyle(fontSize: 12, color: AppColors.gray600),
                        )
                      else if (membership.submittedDate != null)
                        Text(
                          'Submitted on ${membership.submittedDate}',
                          style: const TextStyle(fontSize: 12, color: AppColors.gray600),
                        ),
                      if (membership.status == MembershipStatus.active) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.check_circle, size: 16, color: Colors.green.shade600),
                            const SizedBox(width: 4),
                            Text(
                              'Active Member',
                              style: TextStyle(fontSize: 12, color: Colors.green.shade700),
                            ),
                          ],
                        ),
                      ],
                      if (membership.status == MembershipStatus.pending) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Your application is being reviewed by club officers. You\'ll be notified once a decision is made.',
                          style: const TextStyle(fontSize: 12, color: AppColors.gray600),
                        ),
                      ],
                      if (membership.status == MembershipStatus.declined) ...[
                        const SizedBox(height: 8),
                        if (membership.declinedReason != null) ...[
                          const Text(
                            'Reason:',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.gray700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            membership.declinedReason!,
                            style: const TextStyle(fontSize: 12, color: AppColors.gray600),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClubDetails(club: membership.club),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('View Club'),
                  ),
                ),
                const SizedBox(width: 12),
                if (membership.status == MembershipStatus.declined)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showSnackBar('Contact request sent (mock).');
                      },
                      icon: const Icon(Icons.email, size: 18),
                      label: const Text('Contact Club Officers'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.email, color: AppColors.primary),
                    onPressed: () {
                      _showSnackBar('Contact request sent (mock).');
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText() {
    switch (_selectedIndex) {
      case 0:
        return 'active';
      case 1:
        return 'pending';
      case 2:
        return 'declined';
      default:
        return '';
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

