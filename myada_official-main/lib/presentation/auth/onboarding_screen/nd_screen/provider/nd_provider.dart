import 'package:flutter/material.dart';
import 'package:myada_official/core/app_export.dart';

import '../models/nd_model.dart'; // Ensure this path is correct

/// A provider class for the NdScreen.
///
/// This provider manages the state of the NdScreen, including the current ndModelObj

// ignore_for_file: must_be_immutable
class NdProvider extends ChangeNotifier {
  NDModel ndModelObj = NDModel();

  @override
  void dispose() {
    super.dispose();
  }
}
