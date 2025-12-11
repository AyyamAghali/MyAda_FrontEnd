import 'package:flutter/material.dart';
import 'package:myada_official/core/app_export.dart';

import '../models/st_model.dart';

/// A provider class for the StScreen.
///
/// This provider manages the state of the StScreen, including the
/// current stModelObj

// ignore_for_file: must_be_immutable
class StProvider extends ChangeNotifier {
  StModel stModelObj = StModel();

  @override
  void dispose() {
    super.dispose();
  }
}
