import 'package:flutter/material.dart';

import '../../utils/constants.dart';
import 'qr_scanner_screen.dart';
import 'my_attendance_screen.dart';

class AttendanceHome extends StatefulWidget {
  const AttendanceHome({super.key});

  @override
  State<AttendanceHome> createState() => _AttendanceHomeState();
}

class _AttendanceHomeState extends State<AttendanceHome> {
  int _currentIndex = 0;

  final _pages = const <Widget>[
    QrScannerScreen(embedded: true),
    MyAttendanceScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        bottom: bottomPadding > 0 ? bottomPadding : 8,
        top: 6,
      ),
      child: Row(
        children: [
          _buildTab(0, Icons.qr_code_scanner_rounded, 'Check In'),
          _buildTab(1, Icons.history_rounded, 'My Records'),
        ],
      ),
    );
  }

  Widget _buildTab(int index, IconData icon, String label) {
    final isActive = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 32,
              decoration: BoxDecoration(
                color:
                    isActive ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 22,
                color: isActive ? AppColors.primary : AppColors.gray400,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppColors.primary : AppColors.gray400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
