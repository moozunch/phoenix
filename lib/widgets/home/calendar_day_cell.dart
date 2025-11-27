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
    Color bg;
    Color textColor = Colors.black87;
    Border? border;
    if (isOutside) {
      bg = Colors.white;
      textColor = Colors.black26;
    } else if (hasPhoto) {
      bg = AppPalette.primary;
      textColor = Colors.white;
    } else if (isLogged) {
      bg = AppPalette.secondary;
      textColor = Colors.white;
    } else if (isToday) {
      bg = const Color(0xFFFFF4F0);
      border = Border.all(color: AppPalette.primary, width: 1.4);
    } else {
      bg = const Color(0xFFEDEDED);
    }
    if (isSelected) {
      border = Border.all(color: Colors.blueAccent, width: 2);
    }
    return GestureDetector(
      onTap: isOutside ? null : onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
          border: border,
        ),
        alignment: Alignment.center,
        child: Text('${date.day}',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textColor)),
      ),
    );
  }
}
