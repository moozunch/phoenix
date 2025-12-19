// Firestore removed; use plain mapping

class PhotoModel {
  final String photoId;
  final String uid;
  final DateTime date;
  final String? caption;
  final String photoUrl;
  final DateTime createdAt;

  PhotoModel({
    required this.photoId,
    required this.uid,
    required this.date,
    this.caption,
    required this.photoUrl,
    required this.createdAt,
  });

  // Firestore factory removed

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'date': date.toIso8601String(),
      'caption': caption,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
