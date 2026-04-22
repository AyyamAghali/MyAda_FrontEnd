import 'attendance_device_info_impl.dart'
    if (dart.library.html) 'attendance_device_info_impl_stub.dart' as impl;

/// Optional `deviceInfo` for attendance APIs, e.g. "iOS 17.4; iPhone15,3".
Future<String> resolveAttendanceDeviceInfo() =>
    impl.resolveAttendanceDeviceInfo();
