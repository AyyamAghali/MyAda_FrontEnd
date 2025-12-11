import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/responsive_container.dart';
import '../../widgets/unified_photo_picker.dart';
import '../../models/lost_item.dart';

class ReportItemForm extends StatefulWidget {
  final bool isLostItem;
  
  const ReportItemForm({
    super.key,
    this.isLostItem = false,
  });

  @override
  State<ReportItemForm> createState() => _ReportItemFormState();
}

class _ReportItemFormState extends State<ReportItemForm> {
  final _formKey = GlobalKey<FormState>();
  String itemName = '';
  ItemCategory category = ItemCategory.electronics;
  String location = '';
  String building = '';
  String floor = '';
  String room = '';
  String description = '';
  String color = '';
  String brand = '';
  DateTime dateFound = DateTime.now();
  TimeOfDay timeFound = TimeOfDay.now();
  List<String> imagePreviews = [];

  final List<String> buildings = [
    'Main Building',
    'Library',
    'Sports Complex',
    'Building C',
    'Cafeteria',
    'Parking Lot'
  ];

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
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoBanner(),
                              const SizedBox(height: 16),
                              _buildBasicInfoSection(),
                              const SizedBox(height: 12),
                              _buildLocationSection(),
                              const SizedBox(height: 12),
                              _buildDateTimeSection(),
                              const SizedBox(height: 12),
                              _buildDescriptionSection(),
                              const SizedBox(height: 12),
                              _buildPhotosSection(),
                              const SizedBox(height: 12),
                              _buildContactSection(),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                      _buildSubmitButton(),
                    ],
                  ),
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
                  widget.isLostItem ? 'Report Lost Item' : 'Report Found Item',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.isLostItem
                      ? 'Report your lost item to help others find it'
                      : 'Help someone find their lost item',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.gray500,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.blue.shade50.withOpacity(0.6),
        border: Border.all(color: Colors.blue.shade200.withOpacity(0.5), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Verification Required',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'All submissions are reviewed by staff before being published.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blue.shade700,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildSection(
      title: 'Basic Information',
      number: 1,
      children: [
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Item Name *',
            hintText: 'e.g., Black Leather Wallet',
            filled: true,
            fillColor: AppColors.gray50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.gray200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.gray200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            labelStyle: const TextStyle(color: AppColors.gray600, fontSize: 14),
            hintStyle: TextStyle(color: AppColors.gray400, fontSize: 14),
          ),
          style: const TextStyle(fontSize: 15, color: AppColors.gray900),
          onChanged: (value) => setState(() => itemName = value),
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<ItemCategory>(
          value: category,
          decoration: InputDecoration(
            labelText: 'Category *',
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
            labelStyle: const TextStyle(color: AppColors.gray600, fontSize: 14),
            suffixIcon: Icon(Icons.keyboard_arrow_down, color: AppColors.gray400, size: 20),
          ),
          style: const TextStyle(fontSize: 15, color: AppColors.gray900),
          dropdownColor: AppColors.white,
          iconSize: 20,
          items: ItemCategory.values.map((cat) {
            return DropdownMenuItem(
              value: cat,
              child: Text(_getCategoryName(cat)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => category = value);
            }
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Color',
                  hintText: 'e.g., Black',
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
                  labelStyle: const TextStyle(color: AppColors.gray600, fontSize: 14),
                  hintStyle: TextStyle(color: AppColors.gray400.withOpacity(0.7), fontSize: 14),
                ),
                style: const TextStyle(fontSize: 15, color: AppColors.gray900),
                onChanged: (value) => setState(() => color = value),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Brand',
                  hintText: 'e.g., Apple',
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
                  labelStyle: const TextStyle(color: AppColors.gray600, fontSize: 14),
                  hintStyle: TextStyle(color: AppColors.gray400.withOpacity(0.7), fontSize: 14),
                ),
                style: const TextStyle(fontSize: 15, color: AppColors.gray900),
                onChanged: (value) => setState(() => brand = value),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return _buildSection(
      title: 'Location Details',
      number: 2,
      children: [
        DropdownButtonFormField<String>(
          value: building.isEmpty ? null : building,
          decoration: InputDecoration(
            labelText: 'Building *',
            filled: true,
            fillColor: AppColors.gray50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.gray200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.gray200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            labelStyle: const TextStyle(color: AppColors.gray600, fontSize: 14),
          ),
          style: const TextStyle(fontSize: 15, color: AppColors.gray900),
          dropdownColor: AppColors.white,
          items: buildings.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
          onChanged: (value) => setState(() => building = value ?? ''),
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Floor',
                  hintText: 'e.g., 2',
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
                  labelStyle: const TextStyle(color: AppColors.gray600, fontSize: 14),
                  hintStyle: TextStyle(color: AppColors.gray400.withOpacity(0.7), fontSize: 14),
                ),
                style: const TextStyle(fontSize: 15, color: AppColors.gray900),
                keyboardType: TextInputType.number,
                onChanged: (value) => setState(() => floor = value),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Room/Area',
                  hintText: 'e.g., A120',
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
                  labelStyle: const TextStyle(color: AppColors.gray600, fontSize: 14),
                  hintStyle: TextStyle(color: AppColors.gray400.withOpacity(0.7), fontSize: 14),
                ),
                style: const TextStyle(fontSize: 15, color: AppColors.gray900),
                onChanged: (value) => setState(() => room = value),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          decoration: InputDecoration(
            labelText: widget.isLostItem ? 'Last Known Location *' : 'Specific Location *',
            hintText: widget.isLostItem 
                ? 'e.g., Library, Cafeteria, Parking Lot'
                : 'e.g., Near the entrance, on table',
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
            labelStyle: const TextStyle(color: AppColors.gray600, fontSize: 14),
            hintStyle: TextStyle(color: AppColors.gray400.withOpacity(0.7), fontSize: 14),
          ),
          style: const TextStyle(fontSize: 15, color: AppColors.gray900),
          onChanged: (value) => setState(() => location = value),
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildDateTimeSection() {
    return _buildSection(
      title: widget.isLostItem ? 'When did you lose it?' : 'When was it found?',
      number: 3,
      children: [
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: dateFound,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => dateFound = date);
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date',
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
                    labelStyle: const TextStyle(color: AppColors.gray600, fontSize: 14),
                  ),
                  child: Text(
                    '${dateFound.year}-${dateFound.month.toString().padLeft(2, '0')}-${dateFound.day.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 15, color: AppColors.gray900),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: InkWell(
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: timeFound,
                  );
                  if (time != null) {
                    setState(() => timeFound = time);
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Time',
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
                    labelStyle: const TextStyle(color: AppColors.gray600, fontSize: 14),
                  ),
                  child: Text(
                    timeFound.format(context),
                    style: const TextStyle(fontSize: 15, color: AppColors.gray900),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return _buildSection(
      title: 'Additional Details',
      number: 4,
      children: [
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Description',
            hintText: 'Add any distinguishing features, condition, or other details...',
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
            labelStyle: const TextStyle(color: AppColors.gray600, fontSize: 14),
            hintStyle: TextStyle(color: AppColors.gray400.withOpacity(0.7), fontSize: 14),
          ),
          style: const TextStyle(fontSize: 15, color: AppColors.gray900),
          maxLines: 4,
          maxLength: 500,
          onChanged: (value) => setState(() => description = value),
        ),
      ],
    );
  }

  Widget _buildPhotosSection() {
    return _buildSection(
      title: 'Photos',
      number: 5,
      children: [
        if (imagePreviews.isEmpty)
          UnifiedPhotoPicker(
            label: 'Add Photo',
            icon: Icons.add_photo_alternate,
            backgroundColor: AppColors.gray50,
            iconColor: AppColors.primary,
            textColor: AppColors.primary,
            onCameraSelected: () {
              setState(() {
                imagePreviews.add('mock_camera');
              });
            },
            onPhotoSelected: () {
              setState(() {
                imagePreviews.add('mock_upload');
              });
            },
          )
        else
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ...imagePreviews.map((img) => Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.gray100,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.gray200),
                        ),
                        child: const Icon(Icons.image, color: AppColors.gray400, size: 32),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.gray900.withOpacity(0.8),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.close, size: 16, color: AppColors.white),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                            onPressed: () {
                              setState(() {
                                imagePreviews.remove(img);
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  )),
              if (imagePreviews.length < 5)
                InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (BuildContext context) {
                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: SafeArea(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 12),
                                  width: 40,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: AppColors.gray300,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ListTile(
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Icon(
                                      Icons.camera_alt,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                  ),
                                  title: const Text(
                                    'Take Photo',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    setState(() {
                                      imagePreviews.add('mock_camera');
                                    });
                                  },
                                ),
                                ListTile(
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Icon(
                                      Icons.photo_library,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                  ),
                                  title: const Text(
                                    'Choose from Library',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    setState(() {
                                      imagePreviews.add('mock_upload');
                                    });
                                  },
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.gray50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.gray300, width: 1.5, style: BorderStyle.solid),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle_outline, color: AppColors.primary, size: 28),
                        const SizedBox(height: 4),
                        Text(
                          'Add More',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        if (imagePreviews.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${imagePreviews.length} photo${imagePreviews.length > 1 ? 's' : ''} added',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.gray500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContactSection() {
    return _buildSection(
      title: 'Your Contact Information',
      number: 6,
      children: [
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Your Name',
            hintText: 'e.g., John Doe',
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
            labelStyle: const TextStyle(color: AppColors.gray600, fontSize: 14),
            hintStyle: TextStyle(color: AppColors.gray400.withOpacity(0.7), fontSize: 14),
          ),
          style: const TextStyle(fontSize: 15, color: AppColors.gray900),
        ),
        const SizedBox(height: 12),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Phone Number',
            hintText: 'e.g., +994 50 123 45 67',
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
            labelStyle: const TextStyle(color: AppColors.gray600, fontSize: 14),
            hintStyle: TextStyle(color: AppColors.gray400.withOpacity(0.7), fontSize: 14),
          ),
          style: const TextStyle(fontSize: 15, color: AppColors.gray900),
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required int number,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
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
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Item submitted for review'),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Submit for Review',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getCategoryName(ItemCategory category) {
    switch (category) {
      case ItemCategory.electronics:
        return 'Electronics';
      case ItemCategory.documents:
        return 'Documents';
      case ItemCategory.clothing:
        return 'Clothing';
      case ItemCategory.accessories:
        return 'Accessories';
      case ItemCategory.other:
        return 'Other';
    }
  }
}

