import 'package:flutter/material.dart';
import 'progress_row.dart';

class OnboardingFooter extends StatelessWidget {
  final VoidCallback onSkip;
  final VoidCallback onNext;
  final int activeIndex;
  final int total;

  const OnboardingFooter({
    super.key,
    required this.onSkip,
    required this.onNext,
    this.activeIndex = 0,
    this.total = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: onSkip,
          child: const Text(
            "Skip",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black45,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        ProgressRow(activeIndex: activeIndex, total: total),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrange,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: onNext,
          child: const Text(
            "Next",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
