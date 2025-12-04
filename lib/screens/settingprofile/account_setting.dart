import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phoenix/styles/app_palette.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:phoenix/widgets/show_modern_snackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountSettingPage extends StatefulWidget {
  const AccountSettingPage({super.key});

  @override
  State<AccountSettingPage> createState() => _AccountSettingPageState();
}

class _AccountSettingPageState extends State<AccountSettingPage> {
  String gender = "Female";
  DateTime? birthDate;

  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final currentPasswordCtrl = TextEditingController();
  final deletePasswordCtrl = TextEditingController();

  late String originalEmail;
  bool loading = false;

  late String originalGender;
  DateTime? originalBirthDate;

  @override
  void initState() {
    super.initState();

    originalGender = gender;
    originalBirthDate = birthDate;


    final user = FirebaseAuth.instance.currentUser;
    originalEmail = user?.email ?? '';
    emailCtrl.text = originalEmail;

    emailCtrl.addListener(_updateButtonState);
    passwordCtrl.addListener(_updateButtonState);
    currentPasswordCtrl.addListener(_updateButtonState);

    _loadUserData();
  }

  @override
  void dispose() {
    emailCtrl.removeListener(_updateButtonState);
    passwordCtrl.removeListener(_updateButtonState);
    currentPasswordCtrl.removeListener(_updateButtonState);
    emailCtrl.dispose();
    passwordCtrl.dispose();
    currentPasswordCtrl.dispose();
    deletePasswordCtrl.dispose();
    super.dispose();
  }

  bool get _canSave {
    final emailChanged = emailCtrl.text.trim() != originalEmail;
    final passwordChanged = passwordCtrl.text.isNotEmpty;
    final genderChanged = gender != originalGender;
    final birthDateChanged = birthDate != originalBirthDate;

    final passwordValid =
        passwordCtrl.text.isEmpty || passwordCtrl.text.length >= 6;

    final currentPasswordValid =
        !passwordChanged || currentPasswordCtrl.text.isNotEmpty;

    final hasChanges = emailChanged || passwordChanged || genderChanged || birthDateChanged;

    return hasChanges && passwordValid && currentPasswordValid;
  }

  void _updateButtonState() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          "Account",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.textTheme.titleLarge!.color,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => context.pop('/setting_profile'),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _editableMenuItem(
                title: "Change Email",
                controller: emailCtrl,
                hint: "Enter your email",
                theme: theme,
              ),
              const SizedBox(height: 12),
              _editableMenuItem(
                title: "Change Password",
                controller: passwordCtrl,
                hint: "Enter new password",
                obscureText: true,
                theme: theme,
              ),
              const SizedBox(height: 12),
              _editableMenuItem(
                title: "Current Password *",
                controller: currentPasswordCtrl,
                hint: "Enter current password",
                obscureText: true,
                theme: theme,
              ),
              const SizedBox(height: 20),

              _menuItem(
                title: "Gender",
                value: gender,
                onTap: _selectGender,
                theme: theme,
              ),
              _menuItem(
                title: "Birth Date",
                value: birthDate == null
                    ? "Select"
                    : "${birthDate!.year}.${birthDate!.month.toString().padLeft(2, '0')}.${birthDate!.day.toString().padLeft(2, '0')}",
                onTap: _selectBirthDate,
                theme: theme,
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: (_canSave && !loading) ? _saveChanges : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: (_canSave && !loading)
                      ? AppPalette.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  foregroundColor: (_canSave && !loading)
                  ?Colors.white
                  : theme.colorScheme.onSurface.withValues(alpha: 0.5),//when disabled
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: loading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text("Save Changes"),
              ),

              const SizedBox(height: 20),

              GestureDetector(
                onTap: () => _showDeleteDialog(context),
                child: const Text(
                  "Delete Account",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //delete account dialog
  void _showDeleteDialog(BuildContext context) {
    deletePasswordCtrl.clear();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;

            final hasText = deletePasswordCtrl.text.isNotEmpty;
            final primaryColor = theme.colorScheme.primary;

            final borderColor = hasText
                ? primaryColor
                : (isDark ? Colors.grey[700]! : Colors.grey[400]!);

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: theme.colorScheme.surface,

              title: const Text("Delete Account"),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "To continue, please enter your current password:",
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: deletePasswordCtrl,
                    obscureText: true,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: "Current Password",
                      filled: true,
                      fillColor: isDark ? Colors.grey[850] : Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 12,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: borderColor, width: 1.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: primaryColor, width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _deleteAccount();
                  },
                  style: TextButton.styleFrom(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Delete",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  //delete account logic
  Future<void> _deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;
    final password = deletePasswordCtrl.text.trim();

    if (user == null || email == null) {
      if (!mounted) return;
      showModernSnackbar(context, "User not found.");
      return;
    }

    if (password.isEmpty) {
      if (!mounted) return;
      showModernSnackbar(context, "Password cannot be empty.");
      return;
    }

    try {
      final cred = EmailAuthProvider.credential(email: email, password: password);
      await user.reauthenticateWithCredential(cred);
      await user.delete();

      if (!mounted) return;

      showModernSnackbar(context, "Account deleted successfully.");
      context.go('/signin');
    } catch (e) {
      if (!mounted) return;
      showModernSnackbar(context, "Failed to delete account: $e");
    }
  }

  //save profile
  Future<void> _saveProfileData() async {
    try {
      final supabase = Supabase.instance.client;
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final response = await supabase
          .from('users')
          .select()
          .eq('uid', user.uid)
          .maybeSingle();

      if (response == null) {
        await supabase.from('users').insert({
          'uid': user.uid,
          'gender': gender,
          'birth_date': birthDate?.toIso8601String(),
        });
      } else {
        await supabase.from('users').update({
          'gender': gender,
          'birth_date': birthDate?.toIso8601String(),
        }).eq('uid', user.uid);
      }
      await _loadUserData();
    } catch (e) {
      if (!mounted) return;
      showModernSnackbar(context, "Failed to save profile data: $e");
    }
  }

  Future<void> _loadUserData() async{
    try{
      final supabase = Supabase.instance.client;
      final user = FirebaseAuth.instance.currentUser;
      if(user == null) return;

      final response = await supabase
      .from('users')
      .select()
      .eq('uid', user.uid)
      .maybeSingle();

      if(response != null){
        setState(() {
          gender = response['gender'] ?? 'Female';
          birthDate = response['birth_date'] != null
          ? DateTime.parse(response['birth_date'])
              : null;

          originalGender = gender;
          originalBirthDate = birthDate;
        });
      }
    } catch (e){
      if(!mounted) return;
      showModernSnackbar(context, "Failed to load profile: $e" );
    }
  }


  Widget _editableMenuItem({
    required String title,
    required TextEditingController controller,
    required ThemeData theme,
    String? hint,
    bool obscureText = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(13),
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(color: theme.textTheme.bodyLarge!.color),
        ),
        subtitle: TextField(
          controller: controller,
          obscureText: obscureText,
          style: TextStyle(color: theme.textTheme.bodyMedium!.color),
          decoration: InputDecoration(
            hintText: hint,
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ),
      ),
    );
  }

  Widget _menuItem({
    required String title,
    String? value,
    required Function() onTap,
    required ThemeData theme,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(13),
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(color: theme.textTheme.bodyLarge!.color),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (value != null)
              Text(
                value,
                style: TextStyle(color: theme.textTheme.bodyMedium!.color),
              ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_forward_ios,
                size: 16, color: theme.iconTheme.color),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  void _selectGender() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 12),
            _genderOption("Male", theme),
            _divider(theme),
            _genderOption("Female", theme),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style:
                TextStyle(fontWeight: FontWeight.bold, color: AppPalette.primary),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _genderOption(String label, ThemeData theme) {
    return InkWell(
      onTap: () {
        setState(() => gender = label);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        width: double.infinity,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: theme.textTheme.bodyLarge!.color,
          ),
        ),
      ),
    );
  }

  void _selectBirthDate() async {
    final theme = Theme.of(context);
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            datePickerTheme:
            DatePickerThemeData(backgroundColor: theme.colorScheme.surface),
          ),
          child: child!,
        );
      },
    );
    if (date != null) setState(() => birthDate = date);
  }

  Widget _divider(ThemeData theme) => Divider(
    height: 1,
    thickness: 1,
    color: theme.dividerColor,
  );

  Future<void> _saveChanges() async {
    final newEmail = emailCtrl.text.trim();
    final newPassword = passwordCtrl.text.trim();
    final currentPassword = currentPasswordCtrl.text;

    if (newEmail.isEmpty) return;

    if (newPassword.isNotEmpty && newPassword.length < 6) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password must be at least 6 characters")),
      );
      return;
    }

    if (newPassword.isNotEmpty && currentPassword.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Current password is required to change password")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      if (newPassword.isNotEmpty) {
        final cred = EmailAuthProvider.credential(
            email: user.email!, password: currentPassword);
        await user.reauthenticateWithCredential(cred);
        await user.updatePassword(newPassword);
      }

      if (newEmail != user.email) {
        await user.verifyBeforeUpdateEmail(newEmail);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account updated successfully")),
      );

      passwordCtrl.clear();
      currentPasswordCtrl.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update: $e")),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
    await _saveProfileData();
  }

}
