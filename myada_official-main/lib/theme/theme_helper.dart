import 'package:flutter/material.dart';
import 'package:myada_official/theme/color_constant.dart';

/// Helper class for app theming
class ThemeHelper {
  /// Generate color schemes for light theme
  static ColorScheme get lightColorScheme => ColorScheme.light(
        primary: ColorConstant.primaryColor,
        primaryContainer: ColorConstant.primaryColorLight,
        secondary: ColorConstant.secondaryColor,
        secondaryContainer: ColorConstant.secondaryColorLight,
        tertiary: ColorConstant.tertiaryColor,
        background: ColorConstant.backgroundColor,
        surface: ColorConstant.surfaceColor,
        error: ColorConstant.errorColor,
        onPrimary: ColorConstant.onPrimaryColor,
        onSecondary: ColorConstant.onSecondaryColor,
        onBackground: ColorConstant.onBackgroundColor,
        onSurface: ColorConstant.onSurfaceColor,
        onError: ColorConstant.onErrorColor,
      );

  /// Generate color schemes for dark theme
  static ColorScheme get darkColorScheme => ColorScheme.dark(
        primary: ColorConstant.primaryColorLight,
        primaryContainer: ColorConstant.primaryColorDark,
        secondary: ColorConstant.secondaryColorLight,
        secondaryContainer: ColorConstant.secondaryColorDark,
        tertiary: ColorConstant.tertiaryColor,
        background: ColorConstant.gray900,
        surface: ColorConstant.gray800,
        error: ColorConstant.errorColor,
        onPrimary: ColorConstant.onPrimaryColor,
        onSecondary: ColorConstant.onSecondaryColor,
        onBackground: ColorConstant.gray100,
        onSurface: ColorConstant.gray100,
        onError: ColorConstant.onErrorColor,
      );

  /// Generate light theme data
  static ThemeData get lightTheme => ThemeData(
        colorScheme: lightColorScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: ColorConstant.backgroundColor,
        appBarTheme: AppBarTheme(
          backgroundColor: ColorConstant.surfaceColor,
          elevation: 0,
          iconTheme: IconThemeData(
            color: ColorConstant.onSurfaceColor,
          ),
          titleTextStyle: TextStyle(
            color: ColorConstant.onSurfaceColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        cardTheme: CardTheme(
          color: ColorConstant.surfaceColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorConstant.primaryColor,
            foregroundColor: ColorConstant.onPrimaryColor,
            elevation: 2,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: ColorConstant.primaryColor,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: ColorConstant.surfaceColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: ColorConstant.gray300,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: ColorConstant.gray300,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: ColorConstant.primaryColor,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: ColorConstant.errorColor,
            ),
          ),
        ),
      );

  /// Generate dark theme data
  static ThemeData get darkTheme => ThemeData(
        colorScheme: darkColorScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: ColorConstant.gray900,
        appBarTheme: AppBarTheme(
          backgroundColor: ColorConstant.gray800,
          elevation: 0,
          iconTheme: IconThemeData(
            color: ColorConstant.gray100,
          ),
          titleTextStyle: TextStyle(
            color: ColorConstant.gray100,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        cardTheme: CardTheme(
          color: ColorConstant.gray800,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorConstant.primaryColor,
            foregroundColor: ColorConstant.onPrimaryColor,
            elevation: 2,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: ColorConstant.primaryColorLight,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: ColorConstant.gray800,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: ColorConstant.gray600,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: ColorConstant.gray600,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: ColorConstant.primaryColorLight,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: ColorConstant.errorColor,
            ),
          ),
        ),
      );
}

/// Global theme getter
ThemeData get theme => ThemeHelper.lightTheme;

/// Global app theme getter
ThemeData get appTheme => ThemeHelper.lightTheme;

/// Global color helper for styles in the app
LightCodeColors get codeColors => LightCodeColors();

/// Application light color palette
class LightCodeColors {
  // Primary colors
  Color get pink700 => const Color(0xFFEF476F);
  Color get cyan700 => const Color(0xFF26A69A);

  // Gray scale
  Color get gray50 => const Color(0xFFFAFAFA);
  Color get gray100 => const Color(0xFFF5F5F5);
  Color get gray200 => const Color(0xFFEEEEEE);
  Color get gray300 => const Color(0xFFE0E0E0);
  Color get gray400 => const Color(0xFFBDBDBD);
  Color get gray500 => const Color(0xFF9E9E9E);
  Color get gray600 => const Color(0xFF757575);
  Color get gray700 => const Color(0xFF616161);
  Color get gray800 => const Color(0xFF424242);
  Color get gray900 => const Color(0xFF212121);
  Color get black900 => const Color(0xFF000000);
  Color get redA700 => const Color(0xFFD50000);
  Color get indigoA40019 => const Color(0x193F51B5);
}
