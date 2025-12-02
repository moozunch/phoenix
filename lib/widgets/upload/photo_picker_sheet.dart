import 'package:flutter/material.dart';
import 'package:phoenix/styles/app_palette.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

Future<XFile?> photoPickerSheet(BuildContext context) async {
  final ImagePicker picker = ImagePicker();
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  final backgroundColor = theme.scaffoldBackgroundColor; // bottom sheet background
  final tileColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF8F8F8); // tiap tile
  final dividerColor = isDark ? Colors.white24 : const Color(0xFFD7D7D7); // line divider
  final iconColor = isDark ? Colors.white : AppPalette.primary; // icon


  return showModalBottomSheet<XFile?>(
    context: context,
    backgroundColor: backgroundColor,
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
            color: iconColor,
            backgroundColor: tileColor,
            onTap: () async {
              final XFile? photo = await picker.pickImage(source: ImageSource.camera);
              if (context.mounted) Navigator.pop(context, photo);
            },
          ),
          _divider(dividerColor),

          // ---------- Option 2 ----------
          _pickerTile(
            icon: Icons.photo_library,
            text: "Add from Photo Library",
            color: iconColor,
            backgroundColor: tileColor,
            onTap: () async {
              final XFile? image = await picker.pickImage(source: ImageSource.gallery);
              if (context.mounted) Navigator.pop(context, image);
            },
          ),
          _divider(dividerColor),

          // ---------- Option 3 ----------
          _pickerTile(
            icon: Icons.insert_drive_file,
            text: "Select Existing File",
            color: iconColor,
            backgroundColor: tileColor,
            onTap: () async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.image,
              );
              if (context.mounted) {
                if (result != null && result.files.first.path != null){
                  Navigator.pop(
                    context,
                    XFile(result.files.first.path!),
                  );
                } else {
                  Navigator.pop(context, null);
                }
              }
            },
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
  required Color color,
  required Color backgroundColor,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      color:backgroundColor, // light grey background
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

Widget _divider(Color color) => Container(
  height: 1,
  color: color, // LIGHT DIVIDER
);
