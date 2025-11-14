import 'package:flutter/material.dart';

class TimePicker extends StatelessWidget {
  final String timeLabel;
  final VoidCallback onTap;

  // ⬇️ Added optional color parameters
  final Color? primaryColor;
  final Color? surfaceColor;
  final Color? textColor;

  const TimePicker({
    super.key,
    required this.timeLabel,
    required this.onTap,
    this.primaryColor,
    this.surfaceColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,   // ⬅️ You will handle the themed picker HERE
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Text(
            timeLabel,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: textColor ?? Colors.black87, // ⬅️ apply text color if provided
            ),
          ),
        ),
      ),
    );
  }
}
