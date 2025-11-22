import 'package:flutter/material.dart';
import 'package:phoenix/styles/app_palette.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

Future<XFile?> photoPickerSheet(BuildContext context) async {
  final ImagePicker picker = ImagePicker();

  return showModalBottomSheet<XFile?>(
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
            onTap: () async {
              final picker = ImagePicker();
              final XFile ? photo =
                  await picker.pickImage(source: ImageSource.camera);
              Navigator.pop(context, photo);
            },
          ),
          _divider(),

          // ---------- Option 2 ----------
          _pickerTile(
            icon: Icons.photo_library,
            text: "Add from Photo Library",
            onTap: () async {
              final picker = ImagePicker();
              final XFile? image =
                  await picker.pickImage(source: ImageSource.gallery);

              Navigator.pop(context, image);
            },
          ),
          _divider(),

          // ---------- Option 3 ----------
          _pickerTile(
            icon: Icons.insert_drive_file,
            text: "Select Existing File",
            onTap: () async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.image,
              );

              if (result != null && result.files.first.path != null){
                Navigator.pop(
                  context,
                  XFile(result.files.first.path!),
                );
              } else {
                Navigator.pop(context, null);
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
