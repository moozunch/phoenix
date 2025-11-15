import 'package:flutter/material.dart';
import 'package:phoenix/styles/app_palette.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({super.key, required this.controller, this.label, this.hint, this.obscure = false, this.keyboardType});

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final bool obscure;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(10);
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        labelStyle: const TextStyle(color: AppPalette.primary),
        floatingLabelStyle: const TextStyle(color: AppPalette.primary, fontWeight: FontWeight.w600),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: Colors.black26),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: AppPalette.primary, width: 1.6),
        ),
        border: OutlineInputBorder(borderRadius: radius),
      ),
    );
  }
}
