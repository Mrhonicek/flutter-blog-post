import 'package:flutter/material.dart';

class CustomSnackBar {
  static void show(BuildContext context, String message,
      {Color? textColor, Color? backgroundColor}) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(
            color: textColor ?? Theme.of(context).colorScheme.tertiary),
      ),
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
