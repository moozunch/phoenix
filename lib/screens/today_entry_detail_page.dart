import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phoenix/widgets/journal_options_menu.dart';

class TodayEntryDetailPage extends StatelessWidget {
  String _mapMoodToAsset(String mood) {
    switch (mood.trim().toLowerCase()) {
      case '0.5450980392156862,0.7647058823529411,0.2901960784313726':
        return 'happy';
      case '1.0,0.596078431372549,0.0':
        return 'sad';
      case '1.0,0.9215686274509803,0.23137254901960785':
        return 'neutral';
      case '0.2980392156862745,0.6862745098039216,0.3137254901960784':
        return 'veryhappy';
      case '0.9568627450980393,0.2627450980392157,0.21176470588235294':
        return 'verysad';
      default:
        return 'happy';
    }
  }

  final String headline;
  final String body;
  final String mood;
  final DateTime date;
  final String photoUrl;
  final String journalId;
  final VoidCallback? onEdit;

  const TodayEntryDetailPage({
    super.key,
    required this.headline,
    required this.body,
    required this.mood,
    required this.date,
    required this.photoUrl,
    required this.journalId,
    this.onEdit,
  });

  String _formatDate(DateTime d) {
    const names = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${names[d.month - 1]}, ${d.day.toString().padLeft(2, '0')} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final moodName = _mapMoodToAsset(mood);
    final moodAsset = moodName.isNotEmpty
        ? 'assets/images/feelings/$moodName.png'
        : null;

    final hasPhoto = photoUrl.isNotEmpty;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),

                // Drag handle
                Center(
                  child: Container(
                    width: 38,
                    height: 5,
                    decoration: BoxDecoration(
                      color: cs.outlineVariant,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Top bar (Close - Date - Options)
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.close, size: 26, color: cs.onSurface),
                      onPressed: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          _formatDate(date),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                    ),
                    JournalOptionsMenu(
                      journalId: journalId,
                      onEdit: () async {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                        Future.delayed(Duration.zero, () {
                          if (!context.mounted) return;
                          context.push(
                            '/edit_journal',
                            extra: {
                              'journalId': journalId,
                              'headline': headline,
                              'body': body,
                              'mood': mood,
                              'photoUrl': photoUrl,
                            },
                          );
                        });
                      },
                      onDeleted: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Mood badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          if (moodAsset != null)
                            Container(
                              width: 22,
                              height: 22,
                              decoration: const BoxDecoration(
                                color: Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Image.asset(
                                  moodAsset,
                                  width: 18,
                                  height: 18,
                                ),
                              ),
                            ),
                          const SizedBox(width: 8),
                          Text(
                            moodName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Headline
                Text(
                  headline,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),

                const SizedBox(height: 18),

                // Photo preview
                if (hasPhoto)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      photoUrl,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  ),

                if (hasPhoto) const SizedBox(height: 18),

                // Body text
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
