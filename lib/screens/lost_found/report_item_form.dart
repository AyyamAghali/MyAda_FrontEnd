import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/lost_item.dart';
import '../../services/lost_found_service.dart';
import '../../utils/constants.dart';
import '../../widgets/modern_select_sheet.dart';

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
  final _service = LostFoundService();
  final _picker = ImagePicker();

  String _itemName = '';
  ItemCategory _category = ItemCategory.electronics;
  String _description = '';

  // Real XFile picks (works on iOS/Android/Web)
  List<XFile> _pickedImages = [];

  String _locationType = 'building';
  String? _selectedBuilding;
  String? _isRoomSelection;
  String? _selectedRoom;
  String _locationDetails = '';
  String _campusLocation = '';

  bool _isSubmitting = false;

  static const List<String> _buildings = [
    'Main Building',
    'Library',
    'Sports Complex',
    'Building C',
    'Cafeteria',
  ];

  static const Map<String, List<String>> _buildingRooms = {
    'Main Building': ['101', '102', '103', '201', '202', '203', '301', '302', '303', 'A101', 'A102', 'A201', 'A301'],
    'Library': ['L1', 'L2', 'L3', 'Reading Hall', 'Study Room 1', 'Study Room 2', 'Study Room 3'],
    'Sports Complex': ['Gym', 'Pool Area', 'S101', 'S102', 'S201', 'Locker Room A', 'Locker Room B'],
    'Building C': ['C101', 'C102', 'C103', 'C201', 'C202', 'C203', 'C301', 'C302'],
    'Cafeteria': ['Main Hall', 'Kitchen', 'Storage'],
  };

  // ── Helpers ─────────────────────────────────────────────────────────

  String get _resolvedLocation {
    if (_locationType == 'campus') return _campusLocation.trim();
    final parts = <String>[];
    if (_selectedBuilding != null) parts.add(_selectedBuilding!);
    if (_isRoomSelection == 'yes' && _selectedRoom != null) {
      parts.add('Room $_selectedRoom');
    } else if (_isRoomSelection == 'no' && _locationDetails.isNotEmpty) {
      parts.add(_locationDetails.trim());
    }
    return parts.join(' - ');
  }

  InputDecoration _field({String? label, String? hint, Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.gray50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.gray200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.gray200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      labelStyle: const TextStyle(color: AppColors.gray600, fontSize: 14),
      hintStyle: TextStyle(
          color: AppColors.gray400.withOpacity(0.7), fontSize: 14),
    );
  }

  // ── Image picking ────────────────────────────────────────────────────

  Future<void> _pickFromCamera() async {
    if (_pickedImages.length >= 5) return;
    final xfile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (xfile != null && mounted) {
      setState(() => _pickedImages.add(xfile));
    }
  }

  Future<void> _pickFromGallery() async {
    if (_pickedImages.length >= 5) return;
    final xfile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (xfile != null && mounted) {
      setState(() => _pickedImages.add(xfile));
    }
  }

  void _showPhotoPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.gray300,
                    borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Icon(Icons.camera_alt,
                      color: AppColors.primary, size: 20),
                ),
                title: const Text('Take Photo',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickFromCamera();
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Icon(Icons.photo_library,
                      color: AppColors.primary, size: 20),
                ),
                title: const Text('Choose from Library',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickFromGallery();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ── Submit ────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final photosRequired = !widget.isLostItem;
    if (photosRequired && _pickedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please add at least one photo of the found item'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      if (widget.isLostItem) {
        await _service.reportLost(
          title: _itemName.trim(),
          location: _resolvedLocation,
          description: _description.trim(),
          category: _catName(_category),
          locationType: _locationType,
          building: _locationType == 'building' ? _selectedBuilding : null,
          roomArea: _locationType == 'building'
              ? (_isRoomSelection == 'yes'
                  ? (_selectedRoom != null ? 'Room $_selectedRoom' : null)
                  : _locationDetails.trim())
              : null,
          campusLocation:
              _locationType == 'campus' ? _campusLocation.trim() : null,
          collectionPlace: 'Security Desk',
          imageFile: _pickedImages.isNotEmpty ? _pickedImages.first : null,
        );
      } else {
        await _service.reportFound(
          title: _itemName.trim(),
          location: _resolvedLocation,
          description: _description.trim(),
          category: _catName(_category),
          locationType: _locationType,
          building: _locationType == 'building' ? _selectedBuilding : null,
          roomArea: _locationType == 'building'
              ? (_isRoomSelection == 'yes'
                  ? (_selectedRoom != null ? 'Room $_selectedRoom' : null)
                  : _locationDetails.trim())
              : null,
          campusLocation:
              _locationType == 'campus' ? _campusLocation.trim() : null,
          collectionPlace: 'Security Desk',
          imageFile: _pickedImages.isNotEmpty ? _pickedImages.first : null,
        );
      }

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(kLostFoundUseMockData
              ? 'Item submitted (mock – no data was sent to server)'
              : 'Item submitted for review'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } on LostFoundException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final photosRequired = !widget.isLostItem;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: AppColors.gray900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isLostItem ? 'Report Lost Item' : 'Report Found Item',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900),
            ),
            Text(
              widget.isLostItem
                  ? 'Report your lost item to help others find it'
                  : 'Help someone find their lost item',
              style: const TextStyle(fontSize: 12, color: AppColors.gray500),
            ),
          ],
        ),
        titleSpacing: 0,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  _infoBanner(),
                  const SizedBox(height: 24),

                  _sectionLabel('1', 'Basic Information'),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: _field(
                        label: 'Item Name *',
                        hint: 'e.g., Black Leather Wallet'),
                    style: const TextStyle(
                        fontSize: 15, color: AppColors.gray900),
                    onChanged: (v) => setState(() => _itemName = v),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () async {
                      final result = await showModernSelectSheet<ItemCategory>(
                        context: context,
                        title: 'Select Category',
                        selectedValue: _category,
                        options: ItemCategory.values
                            .map((c) => SelectOption(
                                value: c, label: _catName(c)))
                            .toList(),
                      );
                      if (result != null) setState(() => _category = result);
                    },
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: _field(
                          label: 'Category *',
                          suffix: const Icon(Icons.keyboard_arrow_down_rounded,
                              color: AppColors.gray400, size: 22),
                        ),
                        controller: TextEditingController(text: _catName(_category)),
                        style: const TextStyle(
                            fontSize: 15, color: AppColors.gray900),
                      ),
                    ),
                  ),

                  _divider(),

                  _sectionLabel('2', 'Location'),
                  const SizedBox(height: 8),
                  _locationBody(),

                  _divider(),

                  _sectionLabel('3', 'Description'),
                  const SizedBox(height: 4),
                  const Text('Describe the item to help identify it.',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.gray500)),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: _field(hint: 'Describe the item...'),
                    style: const TextStyle(
                        fontSize: 15, color: AppColors.gray900),
                    minLines: 1,
                    maxLines: 5,
                    maxLength: 500,
                    onChanged: (v) => setState(() => _description = v),
                  ),

                  _divider(),

                  _sectionLabel(
                      '4', photosRequired ? 'Photos *' : 'Photos'),
                  const SizedBox(height: 10),
                  _photosBody(),
                ],
              ),
            ),
            _submitBar(),
          ],
        ),
      ),
    );
  }

  // ── Widgets ───────────────────────────────────────────────────────────

  Widget _infoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.blue.shade50.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: Colors.blue.shade200.withOpacity(0.4), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade400, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              kLostFoundUseMockData
                  ? 'Mock mode – submissions will not be sent to the server.'
                  : 'All submissions are reviewed by staff before being published.',
              style: TextStyle(
                  fontSize: 12, color: Colors.blue.shade700, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String number, String title) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(number,
                style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.gray900)),
      ],
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Divider(color: AppColors.gray200, height: 1),
    );
  }

  // ── Location ────────────────────────────────────────────────────────

  Widget _locationBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        Row(
          children: [
            _LocationRadio(
                label: 'Building',
                selected: _locationType == 'building',
                onTap: () => setState(() {
                      _locationType = 'building';
                      _campusLocation = '';
                    })),
            const SizedBox(width: 24),
            _LocationRadio(
                label: 'Campus',
                selected: _locationType == 'campus',
                onTap: () => setState(() {
                      _locationType = 'campus';
                      _selectedBuilding = null;
                      _isRoomSelection = null;
                      _selectedRoom = null;
                      _locationDetails = '';
                    })),
          ],
        ),
        const SizedBox(height: 14),
        if (_locationType == 'building') ...[
          GestureDetector(
            onTap: () async {
              final result = await showModernSelectSheet<String>(
                context: context,
                title: 'Select Building',
                selectedValue: _selectedBuilding,
                options: _buildings
                    .map((b) => SelectOption(value: b, label: b))
                    .toList(),
              );
              if (result != null) {
                setState(() {
                  _selectedBuilding = result;
                  _isRoomSelection = null;
                  _selectedRoom = null;
                  _locationDetails = '';
                });
              }
            },
            child: AbsorbPointer(
              child: TextFormField(
                controller: TextEditingController(
                    text: _selectedBuilding ?? ''),
                decoration: _field(
                  label: 'Building',
                  hint: 'Select building',
                  suffix: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: AppColors.gray400, size: 22),
                ),
                style: const TextStyle(
                    fontSize: 15, color: AppColors.gray900),
              ),
            ),
          ),
          if (_selectedBuilding != null) ...[
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () async {
                final result = await showModernSelectSheet<String>(
                  context: context,
                  title: 'Is it a room?',
                  selectedValue: _isRoomSelection,
                  options: const [
                    SelectOption(value: 'yes', label: 'Yes, it is a room'),
                    SelectOption(value: 'no', label: 'No, another area'),
                  ],
                );
                if (result != null) {
                  setState(() {
                    _isRoomSelection = result;
                    _selectedRoom = null;
                    _locationDetails = '';
                  });
                }
              },
              child: AbsorbPointer(
                child: TextFormField(
                  controller: TextEditingController(
                    text: _isRoomSelection == 'yes'
                        ? 'Yes, it is a room'
                        : _isRoomSelection == 'no'
                            ? 'No, another area'
                            : '',
                  ),
                  decoration: _field(
                    label: 'Is it a room?',
                    hint: 'Select...',
                    suffix: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColors.gray400, size: 22),
                  ),
                  style: const TextStyle(
                      fontSize: 15, color: AppColors.gray900),
                ),
              ),
            ),
          ],
          if (_isRoomSelection == 'yes') ...[
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () async {
                final rooms = _buildingRooms[_selectedBuilding] ?? [];
                final result = await showModernSelectSheet<String>(
                  context: context,
                  title: 'Select Room',
                  selectedValue: _selectedRoom,
                  options: rooms
                      .map((r) => SelectOption(value: r, label: r))
                      .toList(),
                );
                if (result != null) {
                  setState(() => _selectedRoom = result);
                }
              },
              child: AbsorbPointer(
                child: TextFormField(
                  controller:
                      TextEditingController(text: _selectedRoom ?? ''),
                  decoration: _field(
                    label: 'Room',
                    hint: 'Select room',
                    suffix: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColors.gray400, size: 22),
                  ),
                  style: const TextStyle(
                      fontSize: 15, color: AppColors.gray900),
                ),
              ),
            ),
          ],
          if (_isRoomSelection == 'no') ...[
            const SizedBox(height: 14),
            TextFormField(
              decoration: _field(
                  label: 'Location details',
                  hint: 'e.g. Lobby near reception'),
              style: const TextStyle(
                  fontSize: 15, color: AppColors.gray900),
              onChanged: (v) => setState(() => _locationDetails = v),
            ),
          ],
        ],
        if (_locationType == 'campus')
          TextFormField(
            decoration: _field(
                label: 'Campus location',
                hint:
                    'Describe where on campus (e.g. main yard, parking area)'),
            style: const TextStyle(
                fontSize: 15, color: AppColors.gray900),
            minLines: 1,
            maxLines: 3,
            onChanged: (v) => setState(() => _campusLocation = v),
          ),
      ],
    );
  }

  // ── Photos ──────────────────────────────────────────────────────────

  Widget _photosBody() {
    if (_pickedImages.isEmpty) {
      return GestureDetector(
        onTap: _showPhotoPicker,
        child: Container(
          height: 56,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.gray50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gray300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate_outlined,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text('Add Photo',
                  style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ..._pickedImages.map((f) => _photoThumb(f)),
            if (_pickedImages.length < 5) _addMoreButton(),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '${_pickedImages.length} photo${_pickedImages.length > 1 ? 's' : ''} added',
          style: const TextStyle(fontSize: 12, color: AppColors.gray500),
        ),
      ],
    );
  }

  Widget _photoThumb(XFile file) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 80,
            height: 80,
            child: kIsWeb
                ? Image.network(file.path, fit: BoxFit.cover)
                : Image.file(File(file.path), fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: GestureDetector(
            onTap: () => setState(() => _pickedImages.remove(file)),
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: AppColors.gray900.withOpacity(0.75),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close,
                  size: 13, color: AppColors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _addMoreButton() {
    return GestureDetector(
      onTap: _showPhotoPicker,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.gray50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: AppColors.gray300,
              width: 1.5,
              style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline,
                color: AppColors.primary, size: 22),
            const SizedBox(height: 2),
            Text('Add',
                style: TextStyle(
                    fontSize: 10,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  // ── Submit bar ────────────────────────────────────────────────────────

  Widget _submitBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, -2)),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Submit for Review',
                    style: TextStyle(
                        color: AppColors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }

  String _catName(ItemCategory c) {
    switch (c) {
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

// ══════════════════════════════════════════════════════════════════════

class _LocationRadio extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LocationRadio({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : AppColors.gray400,
                  width: 2),
            ),
            child: selected
                ? Center(
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 7),
          Text(label,
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w400,
                color: selected
                    ? AppColors.gray900
                    : AppColors.gray600,
              )),
        ],
      ),
    );
  }
}
