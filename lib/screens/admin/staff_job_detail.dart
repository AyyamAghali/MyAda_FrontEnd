import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class StaffJobDetail extends StatelessWidget {
  const StaffJobDetail({super.key, required this.job});

  final Map<String, String> job;

  @override
  Widget build(BuildContext context) {
    final status = job['status'] ?? 'Queued';
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.white,
        title: const Text(
          'Job Details',
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
            _buildNotesCard(),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Marked as started (mock).')),
                      );
                    },
                    child: const Text('Mark as Started'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Marked complete (mock).')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                    ),
                    child: Text(status.toLowerCase().contains('progress') ? 'Complete' : 'Start'),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          job['title'] ?? 'Task',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.gray900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          job['location'] ?? '',
          style: const TextStyle(fontSize: 12, color: AppColors.gray600),
        ),
        const SizedBox(height: 6),
        _statusChip(job['status'] ?? 'Queued'),
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
            'Job Info',
            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.gray900),
          ),
          const SizedBox(height: 12),
          _infoRow('Request ID', job['id'] ?? 'N/A'),
          _infoRow('Category', job['category'] ?? 'N/A'),
          _infoRow('Reported', job['time'] ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
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
            'Notes',
            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.gray900),
          ),
          SizedBox(height: 8),
          Text(
            'Mock notes about required tools and customer preferences.',
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

  Widget _statusChip(String status) {
    Color color;
    if (status.toLowerCase().contains('progress')) {
      color = Colors.orange;
    } else if (status.toLowerCase().contains('complete')) {
      color = Colors.green;
    } else {
      color = AppColors.gray500;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
