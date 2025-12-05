import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/responsive_container.dart';
import '../../models/lost_item.dart';

class ReportItemForm extends StatefulWidget {
  const ReportItemForm({super.key});

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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      _buildInfoBanner(),
                      const SizedBox(height: 24),
                      _buildBasicInfoSection(),
                      const SizedBox(height: 24),
                      _buildLocationSection(),
                      const SizedBox(height: 24),
                      _buildDateTimeSection(),
                      const SizedBox(height: 24),
                      _buildDescriptionSection(),
                      const SizedBox(height: 24),
                      _buildPhotosSection(),
                      const SizedBox(height: 24),
                      _buildContactSection(),
                      const SizedBox(height: 32),
                      _buildSubmitButton(),
                    ],
                  ),
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
      padding: const EdgeInsets.all(24),
      color: AppColors.white,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.gray700),
            onPressed: () => Navigator.pop(context),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Report Found Item',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const Text(
                'Help someone find their lost item',
                style: TextStyle(fontSize: 12, color: AppColors.gray500),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Verification Required',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'All submissions are reviewed by staff before being published.',
                  style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
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
          decoration: const InputDecoration(
            labelText: 'Item Name *',
            hintText: 'e.g., Black Leather Wallet',
          ),
          onChanged: (value) => setState(() => itemName = value),
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<ItemCategory>(
          value: category,
          decoration: const InputDecoration(labelText: 'Category *'),
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
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(labelText: 'Color'),
                onChanged: (value) => setState(() => color = value),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(labelText: 'Brand'),
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
          decoration: const InputDecoration(labelText: 'Building *'),
          items: buildings.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
          onChanged: (value) => setState(() => building = value ?? ''),
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(labelText: 'Floor'),
                onChanged: (value) => setState(() => floor = value),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(labelText: 'Room/Area'),
                onChanged: (value) => setState(() => room = value),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Specific Location *',
            hintText: 'e.g., Near the entrance, on table',
          ),
          onChanged: (value) => setState(() => location = value),
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildDateTimeSection() {
    return _buildSection(
      title: 'When was it found?',
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
                  decoration: const InputDecoration(labelText: 'Date'),
                  child: Text(DateTime.now().toString().split(' ')[0]),
                ),
              ),
            ),
            const SizedBox(width: 16),
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
                  decoration: const InputDecoration(labelText: 'Time'),
                  child: Text(timeFound.format(context)),
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
          decoration: const InputDecoration(
            labelText: 'Description',
            hintText: 'Add any distinguishing features...',
          ),
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
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Mock adding a sample photo
                    setState(() {
                      imagePreviews.add('mock_camera');
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Mock photo captured (no real upload in this demo).')),
                    );
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Take Photo'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      imagePreviews.add('mock_upload');
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Mock photo uploaded (no real file handling).')),
                    );
                  },
                  icon: const Icon(Icons.upload),
                  label: const Text('Upload Photo'),
                ),
              ),
            ],
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
                          color: AppColors.gray200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.image),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () {
                            setState(() {
                              imagePreviews.remove(img);
                            });
                          },
                        ),
                      ),
                    ],
                  )),
              if (imagePreviews.length < 5)
                InkWell(
                  onTap: () {
                    setState(() {
                      imagePreviews.add('mock_additional');
                    });
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.gray300, style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add),
                  ),
                ),
            ],
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
          decoration: const InputDecoration(labelText: 'Your Name'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Phone Number'),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
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
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Item submitted for review (mock).')),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Submit for Review',
          style: TextStyle(color: AppColors.white, fontSize: 16),
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

