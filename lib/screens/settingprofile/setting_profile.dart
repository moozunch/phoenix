import 'package:flutter/material.dart';
import 'package:phoenix/styles/app_palette.dart';
import 'package:phoenix/widgets/app_button.dart';
import 'package:phoenix/services/supabase_user_service.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:phoenix/models/user_model.dart';
import 'package:phoenix/services/supabase_journal_service.dart';
import 'package:phoenix/screens/settingprofile/photo_archive_page.dart';
import 'package:phoenix/screens/settingprofile/notification_settings.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SettingProfile extends StatefulWidget {
  const SettingProfile({super.key});

  @override
  State<SettingProfile> createState() => _SettingProfileState();
}

class _SettingProfileState extends State<SettingProfile> {
  UserModel? userModel;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final fetched = await SupabaseUserService().getUser(user.uid);
      if (fetched != null) {
        final journalMaps = await SupabaseJournalService().fetchJournals(user.uid);
        final journalCount = journalMaps.length;
        final photoCount = journalMaps.where((j) => j['photo_url'] != null && (j['photo_url'] as String).isNotEmpty).length;
        final daysActive = DateTime.now().difference(fetched.joinedAt).inDays + 1;
        userModel = UserModel(
          uid: fetched.uid,
          name: fetched.name,
          username: fetched.username,
          profilePicUrl: fetched.profilePicUrl,
          joinedAt: fetched.joinedAt,
          routine: fetched.routine,
          journalCount: journalCount,
          photoCount: photoCount,
          daysActive: daysActive,
          reminderTime: fetched.reminderTime,
        );
      } else {
        userModel = null;
      }
      setState(() {
        loading = false;
      });
    } else {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchUser,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : userModel == null
                    ? const Center(child: Text('User not found'))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 10),
                          const Text(
                            'My Profile',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          // profile picture
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child: userModel!.profilePicUrl.isNotEmpty
                                  ? Image.network(
                                      userModel!.profilePicUrl,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      'assets/images/no_profile_picture.png',
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(userModel!.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('@${userModel!.username}', style: const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 10),
                          Center(
                            child: AppButton(
                              label: 'Edit Profile',
                              fullWidth: false,
                              minHeight: 36,
                              onPressed: () {
                                // Use GoRouter for navigation
                                context.push('/edit_profile');
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: _infoCard(iconPath: 'assets/images/icon/entry_journal.svg', title: 'Daily Entry', quantity: '${userModel!.journalCount} journal')),
                              const SizedBox(width: 8),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (_) => SizedBox(
                                        height: MediaQuery.of(context).size.height * 0.95,
                                        child: const PhotoArchivePage(),
                                      ),
                                    );
                                  },
                                  child: _infoCard(
                                    iconPath: 'assets/images/icon/photos.svg',
                                    title: 'Photos',
                                    quantity: '${userModel!.photoCount} uploaded',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: _infoCard(iconPath: 'assets/images/icon/join.svg', title: 'Since Joined', quantity: '${userModel!.daysActive} days')),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text('Routine: ${userModel!.routine}', style: const TextStyle(fontSize: 14, color: Colors.black54)),
                          const SizedBox(height: 26),
                          // Section Pengaturan Notifikasi
                          const SizedBox(height: 30),
                          Container(
                            alignment: Alignment.centerLeft,
                            child: const Text(
                              'Pengaturan Notifikasi',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _menuItem(Icons.notifications_active, 'Pengaturan Notifikasi', onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const NotificationSettingsPage()),
                            );
                          }),
                          const SizedBox(height: 30),
                          // Menu List
                          _menuItem(Icons.person_outline, 'Account', onTap: () => context.push('/account_setting')),
                          _menuItem(Icons.desktop_windows_outlined, 'Display', onTap: () => context.push('/display')),
                          _menuItem(Icons.notifications_none, 'Announcements', onTap: () {}),
                          _menuItem(Icons.info_outline, 'Information', onTap: () {}),
                          GestureDetector(
                            onTap: () {},
                            child: Text(
                              'Sign Out',
                              style: TextStyle(
                                color: AppPalette.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
          ),
        ),
      ),
    );
  }
  }

  // Info Card Widget
  Widget _infoCard({required String iconPath, required String title, required String quantity}) {
    // Removed unused gradient variable

    return Container(
      width: 105,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFEB25A), Color(0xFFE63946)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        margin: const EdgeInsets.all(1.5),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(iconPath, width: 26, height: 26),
            const SizedBox(height: 6),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFFEB25A), Color(0xFFE63946)],
              ).createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            ),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFFEB25A), Color(0xFFE63946)],
              ).createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: Text(quantity, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Container(
          color: const Color(0xFFF7F7F7),
          child: ListTile(
            leading: Icon(icon, color: Colors.black87),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            onTap: onTap,
          ),
        ),
      ),
    );
  }

