import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phoenix/styles/app_palette.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:phoenix/services/supabase_user_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:phoenix/widgets/upload/photo_picker_sheet.dart';
import 'package:phoenix/services/storage_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
    XFile? selectedProfileImage;
    bool isUploadingProfilePic = false;
    // ...existing code...
  final nameCtrl = TextEditingController();
  final usernameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  bool loading = true;
  String? profilePicUrl;

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
        nameCtrl.text = fetched.name;
        usernameCtrl.text = fetched.username;
        emailCtrl.text = user.email ?? '';
        descCtrl.text = '';
        profilePicUrl = fetched.profilePicUrl;
      }
    }
    if (context.mounted) setState(() => loading = false);
  }

  Future<void> _updateProfile() async {
        // If profile image is picked, upload and update profile
        if (selectedProfileImage != null) {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            if (context.mounted) setState(() => isUploadingProfilePic = true);
            try {
              final photoUrl = await StorageService().uploadImageToSupabase(
                File(selectedProfileImage!.path),
                'profile_picture',
                user.uid,
              );
              await SupabaseUserService().updateProfilePic(user.uid, photoUrl);
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to upload profile picture: $e')),
                );
              }
            }
            if (context.mounted) setState(() => isUploadingProfilePic = false);
          }
        }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await SupabaseUserService().updateUser(user.uid, {
      'name': nameCtrl.text,
      'username': usernameCtrl.text,
      // add other fields if needed
    });
    if (context.mounted) {
      // Use GoRouter to reload the page for latest info
      context.go('/setting_profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              //header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.pop('/setting_profile'),
                    child: const Icon(Icons.arrow_back, size: 26),
                  ),
                  const Text(
                    "Edit Profile",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: _updateProfile,
                    child: Icon(
                      Icons.check,
                      size: 28,
                      color: AppPalette.primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              //profile image
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final file = await photoPickerSheet(context);
                        if (file != null) {
                          setState(() {
                            selectedProfileImage = file;
                          });
                        }
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(65),
                        child: selectedProfileImage != null
                            ? Image.file(
                                File(selectedProfileImage!.path),
                                width: 130,
                                height: 130,
                                fit: BoxFit.cover,
                              )
                            : (profilePicUrl != null && profilePicUrl!.isNotEmpty)
                                ? Image.network(
                                    profilePicUrl!,
                                    width: 130,
                                    height: 130,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    "assets/images/no_profile_picture.png",
                                    width: 130,
                                    height: 130,
                                    fit: BoxFit.cover,
                                  ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () async {
                          final file = await photoPickerSheet(context);
                          if (file != null) {
                            setState(() {
                              selectedProfileImage = file;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(color: Colors.black26),
                          ),
                          child: isUploadingProfilePic
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.camera_alt, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              const Center(
                child: Text(
                  "Profile Image",
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),

              const SizedBox(height: 24),

              //display name
              const Text("Display Name",
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              _inputField(
                controller: nameCtrl,
                hint: "What you want to be called",
                icon: Icons.badge_outlined,
              ),

              const SizedBox(height: 18),

              //username
              // const Text("Username",
              //     style: TextStyle(
              //         fontSize: 15, fontWeight: FontWeight.w600)),

              const Text("Username",
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              _inputField(
                controller: usernameCtrl,
                hint: "username",
                icon: Icons.alternate_email,
              ),

              const SizedBox(height: 18),

              //email
              const Text("Email",
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              _inputField(
                controller: emailCtrl,
                hint: "email@something.com",
                icon: Icons.email_outlined,
                enabled: false,
              ),

              const SizedBox(height: 18),
              // DESCRIPTION
              const Text("Description",
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              _inputField(
                controller: descCtrl,
                hint: "tell something about yourself",
                icon: Icons.edit_note,
              ),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField({required TextEditingController controller, required String hint, required IconData icon, bool enabled = true}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black26, width: 1),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 15),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          suffixIcon: Icon(icon, size: 20),
        ),
      ),
    );
  }
}
