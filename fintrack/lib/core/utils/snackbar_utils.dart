import 'package:flutter/material.dart';

void showUndoSnackBar(
  BuildContext context, {
  required String message,
  required VoidCallback onUndo,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: const Color.fromARGB(255, 55, 55, 55),
      content: Text(message, style: const TextStyle(color: Colors.white)),
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(
        label: 'Batal',
        textColor: const Color.fromARGB(255, 255, 107, 107),
        onPressed: onUndo,
      ),
    ),
  );
}
