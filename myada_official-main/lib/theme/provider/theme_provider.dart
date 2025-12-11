import 'package:flutter/material.dart';
import 'package:myada_official/core/app_export.dart';
import 'package:myada_official/core/utils/pref_utils.dart';

class ThemeProvider extends ChangeNotifier {
  themeChange(String themeType) async {
    PrefUtils().setThemeData(themeType);
    notifyListeners();
  }
}
