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
        descCtrl.text = fetched.desc ?? '';
        profilePicUrl = fetched.profilePicUrl;
      }
    }
    if (!mounted) return;
    setState(() => loading = false);
  }

  Future<void> _updateProfile() async {
    if (selectedProfileImage != null) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (!mounted) return;
        setState(() => isUploadingProfilePic = true);

        try {
          final photoUrl = await StorageService().uploadImageToSupabase(
            File(selectedProfileImage!.path),
            'profile_picture',
            user.uid,
          );
          await SupabaseUserService().updateProfilePic(user.uid, photoUrl);
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload profile picture: $e')),
          );
        }

        if (!mounted) return;
        setState(() => isUploadingProfilePic = false);
      }
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await SupabaseUserService().updateUser(user.uid, {
      'name': nameCtrl.text,
      'username': usernameCtrl.text,
      'desc': descCtrl.text,
    });

    if (!mounted) return;

    context.go('/setting_profile');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // ✔ berubah otomatis
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.pop('/setting_profile'),
                    child: Icon(Icons.arrow_back,
                        size: 26, color: theme.iconTheme.color),
                  ),
                  Text(
                    "Edit Profile",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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

              // PROFILE IMAGE
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final file = await photoPickerSheet(context);
                        if (file != null) {
                          setState(() => selectedProfileImage = file);
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

                    // CAMERA BUTTON
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () async {
                          final file = await photoPickerSheet(context);
                          if (file != null) {
                            setState(() => selectedProfileImage = file);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface, // ✔ jangan hardcoded
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: isUploadingProfilePic
                              ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                              : Icon(Icons.camera_alt,
                              size: 18, color: theme.iconTheme.color),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              Center(
                child: Text(
                  "Profile Image",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ------ INPUT SECTIONS ------
              _label("Display Name"),
              _inputField(controller: nameCtrl, hint: "What you want to be called", icon: Icons.badge_outlined),

              const SizedBox(height: 18),

              _label("Username"),
              _inputField(controller: usernameCtrl, hint: "username", icon: Icons.alternate_email),

              const SizedBox(height: 18),

              _label("Email"),
              _inputField(controller: emailCtrl, hint: "email@something.com", icon: Icons.email_outlined, enabled: false),

              const SizedBox(height: 18),

              _label("Description"),
              _inputField(controller: descCtrl, hint: "tell something about yourself", icon: Icons.edit_note),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool enabled = true,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, // ✔ update dari hardcoded light grey
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor), // ✔ adaptif
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(fontSize: 15),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          suffixIcon: Icon(icon, size: 20, color: theme.iconTheme.color),
        ),
      ),
    );
  }
}
