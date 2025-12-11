import 'package:flutter/material.dart';

class ApduToggleButton extends StatefulWidget {
  final Function(bool)? onToggle;
  final bool initialValue;

  const ApduToggleButton({
    Key? key,
    this.onToggle,
    this.initialValue = false,
  }) : super(key: key);

  @override
  State<ApduToggleButton> createState() => _ApduToggleButtonState();
}

class _ApduToggleButtonState extends State<ApduToggleButton> {
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _isActive = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          _isActive = !_isActive;
        });
        if (widget.onToggle != null) {
          widget.onToggle!(_isActive);
        }
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: _isActive ? Colors.green.withOpacity(0.2) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Base circle for the icon
            Icon(
              Icons.wifi,
              color: _isActive ? Colors.green : Colors.grey,
              size: 28,
            ),

            // Animated waves when active
            if (_isActive)
              ...List.generate(3, (index) {
                return AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: 44.0 - (index * 6),
                  height: 44.0 - (index * 6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.green.withOpacity(0.3 + (index * 0.2)),
                      width: 2,
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
