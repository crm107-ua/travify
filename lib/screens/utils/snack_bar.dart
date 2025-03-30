import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

class SnackbarUtils {
  static void showSnackBar(BuildContext context, String message) {
    Flushbar(
      duration: const Duration(seconds: 2),
      borderRadius: BorderRadius.circular(8),
      margin: const EdgeInsets.all(16),
      flushbarPosition: FlushbarPosition.BOTTOM,
      dismissDirection: FlushbarDismissDirection.VERTICAL,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[850]!
          : Colors.grey[200]!,
      messageText: Text(
        message,
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
      ),
    ).show(context);
  }
}
