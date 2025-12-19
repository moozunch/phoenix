// Firestore removed; keep Supabase mapping only

class UserModel {
    factory UserModel.fromSupabase(Map<String, dynamic> data) {
      return UserModel(
        uid: data['uid'] ?? '',
        name: data['name'] ?? '',
        username: data['username'] ?? '',
        profilePicUrl: data['profilepicurl'] ?? '',
        joinedAt: DateTime.parse(data['joinedAt'] ?? DateTime.now().toIso8601String()),
        routine: data['routine'] ?? 'daily',
        journalCount: data['stats']?['journalCount'] ?? 0,
        photoCount: data['stats']?['photoCount'] ?? 0,
        daysActive: data['stats']?['daysActive'] ?? 0,
        reminderTime: data['reminder_time'] ?? '',
        desc: data['desc'],
      );
    }
  final String uid;
  final String name;
  final String username;
  final String profilePicUrl;
  final DateTime joinedAt;
  final String routine; // 'daily' or 'weekly'
  final int journalCount;
  final int photoCount;
  final int daysActive;
  final String reminderTime;
  final String? desc;
  final String? gender;
  final DateTime? birthDate;

  UserModel({
    required this.uid,
    required this.name,
    required this.username,
    required this.profilePicUrl,
    required this.joinedAt,
    required this.routine,
    required this.journalCount,
    required this.photoCount,
    required this.daysActive,
    required this.reminderTime,
    this.desc,
    this.gender,
    this.birthDate,
  });

  // Firestore factory removed

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'username': username,
      'profilePicUrl': profilePicUrl,
      'joinedAt': joinedAt.toIso8601String(),
      'routine': routine,
      'reminder_time': reminderTime,
      if (gender != null) 'gender': gender,
      if (birthDate != null) 'birth_date': birthDate!.toIso8601String(),
      if (desc != null) 'desc': desc,
      'stats': {
        'journalCount': journalCount,
        'photoCount': photoCount,
        'daysActive': daysActive,
      },
    };
  }
}
