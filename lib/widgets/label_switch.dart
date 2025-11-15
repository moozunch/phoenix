import 'package:flutter/material.dart';
import 'package:phoenix/styles/app_palette.dart';
class LabelSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const LabelSwitch({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.black87)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: AppPalette.primary,
          inactiveThumbColor: AppPalette.primary,
          inactiveTrackColor: Colors.grey.shade300,
        ),
      ],
    );
  }
}
