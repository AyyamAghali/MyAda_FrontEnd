/// A provider class for the Th3Screen.
///
/// This provider manages the state of the Th3Screen, including the
/// current th3ModelObj
import 'package:flutter/material.dart';

import '../models/th3_model.dart';

/// A provider class for the Th3Screen.
///
/// This provider manages the state of the Th3Screen, including the
/// current th3ModelObj

// ignore_for_file: must_be_immutable
class Th3Provider extends ChangeNotifier {
  Th3Model th3ModelObj = Th3Model();

  @override
  void dispose() {
    super.dispose();
  }
}
