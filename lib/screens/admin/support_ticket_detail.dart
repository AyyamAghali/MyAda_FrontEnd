import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class SupportTicketDetail extends StatelessWidget {
  const SupportTicketDetail({super.key, required this.ticket});

  final Map<String, String> ticket;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.white,
        title: const Text(
          'Ticket Details',
          style: TextStyle(color: AppColors.gray900, fontWeight: FontWeight.w700),
        ),
        iconTheme: const IconThemeData(color: AppColors.gray700),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildInfoCard(),
            const SizedBox(height: 16),
            _buildTimelineCard(),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ticket assigned (mock).')),
                      );
                    },
                    child: const Text('Assign'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ticket resolved (mock).')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                    ),
                    child: const Text('Resolve'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: const Icon(Icons.confirmation_number_outlined, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ticket['title'] ?? 'Ticket',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                ticket['location'] ?? '',
                style: const TextStyle(fontSize: 12, color: AppColors.gray600),
              ),
            ],
          ),
        ),
        _priorityChip(ticket['priority'] ?? 'Medium'),
      ],
    );
  }

  Widget _buildInfoCard() {
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
          const Text(
            'Issue Details',
            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.gray900),
          ),
          const SizedBox(height: 12),
          _infoRow('Status', ticket['status'] ?? 'Open'),
          _infoRow('Priority', ticket['priority'] ?? 'Medium'),
          _infoRow('Assigned', 'Unassigned'),
        ],
      ),
    );
  }

  Widget _buildTimelineCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Timeline',
            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.gray900),
          ),
          SizedBox(height: 12),
          Text(
            '• Ticket created - 10:32 AM\n• Status changed to In Progress - 11:05 AM',
            style: TextStyle(fontSize: 12, color: AppColors.gray600),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.gray600),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 12, color: AppColors.gray900),
          ),
        ],
      ),
    );
  }

  Widget _priorityChip(String priority) {
    Color color;
    if (priority.toLowerCase().contains('high')) {
      color = Colors.red;
    } else if (priority.toLowerCase().contains('medium')) {
      color = Colors.orange;
    } else {
      color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        priority,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
