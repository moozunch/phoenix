import 'package:flutter/material.dart';
import 'package:phoenix/styles/app_palette.dart';
import 'package:phoenix/widgets/app_button.dart';
import 'package:flutter_svg/flutter_svg.dart';


class SettingProfile extends StatelessWidget {
  const SettingProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              const Text(
                'My Profile',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              // profile picture
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black12, width: 2),
                      image: const DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage('assets/profile.png'),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: const Icon(Icons.camera_alt, size: 16),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Text('Udin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('@walidudin', style: TextStyle(color: Colors.grey)),

              const SizedBox(height: 10),

              Center(
                child: AppButton(
                  label: 'Edit Profile',
                  fullWidth: false,
                  minHeight: 36,
                  onPressed: () {},
                ),
              ),

              const SizedBox(height: 22),

              // Stats Section
              // Row(
              //   children: [
              //     _infoCard(iconPath: 'assets/images/icon/entry_journal.svg', title: 'Daily Entry', quantity: '133 journals'),
              //     _infoCard(iconPath: 'assets/images/icon/photos.svg', title: 'Photos', quantity: '133 uploaded'),
              //     _infoCard(iconPath: 'assets/images/icon/join.svg', title: 'Since Joined', quantity: '133 days'),
              //   ],
              // ),

              Row(
                children: [
                  Expanded(child: _infoCard(iconPath: 'assets/images/icon/entry_journal.svg', title: 'Daily Entry', quantity: '133 journals')),
                  SizedBox(width: 8),
                  Expanded(child: _infoCard(iconPath: 'assets/images/icon/photos.svg', title: 'Photos', quantity: '133 uploaded')),
                  SizedBox(width: 8),
                  Expanded(child: _infoCard(iconPath: 'assets/images/icon/join.svg', title: 'Since Joined', quantity: '133 days')),
                ],
              ),

              const SizedBox(height: 26),

              // Menu List
              _menuItem(Icons.person_outline, 'Account'),
              _menuItem(Icons.desktop_windows_outlined, 'Display'),
              _menuItem(Icons.notifications_none, 'Announcements'),
              _menuItem(Icons.info_outline, 'Information'),

              const SizedBox(height: 30),

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
    );
  }

  // Info Card Widget
  Widget _infoCard({required String iconPath, required String title, required String quantity}) {
    const gradient = LinearGradient(
      colors: [Color(0xFFFEB25A), Color(0xFFE63946)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

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

  Widget _menuItem(IconData icon, String title) {
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
            onTap: () {},
          ),
        ),
      ),
    );
  }


}
