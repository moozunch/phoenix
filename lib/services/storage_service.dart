import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
class StorageService {
  // Supabase client instance
  final _supabase = Supabase.instance.client;

  /// Uploads an image to Supabase Storage bucket and returns the public URL.
  /// [bucket] is the name of your Supabase bucket (e.g., 'user_uploads').
  /// [uid] is the user id, used for foldering.
  Future<String> uploadImageToSupabase(File file, String bucket, String uid) async {
    if (!file.existsSync()) {
      throw Exception('File does not exist: ${file.path}');
    }
    final filename = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    final path = '$uid/$filename';
    try {
      await _supabase.storage.from(bucket).upload(path, file);
    } catch (e) {
      throw Exception('Supabase upload failed: $e');
    }
    // Get public URL
    final publicUrl = _supabase.storage.from(bucket).getPublicUrl(path);
    return publicUrl;
  }
}
