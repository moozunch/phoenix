import 'package:flutter/material.dart';

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

  const TodayEntryDetailPage({
    super.key,
    required this.headline,
    required this.body,
    required this.mood,
    required this.date,
    required this.photoUrl,
  });

  String _formatDate(DateTime d) {
    const names = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${names[d.month-1]}, ${d.day.toString().padLeft(2,'0')} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final moodName = _mapMoodToAsset(mood);
    final moodAsset = moodName.isNotEmpty ? 'assets/images/feelings/$moodName.png' : null;
    return DraggableScrollableSheet(
      initialChildSize: 0.95,
      minChildSize: 0.6,
      maxChildSize: 0.95,
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
                const SizedBox(height: 10),
                Center(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onVerticalDragUpdate: (details) {
                      if (details.primaryDelta != null && details.primaryDelta! > 8) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Container(
                      width: 38,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
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
                    const Spacer(),
                    Text(
                      _formatDate(date),
                      style: const TextStyle(fontSize: 12, color: Color(0xFF8F9BB3)),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  headline,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF222B45)),
                ),
                const SizedBox(height: 18),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    photoUrl,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 18),
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
