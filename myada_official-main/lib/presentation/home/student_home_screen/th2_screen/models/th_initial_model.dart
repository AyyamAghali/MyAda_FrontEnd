import 'package:myada_official/core/app_export.dart';

import 'listattendancec_item_model.dart';

/// This class is used in the [th_initial_page] screen.

// ignore_for_file: must_be_immutable
class ThInitialModel {
  List<ListattendancecItemModel> listattendancecItemList = [
    ListattendancecItemModel(
        attendancecheck: ImageConstant.imgAssign12691866,
        attendancecheck1: "msg_attendance_check"),
    ListattendancecItemModel(
        attendancecheck: ImageConstant.imgBookingOnline10992406,
        attendancecheck1: "msg_room_reservation"),
    ListattendancecItemModel()
  ];
}
