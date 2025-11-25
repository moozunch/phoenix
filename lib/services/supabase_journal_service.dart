import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

class SupabaseJournalService {
  final _supabase = Supabase.instance.client;

  // Create journal
  Future<dynamic> createJournal({
    required String uid,
    required String headline,
    required String body,
    required String mood,
    String? photoUrl,
    required DateTime date,
  }) async {
    final data = {
      'uid': uid,
      'headline': headline,
      'body': body,
      'mood': mood.toString(),
      'photo_url': photoUrl,
      'date': date.toIso8601String(),
      // 'created_at' diisi otomatis oleh DB
    };
    developer.log('Data sent to Supabase journals insert:', name: 'SupabaseJournalService');
    developer.log(data.toString(), name: 'SupabaseJournalService');
    final response = await _supabase.from('journals').insert(data);
    // Return response for UI to handle error/success
    return response;
  }

  // Fetch journals for a user
  Future<List<Map<String, dynamic>>> fetchJournals(String uid) async {
    final response = await _supabase.from('journals').select().eq('uid', uid).order('date', ascending: false);
    if (response == null) {
      throw Exception('Supabase fetch failed: No response received.');
    }
    if (response is Map && response.containsKey('error')) {
      throw Exception('Supabase fetch failed: ${response['error']}');
    }
    return List<Map<String, dynamic>>.from(response);
  }
}
