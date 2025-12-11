import 'package:flutter/material.dart';
import 'package:myada_official/core/app_export.dart';

import '../models/rd_model.dart';

/// A provider class for the RdScreen.
///
/// This provider manages the state of the RdScreen, including the
/// current rdModelObj

// ignore_for_file: must_be_immutable
class RdProvider extends ChangeNotifier {
  RdModel rdModelObj = RdModel();

  @override
  void dispose() {
    super.dispose();
  }
}
