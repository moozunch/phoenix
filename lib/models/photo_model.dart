import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory PhotoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PhotoModel(
      photoId: doc.id,
      uid: data['uid'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      caption: data['caption'],
      photoUrl: data['photoUrl'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'date': Timestamp.fromDate(date),
      'caption': caption,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
