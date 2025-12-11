import 'package:myada_official/core/app_export.dart';

/// Class containing app decoration styles
class AppDecoration {
  // Card decorations
  static BoxDecoration get card2 => BoxDecoration(
        color: theme.colorScheme.onPrimary,
        border: Border.all(
          color: codeColors.pink700,
          width: 0.5.h,
        ),
        boxShadow: [
          BoxShadow(
            color: codeColors.black900.withAlpha(13),
            spreadRadius: 2.h,
            blurRadius: 2.h,
            offset: const Offset(
              0,
              5,
            ),
          ),
        ],
      );

  // Fill decorations
  static BoxDecoration get fillGray => BoxDecoration(
        color: ColorConstant.gray100,
      );

  static BoxDecoration get fillPrimary => BoxDecoration(
        color: theme.colorScheme.primary,
      );

  static BoxDecoration get fillWhite => BoxDecoration(
        color: theme.colorScheme.onPrimary,
      );

  // Pink decorations
  static BoxDecoration get fillPink => BoxDecoration(
        color: codeColors.pink700,
      );

  // Outline decorations
  static BoxDecoration get outlineGray => BoxDecoration(
        color: theme.colorScheme.onPrimary,
        border: Border.all(
          color: ColorConstant.gray300,
          width: 1.w,
        ),
      );

  static BoxDecoration get outlinePrimary => BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.primary,
          width: 1.w,
        ),
      );

  // Column decorations
  static BoxDecoration get column3 => BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            ImageConstant.imgEllipse61,
          ),
          fit: BoxFit.fill,
        ),
      );
  static BoxDecoration get column5 => BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            ImageConstant.imgEllipse61,
          ),
          fit: BoxFit.fill,
        ),
      );

  // Fs decorations
  static BoxDecoration get fs222 => BoxDecoration(
        color: theme.colorScheme.onPrimary,
        border: Border.all(
          color: codeColors.pink700,
          width: 0.5.h,
        ),
        boxShadow: [
          BoxShadow(
            color: codeColors.indigoA40019,
            spreadRadius: 2.h,
            blurRadius: 2.h,
            offset: const Offset(
              0,
              6,
            ),
          )
        ],
      );

  // Gradient decorations
  static BoxDecoration get gradientPrimaryToSecondary => BoxDecoration(
        gradient: LinearGradient(
          begin: const Alignment(0.5, 0),
          end: const Alignment(0.5, 1),
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
        ),
      );
}

/// Class containing border radius styles
class BorderRadiusStyle {
  // Circular border radius
  static BorderRadius get circleBorder8 => BorderRadius.circular(8.r);

  static BorderRadius get circleBorder12 => BorderRadius.circular(12.r);

  static BorderRadius get circleBorder16 => BorderRadius.circular(16.r);

  static BorderRadius get circleBorder20 => BorderRadius.circular(20.r);

  static BorderRadius get circleBorder24 => BorderRadius.circular(24.r);

  static BorderRadius get circleBorder28 => BorderRadius.circular(28.r);

  static BorderRadius get circleBorder32 => BorderRadius.circular(32.r);

  static BorderRadius get roundedBorder4 => BorderRadius.circular(4.r);

  // Custom border radius
  static BorderRadius get customBorderTL16 => BorderRadius.only(
        topLeft: Radius.circular(16.r),
        topRight: Radius.circular(16.r),
      );

  static BorderRadius get customBorderBL16 => BorderRadius.only(
        bottomLeft: Radius.circular(16.r),
        bottomRight: Radius.circular(16.r),
      );

  // Circle borders
  static BorderRadius get circleBorder5 => BorderRadius.circular(
        5.h,
      );
  // Custom borders
  static BorderRadius get customBorderTL32 => BorderRadius.vertical(
        top: Radius.circular(32.h),
      );
  // Rounded borders
  static BorderRadius get roundedBorder10 => BorderRadius.circular(
        10.h,
      );
  static BorderRadius get roundedBorder14 => BorderRadius.circular(
        14.h,
      );
  static BorderRadius get roundedBorder12 => BorderRadius.circular(12.r);
}
