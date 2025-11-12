import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({super.key, required this.controller, this.label, this.hint, this.obscure = false, this.keyboardType});

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final bool obscure;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
