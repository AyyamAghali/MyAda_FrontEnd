import 'package:flutter/material.dart';
import '../utils/constants.dart';

enum SupportLocationType { building, campus }

class SupportLocationValue {
  final SupportLocationType type;
  final String? building;
  final bool? isRoom;
  final String? room;
  final String? details;

  const SupportLocationValue({
    required this.type,
    this.building,
    this.isRoom,
    this.room,
    this.details,
  });

  bool get isComplete {
    if (type == SupportLocationType.campus) {
      return (details ?? '').trim().isNotEmpty;
    }
    if ((building ?? '').trim().isEmpty) return false;
    if (isRoom == true) return (room ?? '').trim().isNotEmpty;
    if (isRoom == false) return (details ?? '').trim().isNotEmpty;
    return false;
  }

  String asDisplayString() {
    if (type == SupportLocationType.campus) {
      final d = (details ?? '').trim();
      return d.isEmpty ? 'Campus' : 'Campus - $d';
    }
    final b = (building ?? '').trim();
    if (b.isEmpty) return '';
    if (isRoom == true) {
      final r = (room ?? '').trim();
      return r.isEmpty ? b : '$b - Room $r';
    }
    final d = (details ?? '').trim();
    return d.isEmpty ? b : '$b - $d';
  }
}

class SupportLocationPicker extends StatefulWidget {
  final SupportLocationValue? initialValue;
  final ValueChanged<SupportLocationValue> onChanged;

  /// Shown under the field header; matches other forms.
  final String? helperText;

  const SupportLocationPicker({
    super.key,
    this.initialValue,
    required this.onChanged,
    this.helperText,
  });

  @override
  State<SupportLocationPicker> createState() => _SupportLocationPickerState();
}

class _SupportLocationPickerState extends State<SupportLocationPicker> {
  static const List<String> _buildings = [
    'Main Building',
    'Library',
    'Sports Complex',
    'Building C',
    'Cafeteria',
  ];

  static const Map<String, List<String>> _buildingRooms = {
    'Main Building': [
      '101',
      '102',
      '103',
      '201',
      '202',
      '203',
      '301',
      '302',
      '303',
      'A101',
      'A102',
      'A201',
      'A301',
    ],
    'Library': [
      'L1',
      'L2',
      'L3',
      'Reading Hall',
      'Study Room 1',
      'Study Room 2',
      'Study Room 3',
    ],
    'Sports Complex': [
      'Gym',
      'Pool Area',
      'S101',
      'S102',
      'S201',
      'Locker Room A',
      'Locker Room B',
    ],
    'Building C': ['C101', 'C102', 'C103', 'C201', 'C202', 'C203', 'C301', 'C302'],
    'Cafeteria': ['Main Hall', 'Kitchen', 'Storage'],
  };

  late SupportLocationType _type;
  String? _building;
  bool? _isRoom;
  String? _room;
  String _details = '';

  @override
  void initState() {
    super.initState();
    final v = widget.initialValue;
    _type = v?.type ?? SupportLocationType.building;
    _building = v?.building;
    _isRoom = v?.isRoom;
    _room = v?.room;
    _details = v?.details ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) => _emit());
  }

  void _emit() {
    widget.onChanged(
      SupportLocationValue(
        type: _type,
        building: _building,
        isRoom: _isRoom,
        room: _room,
        details: _details,
      ),
    );
  }

  InputDecoration _field({String? label, String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
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
      hintStyle: TextStyle(color: AppColors.gray400.withOpacity(0.7), fontSize: 14),
    );
  }

  Widget _radio({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
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
                color: selected ? AppColors.primary : AppColors.gray400,
                width: 2,
              ),
            ),
            child: selected
                ? Center(
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? AppColors.gray900 : AppColors.gray600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final helper = widget.helperText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _radio(
              label: 'Building',
              selected: _type == SupportLocationType.building,
              onTap: () => setState(() {
                _type = SupportLocationType.building;
                _details = '';
                _emit();
              }),
            ),
            const SizedBox(width: 24),
            _radio(
              label: 'Campus',
              selected: _type == SupportLocationType.campus,
              onTap: () => setState(() {
                _type = SupportLocationType.campus;
                _building = null;
                _isRoom = null;
                _room = null;
                _details = '';
                _emit();
              }),
            ),
          ],
        ),
        if (helper != null) ...[
          const SizedBox(height: 6),
          Text(helper, style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
        ],
        const SizedBox(height: 12),
        if (_type == SupportLocationType.building) ...[
          DropdownButtonFormField<String>(
            initialValue: _building,
            decoration: _field(label: 'Building'),
            style: const TextStyle(fontSize: 15, color: AppColors.gray900),
            dropdownColor: AppColors.white,
            items: _buildings.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
            onChanged: (v) => setState(() {
              _building = v;
              _isRoom = null;
              _room = null;
              _details = '';
              _emit();
            }),
          ),
          if (_building != null) ...[
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _isRoom == null ? null : (_isRoom == true ? 'yes' : 'no'),
              decoration: _field(label: 'Is it a room?'),
              style: const TextStyle(fontSize: 15, color: AppColors.gray900),
              dropdownColor: AppColors.white,
              hint: const Text('Select...', style: TextStyle(fontSize: 15, color: AppColors.gray400)),
              items: const [
                DropdownMenuItem(value: 'yes', child: Text('Yes, it is a room')),
                DropdownMenuItem(value: 'no', child: Text('No, another area')),
              ],
              onChanged: (v) => setState(() {
                _isRoom = v == null ? null : v == 'yes';
                _room = null;
                _details = '';
                _emit();
              }),
            ),
          ],
          if (_isRoom == true) ...[
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _room,
              decoration: _field(label: 'Room'),
              style: const TextStyle(fontSize: 15, color: AppColors.gray900),
              dropdownColor: AppColors.white,
              items: (_buildingRooms[_building] ?? [])
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (v) => setState(() {
                _room = v;
                _emit();
              }),
            ),
          ],
          if (_isRoom == false) ...[
            const SizedBox(height: 14),
            TextFormField(
              initialValue: _details,
              decoration: _field(label: 'Location details', hint: 'e.g. Lobby near reception'),
              style: const TextStyle(fontSize: 15, color: AppColors.gray900),
              onChanged: (v) => setState(() {
                _details = v;
                _emit();
              }),
            ),
          ],
        ] else ...[
          TextFormField(
            initialValue: _details,
            decoration: _field(
              label: 'Campus location',
              hint: 'Describe where on campus (e.g. main yard, parking area)',
            ),
            style: const TextStyle(fontSize: 15, color: AppColors.gray900),
            minLines: 1,
            maxLines: 3,
            onChanged: (v) => setState(() {
              _details = v;
              _emit();
            }),
          ),
        ],
      ],
    );
  }
}

