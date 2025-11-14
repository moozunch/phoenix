import 'package:flutter/material.dart';

class OptionButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const OptionButton({
    super.key,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: selected ? Colors.deepOrange : Colors.grey.shade400,
        ),
        backgroundColor: selected ? Colors.deepOrange.withOpacity(0.08) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      onPressed: onTap,
      child: Text(
        text,
        style: TextStyle(
          color: selected ? Colors.deepOrange : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
