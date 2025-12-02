import 'package:flutter/material.dart';
import 'package:phoenix/styles/app_palette.dart';

class DashedUploadBox extends StatelessWidget {
  const DashedUploadBox({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade400,
          style: BorderStyle.solid,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFEDEDED),
            ),
            child: Icon(Icons.image_outlined,
                color: AppPalette.primary, size: 40),
          ),
          const SizedBox(height: 10),
           Text(
            "Snap or upload your photo",
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: cs.onSurface),
          ),
          const SizedBox(height: 4),
          Text(
            "Take a selfie to start your reflection day",
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
