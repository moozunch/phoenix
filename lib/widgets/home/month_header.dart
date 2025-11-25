import 'package:flutter/material.dart';
import 'package:phoenix/styles/app_palette.dart';

class MonthHeader extends StatelessWidget {
  final String monthLabel;
  final int totalEntries;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  const MonthHeader({
    super.key,
    required this.monthLabel,
    required this.totalEntries,
    required this.onPrevMonth,
    required this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(monthLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        const Icon(Icons.star, size: 16, color: AppPalette.primary),
        Text(' $totalEntries', style: const TextStyle(fontWeight: FontWeight.w600)),
        const Spacer(),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          iconSize: 20,
          onPressed: onPrevMonth,
          icon: const Icon(Icons.chevron_left),
        ),
        const SizedBox(width: 4),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          iconSize: 20,
          onPressed: onNextMonth,
          icon: const Icon(Icons.chevron_right),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black26, width: 1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text('W', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        )
      ],
    );
  }
}
