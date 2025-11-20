import 'package:flutter/material.dart';
import 'package:phoenix/styles/app_palette.dart';

void showPhotoPicker(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ---------- Header ----------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                const Text(
                  "Add",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, size: 22),
                ),
              ],
            ),
          ),

          // ---------- Option 1 ----------
          _pickerTile(
            icon: Icons.camera_alt,
            text: "Take a Photo",
            onTap: () {},
          ),
          _divider(),

          // ---------- Option 2 ----------
          _pickerTile(
            icon: Icons.photo_library,
            text: "Add from Photo Library",
            onTap: () {},
          ),
          _divider(),

          // ---------- Option 3 ----------
          _pickerTile(
            icon: Icons.insert_drive_file,
            text: "Select Existing File",
            onTap: () {},
          ),

          const SizedBox(height: 20),
        ],
      );
    },
  );
}

Widget _pickerTile({
  required IconData icon,
  required String text,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      color: const Color(0xFFF8F8F8), // light grey background
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: AppPalette.primary), // your orange brand color
          const SizedBox(width: 16),
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    ),
  );
}

Widget _divider() => Container(
  height: 1,
  color: const Color(0xFFD7D7D7), // LIGHT DIVIDER
);
