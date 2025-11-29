import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;
import '../models/user_model.dart';

class SupabaseUserService {
      Future<void> updateProfilePic(String uid, String photoUrl) async {
        await _supabase.from('users').update({'profilepicurl': photoUrl}).eq('uid', uid);
      }
    Future<void> createUser(UserModel user) async {
      final data = {
        'uid': user.uid,
        'name': user.name,
        'username': user.username,
        'profilepicurl': user.profilePicUrl,
        'joinedat': user.joinedAt.toIso8601String(),
        'routine': user.routine,
        'reminder_time': user.reminderTime,
        'stats': {
          'journalCount': user.journalCount,
          'photoCount': user.photoCount,
          'daysActive': user.daysActive,
        },
      };
      developer.log('Insert user to Supabase:', name: 'SupabaseUserService');
      developer.log(data.toString(), name: 'SupabaseUserService');
      final response = await Supabase.instance.client
        .from('users')
        .insert(data)
        .select()
        .single();

      developer.log('Supabase insert result:', name: 'SupabaseUserService');
      developer.log(response.toString(), name: 'SupabaseUserService');
    }
  final _supabase = Supabase.instance.client;

  Future<UserModel?> getUser(String uid) async {
    try {
      final response = await _supabase.from('users').select().eq('uid', uid).single();
      if (response == null || (response is Map && response.containsKey('error'))) {
        return null;
      }
      return UserModel.fromSupabase(response);
    } catch (e) {
      // If no user found, return null
      return null;
    }
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _supabase.from('users').update(data).eq('uid', uid);
  }
}
