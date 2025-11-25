class SupabaseJournalModel {
  final String journalId;
  final String uid;
  final String headline;
  final String body;
  final String mood;
  final String? photoUrl;
  final DateTime date;
  final DateTime createdAt;

  SupabaseJournalModel({
    required this.journalId,
    required this.uid,
    required this.headline,
    required this.body,
    required this.mood,
    this.photoUrl,
    required this.date,
    required this.createdAt,
  });

  factory SupabaseJournalModel.fromMap(Map<String, dynamic> map) {
    return SupabaseJournalModel(
      journalId: map['id'].toString(),
      uid: map['uid'],
      headline: map['headline'],
      body: map['body'],
      mood: map['mood'],
      photoUrl: map['photo_url'],
      date: DateTime.parse(map['date']),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': journalId,
      'uid': uid,
      'headline': headline,
      'body': body,
      'mood': mood,
      'photo_url': photoUrl,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
