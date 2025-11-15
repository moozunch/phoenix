import 'package:flutter/material.dart';
import 'package:phoenix/styles/app_palette.dart';

class AppLinkButton extends StatelessWidget {
  const AppLinkButton({super.key, required this.onPressed, required this.text});

  final VoidCallback onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppPalette.primary,
      ),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
