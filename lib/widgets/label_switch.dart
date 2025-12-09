import 'package:flutter/material.dart';
import 'package:phoenix/styles/app_palette.dart';
class LabelSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? labelColor;

  const LabelSwitch({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 16, color : labelColor ??  Colors.black87)),
 Switch(
          value: value,
          onChanged: onChanged,
          thumbColor: WidgetStateProperty.resolveWith<Color>(
            (states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.white;
              }
              return AppPalette.primary;
            },
          ),
          trackColor: WidgetStateProperty.resolveWith<Color>(
            (states) {
              if (states.contains(WidgetState.selected)) {
                return AppPalette.primary;
              }
              return Colors.grey.shade300;
            },
          ),
        ),
      ],
    );
  }
}
