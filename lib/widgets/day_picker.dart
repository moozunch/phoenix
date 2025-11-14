import 'package:flutter/material.dart';

class DayPicker extends StatelessWidget{
  final Map<String, bool> selectedDays;
  final Function(String) onToggle;

  const DayPicker({
    super.key,
    required this.selectedDays,
    required this.onToggle,
});
  @override
  Widget build(BuildContext context){
    return Wrap(
      spacing: 20,
      runSpacing: 16,
      children: selectedDays.keys.map((day){
        final isSelected = selectedDays[day]!;
        return InkWell(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? Colors.deepOrange : Colors.deepOrange,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(6),
                  color: isSelected ? Colors.deepOrange.withOpacity(0.1) : Colors.white,
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 18, color: Colors.deepOrange)
                    : null,
              ),
              const SizedBox(width: 8),
              Text(day, style: const TextStyle(fontSize: 16)),
            ],
          ),
        );
      }).toList(),
    );
  }
}