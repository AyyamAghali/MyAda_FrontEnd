import 'package:flutter/material.dart';

/// Enum for bottom navigation bar items
enum BottomBarEnum { home, attendance, myRooms, profile }

/// Provider class for navigation
class NavigationProvider extends ChangeNotifier {
  BottomBarEnum _selectedBottomBarItem = BottomBarEnum.home;

  int _currentIndex = 0;

  /// Get the current selected bottom bar item
  BottomBarEnum get selectedBottomBarItem => _selectedBottomBarItem;

  /// Get the current index
  int get currentIndex => _currentIndex;

  /// Change selected bottom bar item
  void changeBottomBarItem(BottomBarEnum item) {
    _selectedBottomBarItem = item;
    switch (item) {
      case BottomBarEnum.home:
        _currentIndex = 0;
        break;
      case BottomBarEnum.attendance:
        _currentIndex = 1;
        break;
      case BottomBarEnum.myRooms:
        _currentIndex = 2;
        break;
      case BottomBarEnum.profile:
        _currentIndex = 3;
        break;
    }
    notifyListeners();
  }

  /// Change current index
  void changeIndex(int index) {
    _currentIndex = index;
    switch (index) {
      case 0:
        _selectedBottomBarItem = BottomBarEnum.home;
        break;
      case 1:
        _selectedBottomBarItem = BottomBarEnum.attendance;
        break;
      case 2:
        _selectedBottomBarItem = BottomBarEnum.myRooms;
        break;
      case 3:
        _selectedBottomBarItem = BottomBarEnum.profile;
        break;
    }
    notifyListeners();
  }
}
