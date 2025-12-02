import 'package:flutter/material.dart';
import 'package:phoenix/widgets/home/journal_card.dart';

class JournalList extends StatelessWidget {
  final List<JournalEntry> entries;
  final void Function(JournalEntry)? onTapEntry;

  const JournalList({
    super.key,
    required this.entries,
    this.onTapEntry,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Center(
        child: Text(
          'No journal entries yet.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.color
                ?.withValues(alpha: 0.4),
          ),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) => JournalCard(
        date: entries[i].date,
        headline: entries[i].headline,
        body: entries[i].body,
        mood: entries[i].mood,
        tag: entries[i].tag,
        onDetail: () => onTapEntry?.call(entries[i]),
      ),
    );
  }
}

class JournalEntry {
  final DateTime date;
  final String headline;
  final String body;
  final String mood;
  final String tag;
  final String? imageUrl;
  JournalEntry({
    required this.date,
    required this.headline,
    required this.body,
    required this.mood,
    required this.tag,
    this.imageUrl,
  });
}
