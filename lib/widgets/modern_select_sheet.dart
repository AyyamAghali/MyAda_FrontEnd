import 'package:flutter/material.dart';
import '../utils/constants.dart';

class SelectOption<T> {
  final T value;
  final String label;
  final IconData? icon;

  const SelectOption({required this.value, required this.label, this.icon});
}

Future<T?> showModernSelectSheet<T>({
  required BuildContext context,
  required String title,
  required List<SelectOption<T>> options,
  T? selectedValue,
  Color accentColor = AppColors.primary,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _ModernSelectBody<T>(
      title: title,
      options: options,
      selectedValue: selectedValue,
      accentColor: accentColor,
    ),
  );
}

class _ModernSelectBody<T> extends StatefulWidget {
  final String title;
  final List<SelectOption<T>> options;
  final T? selectedValue;
  final Color accentColor;

  const _ModernSelectBody({
    required this.title,
    required this.options,
    this.selectedValue,
    required this.accentColor,
  });

  @override
  State<_ModernSelectBody<T>> createState() => _ModernSelectBodyState<T>();
}

class _ModernSelectBodyState<T> extends State<_ModernSelectBody<T>> {
  String _search = '';

  List<SelectOption<T>> get _filtered {
    if (_search.isEmpty) return widget.options;
    final q = _search.toLowerCase();
    return widget.options
        .where((o) => o.label.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom +
        MediaQuery.of(context).padding.bottom;
    final maxH = MediaQuery.of(context).size.height * 0.65;

    return Container(
      constraints: BoxConstraints(maxHeight: maxH),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: bottomPad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.gray300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray900,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: AppColors.gray500),
                  onPressed: () => Navigator.pop(context),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          if (widget.options.length > 5) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: SizedBox(
                height: 40,
                child: TextField(
                  onChanged: (v) => setState(() => _search = v),
                  style: const TextStyle(fontSize: 14, color: AppColors.gray900),
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle:
                        const TextStyle(fontSize: 13, color: AppColors.gray400),
                    prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.gray400),
                    prefixIconConstraints:
                        const BoxConstraints(minWidth: 40, minHeight: 0),
                    filled: true,
                    fillColor: AppColors.gray50,
                    contentPadding: EdgeInsets.zero,
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
                      borderSide: BorderSide(color: widget.accentColor, width: 1.5),
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 4),
          Flexible(
            child: _filtered.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No options found',
                      style: TextStyle(fontSize: 14, color: AppColors.gray500),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 2),
                    itemBuilder: (_, i) {
                      final opt = _filtered[i];
                      final isSelected = opt.value == widget.selectedValue;
                      return Material(
                        color: isSelected
                            ? widget.accentColor.withValues(alpha: 0.08)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => Navigator.pop(context, opt.value),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14),
                            child: Row(
                              children: [
                                if (opt.icon != null) ...[
                                  Icon(
                                    opt.icon,
                                    size: 20,
                                    color: isSelected
                                        ? widget.accentColor
                                        : AppColors.gray500,
                                  ),
                                  const SizedBox(width: 14),
                                ],
                                Expanded(
                                  child: Text(
                                    opt.label,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? widget.accentColor
                                          : AppColors.gray900,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(Icons.check_circle,
                                      size: 20, color: widget.accentColor),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
