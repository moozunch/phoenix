import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phoenix/styles/app_palette.dart';

class AccountSettingPage extends StatefulWidget{
  const AccountSettingPage({super.key});

  @override
  State<AccountSettingPage> createState() => _AccountSettingPageState();
}

class _AccountSettingPageState extends State<AccountSettingPage> {
  String gender = "Male";
  DateTime? birthDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Account",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop('/setting_profile'),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _menuItem(
                title: "Change Email",
                value: "Walid@gmail.com",
                onTap: () {},
              ),
        
              _menuItem(
                title: "Change Password",
                onTap: () {},
              ),
        
              _menuItem(
                title: "Gender",
                value: gender,
                onTap: () => _selectGender(),
              ),
        
              _menuItem(
                title: "Birth Date",
                value: birthDate == null
                    ? "Select"
                    : "${birthDate!.year}.${birthDate!.month.toString().padLeft(
                    2, '0')}.${birthDate!.day.toString().padLeft(2, '0')}",
                onTap: () => _selectBirthDate(),
              ),
        
              const SizedBox(height: 30),
        
              GestureDetector(
                onTap: () {},
                child: const Text(
                  "Delete Account",
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuItem(
      {required String title, String? value, required Function() onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(13),
      ),
      child: ListTile(
        title: Text(title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if(value != null) Text(value),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  void _selectGender() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) =>
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 12),

                _genderOption("Male"),
                _divider(),
                _genderOption("Female"),

                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppPalette.primary,
                    ),
                  ),
                )
              ],
            ),
          ),
    );
  }

  Widget _genderOption(String label) {
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
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }


  void _selectBirthDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppPalette.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            datePickerTheme: const DatePickerThemeData(
              backgroundColor: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() => birthDate = date);
    }
  }

  Widget _divider() =>
      Divider(
        height: 1,
        thickness: 1,
        color: Colors.grey.shade200,
      );
}
