import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phoenix/widgets/upload/dashed_upload_box.dart';
import 'package:phoenix/widgets/upload/mood_picker_dialog.dart';
import 'package:phoenix/widgets/upload/photo_picker_sheet.dart';
import 'package:phoenix/styles/app_palette.dart';

class DailyReflectionScreen extends StatefulWidget {
  const DailyReflectionScreen({super.key});

  @override
  State<DailyReflectionScreen> createState() => _DailyReflectionScreenState();
}

class _DailyReflectionScreenState extends State<DailyReflectionScreen> {
  final TextEditingController headlineCtrl = TextEditingController();
  final TextEditingController journalCtrl = TextEditingController();

  Color? selectedEmotion;

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, statusBarHeight + 60, 20, 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //upload box
                  GestureDetector(
                    onTap: () => showPhotoPicker(context),
                    child: const DashedUploadBox(),
                  ),

                  const SizedBox(height: 30),

                  //headline
                  Row(
                    children: [
                      const Text(
                        "Your Day’s Headline",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      Text(
                        "${headlineCtrl.text.length}/25",
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: headlineCtrl,
                    maxLength: 25,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: "Please insert your day’s headline…",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  //journal and mood picker
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => showMoodPicker(context, (color) {
                          setState(() => selectedEmotion = color);
                        }),
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor:
                          selectedEmotion ?? Colors.grey.shade300,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Your Journal",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      Text(
                        "${journalCtrl.text.length}/3000",
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: journalCtrl,
                    maxLength: 3000,
                    maxLines: 10,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText:
                      "It’s okay to be honest, this space is for you…",
                      alignLabelWithHint: true,
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          //header arrow and date
          Positioned(
            top: statusBarHeight + 8,
            left: 0,
            right: 0,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, size: 22),
                  onPressed: () => GoRouter.of(context).pop(),
                ),
                const Spacer(),
                const Text(
                  "Friday, 26 Sep",
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                const SizedBox(width: 48), // balance arrow spacing
              ],
            ),
          ),

          //button log
          Positioned(
            right: 20,
            bottom: 30,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPalette.primary,
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                // TODO: Save logic here
              },
              child: const Text(
                "Log",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
