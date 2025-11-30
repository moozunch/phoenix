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
        return 'happy'; // fallback
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
    const names = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${names[d.month-1]}, ${d.day.toString().padLeft(2,'0')} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final moodName = _mapMoodToAsset(mood);
    final moodAsset = moodName.isNotEmpty ? 'assets/images/feelings/$moodName.png' : null;
    final hasPhoto = photoUrl.isNotEmpty;
    final minSheet = 0.4;
    final maxSheet = 0.95;
    const initialSheet = 0.75;
    return DraggableScrollableSheet(
      initialChildSize: initialSheet,
      minChildSize: minSheet,
      maxChildSize: maxSheet,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                // Drag handle above top bar
                Center(
                  child: Container(
                    width: 38,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Top bar: close, date, options
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, size: 26),
                      onPressed: () {
                        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
                      },
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          _formatDate(date),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    JournalOptionsMenu(
                      journalId: journalId,
                        onEdit: () async {
                          if (Navigator.of(context).canPop()) Navigator.of(context).pop();
                          Future.delayed(Duration.zero, () {
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
                        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                // Edit button removed, use JournalOptionsMenu only
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3C0),
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
                                child: Image.asset(moodAsset, width: 18, height: 18),
                              ),
                            ),
                          const SizedBox(width: 8),
                          Text(
                            moodName,
                            style: const TextStyle(fontSize: 14, color: Color(0xFF222B45), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  headline,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF222B45)),
                ),
                const SizedBox(height: 18),
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
                Text(
                  body,
                  style: const TextStyle(fontSize: 15, color: Color(0xFF222B45), height: 1.5),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
