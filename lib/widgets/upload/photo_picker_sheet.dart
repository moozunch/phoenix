import 'package:flutter/material.dart';

void showPhotoPicker(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text(
                  "Add",
                  style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const SizedBox(height: 10),
            _option("Take a Photo", Icons.camera_alt_outlined),
            _option("Add from Photo Library", Icons.photo_library_outlined),
            _option("Select Existing File", Icons.insert_drive_file_outlined),
          ],
        ),
      );
    },
  );
}

Widget _option(String title, IconData icon) {
  return ListTile(
    leading: Text(title, style: const TextStyle(fontSize: 16)),
    trailing: Icon(icon),
    onTap: () {},
  );
}
