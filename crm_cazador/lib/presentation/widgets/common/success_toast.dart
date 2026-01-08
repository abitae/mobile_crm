import 'package:flutter/material.dart';
import 'custom_snackbar.dart';

class SuccessToast {
  static void show(BuildContext context, String message) {
    CustomSnackbar.show(context, message, type: SnackbarType.success);
  }
}
