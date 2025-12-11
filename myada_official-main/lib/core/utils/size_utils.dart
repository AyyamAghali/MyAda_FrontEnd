import 'package:flutter/material.dart'; // These are the Viewport values of your Figma Design.
import 'package:flutter_screenutil/flutter_screenutil.dart';

// These are used in the code as a reference to create your UI Responsively.
const num FIGMA_DESIGN_WIDTH = 393;
const num FIGMA_DESIGN_HEIGHT = 852;
const num FIGMA_DESIGN_STATUS_BAR = 0;

/// Device type enumeration
enum DeviceType {
  mobile,
  tablet,
  desktop,
}

/// Size utility class for responsive UI
class SizeUtils {
  static MediaQueryData _mediaQueryData = MediaQueryData.fromView(
    WidgetsBinding.instance.platformDispatcher.views.first,
  );

  static double _width = _mediaQueryData.size.width;
  static double _height = _mediaQueryData.size.height;

  /// Get screen width
  static double get width => _width;

  /// Set screen width
  static set width(double value) {
    _width = value;
  }

  /// Get screen height
  static double get height => _height;

  /// Set screen height
  static set height(double value) {
    _height = value;
  }

  /// Get status bar height
  static double get statusBarHeight => _mediaQueryData.padding.top;

  /// Get bottom padding (safe area bottom)
  static double get bottomPadding => _mediaQueryData.padding.bottom;

  /// Get horizontal padding (safe area left + right)
  static double get horizontalPadding =>
      _mediaQueryData.padding.left + _mediaQueryData.padding.right;

  /// Get vertical padding (safe area top + bottom)
  static double get verticalPadding =>
      _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;

  /// Detect device type based on width
  static DeviceType getDeviceType() {
    if (width < 600) {
      return DeviceType.mobile;
    } else if (width < 1200) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// Check if device is mobile
  static bool get isMobile => getDeviceType() == DeviceType.mobile;

  /// Check if device is tablet
  static bool get isTablet => getDeviceType() == DeviceType.tablet;

  /// Check if device is desktop
  static bool get isDesktop => getDeviceType() == DeviceType.desktop;

  /// Device's BoxConstraints
  static late BoxConstraints boxConstraints;

  /// Device's Orientation
  static late Orientation orientation;

  /// Type of Device
  ///
  /// This can either be mobile or tablet
  static DeviceType deviceType = DeviceType.mobile;

  /// Set screen size for responsive layout
  static void setScreenSize(
    BoxConstraints constraints,
    Orientation currentOrientation,
  ) {
    boxConstraints = constraints;
    orientation = currentOrientation;
    if (orientation == Orientation.portrait) {
      width =
          boxConstraints.maxWidth.isNonZero(defaultValue: FIGMA_DESIGN_WIDTH);
      height = boxConstraints.maxHeight.isNonZero();
    } else {
      width =
          boxConstraints.maxHeight.isNonZero(defaultValue: FIGMA_DESIGN_WIDTH);
      height = boxConstraints.maxWidth.isNonZero();
    }
    deviceType = getDeviceType();
  }
}

/// Extension for responsive dimensions using ScreenUtil 'w' and 'h' methods
extension SizeExtension on num {
  /// Returns the [ScreenUtil().setWidth] equivalent of the given value
  double get w => ScreenUtil().setWidth(this);

  /// Returns the [ScreenUtil().setHeight] equivalent of the given value
  double get h => ScreenUtil().setHeight(this);

  /// Returns the [ScreenUtil().radius] equivalent of the given value
  double get r => ScreenUtil().radius(this);

  /// Returns the [ScreenUtil().setSp] equivalent of the given value
  double get sp => ScreenUtil().setSp(this);
}

extension FormatExtension on double {
  double toDoubleValue({int fractionDigits = 2}) {
    return double.parse(this.toStringAsFixed(fractionDigits));
  }

  double isNonZero({num defaultValue = 0.0}) {
    return this > 0 ? this : defaultValue.toDouble();
  }
}

typedef ResponsiveBuild = Widget Function(
    BuildContext context, Orientation orientation, DeviceType deviceType);

class Sizer extends StatelessWidget {
  const Sizer({Key? key, required this.builder}) : super(key: key);

  /// Builds the widget whenever the orientation changes.
  final ResponsiveBuild builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return OrientationBuilder(builder: (context, orientation) {
        SizeUtils.setScreenSize(constraints, orientation);
        return builder(context, orientation, SizeUtils.deviceType);
      });
    });
  }
}

/// Returns the device height
double get deviceHeight => ScreenUtil().screenHeight;

/// Returns the device width
double get deviceWidth => ScreenUtil().screenWidth;

// MediaQuery extension
extension MediaQueryExtension on BuildContext {
  /// Returns the height of the device
  double get height => MediaQuery.of(this).size.height;

  /// Returns the width of the device
  double get width => MediaQuery.of(this).size.width;

  /// Returns if the device is in landscape mode
  bool get isLandscape =>
      MediaQuery.of(this).orientation == Orientation.landscape;

  /// Returns the device's pixel ratio
  double get pixelRatio => MediaQuery.of(this).devicePixelRatio;
}

/// ScreenUtil initialization parameters
void initScreenUtil(BuildContext context) {
  ScreenUtil.init(
    context,
    designSize: const Size(390, 844), // Design size based on iPhone 13
    minTextAdapt: true,
    splitScreenMode: true,
  );
}
