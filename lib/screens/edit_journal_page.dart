import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phoenix/widgets/upload/dashed_upload_box.dart';
import 'package:phoenix/widgets/upload/mood_picker_dialog.dart';
import 'package:phoenix/styles/app_palette.dart';
import 'package:phoenix/services/supabase_journal_service.dart';

class EditJournalPage extends StatefulWidget {
  final String journalId;
  final String headline;
  final String body;
  final String mood;
  final String? photoUrl;

  const EditJournalPage({
    super.key,
    required this.journalId,
    required this.headline,
    required this.body,
    required this.mood,
    this.photoUrl,
  });

  @override
  State<EditJournalPage> createState() => _EditJournalPageState();
}

class _EditJournalPageState extends State<EditJournalPage> {
  bool isUploading = false;
  late TextEditingController headlineCtrl;
  late TextEditingController journalCtrl;
  Color? selectedEmotion;

  @override
  void initState() {
    super.initState();
    headlineCtrl = TextEditingController(text: widget.headline);
    journalCtrl = TextEditingController(text: widget.body);
    selectedEmotion = _parseMoodColor(widget.mood);
  }

  Color? _parseMoodColor(String mood) {
    if (mood.isEmpty) return null;
    final parts = mood.split(',');
    if (parts.length == 3) {
      try {
        final values = parts.map((p) => double.parse(p.trim())).toList();
        final isNormalized = values.every((v) => v >= 0.0 && v <= 1.0);
        final r = isNormalized ? (values[0] * 255).round() : values[0].round();
        final g = isNormalized ? (values[1] * 255).round() : values[1].round();
        final b = isNormalized ? (values[2] * 255).round() : values[2].round();
        return Color.fromRGBO(
          r.clamp(0, 255),
          g.clamp(0, 255),
          b.clamp(0, 255),
          1,
        );
      } catch (_) {}
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, statusBarHeight + 60, 20, 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image preview only
                  widget.photoUrl == null || widget.photoUrl!.isEmpty
                      ? const DashedUploadBox()
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            widget.photoUrl!,
                            width: double.infinity,
                            height: 220,
                            fit: BoxFit.cover,
                          ),
                        ),
                  const SizedBox(height: 30),
                  //headline
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
                    decoration: InputDecoration(
                      hintText: "Please insert your day’s headline…",
                      filled: true,
                      fillColor: cs.surface,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: cs.onSurfaceVariant,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppPalette.primary,
                          width: 1,
                        ),
                      ),
                      counterText: '',
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
                          backgroundColor: selectedEmotion ??  cs.surfaceContainerHighest,
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
                      fillColor:cs.surface,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: cs.onSurfaceVariant,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
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
          //header arrow and date
          Positioned(
            top: statusBarHeight + 8,
            left: 0,
            right: 0,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, size: 22, color: cs.onSurface),
                  onPressed: () => GoRouter.of(context).pop(),
                ),
                const Spacer(),
                 Text(
                  "Edit Journal",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: cs.onSurface),
                ),
                const Spacer(),
                const SizedBox(width: 48),
              ],
            ),
          ),
          //button save
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
                if (headlineCtrl.text.isEmpty && journalCtrl.text.isEmpty) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a headline or journal.')),
                    );
                  }
                  return;
                }
                setState(() => isUploading = true);
                try {
                  await SupabaseJournalService().updateJournal(
                    journalId: widget.journalId,
                    headline: headlineCtrl.text,
                    body: journalCtrl.text,
                    mood: selectedEmotion == null ? '' : '${selectedEmotion!.r},${selectedEmotion!.g},${selectedEmotion!.b}',
                  );
                  setState(() => isUploading = false);
                  if (context.mounted) GoRouter.of(context).pop();
                } catch (e) {
                  setState(() => isUploading = false);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Update failed: $e')),
                    );
                  }
                }
              },
              child: isUploading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text(
                      "Save",
                      style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}