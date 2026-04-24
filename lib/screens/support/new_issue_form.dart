import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/support_ticket.dart';
import '../../services/auth_service.dart';
import '../../services/support_service.dart';
import '../../utils/constants.dart';
import '../../widgets/responsive_container.dart';
import '../../widgets/support_location_picker.dart';
import '../../widgets/unified_media_picker.dart';
import 'my_requests.dart';

class NewIssueForm extends StatefulWidget {
  final String category; // 'IT' or 'FM'

  const NewIssueForm({super.key, required this.category});

  @override
  State<NewIssueForm> createState() => _NewIssueFormState();
}

class _NewIssueFormState extends State<NewIssueForm> {
  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();
  final _otherCategoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  TicketPriority _urgencyLevel = TicketPriority.low; // Default to "Not Urgent"
  List<String> _attachments = [];
  bool _isOtherCategorySelected = false;
  late String _module; // IT | FM
  SupportLocationValue? _locationValue;
  final SupportService _supportService = SupportService();
  List<SupportCategoryOption> _categoryOptions = const [];
  SupportCategoryOption? _selectedCategory;
  bool _isLoadingCategories = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _categoryController.dispose();
    _otherCategoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _module = widget.category == 'FM' ? 'FM' : 'IT';
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoadingCategories = true);
    try {
      final categories = await _supportService.fetchCategories(module: _module);
      if (!mounted) return;
      setState(() {
        _categoryOptions = categories;
        final currentText = _categoryController.text.trim();
        if (currentText.isEmpty) {
          _selectedCategory = categories.isNotEmpty ? categories.first : null;
          _categoryController.text = _selectedCategory?.name ?? '';
          _isOtherCategorySelected = (_selectedCategory?.name.toLowerCase() ?? '') == 'other';
        } else {
          SupportCategoryOption? selected;
          for (final c in categories) {
            if (c.name == currentText) {
              selected = c;
              break;
            }
          }
          _selectedCategory = selected;
        }
      });
    } catch (_) {
      // Keep manual fallback categories.
    } finally {
      if (mounted) setState(() => _isLoadingCategories = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIT = _module == 'IT';
    final responseTime = isIT ? '2-4 hours' : '4-8 hours';
    final primaryColor = isIT ? AppColors.primary : AppColors.secondary;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        top: false,
        child: ResponsiveContainer(
          backgroundColor: AppColors.backgroundLight,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildHeader(context, isIT),
                _buildProgressIndicator(),
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
                              _buildModuleSwitcher(primaryColor),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _categoryController,
                                decoration: InputDecoration(
                                  hintText: _isLoadingCategories ? 'Loading categories...' : 'Select category',
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
                                    enabled: !_isLoadingCategories,
                                    onSelected: (value) {
                                      SupportCategoryOption? selected;
                                      for (final c in _categoryOptions) {
                                        if (c.name == value) {
                                          selected = c;
                                          break;
                                        }
                                      }
                                      setState(() {
                                        _categoryController.text = value;
                                        _selectedCategory = selected;
                                        _isOtherCategorySelected = value == 'Other';
                                        if (!_isOtherCategorySelected) {
                                          _otherCategoryController.clear();
                                        }
                                      });
                                    },
                                    itemBuilder: (context) {
                                      final names = _categoryOptions.isNotEmpty
                                          ? _categoryOptions.map((c) => c.name).toList(growable: false)
                                          : const <String>[
                                              'Wi-Fi & Network',
                                              'Email & Office 365',
                                              'Password Reset',
                                              'Projector/Display',
                                              'Printer/Scanner',
                                              'Software Installation',
                                              'Computer Repair',
                                              'Other',
                                            ];
                                      return names.map((cat) {
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
                                    prefixIcon: Icon(Icons.edit, color: primaryColor, size: 20),
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
                                      borderSide: BorderSide(color: primaryColor, width: 2),
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
                          child: SupportLocationPicker(
                            helperText: 'First choose Building or Campus, then add details.',
                            initialValue: _locationValue,
                            onChanged: (v) => setState(() => _locationValue = v),
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
                            label: 'Add Photo',
                            icon: Icons.add_photo_alternate,
                            showVideoOption: false,
                            onCameraSelected: () async {
                              final picker = ImagePicker();
                              final image = await picker.pickImage(source: ImageSource.camera);
                              if (image != null) {
                                setState(() => _attachments.add(image.path));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Photo added')),
                                );
                              }
                            },
                            onPhotoSelected: () async {
                              final picker = ImagePicker();
                              final image = await picker.pickImage(source: ImageSource.gallery);
                              if (image != null) {
                                setState(() => _attachments.add(image.path));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Photo added')),
                                );
                              }
                            },
                            onVideoSelected: () {},
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
                                activeColor: primaryColor,
                              ),
                              RadioListTile<TicketPriority>(
                                title: const Text('Urgent', style: TextStyle(fontSize: 14)),
                                subtitle: const Text('Needed ASAP', style: TextStyle(fontSize: 12)),
                                value: TicketPriority.high,
                                groupValue: _urgencyLevel,
                                onChanged: (value) => setState(() => _urgencyLevel = value!),
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                activeColor: primaryColor,
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
    final top = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(12, top + 8, 16, 8),
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
                  isIT ? 'Create New IT Request' : 'Create New FM Request',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray900,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Step 1 of 1',
                  style: TextStyle(fontSize: 12, color: AppColors.gray500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      color: AppColors.white,
      width: double.infinity,
      child: Row(
        children: List.generate(4, (index) {
          return Expanded(
            child: Container(
              height: 3,
              margin: EdgeInsets.only(right: index < 3 ? 6 : 0),
              decoration: BoxDecoration(
                color: index == 0 ? AppColors.primary : AppColors.gray200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildModuleSwitcher(Color primaryColor) {
    Widget pill({
      required String label,
      required IconData icon,
      required bool selected,
      required VoidCallback onTap,
    }) {
      return Expanded(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOutCubic,
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: selected ? primaryColor.withOpacity(0.10) : AppColors.gray50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected ? primaryColor.withOpacity(0.45) : AppColors.gray200,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 16, color: selected ? primaryColor : AppColors.gray600),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                      color: selected ? primaryColor : AppColors.gray700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        pill(
          label: 'IT & Network',
          icon: Icons.computer_outlined,
          selected: _module == 'IT',
          onTap: () {
            if (_module == 'IT') return;
            setState(() {
              _module = 'IT';
              _selectedCategory = null;
              _categoryController.clear();
              _otherCategoryController.clear();
              _isOtherCategorySelected = false;
            });
            _loadCategories();
          },
        ),
        const SizedBox(width: 10),
        pill(
          label: 'Facilities (FM)',
          icon: Icons.build_outlined,
          selected: _module == 'FM',
          onTap: () {
            if (_module == 'FM') return;
            setState(() {
              _module = 'FM';
              _selectedCategory = null;
              _categoryController.clear();
              _otherCategoryController.clear();
              _isOtherCategorySelected = false;
            });
            _loadCategories();
          },
        ),
      ],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.gray500, size: 16),
              SizedBox(width: 6),
              Text(
                'What happens next?',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gray700),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _buildInfoItem('Your request will be reviewed by our support team'),
          _buildInfoItem('You\'ll receive a ticket number for tracking'),
          _buildInfoItem('Support staff will contact you via chat or call'),
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
            style: TextStyle(fontSize: 12, color: AppColors.gray500),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: AppColors.gray500, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitRequest(BuildContext context) async {
    final ok = _formKey.currentState?.validate() ?? false;
    final locOk = _locationValue?.isComplete ?? false;
    if (!ok) return;
    if (!locOk) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please complete the Location section'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    final categoryName = _categoryController.text.trim();
    if (categoryName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await AuthService.instance.loadSession();
      final memberId = AuthService.instance.studentId;
      if (memberId == null || memberId.isEmpty) {
        throw Exception('Authentication required. Please sign in again.');
      }

      var categoryId = _selectedCategory?.id ?? 0;
      if (categoryId <= 0) {
        final options = await _supportService.fetchCategories(module: _module);
        for (final c in options) {
          if (c.name.toLowerCase() == categoryName.toLowerCase()) {
            categoryId = c.id;
            break;
          }
        }
      }
      if (categoryId <= 0) {
        throw Exception('Selected category is not available on backend.');
      }

      await _supportService.createRequest(
        memberId: memberId,
        area: _module,
        categoryId: categoryId,
        location: _locationValue!,
        description: _descriptionController.text.trim(),
        urgency: _urgencyLevel,
        attachmentPaths: _attachments,
      );

      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyRequests()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$_module request submitted successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Required fields are marked with *',
                style: TextStyle(fontSize: 11, color: AppColors.gray500),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : () => _submitRequest(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                        ),
                      )
                    : const Text(
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

