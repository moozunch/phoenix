import 'package:flutter/material.dart';
import 'package:phoenix/styles/app_palette.dart';

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
                    color: isSelected ? AppPalette.primary :AppPalette.primary,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(6),
                  color: isSelected ? AppPalette.primary.withAlpha((0.1 * 255).toInt()) : Colors.white,
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 18, color: AppPalette.primary)
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