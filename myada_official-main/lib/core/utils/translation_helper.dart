import 'package:flutter/material.dart';

// Extension method for String to provide translations
extension StringTranslation on String {
  String appTr([BuildContext? context]) {
    // Implement your translation logic here
    // For now, return a simple mapping
    final translations = {
      'lbl_full_name': 'Full Name:',
      'lbl_id': 'ID:',
      'lbl_name': 'Name:',
      'lbl_surname': 'Surname:',
      'lbl_status': 'Status:',
      'lbl_class': 'Class:',
      'lbl_date_of_issue': 'Date of Issue:',
      'lbl_validity_date': 'Validity Date:',
      'lbl_more': 'More',
      'lbl_today': 'Today',
      'lbl_my_classroom': 'My Classroom',
      'lbl_student': 'Student',
      'lbl_1': '1',
      // Add more translations as needed
    };

    return translations[this] ?? this;
  }
}
