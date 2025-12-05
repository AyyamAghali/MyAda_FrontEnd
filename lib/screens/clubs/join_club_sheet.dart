import 'package:flutter/material.dart';
import '../../models/club.dart';
import '../../utils/constants.dart';
import '../../widgets/responsive_container.dart';

class JoinClubSheet extends StatefulWidget {
  final Club club;

  const JoinClubSheet({super.key, required this.club});

  @override
  State<JoinClubSheet> createState() => _JoinClubSheetState();
}

class _JoinClubSheetState extends State<JoinClubSheet> {
  final _formKey = GlobalKey<FormState>();
  String fullName = '';
  String major = '';
  String graduationYear = '';
  String email = '';
  String phone = '';
  String selectedPosition = 'Member';
  String experience = '';
  List<String> portfolioFiles = [];
  bool _showValidationError = false;

  final List<String> positions = [
    'Member',
    'Esports Player',
    'Content Creator',
    'Streamer',
    'Tournament Organizer',
    'Social Media Manager',
    'Designer',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: ResponsiveContainer(
          backgroundColor: AppColors.backgroundLight,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildIntroText(),
                        const SizedBox(height: 16),
                        _buildInfoBanner(),
                        const SizedBox(height: 24),
                        _buildFormFields(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
                _buildSubmitButton(context),
              ],
            ),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.club.name} Recruitment',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray900,
                  ),
                ),
                const Text(
                  'Application Form',
                  style: TextStyle(fontSize: 12, color: AppColors.gray500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroText() {
    return const Text(
      'Join us to express your creativity, grow your talent, and be part of an amazing community!',
      style: TextStyle(fontSize: 14, color: AppColors.gray700, height: 1.5),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border.all(color: Colors.blue.shade200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.info, color: Colors.blue, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'When you submit this form, club representatives will see your name and email address.',
              style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNumberedField(
          number: 1,
          label: 'Full Name *',
          child: TextFormField(
            decoration: const InputDecoration(hintText: 'Enter your full name'),
            onChanged: (value) => setState(() => fullName = value),
            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
          ),
        ),
        const SizedBox(height: 16),
        _buildNumberedField(
          number: 2,
          label: 'Major and Graduation year *',
          child: TextFormField(
            decoration: const InputDecoration(hintText: 'e.g., Computer Science, 2026'),
            onChanged: (value) => setState(() => major = value),
            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
          ),
        ),
        const SizedBox(height: 16),
        _buildNumberedField(
          number: 3,
          label: 'ADA Email *',
          child: TextFormField(
            decoration: const InputDecoration(hintText: 'student@ada.edu.az'),
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) => setState(() => email = value),
            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
          ),
        ),
        const SizedBox(height: 16),
        _buildNumberedField(
          number: 4,
          label: 'Phone Number *',
          child: TextFormField(
            decoration: const InputDecoration(hintText: '+994 XX XXX XX XX'),
            keyboardType: TextInputType.phone,
            onChanged: (value) => setState(() => phone = value),
            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
          ),
        ),
        const SizedBox(height: 16),
        _buildNumberedField(
          number: 5,
          label: 'What position are you applying for?',
          child: Column(
            children: positions.map((position) {
              return RadioListTile<String>(
                title: Text(position),
                value: position,
                groupValue: selectedPosition,
                onChanged: (value) => setState(() => selectedPosition = value!),
                contentPadding: EdgeInsets.zero,
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        _buildNumberedField(
          number: 6,
          label: 'Any previous experience, works or portfolio links?',
          child: TextFormField(
            decoration: const InputDecoration(
              hintText: 'https://example.com/portfolio',
            ),
            maxLines: 3,
            onChanged: (value) => setState(() => experience = value),
          ),
        ),
        const SizedBox(height: 16),
        _buildNumberedField(
          number: 7,
          label: 'Any previous works or portfolio files? (optional)',
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.gray300, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Icon(Icons.upload_file, size: 48, color: AppColors.gray400),
                const SizedBox(height: 8),
                const Text(
                  'Upload Files',
                  style: TextStyle(fontSize: 14, color: AppColors.gray600),
                ),
                const SizedBox(height: 4),
                Text(
                  '10 files, 1GB each',
                  style: TextStyle(fontSize: 12, color: AppColors.gray500),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberedField({
    required int number,
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  number.toString(),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.gray200)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() => _showValidationError = false);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Application submitted successfully!')),
                    );
                  } else {
                    setState(() => _showValidationError = true);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Submit Application',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            if (_showValidationError) ...[
              const SizedBox(height: 12),
              const Text(
                'Please fill in all required fields',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

