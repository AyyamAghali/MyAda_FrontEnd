import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/club.dart';
import '../../utils/constants.dart';
import '../../widgets/responsive_container.dart';

class EventRegistration extends StatefulWidget {
  final ClubEvent event;
  final String clubName;

  const EventRegistration({
    super.key,
    required this.event,
    required this.clubName,
  });

  @override
  State<EventRegistration> createState() => _EventRegistrationState();
}

class _EventRegistrationState extends State<EventRegistration> {
  final _formKey = GlobalKey<FormState>();
  String fullName = '';
  String studentId = '';
  String email = '';
  String phone = '';
  String attendanceType = 'In-Person';
  String additionalInfo = '';
  bool _showValidationError = false;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(widget.event.date);
    final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(date);

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
                        _buildEventCard(context, formattedDate),
                        const SizedBox(height: 24),
                        _buildInfoBanner(),
                        const SizedBox(height: 24),
                        _buildEventInfo(context),
                        const SizedBox(height: 24),
                        _buildFormFields(),
                        const SizedBox(height: 24),
                        _buildBenefits(),
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
                const Text(
                  'Event Registration',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray900,
                  ),
                ),
                Text(
                  widget.clubName,
                  style: const TextStyle(fontSize: 12, color: AppColors.gray500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, String formattedDate) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.event.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: AppColors.white),
              const SizedBox(width: 8),
              Text(
                formattedDate,
                style: const TextStyle(fontSize: 14, color: AppColors.white),
              ),
            ],
          ),
          if (widget.event.time != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: AppColors.white),
                const SizedBox(width: 8),
                Text(
                  widget.event.time!,
                  style: const TextStyle(fontSize: 14, color: AppColors.white),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: AppColors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.event.location,
                  style: const TextStyle(fontSize: 14, color: AppColors.white),
                ),
              ),
            ],
          ),
        ],
      ),
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
              'Please fill out all required fields. Event organizers will contact you with additional details before the event.',
              style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventInfo(BuildContext context) {
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
            'About This Event',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: 8),
          if (widget.event.description != null)
            Text(
              widget.event.description!,
              style: const TextStyle(fontSize: 14, color: AppColors.gray600),
            ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: const Text(
              '45 spots remaining out of 100',
              style: TextStyle(fontSize: 14, color: Colors.green),
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
          label: 'Student ID *',
          child: TextFormField(
            decoration: const InputDecoration(hintText: 'e.g., 12345'),
            onChanged: (value) => setState(() => studentId = value),
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
          label: 'How will you attend?',
          child: Column(
            children: [
              RadioListTile<String>(
                title: const Text('In-Person'),
                value: 'In-Person',
                groupValue: attendanceType,
                onChanged: (value) => setState(() => attendanceType = value!),
                contentPadding: EdgeInsets.zero,
              ),
              RadioListTile<String>(
                title: const Text('Online/Virtual'),
                value: 'Online/Virtual',
                groupValue: attendanceType,
                onChanged: (value) => setState(() => attendanceType = value!),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildNumberedField(
          number: 6,
          label: 'Additional Information or Questions',
          child: TextFormField(
            decoration: const InputDecoration(hintText: 'Optional'),
            maxLines: 3,
            onChanged: (value) => setState(() => additionalInfo = value),
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

  Widget _buildBenefits() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Registration Benefits',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.gray900,
            ),
          ),
          const SizedBox(height: 12),
          _buildBenefitItem('Guaranteed seat at the event'),
          _buildBenefitItem('Email reminders before the event'),
          _buildBenefitItem('Certificate of attendance'),
          _buildBenefitItem('Priority registration for future events'),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.green.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: Colors.green.shade900),
            ),
          ),
        ],
      ),
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
                      const SnackBar(content: Text('Successfully registered for event!')),
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
                  'Register for Event',
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

