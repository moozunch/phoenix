import 'package:flutter/material.dart';

void showModernSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.black.withValues(alpha: 0.85),
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      content: Text(
        message,
        style: const TextStyle(fontSize: 14, color: Colors.white),
      ),
      duration: const Duration(seconds: 2),
    ),
  );
}
