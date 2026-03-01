import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class ClubApplicationDetail extends StatelessWidget {
  const ClubApplicationDetail({super.key, required this.application});

  final Map<String, String> application;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.white,
        title: const Text(
          'Application Details',
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
                        const SnackBar(content: Text('Application rejected (mock).')),
                      );
                    },
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Application approved (mock).')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                    ),
                    child: const Text('Approve'),
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
          radius: 24,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: const Icon(Icons.person, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                application['name'] ?? 'Applicant',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Student ID: ${application['studentId'] ?? 'N/A'}',
                style: const TextStyle(fontSize: 12, color: AppColors.gray600),
              ),
            ],
          ),
        ),
        _statusChip(application['status'] ?? 'Pending'),
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
            'Application Info',
            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.gray900),
          ),
          const SizedBox(height: 12),
          _infoRow('Role/Type', application['role'] ?? 'N/A'),
          _infoRow('Applied on', application['date'] ?? 'N/A'),
          _infoRow('Type', application['type'] ?? 'Membership'),
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
            'Mocked notes about the applicant and interview feedback.',
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
    if (status.toLowerCase().contains('pending')) {
      color = Colors.orange;
    } else if (status.toLowerCase().contains('review')) {
      color = Colors.blue;
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
