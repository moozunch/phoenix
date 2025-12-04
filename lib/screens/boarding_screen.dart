import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phoenix/core/app_state.dart';
import 'package:phoenix/models/user_model.dart';
import 'package:phoenix/services/auth_service.dart';
import 'package:phoenix/services/supabase_user_service.dart';
import 'package:phoenix/styles/app_palette.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_svg/flutter_svg.dart';

const double kBoardingLogoScale = 0.80; 
const double kBoardingLogoMin = 120.0;  
const double kBoardingLogoMax = 360.0; 

class BoardingScreen extends StatelessWidget {
  const BoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final logoHeight = (media.width * kBoardingLogoScale).clamp(kBoardingLogoMin, kBoardingLogoMax);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top gradient background
            Container(
              height: media.height * 0.38,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFF7E3E0),
                    Color(0xFFF7E3E0),
                    Colors.white,
                  ],
                  stops: [0.0, 0.7, 1.0],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Center(
                child: SizedBox(
                  height: logoHeight,
                  width: logoHeight,
                  child: Lottie.asset(
                    'assets/json/starselfie.json',
                    fit: BoxFit.contain,
                    repeat: true,
                    errorBuilder: (context, error, stack) => Icon(
                      Icons.auto_fix_high,
                      size: logoHeight * 0.3,
                      color: AppPalette.primary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Reflect, grow, and\nfind calm every day',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _BoardingButton(
                    icon: Icons.email,
                    label: 'Continue with email',
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    onPressed: () async {
                      final state = await AppState.create();
                      await state.setHasOnboarded(true);
                      if (!context.mounted) return;
                      context.go('/signin');
                    },
                  ),
                  const SizedBox(height: 14),
                  // _BoardingButton(
                  //   icon: Icons.apple,
                  //   label: 'Continue with Apple',
                  //   backgroundColor: Colors.white,
                  //   textColor: Colors.black,
                  //   borderColor: Colors.black,
                  //   onPressed: () async {
                  //     final state = await AppState.create();
                  //     await state.setHasOnboarded(true);
                  //     if (!context.mounted) return;
                  //     context.go('/signin?provider=apple');
                  //   },
                  // ),
                      _BoardingButton(
                        icon: Icons.apple,
                        label: 'Continue with Apple',
                        backgroundColor: Colors.white,
                        textColor: Colors.black,
                        borderColor: Colors.black,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.black87,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                content: const Text(
                                  'Apple Sign-In is coming soon!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                duration: Duration(milliseconds: 1600),
                              ),
                            );
                          },
                      ),
                  const SizedBox(height: 14),
                  _BoardingButton(
                    svgAsset: 'assets/images/icon/google_logo_bw.svg',
                    label: 'Continue with Google',
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    borderColor: Colors.black,
                    onPressed: () async {
                      // Google sign-in logic, matching sign_in_page.dart
                      final ctx = context;
                      final router = GoRouter.of(ctx);
                      final messenger = ScaffoldMessenger.of(ctx);
                      try {
                        final user = await AuthService.instance.signInGoogle();
                        if (!ctx.mounted) return;
                        if (user != null) {
                          // Insert user to Supabase if not exists
                          final supaUser = await SupabaseUserService().getUser(user.uid);
                          if (supaUser == null) {
                            await SupabaseUserService().createUser(UserModel(
                              uid: user.uid,
                              name: user.displayName ?? '',
                              username: '',
                              profilePicUrl: user.photoURL ?? '',
                              joinedAt: DateTime.now(),
                              routine: 'daily',
                              journalCount: 0,
                              photoCount: 0,
                              daysActive: 0,
                              reminderTime: '08:00:00',
                            ));
                            // New user: go to onboarding/boarding
                            final state = await AppState.create();
                            await state.setHasOnboarded(false);
                            await state.setIsNewUser(true);
                            router.go('/boarding');
                          } else {
                            // Existing user: go to home
                            final state = await AppState.create();
                            await state.setHasOnboarded(true);
                            await state.setLoggedIn(true);
                            await state.setIsNewUser(false);
                            router.go('/home');
                          }
                        } else {
                          messenger.showSnackBar(
                            const SnackBar(content: Text('Google Sign-In failed.')),
                          );
                        }
                      } catch (e) {
                        messenger.showSnackBar(
                          const SnackBar(content: Text('An error occurred during Google Sign-In.')),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 18),
                  Text(
                    "By continuing, you agree to Phoenix's Terms of Use and Privacy Policy",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BoardingButton extends StatelessWidget {
  final IconData? icon;
  final String? svgAsset;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final VoidCallback onPressed;

  const _BoardingButton({
    this.icon,
    this.svgAsset,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: borderColor != null ? BorderSide(color: borderColor!, width: 1.2) : BorderSide.none,
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (svgAsset != null)
              SizedBox(
                height: 22,
                width: 22,
                child: SvgPicture.asset(
                  svgAsset!,
                  height: 22,
                  width: 22,
                ),
              )
            else if (icon != null)
              SizedBox(
                height: 22,
                width: 22,
                child: Icon(icon, color: textColor, size: 22),
              ),
            const SizedBox(width: 10),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
