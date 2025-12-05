import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/support_ticket.dart';
import '../../utils/constants.dart';
import '../../widgets/responsive_container.dart';
import 'my_requests.dart';

class NewIssueForm extends StatefulWidget {
  final String category; // 'IT' or 'Technical'

  const NewIssueForm({super.key, required this.category});

  @override
  State<NewIssueForm> createState() => _NewIssueFormState();
}

class _NewIssueFormState extends State<NewIssueForm> {
  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();
  final _locationController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  TicketPriority _urgencyLevel = TicketPriority.medium;
  List<String> _attachments = [];

  final List<String> _categories = [
    'Wi-Fi & Network',
    'Email & Office 365',
    'Password Reset',
    'Projector/Display',
    'Printer/Scanner',
    'Software Installation',
    'Computer Repair',
    'Other',
  ];

  @override
  void dispose() {
    _categoryController.dispose();
    _locationController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isIT = widget.category == 'IT';
    final responseTime = isIT ? '2-4 hours' : '4-8 hours';
    final primaryColor = isIT ? AppColors.primary : AppColors.secondary;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: ResponsiveContainer(
          backgroundColor: AppColors.backgroundLight,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildHeader(context, isIT),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildNumberedField(
                          number: 1,
                          label: 'Issue Category *',
                          child: TextFormField(
                            controller: _categoryController,
                            decoration: InputDecoration(
                              hintText: 'Select category',
                              suffixIcon: PopupMenuButton<String>(
                                icon: const Icon(Icons.arrow_drop_down),
                                onSelected: (value) {
                                  setState(() => _categoryController.text = value);
                                },
                                itemBuilder: (context) {
                                  return _categories.map((cat) {
                                    return PopupMenuItem(
                                      value: cat,
                                      child: Text(cat),
                                    );
                                  }).toList();
                                },
                              ),
                            ),
                            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildNumberedField(
                          number: 2,
                          label: 'Location *',
                          child: TextFormField(
                            controller: _locationController,
                            decoration: const InputDecoration(
                              hintText: 'Enter location',
                              prefixIcon: Icon(Icons.location_on, color: AppColors.primary),
                            ),
                            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildNumberedField(
                          number: 3,
                          label: 'Issue Title *',
                          child: TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              hintText: 'Brief summary of the issue',
                            ),
                            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildNumberedField(
                          number: 4,
                          label: 'Detailed Description *',
                          child: TextFormField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              hintText: 'Provide as much detail as possible about the issue...',
                              helperText: 'Include error messages, what you were doing when the issue occurred, etc.',
                            ),
                            maxLines: 5,
                            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildNumberedField(
                          number: 5,
                          label: 'Attachments (Optional)',
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    final picker = ImagePicker();
                                    final image = await picker.pickImage(source: ImageSource.camera);
                                    if (image != null) {
                                      setState(() => _attachments.add(image.path));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Photo added (mock)')),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.camera_alt),
                                  label: const Text('Add Photo'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    setState(() => _attachments.add('video_${_attachments.length}.mp4'));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Video added (mock)')),
                                    );
                                  },
                                  icon: const Icon(Icons.videocam),
                                  label: const Text('Add Video'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_attachments.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _attachments.map((attachment) {
                              return Chip(
                                label: Text(attachment.split('/').last),
                                onDeleted: () {
                                  setState(() => _attachments.remove(attachment));
                                },
                              );
                            }).toList(),
                          ),
                        ],
                        const SizedBox(height: 16),
                        _buildNumberedField(
                          number: 6,
                          label: 'Urgency Level *',
                          child: Column(
                            children: [
                              RadioListTile<TicketPriority>(
                                title: const Text('Low'),
                                subtitle: const Text('Can wait 24+ hours'),
                                value: TicketPriority.low,
                                groupValue: _urgencyLevel,
                                onChanged: (value) => setState(() => _urgencyLevel = value!),
                                contentPadding: EdgeInsets.zero,
                              ),
                              RadioListTile<TicketPriority>(
                                title: const Text('Medium'),
                                subtitle: const Text('Needed within today'),
                                value: TicketPriority.medium,
                                groupValue: _urgencyLevel,
                                onChanged: (value) => setState(() => _urgencyLevel = value!),
                                contentPadding: EdgeInsets.zero,
                              ),
                              RadioListTile<TicketPriority>(
                                title: const Text('High'),
                                subtitle: const Text('Urgent - needed ASAP'),
                                value: TicketPriority.high,
                                groupValue: _urgencyLevel,
                                onChanged: (value) => setState(() => _urgencyLevel = value!),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildWhatHappensNext(responseTime),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
                _buildSubmitButton(context, primaryColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isIT) {
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
                  isIT ? 'New IT Request' : 'New Technical Request',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray900,
                  ),
                ),
                const Text(
                  'Fill in the details below',
                  style: TextStyle(fontSize: 12, color: AppColors.gray500),
                ),
              ],
            ),
          ),
        ],
      ),
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
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.gray900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildWhatHappensNext(String responseTime) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border.all(color: Colors.blue.shade200),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info, color: Colors.blue, size: 24),
              SizedBox(width: 8),
              Text(
                'What happens next?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoItem('Your request will be reviewed by our support team'),
          _buildInfoItem('You\'ll receive a ticket number for tracking'),
          _buildInfoItem('Support staff will contact you via chat or email'),
          _buildInfoItem('Average response time: $responseTime'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(fontSize: 14, color: Colors.blue.shade700),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.gray200)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            if (_formKey.currentState == null || !_formKey.currentState!.validate())
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'Please fill in all required fields',
                  style: TextStyle(fontSize: 12, color: Colors.red),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MyRequests()),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${widget.category} request submitted successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Submit Request',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

