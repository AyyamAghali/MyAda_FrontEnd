import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/support_ticket.dart';
import '../../utils/constants.dart';
import '../../widgets/responsive_container.dart';
import '../../widgets/unified_media_picker.dart';
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
  final _otherCategoryController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  TicketPriority _urgencyLevel = TicketPriority.low; // Default to "Not Urgent"
  List<String> _attachments = [];
  bool _isOtherCategorySelected = false;

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
    _otherCategoryController.dispose();
    _locationController.dispose();
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
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildNumberedField(
                          number: 1,
                          label: 'Issue Category *',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: _categoryController,
                                decoration: InputDecoration(
                                  hintText: 'Select category',
                                  filled: true,
                                  fillColor: AppColors.gray50,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: AppColors.gray200),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: AppColors.gray200),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  hintStyle: TextStyle(color: AppColors.gray400.withOpacity(0.7), fontSize: 14),
                                  suffixIcon: PopupMenuButton<String>(
                                    icon: Icon(Icons.keyboard_arrow_down, color: AppColors.gray400, size: 20),
                                    onSelected: (value) {
                                      setState(() {
                                        _categoryController.text = value;
                                        _isOtherCategorySelected = value == 'Other';
                                        if (!_isOtherCategorySelected) {
                                          _otherCategoryController.clear();
                                        }
                                      });
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
                                style: const TextStyle(fontSize: 15, color: AppColors.gray900),
                                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                              ),
                              if (_isOtherCategorySelected) ...[
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _otherCategoryController,
                                  decoration: InputDecoration(
                                    hintText: 'Please specify the category',
                                    prefixIcon: const Icon(Icons.edit, color: AppColors.primary, size: 20),
                                    filled: true,
                                    fillColor: AppColors.gray50,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: AppColors.gray200),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: AppColors.gray200),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    hintStyle: TextStyle(color: AppColors.gray400.withOpacity(0.7), fontSize: 14),
                                  ),
                                  style: const TextStyle(fontSize: 15, color: AppColors.gray900),
                                  validator: (value) {
                                    if (_isOtherCategorySelected && (value == null || value.isEmpty)) {
                                      return 'Please specify the category';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildNumberedField(
                          number: 2,
                          label: 'Location *',
                          child: TextFormField(
                            controller: _locationController,
                            decoration: InputDecoration(
                              hintText: 'Enter location',
                              prefixIcon: const Icon(Icons.location_on, color: AppColors.primary, size: 20),
                              filled: true,
                              fillColor: AppColors.gray50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: AppColors.gray200),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: AppColors.gray200),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: AppColors.primary, width: 2),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              hintStyle: TextStyle(color: AppColors.gray400.withOpacity(0.7), fontSize: 14),
                            ),
                            style: const TextStyle(fontSize: 15, color: AppColors.gray900),
                            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildNumberedField(
                          number: 3,
                          label: 'Detailed Description *',
                          child: TextFormField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              hintText: 'Provide as much detail as possible about the issue...',
                              helperText: 'Include error messages, what you were doing when the issue occurred, etc.',
                              filled: true,
                              fillColor: AppColors.gray50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: AppColors.gray200),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: AppColors.gray200),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: AppColors.primary, width: 2),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              hintStyle: TextStyle(color: AppColors.gray400.withOpacity(0.7), fontSize: 14),
                              helperStyle: TextStyle(fontSize: 11, color: AppColors.gray500),
                            ),
                            style: const TextStyle(fontSize: 15, color: AppColors.gray900),
                            maxLines: 5,
                            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildNumberedField(
                          number: 4,
                          label: 'Attachments (Optional)',
                          child: UnifiedMediaPicker(
                            label: 'Add Photo or Video',
                            icon: Icons.add_photo_alternate,
                            showVideoOption: true,
                            onCameraSelected: () async {
                              final picker = ImagePicker();
                              final image = await picker.pickImage(source: ImageSource.camera);
                              if (image != null) {
                                setState(() => _attachments.add(image.path));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Photo added (mock)')),
                                );
                              }
                            },
                            onPhotoSelected: () async {
                              final picker = ImagePicker();
                              final image = await picker.pickImage(source: ImageSource.gallery);
                              if (image != null) {
                                setState(() => _attachments.add(image.path));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Photo added (mock)')),
                                );
                              }
                            },
                            onVideoSelected: () {
                              setState(() => _attachments.add('video_${_attachments.length}.mp4'));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Video added (mock)')),
                              );
                            },
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
                        const SizedBox(height: 12),
                        _buildNumberedField(
                          number: 5,
                          label: 'Urgency Level *',
                          child: Column(
                            children: [
                              RadioListTile<TicketPriority>(
                                title: const Text('Not Urgent', style: TextStyle(fontSize: 14)),
                                subtitle: const Text('Can wait 24+ hours', style: TextStyle(fontSize: 12)),
                                value: TicketPriority.low,
                                groupValue: _urgencyLevel,
                                onChanged: (value) => setState(() => _urgencyLevel = value!),
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                              ),
                              RadioListTile<TicketPriority>(
                                title: const Text('Urgent', style: TextStyle(fontSize: 14)),
                                subtitle: const Text('Needed ASAP', style: TextStyle(fontSize: 12)),
                                value: TicketPriority.high,
                                groupValue: _urgencyLevel,
                                onChanged: (value) => setState(() => _urgencyLevel = value!),
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildWhatHappensNext(responseTime),
                        const SizedBox(height: 16),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.white,
      width: double.infinity,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.gray900, size: 18),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isIT ? 'New IT Request' : 'New Technical Request',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    number.toString(),
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildWhatHappensNext(String responseTime) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.blue.shade50.withOpacity(0.6),
        border: Border.all(color: Colors.blue.shade200.withOpacity(0.5), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.info_outline, color: Colors.blue, size: 16),
              ),
              const SizedBox(width: 10),
              const Text(
                'What happens next?',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
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
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 11, color: Colors.blue.shade700, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, Color primaryColor) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_formKey.currentState == null || !_formKey.currentState!.validate())
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Please fill in all required fields',
                  style: TextStyle(fontSize: 11, color: Colors.red.shade700),
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
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Submit Request',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

