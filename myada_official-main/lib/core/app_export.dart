import 'package:myada_official/localization/app_localization.dart';

// Core utilities
export 'package:flutter/material.dart';
export 'package:flutter/services.dart';
// Re-export what we need from ScreenUtil
export 'package:flutter_screenutil/flutter_screenutil.dart'
    hide DeviceType, SizeExtension, ScreenUtil, ScreenUtilInit;
export 'package:flutter_screenutil/flutter_screenutil.dart' show ScreenUtilInit;
// GetX export for navigation
export 'package:get/get.dart' hide Trans;
// App core
export 'package:myada_official/core/utils/image_constant.dart';
// Add keyboard utils
export 'package:myada_official/core/utils/keyboard_utils.dart';
export 'package:myada_official/core/utils/navigation_provider.dart';
export 'package:myada_official/core/utils/navigator_service.dart';
// Re-export our custom version of SizeUtils and SizeExtension
export 'package:myada_official/core/utils/size_utils.dart';
// Add this import
export 'package:myada_official/core/utils/translation_helper.dart';
// Localization
export 'package:myada_official/localization/app_localization.dart';
// Routes
export 'package:myada_official/routes/app_routes.dart';
// Theming
export 'package:myada_official/theme/app_decoration.dart';
export 'package:myada_official/theme/color_constant.dart';
export 'package:myada_official/theme/custom_text_style.dart';
export 'package:myada_official/theme/theme_helper.dart';
// Custom widgets
export 'package:myada_official/widgets/custom_image_view.dart';
export 'package:provider/provider.dart';
export 'package:shared_preferences/shared_preferences.dart';

/// Extension method to get localization string
extension AppStringX on String {
  String get translate => AppLocalization.of().getString(this);
}
