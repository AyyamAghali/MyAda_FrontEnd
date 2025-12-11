import 'package:shared_preferences/shared_preferences.dart';

// ignore_for_file: must_be_immutable
class PrefUtils {
  static final PrefUtils _instance = PrefUtils._internal();

  factory PrefUtils() {
    return _instance;
  }

  PrefUtils._internal();

  SharedPreferences? _preferences;

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  ///will clear all the data stored in preference
  void clearPreferencesData() async {
    _preferences!.clear();
  }

  Future<void> setThemeData(String themeType) async {
    if (_preferences == null) await init();
    await _preferences?.setString('theme_type', themeType);
  }

  String getThemeData() {
    return _preferences?.getString('theme_type') ?? 'light';
  }
}
