import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF336178);
  static const Color primaryDark = Color(0xFF2A4F61);
  static const Color secondary = Color(0xFFAE485E);
  static const Color secondaryDark = Color(0xFF9A3D50);
  static const Color background = Color(0xFFF5F5F5);
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray900 = Color(0xFF111827);
  static const Color black = Color(0xFF000000);
}

class AppSizes {
  static const double maxContentWidth = 430.0;
  static const double padding = 24.0;
  static const double paddingSmall = 12.0;
  static const double borderRadius = 16.0;
  static const double borderRadiusLarge = 24.0;
}

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.gray900,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.gray900,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AppColors.gray700,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: AppColors.gray600,
  );
}

