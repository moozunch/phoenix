import 'package:flutter/material.dart';
import 'package:phoenix/styles/app_palette.dart';

class TodayEntryCard extends StatelessWidget {
  final String? entryText;
  final VoidCallback? onTap;

  const TodayEntryCard({super.key, this.entryText, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppPalette.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.today, color: AppPalette.primary, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  entryText ?? 'No entry for today',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: entryText != null ? AppPalette.onSurface : AppPalette.onSurface.withAlpha((0.5 * 255).toInt()),
                  ),
                ),
              ),
              if (onTap != null)
                Icon(Icons.arrow_forward_ios, size: 18, color: AppPalette.primary),
            ],
          ),
        ),
      ),
    );
  }
}
