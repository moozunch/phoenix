import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phoenix/widgets/upload/dashed_upload_box.dart';
import 'package:phoenix/widgets/upload/mood_picker_dialog.dart';
import 'package:phoenix/widgets/upload/photo_picker_sheet.dart';
import 'package:phoenix/styles/app_palette.dart';
import 'package:image_picker/image_picker.dart';

class UploadReflectionPage extends StatefulWidget {
  const UploadReflectionPage({super.key});

  @override
  State<UploadReflectionPage> createState() => _UploadReflectionPageState();
}

class _UploadReflectionPageState extends State<UploadReflectionPage> {
  final TextEditingController headlineCtrl = TextEditingController();
  final TextEditingController journalCtrl = TextEditingController();

  Color? selectedEmotion;

  XFile? selectedImage;

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
                    onTap: () async {
                      final file = await photoPickerSheet(context);  // << THIS PART UPDATED
                      if (file != null) {
                        setState(() {
                          selectedImage = file;
                        });
                      }
                    },
                    child: selectedImage == null
                        ? const DashedUploadBox()
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(
                        File(selectedImage!.path),
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.cover,
                      ),

                    ),
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
                      fillColor: const Color(0xFFF8F8F8),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:  BorderSide(
                          color: Colors.grey.shade400,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppPalette.primary, // stays black when focused
                          width: 1,
                        ),
                      ),
                      counterText: '', // optional: hide default counter if you manage it manually
                    ),
                  ),


                  const SizedBox(height: 20),

                  //journal and mood picker
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => MoodPickerDialog.showMoodPicker(context, (color) {
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
                      hintText: "It’s okay to be honest, this space is for you…",
                      alignLabelWithHint: true,
                      filled: true,
                      fillColor: const Color(0xFFF8F8F8),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:  BorderSide(
                          color: Colors.grey.shade400, // black stroke
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppPalette.primary, // same black
                          width: 1,
                        ),
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
                style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
      // Nav handled by shell
    );
  }
}

