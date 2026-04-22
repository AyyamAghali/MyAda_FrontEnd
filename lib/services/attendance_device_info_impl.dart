import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';

/// Native / desktop: real OS + model when available.
Future<String> resolveAttendanceDeviceInfo() async {
  final plugin = DeviceInfoPlugin();
  try {
    if (Platform.isIOS) {
      final ios = await plugin.iosInfo;
      return '${ios.systemName} ${ios.systemVersion}; ${ios.utsname.machine}';
    }
    if (Platform.isAndroid) {
      final a = await plugin.androidInfo;
      return 'Android ${a.version.release}; ${a.model}';
    }
  } catch (_) {
    // ignore
  }
  try {
    return '${Platform.operatingSystem} ${Platform.operatingSystemVersion}';
  } catch (_) {
    return 'unknown';
  }
}
