import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// AppLocalization class for handling translations
class AppLocalization extends Translations {
  /// Get the current locale
  static Locale get currentLocale => Get.locale ?? const Locale('en', 'US');

  /// Get the app locale
  static const Locale appLocale = Locale('en', 'US');

  /// Get the fallback locale
  static const Locale fallbackLocale = Locale('en', 'US');

  /// Available languages
  static final List<String> languages = ['English', 'Arabic'];

  /// Available locales
  static final List<Locale> locales = [
    const Locale('en', 'US'),
    const Locale('ar', 'SA'),
  ];

  /// Static instance of AppLocalization for getting translations
  static final AppLocalization _instance = AppLocalization._();

  AppLocalization._();

  /// Get instance of AppLocalization
  static AppLocalization of() => _instance;

  /// Translate a key
  String getString(String text) => text.appTr;

  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': englishTranslations,
      };
}

/// Extension method to get localization string - renamed to avoid conflict with GetX
extension AppLocalizationExtension on String {
  String get appTr =>
      Get.find<Translations>().keys[Get.locale?.languageCode ?? 'en']?[this] ??
      this;
}

/// English translations
Map<String, String> get englishTranslations => {
      // Common
      'msg_network_err': 'Network Error',
      'msg_something_went_wrong': 'Something Went Wrong!',

      // Onboarding
      'msg_onboarding_title_1': 'Welcome to My ADA',
      'msg_onboarding_desc_1': 'Your digital student ID and attendance system',
      'msg_onboarding_title_2': 'Access Control',
      'msg_onboarding_desc_2': 'Use your phone to access rooms and facilities',
      'msg_onboarding_title_3': 'Track Attendance',
      'msg_onboarding_desc_3':
          'View your attendance records and classroom history',

      // Auth
      'lbl_login': 'Login',
      'lbl_email': 'Email',
      'lbl_password': 'Password',
      'msg_forgot_password': 'Forgot Password?',
      'msg_dont_have_account': 'Don\'t have an account?',
      'lbl_signup': 'Sign Up',
      'lbl_remember_me': 'Remember me',
      'err_msg_please_enter_valid_email': 'Please enter valid email',
      'err_msg_please_enter_valid_password': 'Please enter valid password',

      // Home - Student
      'lbl_my_id': 'My ID',
      'lbl_attendance': 'Attendance',
      'lbl_my_rooms': 'My Rooms',
      'lbl_profile': 'Profile',
      'lbl_today': 'Today',
      'lbl_history': 'History',

      // Home - Teacher
      'lbl_classes': 'Classes',
      'lbl_students': 'Students',
      'lbl_calendar': 'Calendar',
      'lbl_settings': 'Settings',
      'lbl_scan': 'Scan',
      'lbl_classroom': 'Classroom',
      'lbl_more': 'More',
      'lbl_ada_university': 'ADA University',
      'lbl_name': 'Name: ',
      'lbl_fidan': 'Fidan',
      'lbl_surname': 'Surname: ',
      'lbl_mardanli': 'Mardanli',
      'lbl_status_teacher': 'Status: Teacher',
      'lbl_class': 'Class: ',
      'lbl_a120': 'A120',
      'lbl_date_of_issue': 'Date of Issue: ',
      'lbl_20_07_2020': '20.07.2020',
      'lbl_validity_date': 'Validity Date: ',
      'lbl_01_06_2025': '01.06.2025',
      'lbl_id': 'ID: ',
      'lbl_p000011230': 'P000011230',
      'lbl_1': '1',

      // My Room
      'lbl_select_date': 'Select Date',
      'lbl_confirm': 'Confirm',
      'lbl_cancel': 'Cancel',
      'lbl_present': 'Present',
      'lbl_absent': 'Absent',
      'lbl_late': 'Late',
    };
