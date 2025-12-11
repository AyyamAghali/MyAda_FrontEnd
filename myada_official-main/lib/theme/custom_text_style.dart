import 'package:myada_official/core/app_export.dart';

extension on TextStyle {
  TextStyle get tildaSansVF {
    return copyWith(
      fontFamily: 'Tilda Sans VF',
    );
  }

  TextStyle get sFPro {
    return copyWith(
      fontFamily: 'SF Pro',
    );
  }

  TextStyle get roboto {
    return copyWith(
      fontFamily: 'Roboto',
    );
  }

  TextStyle get mulish {
    return copyWith(
      fontFamily: 'Mulish',
    );
  }
}

/// A collection of pre-defined text styles for customizing text appearance,
/// categorized by different font families and weights.
/// Additionally, this class includes extensions on [TextStyle] to easily apply specific font families to text.
class CustomTextStyles {
  // Display text style
  static TextStyle get displayLarge => theme.textTheme.displayLarge!.copyWith(
        color: ColorConstant.onSurfaceColor,
      );

  static TextStyle get displayMedium => theme.textTheme.displayMedium!.copyWith(
        color: ColorConstant.onSurfaceColor,
      );

  static TextStyle get displaySmall => theme.textTheme.displaySmall!.copyWith(
        color: ColorConstant.onSurfaceColor,
      );

  // Headline text style
  static TextStyle get headlineMedium =>
      theme.textTheme.headlineMedium!.copyWith(
        color: ColorConstant.onSurfaceColor,
      );

  // Title text style
  static TextStyle get titleLarge => theme.textTheme.titleLarge!.copyWith(
        color: ColorConstant.onSurfaceColor,
      );

  static TextStyle get titleMedium => theme.textTheme.titleMedium!.copyWith(
        color: ColorConstant.onSurfaceColor,
      );

  static TextStyle get titleSmall => theme.textTheme.titleSmall!.copyWith(
        color: ColorConstant.onSurfaceColor,
      );

  // Body text style
  static TextStyle get bodyLarge => theme.textTheme.bodyLarge!.copyWith(
        color: ColorConstant.onSurfaceColor,
      );

  static TextStyle get bodyMedium => theme.textTheme.bodyMedium!.copyWith(
        color: ColorConstant.onSurfaceColor,
      );

  static TextStyle get bodySmall => theme.textTheme.bodySmall!.copyWith(
        color: ColorConstant.onSurfaceColor.withOpacity(0.8),
      );

  // Label text style
  static TextStyle get labelLarge => theme.textTheme.labelLarge!.copyWith(
        color: ColorConstant.onSurfaceColor,
      );

  // Primary text style variants
  static TextStyle get titleLargePrimary =>
      theme.textTheme.titleLarge!.copyWith(
        color: ColorConstant.primaryColor,
      );

  static TextStyle get titleMediumPrimary =>
      theme.textTheme.titleMedium!.copyWith(
        color: ColorConstant.primaryColor,
      );

  static TextStyle get titleSmallPrimary =>
      theme.textTheme.titleSmall!.copyWith(
        color: ColorConstant.primaryColor,
      );

  static TextStyle get bodyLargePrimary => theme.textTheme.bodyLarge!.copyWith(
        color: ColorConstant.primaryColor,
      );

  static TextStyle get bodyMediumPrimary =>
      theme.textTheme.bodyMedium!.copyWith(
        color: ColorConstant.primaryColor,
      );

  // Secondary text style variants
  static TextStyle get bodyLargeSecondary =>
      theme.textTheme.bodyLarge!.copyWith(
        color: ColorConstant.secondaryColor,
      );

  // White text style variants
  static TextStyle get titleLargeOnPrimary =>
      theme.textTheme.titleLarge!.copyWith(
        color: ColorConstant.onPrimaryColor,
      );

  static TextStyle get titleMediumOnPrimary =>
      theme.textTheme.titleMedium!.copyWith(
        color: ColorConstant.onPrimaryColor,
      );

  static TextStyle get titleSmallOnPrimary =>
      theme.textTheme.titleSmall!.copyWith(
        color: ColorConstant.onPrimaryColor,
      );

  static TextStyle get titleSmallOnPrimaryMedium =>
      theme.textTheme.titleSmall!.copyWith(
        color: ColorConstant.onPrimaryColor,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get bodyLargeOnPrimary =>
      theme.textTheme.bodyLarge!.copyWith(
        color: ColorConstant.onPrimaryColor,
      );

  static TextStyle get bodyMediumOnPrimary =>
      theme.textTheme.bodyMedium!.copyWith(
        color: ColorConstant.onPrimaryColor,
      );

  // Error text style variants
  static TextStyle get bodyMediumError => theme.textTheme.bodyMedium!.copyWith(
        color: ColorConstant.errorColor,
      );

  // Roboto text style
  static TextStyle get robotoOnPrimary => TextStyle(
        color: theme.colorScheme.onPrimary,
        fontSize: 6.sp,
        fontWeight: FontWeight.w500,
      ).roboto;

  // S text style
  static TextStyle get sFProPink700 => TextStyle(
        color: codeColors.pink700,
        fontSize: 7.sp,
        fontWeight: FontWeight.w600,
      ).sFPro;

  static TextStyle get sFProPink700Regular => TextStyle(
        color: codeColors.pink700,
        fontSize: 7.sp,
        fontWeight: FontWeight.w400,
      ).sFPro;

  static TextStyle get sFProPink700SemiBold => TextStyle(
        color: codeColors.pink700,
        fontSize: 7.sp,
        fontWeight: FontWeight.w600,
      ).sFPro;

  // Title text style with specific colors
  static TextStyle get titleMediumSFProBlack900 =>
      theme.textTheme.titleMedium!.sFPro.copyWith(
        color: codeColors.black900,
        fontWeight: FontWeight.w900,
      );

  static TextStyle get titleMediumSFProPink700 =>
      theme.textTheme.titleMedium!.sFPro.copyWith(
        color: codeColors.pink700,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get titleSmallMulishBluegray500 =>
      theme.textTheme.titleSmall!.copyWith(
        color: Colors.blueGrey[500],
        fontFamily: 'Mulish',
      );

  static TextStyle get titleSmallPink700 =>
      theme.textTheme.titleSmall!.copyWith(
        color: codeColors.pink700,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get titleSmallPink700Medium =>
      theme.textTheme.titleSmall!.copyWith(
        color: codeColors.pink700,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get titleSmallTildaSansVFOnPrimary =>
      theme.textTheme.titleSmall!.tildaSansVF.copyWith(
        color: theme.colorScheme.onPrimary,
      );

  static TextStyle get titleSmallTildaSansVFRedA700 =>
      theme.textTheme.titleSmall!.tildaSansVF.copyWith(
        color: codeColors.redA700,
      );
}
