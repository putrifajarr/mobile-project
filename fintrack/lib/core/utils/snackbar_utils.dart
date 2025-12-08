import 'package:flutter/material.dart';
import 'package:fintrack/core/constants/constants.dart';

void showUndoSnackBar(
  BuildContext context, {
  required String message,
  required VoidCallback onUndo,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: ColorPallete.blackLight,
      content: Text(message, style: const TextStyle(color: Colors.white)),
      action: SnackBarAction(
        label: 'Batal',
        textColor: const Color.fromARGB(255, 255, 107, 107),
        onPressed: onUndo,
      ),
    ),
  );
}
