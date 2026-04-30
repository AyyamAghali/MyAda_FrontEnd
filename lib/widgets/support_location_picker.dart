import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'modern_select_sheet.dart';

enum SupportLocationType { building, campus }

class SupportLocationValue {
  final SupportLocationType type;
  final int? buildingId;
  final String? buildingName;
  final bool? isRoom;
  final int? roomId;
  final String? roomName;
  final String? details;

  const SupportLocationValue({
    required this.type,
    this.buildingId,
    this.buildingName,
    this.isRoom,
    this.roomId,
    this.roomName,
    this.details,
  });

  bool get isComplete {
    if (type == SupportLocationType.campus) {
      return (details ?? '').trim().isNotEmpty;
    }
    if ((buildingName ?? '').trim().isEmpty) return false;
    if (isRoom == true) return (roomName ?? '').trim().isNotEmpty;
    if (isRoom == false) return (details ?? '').trim().isNotEmpty;
    return false;
  }

  String asDisplayString() {
    if (type == SupportLocationType.campus) {
      final d = (details ?? '').trim();
      return d.isEmpty ? 'Campus' : 'Campus - $d';
    }
    final b = (buildingName ?? '').trim();
    if (b.isEmpty) return '';
    if (isRoom == true) {
      final r = (roomName ?? '').trim();
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

  /// IT vs FM theme — radios, focus rings, and selectors use this color.
  final Color accentColor;

  const SupportLocationPicker({
    super.key,
    this.initialValue,
    required this.onChanged,
    this.helperText,
    this.accentColor = AppColors.primary,
  });

  @override
  State<SupportLocationPicker> createState() => _SupportLocationPickerState();
}

class _SupportLocationPickerState extends State<SupportLocationPicker> {
  static const List<_BuildingOption> _buildings = [
    _BuildingOption(1, 'Main Building', [
      _RoomOption(101, '101'),
      _RoomOption(102, '102'),
      _RoomOption(103, '103'),
      _RoomOption(201, '201'),
      _RoomOption(202, '202'),
      _RoomOption(203, '203'),
      _RoomOption(301, '301'),
      _RoomOption(302, '302'),
      _RoomOption(303, '303'),
      _RoomOption(1101, 'A101'),
      _RoomOption(1102, 'A102'),
      _RoomOption(1201, 'A201'),
      _RoomOption(1301, 'A301'),
    ]),
    _BuildingOption(2, 'Library', [
      _RoomOption(2001, 'L1'),
      _RoomOption(2002, 'L2'),
      _RoomOption(2003, 'L3'),
      _RoomOption(2101, 'Reading Hall'),
      _RoomOption(2102, 'Study Room 1'),
      _RoomOption(2103, 'Study Room 2'),
      _RoomOption(2104, 'Study Room 3'),
    ]),
    _BuildingOption(3, 'Sports Complex', [
      _RoomOption(3001, 'Gym'),
      _RoomOption(3002, 'Pool Area'),
      _RoomOption(3101, 'S101'),
      _RoomOption(3102, 'S102'),
      _RoomOption(3201, 'S201'),
      _RoomOption(3301, 'Locker Room A'),
      _RoomOption(3302, 'Locker Room B'),
    ]),
    _BuildingOption(4, 'Building C', [
      _RoomOption(4101, 'C101'),
      _RoomOption(4102, 'C102'),
      _RoomOption(4103, 'C103'),
      _RoomOption(4201, 'C201'),
      _RoomOption(4202, 'C202'),
      _RoomOption(4203, 'C203'),
      _RoomOption(4301, 'C301'),
      _RoomOption(4302, 'C302'),
    ]),
    _BuildingOption(5, 'Cafeteria', [
      _RoomOption(5001, 'Main Hall'),
      _RoomOption(5002, 'Kitchen'),
      _RoomOption(5003, 'Storage'),
    ]),
  ];

  late SupportLocationType _type;
  _BuildingOption? _building;
  bool? _isRoom;
  _RoomOption? _room;
  String _details = '';

  @override
  void initState() {
    super.initState();
    final v = widget.initialValue;
    _type = v?.type ?? SupportLocationType.building;
    if (v?.buildingId != null) {
      _building = _buildings.firstWhere(
        (b) => b.id == v!.buildingId,
        orElse: () => _buildings.first,
      );
    }
    _isRoom = v?.isRoom;
    if (v?.roomId != null) {
      for (final b in _buildings) {
        final match = b.rooms.where((r) => r.id == v!.roomId).toList();
        if (match.isNotEmpty) {
          _room = match.first;
          break;
        }
      }
    }
    _details = v?.details ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) => _emit());
  }

  void _emit() {
    widget.onChanged(
      SupportLocationValue(
        type: _type,
        buildingId: _building?.id,
        buildingName: _building?.name,
        isRoom: _isRoom,
        roomId: _room?.id,
        roomName: _room?.name,
        details: _details,
      ),
    );
  }

  InputDecoration _field({String? label, String? hint, Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.white,
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
        borderSide: BorderSide(color: widget.accentColor, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      labelStyle: const TextStyle(color: AppColors.gray600, fontSize: 14),
      hintStyle: TextStyle(
          color: AppColors.gray400.withValues(alpha: 0.7), fontSize: 14),
    );
  }

  Widget _radio({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final accent = widget.accentColor;
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
                color: selected ? accent : AppColors.gray400,
                width: 2,
              ),
            ),
            child: selected
                ? Center(
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent,
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
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                final result = await showModernSelectSheet<String>(
                  context: context,
                  title: 'Building',
                  accentColor: widget.accentColor,
                  selectedValue: _building?.name,
                  options: _buildings
                      .map((b) => SelectOption(value: b.name, label: b.name))
                      .toList(),
                );
                if (result != null) {
                  setState(() {
                    _building = _buildings.firstWhere(
                      (b) => b.name == result,
                      orElse: () => _buildings.first,
                    );
                    _isRoom = null;
                    _room = null;
                    _details = '';
                    _emit();
                  });
                }
              },
              child: InputDecorator(
                decoration: _field(
                  label: 'Building',
                  hint: 'Select building',
                  suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: AppColors.gray400, size: 22),
                ),
                child: Text(
                  _building == null ? 'Select building' : _building!.name,
                  style: TextStyle(
                    fontSize: 15,
                    color: _building == null
                        ? AppColors.gray400
                        : AppColors.gray900,
                  ),
                ),
              ),
            ),
          ),
          if (_building != null) ...[
            const SizedBox(height: 14),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  final result = await showModernSelectSheet<String>(
                    context: context,
                    title: 'Is it a room?',
                    accentColor: widget.accentColor,
                    selectedValue: _isRoom == null
                        ? null
                        : (_isRoom == true ? 'yes' : 'no'),
                    options: const [
                      SelectOption(value: 'yes', label: 'Yes, it is a room'),
                      SelectOption(value: 'no', label: 'No, another area'),
                    ],
                  );
                  if (result != null) {
                    setState(() {
                      _isRoom = result == 'yes';
                      _room = null;
                      _details = '';
                      _emit();
                    });
                  }
                },
                child: InputDecorator(
                  decoration: _field(
                    label: 'Is it a room?',
                    hint: 'Select...',
                    suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColors.gray400, size: 22),
                  ),
                  child: Text(
                    _isRoom == true
                        ? 'Yes, it is a room'
                        : _isRoom == false
                            ? 'No, another area'
                            : 'Select...',
                    style: TextStyle(
                      fontSize: 15,
                      color: _isRoom == null
                          ? AppColors.gray400
                          : AppColors.gray900,
                    ),
                  ),
                ),
              ),
            ),
          ],
          if (_isRoom == true) ...[
            const SizedBox(height: 14),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  final rooms = _building?.rooms ?? const <_RoomOption>[];
                  final result = await showModernSelectSheet<String>(
                    context: context,
                    title: 'Room',
                    accentColor: widget.accentColor,
                    selectedValue: _room?.name,
                    options: rooms
                        .map((r) => SelectOption(value: r.name, label: r.name))
                        .toList(),
                  );
                  if (result != null) {
                    setState(() {
                      _room = rooms.firstWhere(
                        (r) => r.name == result,
                        orElse: () => rooms.first,
                      );
                      _emit();
                    });
                  }
                },
                child: InputDecorator(
                  decoration: _field(
                    label: 'Room',
                    hint: 'Select room',
                    suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColors.gray400, size: 22),
                  ),
                  child: Text(
                  _room == null ? 'Select room' : _room!.name,
                    style: TextStyle(
                      fontSize: 15,
                    color: _room == null
                          ? AppColors.gray400
                          : AppColors.gray900,
                    ),
                  ),
                ),
              ),
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

class _BuildingOption {
  final int id;
  final String name;
  final List<_RoomOption> rooms;

  const _BuildingOption(this.id, this.name, this.rooms);
}

class _RoomOption {
  final int id;
  final String name;

  const _RoomOption(this.id, this.name);
}

