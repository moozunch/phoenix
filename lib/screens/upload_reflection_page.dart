import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phoenix/widgets/upload/dashed_upload_box.dart';
import 'package:phoenix/widgets/upload/mood_picker_dialog.dart';
import 'package:phoenix/widgets/upload/photo_picker_sheet.dart';
import 'package:phoenix/styles/app_palette.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:phoenix/services/supabase_journal_service.dart';
import 'package:phoenix/services/storage_service.dart';
import 'package:intl/intl.dart';

class UploadReflectionPage extends StatefulWidget {
  const UploadReflectionPage({super.key});

  @override
  State<UploadReflectionPage> createState() => _UploadReflectionPageState();
}

class _UploadReflectionPageState extends State<UploadReflectionPage> {
  bool isUploading = false;
  final TextEditingController headlineCtrl = TextEditingController();
  final TextEditingController journalCtrl = TextEditingController();

  Color? selectedEmotion;
  XFile? selectedImage;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final now = DateTime.now();
    final formattedDate = DateFormat('EEEE d MMM').format(now); // Friday 26 Sep


    return Scaffold(
      backgroundColor: cs.surface, // updated
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, statusBarHeight + 60, 20, 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  GestureDetector(
                    onTap: () async {
                      final file = await photoPickerSheet(context);
                      if (file != null) {
                        final allowedTypes = ['jpg', 'jpeg', 'png'];
                        final ext = file.name.split('.').last.toLowerCase();
                        final fileSize = await File(file.path).length();

                        if (!allowedTypes.contains(ext)) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Only JPG, JPEG, or PNG images are allowed.')),
                            );
                          }
                          return;
                        }

                        if (fileSize > 5 * 1024 * 1024) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Image size must be less than 5MB.')),
                            );
                          }
                          return;
                        }

                        setState(() => selectedImage = file);
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

                  /// HEADLINE SECTION
                  Row(
                    children: [
                      Text(
                        "Your Day’s Headline",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurface),
                      ),
                      const Spacer(),
                      Text(
                        "${headlineCtrl.text.length}/25",
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: headlineCtrl,
                    maxLength: 25,
                    onChanged: (_) => setState(() {}),
                    style: TextStyle(color: cs.onSurface),
                    decoration: InputDecoration(
                      hintText: "Please insert your day’s headline…",
                      filled: true,
                      fillColor: cs.surface, // updated
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: cs.onSurfaceVariant,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppPalette.primary,
                          width: 1,
                        ),
                      ),
                      counterText: '',
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// JOURNAL + MOOD
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => MoodPickerDialog.showMoodPicker(
                          context,
                              (color) => setState(() => selectedEmotion = color),
                        ),
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: selectedEmotion ?? cs.surfaceContainerHighest,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Your Journal",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurface),
                      ),
                      const Spacer(),
                      Text(
                        "${journalCtrl.text.length}/3000",
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: journalCtrl,
                    maxLength: 3000,
                    maxLines: 10,
                    onChanged: (_) => setState(() {}),
                    style: TextStyle(color: cs.onSurface),
                    decoration: InputDecoration(
                      hintText: "It’s okay to be honest, this space is for you…",
                      alignLabelWithHint: true,
                      filled: true,
                      fillColor: cs.surface, // updated
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: cs.onSurfaceVariant,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppPalette.primary,
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

          /// HEADER (arrow + date)
          Positioned(
            top: statusBarHeight + 8,
            left: 0,
            right: 0,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, size: 22, color: cs.onSurface),
                  onPressed: () => context.pop(),
                ),
                const Spacer(),
                Text(
                  formattedDate,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: cs.onSurface),
                ),
                const Spacer(),
                const SizedBox(width: 48),
              ],
            ),
          ),

          /// LOG BUTTON (Bottom Right)
          Positioned(
            right: 20,
            bottom: 30,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPalette.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: isUploading ? null : () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) return;

                if (headlineCtrl.text.isEmpty &&
                    journalCtrl.text.isEmpty &&
                    selectedImage == null) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a headline, journal, or photo.')),
                    );
                  }
                  return;
                }

                if (context.mounted) setState(() => isUploading = true);
                String? photoUrl;
                dynamic result;

                try {
                  if (selectedImage != null) {
                    photoUrl = await StorageService().uploadImageToSupabase(
                      File(selectedImage!.path),
                      'user_uploads',
                      user.uid,
                    );
                  }

                  result = await SupabaseJournalService().createJournal(
                    uid: user.uid,
                    headline: headlineCtrl.text,
                    body: journalCtrl.text,
                    mood: selectedEmotion == null
                        ? ''
                        : '${selectedEmotion!.r},${selectedEmotion!.g},${selectedEmotion!.b}',
                    photoUrl: photoUrl,
                    date: DateTime.now(),
                  );

                  if (context.mounted) setState(() => isUploading = false);

                  if (result is Map && result.containsKey('error')) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Upload failed: ${result['error']}')),
                      );
                    }
                  } else {
                    if (context.mounted) context.go('/home');
                  }
                } catch (e) {
                  if (context.mounted) setState(() => isUploading = false);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Upload failed: $e')),
                    );
                  }
                }
              },
              child: isUploading
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
                  : const Text(
                "Log",
                style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
