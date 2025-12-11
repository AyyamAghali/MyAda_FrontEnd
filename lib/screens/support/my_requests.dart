import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/support_ticket.dart';
import '../../utils/constants.dart';
import '../../widgets/responsive_container.dart';
import 'ticket_detail_view.dart';

class MyRequests extends StatefulWidget {
  const MyRequests({super.key});

  @override
  State<MyRequests> createState() => _MyRequestsState();
}

class _MyRequestsState extends State<MyRequests> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<SupportTicket> mockTickets = [
    SupportTicket(
      id: 'T-1234',
      title: 'Cannot connect to ADA-WiFi network',
      description: 'Unable to connect to the campus WiFi network',
      category: TicketCategory.wifiNetwork,
      status: TicketStatus.inProgress,
      priority: TicketPriority.high,
      location: 'Main Building - Floor 2',
      createdAt: DateTime.now().subtract(const Duration(hours: 11)).toIso8601String(),
      assignedTo: 'Farid Mammadov',
      type: 'IT',
    ),
    SupportTicket(
      id: 'T-1198',
      title: 'Projector not working in Lecture Hall 101',
      description: 'The projector in Lecture Hall 101 is not displaying anything',
      category: TicketCategory.projectorDisplay,
      status: TicketStatus.assigned,
      priority: TicketPriority.low,
      location: 'Lecture Hall 101',
      createdAt: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      assignedTo: 'Leyla Huseynova',
      type: 'Technical',
    ),
    SupportTicket(
      id: 'T-1145',
      title: 'Cannot access Outlook email',
      description: 'Unable to log into Outlook email account',
      category: TicketCategory.emailOffice365,
      status: TicketStatus.assigned,
      priority: TicketPriority.low,
      location: 'Dormitory',
      createdAt: DateTime(2025, 11, 15).toIso8601String(),
      assignedTo: 'Support Team',
      type: 'IT',
    ),
    SupportTicket(
      id: 'T-1089',
      title: 'Need password reset for student portal',
      description: 'Forgot password for student portal',
      category: TicketCategory.passwordReset,
      status: TicketStatus.completed,
      priority: TicketPriority.low,
      location: 'Library',
      createdAt: DateTime(2025, 11, 10).toIso8601String(),
      completedAt: DateTime(2025, 11, 14).toIso8601String(),
      assignedTo: 'Aysel Aliyeva',
      rating: 5,
      type: 'IT',
    ),
    SupportTicket(
      id: 'T-0987',
      title: 'Printer not printing in Computer Lab A',
      description: 'Printer in Computer Lab A is not responding',
      category: TicketCategory.printerScanner,
      status: TicketStatus.completed,
      priority: TicketPriority.low,
      location: 'Computer Lab A',
      createdAt: DateTime(2025, 11, 8).toIso8601String(),
      completedAt: DateTime(2025, 11, 10).toIso8601String(),
      assignedTo: 'Rashad Hasanov',
      rating: 5,
      type: 'Technical',
    ),
    SupportTicket(
      id: 'T-0856',
      title: 'Need Adobe Creative Suite installed',
      description: 'Request for Adobe Creative Suite installation',
      category: TicketCategory.softwareInstallation,
      status: TicketStatus.cancelled,
      priority: TicketPriority.low,
      location: 'Computer Lab B',
      createdAt: DateTime(2025, 11, 5).toIso8601String(),
      cancelledReason: 'Found alternative solution',
      type: 'IT',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<SupportTicket> get openTickets =>
      mockTickets.where((t) => t.status == TicketStatus.assigned || 
                               t.status == TicketStatus.inProgress).toList();

  List<SupportTicket> get completedTickets =>
      mockTickets.where((t) => t.status == TicketStatus.completed).toList();

  List<SupportTicket> get cancelledTickets =>
      mockTickets.where((t) => t.status == TicketStatus.cancelled).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildTabs(context),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTicketsList(openTickets),
                  _buildTicketsList(completedTickets),
                  _buildTicketsList(cancelledTickets),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: AppColors.white,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.gray900, size: 20),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Requests',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray900,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Track your support tickets',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.gray600,
                    fontWeight: FontWeight.w400,
                  ),
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.gray900,
        unselectedLabelColor: AppColors.gray600,
        indicatorColor: AppColors.gray900,
        indicatorWeight: 2.5,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.2,
        ),
        labelPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        tabs: [
          _buildTabWithBadge('Open', openTickets.length, 0),
          _buildTabWithBadge('Completed', completedTickets.length, 1),
          _buildTabWithBadge('Cancelled', cancelledTickets.length, 2),
        ],
      ),
    );
  }

  Widget _buildTabWithBadge(String label, int count, int index) {
    return Tab(
      child: AnimatedBuilder(
        animation: _tabController,
        builder: (context, child) {
          final isSelected = _tabController.index == index;
          return Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.gray900.withOpacity(0.15)
                      : AppColors.gray600.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.gray900 : AppColors.gray700,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTicketsList(List<SupportTicket> tickets) {
    if (tickets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: AppColors.gray300),
            const SizedBox(height: 16),
            Text(
              'No tickets',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.gray900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You don\'t have any tickets in this category',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.gray600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        return _buildTicketCard(context, tickets[index]);
      },
    );
  }

  Widget _buildTicketCard(BuildContext context, SupportTicket ticket) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (ticket.hashCode % 100)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTapDown: (_) {
          // Scale animation handled by Material
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TicketDetailView(ticket: ticket),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: Ticket ID and badges
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '#${ticket.id}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.gray600,
                            letterSpacing: 0.2,
                          ),
                        ),
                        Row(
                          children: [
                            _buildStatusBadge(ticket.status),
                            const SizedBox(width: 6),
                            _buildPriorityBadge(ticket.priority),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Title
                    Text(
                      ticket.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray900,
                        height: 1.3,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Category tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.gray100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        ticket.categoryString,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.gray600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Divider
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.gray200,
                    ),
                    const SizedBox(height: 14),
                    // Metadata row
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 16, color: AppColors.gray500),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            ticket.location,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.gray600,
                              fontWeight: FontWeight.w400,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.access_time_outlined, size: 16, color: AppColors.gray500),
                        const SizedBox(width: 6),
                        Text(
                          _getTimeAgo(ticket.createdAt),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.gray600,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    // Assigned to or waiting
                    if (ticket.assignedTo != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.person_outline, size: 16, color: AppColors.gray500),
                          const SizedBox(width: 6),
                          Text(
                            'Assigned to ${ticket.assignedTo}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.gray600,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                    // Completed date
                    if (ticket.completedAt != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.check_circle_outline, size: 16, color: const Color(0xFF10B981)),
                          const SizedBox(width: 6),
                          Text(
                            'Completed ${_formatDate(ticket.completedAt!)}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF10B981),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                    // Rating stars
                    if (ticket.rating != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 2),
                              child: Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: index < ticket.rating!
                                    ? const Color(0xFFFFB800)
                                    : AppColors.gray300,
                              ),
                            );
                          }),
                        ],
                      ),
                    ],
                    // Cancelled reason
                    if (ticket.cancelledReason != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.cancel_outlined, size: 16, color: AppColors.gray500),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Reason: ${ticket.cancelledReason}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.gray600,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(TicketStatus status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case TicketStatus.pending:
        // Treat pending as assigned (pending is deprecated for IT/FM requests)
        bgColor = const Color(0xFFEFF6FF); // Soft pastel blue
        textColor = const Color(0xFF2563EB);
        break;
      case TicketStatus.assigned:
        bgColor = const Color(0xFFEFF6FF); // Soft pastel blue
        textColor = const Color(0xFF2563EB);
        break;
      case TicketStatus.inProgress:
        bgColor = const Color(0xFFECFDF5); // Soft pastel green
        textColor = const Color(0xFF059669);
        break;
      case TicketStatus.completed:
        bgColor = const Color(0xFFECFDF5); // Soft pastel green
        textColor = const Color(0xFF10B981);
        break;
      case TicketStatus.cancelled:
        bgColor = AppColors.gray100;
        textColor = AppColors.gray600;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20), // Pill-shaped
      ),
      child: Text(
        status == TicketStatus.pending || status == TicketStatus.assigned ? 'Assigned' :
        status == TicketStatus.inProgress ? 'In Progress' :
        status == TicketStatus.completed ? 'Completed' : 'Cancelled',
        style: TextStyle(
          fontSize: 11,
          color: textColor,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(TicketPriority priority) {
    Color bgColor;
    Color textColor;
    String label;

    switch (priority) {
      case TicketPriority.low:
        bgColor = const Color(0xFFECFDF5); // Soft pastel green
        textColor = const Color(0xFF059669);
        label = 'Not Urgent';
        break;
      case TicketPriority.medium:
        // Map medium to "Not Urgent" since we only have two options now
        bgColor = const Color(0xFFECFDF5); // Soft pastel green
        textColor = const Color(0xFF059669);
        label = 'Not Urgent';
        break;
      case TicketPriority.high:
        bgColor = const Color(0xFFFEE2E2); // Soft pastel red
        textColor = const Color(0xFFDC2626);
        label = 'Urgent';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20), // Pill-shaped
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: textColor,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  String _getTimeAgo(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return DateFormat('MMM d').format(date);
      }
    } catch (e) {
      return dateStr;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM d').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
