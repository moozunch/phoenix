import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/journal_model.dart';
import '../models/photo_model.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // USER CRUD
  Future<void> createUser(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  Future<void> deleteUser(String uid) async {
    await _db.collection('users').doc(uid).delete();
  }

  // JOURNAL CRUD
  Future<String> createJournal(JournalModel journal) async {
    final doc = await _db.collection('journals').add(journal.toMap());
    return doc.id;
  }

  Future<List<JournalModel>> getJournals(String uid) async {
    final snap = await _db.collection('journals').where('uid', isEqualTo: uid).get();
    return snap.docs.map((doc) => JournalModel.fromFirestore(doc)).toList();
  }

  Future<void> updateJournal(String journalId, Map<String, dynamic> data) async {
    await _db.collection('journals').doc(journalId).update(data);
  }

  Future<void> deleteJournal(String journalId) async {
    await _db.collection('journals').doc(journalId).delete();
  }

  // PHOTO CRUD
  Future<String> createPhoto(PhotoModel photo) async {
    final doc = await _db.collection('photos').add(photo.toMap());
    return doc.id;
  }

  Future<List<PhotoModel>> getPhotos(String uid) async {
    final snap = await _db.collection('photos').where('uid', isEqualTo: uid).get();
    return snap.docs.map((doc) => PhotoModel.fromFirestore(doc)).toList();
  }

  Future<void> updatePhoto(String photoId, Map<String, dynamic> data) async {
    await _db.collection('photos').doc(photoId).update(data);
  }

  Future<void> deletePhoto(String photoId) async {
    await _db.collection('photos').doc(photoId).delete();
  }
}
