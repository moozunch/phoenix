import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phoenix/styles/app_palette.dart';

class EditProfilePage extends StatelessWidget{
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
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
                    style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)
                  ),
                  GestureDetector(
                    onTap: (){
                      //confirmation
                    },
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
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: const DecorationImage(
                          fit: BoxFit.cover,
                          //ganti profile
                          image: AssetImage("assets/profile.png"),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(color: Colors.black26),
                      ),
                      child: const Icon(Icons.camera_alt, size: 18),
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
                hint: "Udin",
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
                hint: "@walidudin",
                icon: Icons.alternate_email,
              ),

              const SizedBox(height: 18),

              //email
              const Text("Email",
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              _inputField(
                hint: "walid@gmail.com",
                icon: Icons.email_outlined,
              ),

              const SizedBox(height: 18),
              // DESCRIPTION
              const Text("Description",
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              _inputField(
                hint: "miaw miaw miaw nyan",
                icon: Icons.edit_note,
              ),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField({required String hint, required IconData icon}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black26, width: 1),
      ),
      child: TextField(
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
