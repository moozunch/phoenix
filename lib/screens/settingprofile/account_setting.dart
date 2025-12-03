import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phoenix/styles/app_palette.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountSettingPage extends StatefulWidget {
  const AccountSettingPage({super.key});

  @override
  State<AccountSettingPage> createState() => _AccountSettingPageState();
}

class _AccountSettingPageState extends State<AccountSettingPage> {
  String gender = "Male";
  DateTime? birthDate;

  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final currentPasswordCtrl = TextEditingController();

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
  }

  @override
  void dispose() {
    emailCtrl.removeListener(_updateButtonState);
    passwordCtrl.removeListener(_updateButtonState);
    currentPasswordCtrl.removeListener(_updateButtonState);
    emailCtrl.dispose();
    passwordCtrl.dispose();
    currentPasswordCtrl.dispose();
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
                onTap: () {},
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
  }
}
