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
      return const Center(
        child: Text('No journal entries yet.', style: TextStyle(color: Colors.black38)),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) => JournalCard(
        date: entries[i].date,
        text: entries[i].text,
      ),
    );
  }
}

class JournalEntry {
  final DateTime date;
  final String text;
  final String? imageUrl;
  JournalEntry({required this.date, required this.text, this.imageUrl});
}
