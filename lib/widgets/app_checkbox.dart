import 'package:flutter/material.dart';
import 'package:phoenix/styles/app_palette.dart';

class AppCheckbox extends StatelessWidget {
  const AppCheckbox({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: value,
      onChanged: onChanged,
      activeColor: AppPalette.primary,
      checkColor: Colors.white,
    );
  }
}
