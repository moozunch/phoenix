import 'package:flutter/material.dart';

class JournalCard extends StatelessWidget {
  final DateTime date;
  final String headline;
  final String body;
  final String mood;
  final String? tag;
  final String? photoUrl;
  final VoidCallback? onDetail;
  const JournalCard({
    super.key,
    required this.date,
    required this.headline,
    required this.body,
    required this.mood,
    this.tag,
    this.photoUrl,
    this.onDetail,
  });

  String _formatDate(DateTime d) {
    const names = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day.toString().padLeft(2,'0')} ${names[d.month-1]} ${d.year}';
  }

  String _formatTime(DateTime d) {
    final hour = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return '$hour:$min';
  }

  String _mapMoodToAsset(String mood) {
    // Example mapping, update as needed based on DB values
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (mood.isNotEmpty)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: cs.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/feelings/${_mapMoodToAsset(mood)}.png',
                      width: 22,
                      height: 22,
                    ),
                  ),
                ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  headline,
                  style: t.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${_formatDate(date)} • ${_formatTime(date)}',
            style: t.bodySmall?.copyWith(
              color: t.bodySmall?.color?.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: t.bodyMedium?.copyWith(height: 1.35),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}