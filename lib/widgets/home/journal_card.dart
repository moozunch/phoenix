import 'package:flutter/material.dart';

class JournalCard extends StatelessWidget {
  final DateTime date;
  final String text;
  final String? photoUrl;
  const JournalCard({super.key, required this.date, required this.text, this.photoUrl});

  String _formatDate(DateTime d) {
    const names = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day.toString().padLeft(2,'0')} ${names[d.month-1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = _formatDate(date);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Text(dateLabel, style: const TextStyle(fontSize: 10, color: Colors.black54)),
          ),
          if (photoUrl != null && photoUrl!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(photoUrl!, height: 160, width: double.infinity, fit: BoxFit.cover),
              ),
            ),
          Text(text,
              style: const TextStyle(fontSize: 12, height: 1.25),
              maxLines: 3,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
