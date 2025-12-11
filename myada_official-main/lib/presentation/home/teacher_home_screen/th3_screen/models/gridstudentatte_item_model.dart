import 'package:myada_official/core/app_export.dart';

/// This class is used in the [gridstudentatte_item_widget] screen.

// ignore_for_file: must_be_immutable
class GridstudentatteItemModel {
  GridstudentatteItemModel({this.image, this.studentattendan, this.id}) {
    image = image ?? ImageConstant.imgAssign12691866;
    studentattendan = studentattendan ?? "Student Attendance";
    id = id ?? "";
  }

  String? image;

  String? studentattendan;

  String? id;
}
