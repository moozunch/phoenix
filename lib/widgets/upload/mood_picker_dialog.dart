import 'package:flutter/material.dart';

final List<Map<String, dynamic>> emotions = [
  {"label": "Very Sad", "color": Colors.red},
  {"label": "Sad", "color": Colors.orange},
  {"label": "Neutral", "color": Colors.yellow},
  {"label": "Happy", "color": Colors.lightGreen},
  {"label": "Very Happy", "color": Colors.green},
];

void showMoodPicker(BuildContext context, Function(Color) onSelect) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text(
                    "Pin your feeling",
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
              ...emotions.map((e) {
                return ListTile(
                  leading: CircleAvatar(
                    radius: 8,
                    backgroundColor: e["color"],
                  ),
                  title: Text(e["label"]),
                  onTap: () {
                    onSelect(e["color"]);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        ),
      );
    },
  );
}
