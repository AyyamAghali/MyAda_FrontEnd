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
      priority: TicketPriority.medium,
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
      status: TicketStatus.pending,
      priority: TicketPriority.low,
      location: 'Dormitory',
      createdAt: DateTime(2025, 11, 15).toIso8601String(),
      type: 'IT',
    ),
    SupportTicket(
      id: 'T-1089',
      title: 'Need password reset for student portal',
      description: 'Forgot password for student portal',
      category: TicketCategory.passwordReset,
      status: TicketStatus.completed,
      priority: TicketPriority.medium,
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
      mockTickets.where((t) => t.status == TicketStatus.pending || 
                               t.status == TicketStatus.assigned || 
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
                    _buildTicketsList(openTickets),
                    _buildTicketsList(completedTickets),
                    _buildTicketsList(cancelledTickets),
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
                  'My Requests',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Track your support tickets',
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
          Tab(text: 'Open (${openTickets.length})'),
          Tab(text: 'Completed (${completedTickets.length})'),
          Tab(text: 'Cancelled (${cancelledTickets.length})'),
        ],
      ),
    );
  }

  Widget _buildTicketsList(List<SupportTicket> tickets) {
    if (tickets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: AppColors.gray300),
            const SizedBox(height: 16),
            const Text(
              'No tickets',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'You don\'t have any tickets in this category',
              style: TextStyle(fontSize: 14, color: AppColors.gray500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        return _buildTicketCard(context, tickets[index]);
      },
    );
  }

  Widget _buildTicketCard(BuildContext context, SupportTicket ticket) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TicketDetailView(ticket: ticket),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${ticket.id}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray900,
                  ),
                ),
                Row(
                  children: [
                    _buildStatusBadge(ticket.status),
                    const SizedBox(width: 8),
                    _buildPriorityBadge(ticket.priority),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              ticket.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.gray900,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gray100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    ticket.categoryString,
                    style: const TextStyle(fontSize: 11, color: AppColors.gray700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: AppColors.gray500),
                const SizedBox(width: 4),
                Text(
                  ticket.location,
                  style: const TextStyle(fontSize: 12, color: AppColors.gray600),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 14, color: AppColors.gray500),
                const SizedBox(width: 4),
                Text(
                  _getTimeAgo(ticket.createdAt),
                  style: const TextStyle(fontSize: 12, color: AppColors.gray600),
                ),
              ],
            ),
            if (ticket.assignedTo != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person, size: 14, color: AppColors.gray500),
                  const SizedBox(width: 4),
                  Text(
                    'Assigned to ${ticket.assignedTo}',
                    style: const TextStyle(fontSize: 12, color: AppColors.gray600),
                  ),
                ],
              ),
            ] else if (ticket.status == TicketStatus.pending) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.gray400),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Waiting for assignment',
                    style: TextStyle(fontSize: 12, color: AppColors.gray600),
                  ),
                ],
              ),
            ],
            if (ticket.completedAt != null) ...[
              const SizedBox(height: 8),
              Text(
                'Completed ${_formatDate(ticket.completedAt!)}',
                style: const TextStyle(fontSize: 12, color: Colors.green),
              ),
            ],
            if (ticket.rating != null) ...[
              const SizedBox(height: 8),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    Icons.star,
                    size: 16,
                    color: index < ticket.rating! ? Colors.amber : AppColors.gray300,
                  );
                }),
              ),
            ],
            if (ticket.cancelledReason != null) ...[
              const SizedBox(height: 8),
              Text(
                'Reason: ${ticket.cancelledReason}',
                style: const TextStyle(fontSize: 12, color: AppColors.gray600),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(TicketStatus status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case TicketStatus.pending:
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        break;
      case TicketStatus.assigned:
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        break;
      case TicketStatus.inProgress:
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        break;
      case TicketStatus.completed:
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        break;
      case TicketStatus.cancelled:
        bgColor = AppColors.gray100;
        textColor = AppColors.gray700;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status == TicketStatus.pending ? 'Pending' :
        status == TicketStatus.assigned ? 'Assigned' :
        status == TicketStatus.inProgress ? 'In Progress' :
        status == TicketStatus.completed ? 'Completed' : 'Cancelled',
        style: TextStyle(fontSize: 10, color: textColor, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildPriorityBadge(TicketPriority priority) {
    Color bgColor;
    Color textColor;

    switch (priority) {
      case TicketPriority.low:
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        break;
      case TicketPriority.medium:
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        break;
      case TicketPriority.high:
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        priority == TicketPriority.low ? 'Low' :
        priority == TicketPriority.medium ? 'Medium' : 'High',
        style: TextStyle(fontSize: 10, color: textColor, fontWeight: FontWeight.w500),
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

