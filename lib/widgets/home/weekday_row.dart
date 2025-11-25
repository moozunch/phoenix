import 'package:flutter/material.dart';

class WeekdayRow extends StatelessWidget {
  const WeekdayRow({super.key});

  @override
  Widget build(BuildContext context) {
    const days = ['MON','TUE','WED','THU','FRI','SAT','SUN'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((d) => SizedBox(
        width: 34,
        child: Text(d,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.black54)),
      )).toList(),
    );
  }
}
