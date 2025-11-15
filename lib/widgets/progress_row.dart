import 'package:flutter/material.dart';
import 'package:phoenix/styles/app_palette.dart';

class ProgressRow extends StatelessWidget {
  final int activeIndex;
  final int total;
  final double dotHeight;
  final double activeWidth;
  final double inactiveWidth;

  const ProgressRow({
    super.key,
    required this.activeIndex,
    this.total = 3,
    this.dotHeight = 8,
    this.activeWidth = 20,
    this.inactiveWidth = 8,
  });

  Widget _buildDot(bool isActive) {
    return Container(
      height: dotHeight,
      width: isActive ? activeWidth : inactiveWidth,
      decoration: BoxDecoration(
        color: isActive ? AppPalette.primary : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (index) {
        return Row(
          children: [
            _buildDot(index == activeIndex),
            if (index != total - 1) const SizedBox(width: 6),
          ],
        );
      }),
    );
  }
}
