import 'package:flutter/material.dart';

class MoodPickerDialog {
  static final List<Map<String, dynamic>> emotions = [
    {"label": "Very Sad", "color": Colors.red},
    {"label": "Sad", "color": Colors.orange},
    {"label": "Neutral", "color": Colors.yellow},
    {"label": "Happy", "color": Colors.lightGreen},
    {"label": "Very Happy", "color": Colors.green},
  ];

  static void showMoodPicker(BuildContext context, Function(Color) onSelect) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final containerColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF8F8F8);
    final dividerColor = isDark ? Colors.white24 : const Color(0xFFD7D7D7);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: theme.scaffoldBackgroundColor,
          surfaceTintColor: theme.scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Material(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      const Text(
                        "Pin your feeling",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Rounded light-grey container
                  Container(
                    decoration: BoxDecoration(
                      color: containerColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        ...emotions.asMap().entries.map((entry) {
                          final index = entry.key;
                          final e = entry.value;

                          return Column(
                            children: [
                              ListTile(
                                leading: CircleAvatar(
                                  radius: 8,
                                  backgroundColor: e["color"],
                                ),
                                title: Text(e["label"]),
                                onTap: () {
                                  onSelect(e["color"]);
                                  Navigator.pop(context);
                                },
                              ),

                              // Divider (not full width)
                              if (index != emotions.length - 1)
                                 Divider(
                                  indent: 56,
                                  endIndent: 16,
                                  height: 1,
                                  thickness: 1,
                                  color: dividerColor,
                                ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
