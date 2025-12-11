import 'package:myada_official/core/app_export.dart';

/// This class is used in the [listattendancec_item_widget] screen.

// ignore_for_file: must_be_immutable
class ListattendancecItemModel {
  ListattendancecItemModel(
      {this.attendancecheck, this.attendancecheck1, this.id}) {
    attendancecheck = attendancecheck ?? ImageConstant.imgAssign12691866;
    attendancecheck1 = attendancecheck1 ?? "msg_attendance_check";
    id = id ?? "";
  }

  String? attendancecheck;

  String? attendancecheck1;

  String? id;
}
