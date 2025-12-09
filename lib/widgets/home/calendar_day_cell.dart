import 'package:flutter/material.dart';
import 'package:phoenix/styles/app_palette.dart';

class CalendarDayCell extends StatelessWidget {
  final DateTime date;
  final bool isOutside;
  final bool isToday;
  final bool isSelected;
  final bool isLogged;
  final bool hasPhoto;
  final VoidCallback? onTap;
  const CalendarDayCell({
    super.key,
    required this.date,
    required this.isOutside,
    required this.isToday,
    required this.isSelected,
    required this.isLogged,
    this.hasPhoto = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Color bg = cs.surfaceContainerHighest;
    Color textColor = cs.onSurface;
    Border? border;

    if (isOutside) {
      bg = cs.surface.withValues(alpha: 0.3);
      textColor = cs.onSurface.withValues(alpha: 0.3);
    } else if (hasPhoto) {
      // bg = cs.primary;
      bg = AppPalette.primary;
      textColor = cs.onPrimary;
    } else if (isLogged) {
      // bg = cs.secondary;
      bg = AppPalette.secondary;
      textColor = cs.onSecondary;
    } else if (isToday) {
      bg = AppPalette.primary.withValues(alpha: 0.15);
      border = Border.all(color: AppPalette.primary, width: 1.4);
    }

    if (isSelected) {
      border = Border.all(color: AppPalette.primary, width: 2);
    }

    return GestureDetector(
      onTap: isOutside ? null : onTap,
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
          border: border,
        ),
        child: Text(
          '${date.day}',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}