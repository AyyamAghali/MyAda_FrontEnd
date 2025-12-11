import 'package:flutter/material.dart';
import 'package:myada_official/core/app_export.dart';

import '../models/th2_model.dart';
import '../models/th_initial_model.dart';

/// A provider class for the Th2Screen.
///
/// This provider manages the state of the Th2Screen, including the
/// current th2ModelObj

// ignore_for_file: must_be_immutable
class Th2Provider extends ChangeNotifier {
  Th2Model th2ModelObj = Th2Model();

  ThInitialModel thInitialModelObj = ThInitialModel();

  @override
  void dispose() {
    super.dispose();
  }
}
