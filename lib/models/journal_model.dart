// Firestore removed; using Supabase mapping

class JournalModel {
    factory JournalModel.fromSupabase(Map<String, dynamic> data) {
      return JournalModel(
        journalId: data['id']?.toString() ?? '',
        uid: data['uid'] ?? '',
        date: DateTime.parse(data['date'] ?? DateTime.now().toIso8601String()),
        headline: data['headline'] ?? '',
        body: data['body'] ?? '',
        mood: data['mood'] ?? '',
        photoUrl: data['photo_url'],
        createdAt: data['created_at'] != null ? DateTime.parse(data['created_at']) : DateTime.now(),
      );
    }
  final String journalId;
  final String uid;
  final DateTime date;
  final String headline;
  final String body;
  final String mood;
  final String? photoUrl;
  final DateTime createdAt;

  JournalModel({
    required this.journalId,
    required this.uid,
    required this.date,
    required this.headline,
    required this.body,
    required this.mood,
    this.photoUrl,
    required this.createdAt,
  });

  // Firestore factory removed

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'date': date.toIso8601String(),
      'headline': headline,
      'body': body,
      'mood': mood,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
