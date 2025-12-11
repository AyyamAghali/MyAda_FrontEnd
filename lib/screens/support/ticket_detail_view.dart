import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/support_ticket.dart';
import '../../utils/constants.dart';
import '../../widgets/responsive_container.dart';

class TicketDetailView extends StatelessWidget {
  final SupportTicket ticket;

  const TicketDetailView({super.key, required this.ticket});

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
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTicketHeader(context),
                      const SizedBox(height: 24),
                      _buildStatusSection(context),
                      const SizedBox(height: 24),
                      _buildDetailsSection(context),
                      const SizedBox(height: 24),
                      _buildDescriptionSection(context),
                      if (ticket.assignedTo != null) ...[
                        const SizedBox(height: 24),
                        _buildAssignedSection(context),
                      ],
                      if (ticket.completedAt != null) ...[
                        const SizedBox(height: 24),
                        _buildCompletedSection(context),
                      ],
                      if (ticket.cancelledReason != null) ...[
                        const SizedBox(height: 24),
                        _buildCancelledSection(context),
                      ],
                      const SizedBox(height: 24),
                      _buildTimelineSection(context),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
              _buildBottomActions(context),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.gray700),
            onPressed: () => Navigator.pop(context),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.share, color: AppColors.gray700),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share ticket (mock)')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTicketHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: ticket.type == 'IT'
              ? [AppColors.primary, AppColors.primaryDark]
              : [AppColors.secondary, AppColors.secondaryDark],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '#${ticket.id}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            ticket.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              ticket.categoryString,
              style: const TextStyle(fontSize: 12, color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatusCard('Status', ticket.statusString, _getStatusColor(ticket.status)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatusCard('Priority', ticket.priorityString, _getPriorityColor(ticket.priority)),
        ),
      ],
    );
  }

  Widget _buildStatusCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.gray500),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ticket Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(Icons.location_on, 'Location', ticket.location),
          _buildDetailRow(Icons.access_time, 'Created', _formatDateTime(ticket.createdAt)),
          if (ticket.completedAt != null)
            _buildDetailRow(Icons.check_circle, 'Completed', _formatDateTime(ticket.completedAt!)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: AppColors.gray500),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.description, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            ticket.description,
            style: const TextStyle(fontSize: 14, color: AppColors.gray600, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignedSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border.all(color: Colors.blue.shade200),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.person, color: Colors.blue, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Assigned To',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                  ),
                ),
                Text(
                  ticket.assignedTo!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border.all(color: Colors.green.shade200),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 24),
              SizedBox(width: 8),
              Text(
                'Completed',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          if (ticket.rating != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  'Your Rating: ',
                  style: TextStyle(fontSize: 14, color: Colors.green),
                ),
                ...List.generate(5, (index) {
                  return Icon(
                    Icons.star,
                    size: 20,
                    color: index < ticket.rating! ? Colors.amber : AppColors.gray300,
                  );
                }),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCancelledSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        border: Border.all(color: AppColors.gray300),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.cancel, color: AppColors.gray700, size: 24),
              SizedBox(width: 8),
              Text(
                'Cancelled',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray700,
                ),
              ),
            ],
          ),
          if (ticket.cancelledReason != null) ...[
            const SizedBox(height: 12),
            Text(
              'Reason: ${ticket.cancelledReason}',
              style: const TextStyle(fontSize: 14, color: AppColors.gray600),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.timeline, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Timeline',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTimelineItem('Created', _formatDateTime(ticket.createdAt), true),
          if (ticket.assignedTo != null)
            _buildTimelineItem('Assigned', 'Assigned to ${ticket.assignedTo}', 
                ticket.status == TicketStatus.assigned || 
                ticket.status == TicketStatus.inProgress || 
                ticket.status == TicketStatus.completed),
          if (ticket.status == TicketStatus.inProgress || ticket.status == TicketStatus.completed)
            _buildTimelineItem('In Progress', 'Work started on ticket', 
                ticket.status == TicketStatus.inProgress),
          if (ticket.status == TicketStatus.completed && ticket.completedAt != null)
            _buildTimelineItem('Completed', _formatDateTime(ticket.completedAt!), true),
          if (ticket.status == TicketStatus.cancelled)
            _buildTimelineItem('Cancelled', ticket.cancelledReason ?? 'Ticket cancelled', true),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String description, bool isActive) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.gray200,
                  shape: BoxShape.circle,
                ),
                child: isActive
                    ? const Icon(Icons.check, color: AppColors.white, size: 16)
                    : Container(
                        margin: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.gray400,
                          shape: BoxShape.circle,
                        ),
                      ),
              ),
              Container(
                width: 2,
                height: 32,
                color: AppColors.gray200,
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isActive ? AppColors.gray900 : AppColors.gray600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive ? AppColors.gray600 : AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    if (ticket.status == TicketStatus.completed) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.gray200)),
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _showRatingDialog(context);
              },
              icon: const Icon(Icons.star),
              label: const Text('Rate This Ticket'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ),
      );
    }

    if (ticket.status == TicketStatus.cancelled) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.gray200)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  _showContactDialog(context);
                },
                icon: const Icon(Icons.message),
                label: const Text('Contact Staff'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  _showCancelDialog(context);
                },
                icon: const Icon(Icons.cancel),
                label: const Text('Cancel Ticket'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support Staff'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (ticket.assignedTo != null) ...[
              Text('Assigned to: ${ticket.assignedTo}'),
              const SizedBox(height: 16),
            ],
            const Text('You can contact support via:'),
            const SizedBox(height: 8),
            const Text('• Email: support@ada.edu.az'),
            const Text('• Phone: +994 12 437 32 35'),
            const Text('• Chat: Available in app'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () async {
              final uri = Uri.parse('mailto:support@ada.edu.az?subject=Ticket ${ticket.id}');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
              Navigator.pop(context);
            },
            child: const Text('Send Email'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Ticket'),
        content: const Text('Are you sure you want to cancel this ticket? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ticket cancelled (mock)'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(BuildContext context) {
    int rating = ticket.rating ?? 0;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Rate This Ticket'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('How would you rate the support you received?'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      Icons.star,
                      size: 40,
                      color: index < rating ? Colors.amber : AppColors.gray300,
                    ),
                    onPressed: () {
                      setState(() => rating = index + 1);
                    },
                  );
                }),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Rating submitted: $rating stars (mock)'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.pending:
        // Treat pending as assigned (pending is deprecated for IT/FM requests)
        return Colors.blue;
      case TicketStatus.assigned:
        return Colors.blue;
      case TicketStatus.inProgress:
        return Colors.green;
      case TicketStatus.completed:
        return Colors.green;
      case TicketStatus.cancelled:
        return AppColors.gray600;
    }
  }

  Color _getPriorityColor(TicketPriority priority) {
    switch (priority) {
      case TicketPriority.low:
        return Colors.green;
      case TicketPriority.medium:
        return Colors.orange;
      case TicketPriority.high:
        return Colors.red;
    }
  }

  String _formatDateTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM d, yyyy • h:mm a').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}

