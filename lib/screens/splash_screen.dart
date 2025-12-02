import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:phoenix/core/app_state.dart';
import 'package:phoenix/styles/app_palette.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Ambil instance AppState dari router (bukan create baru)
      final appState = AppState.instance ?? await AppState.create();

      // Refresh email status
      await FirebaseAuth.instance.currentUser?.reload();

      // Tambahkan delay agar Lottie kelihatan dulu
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // === INITIAL LOGIC DI SPLASH ===

      if (!appState.isLoggedIn) {
        context.go('/boarding');
        return;
      }

      if (!appState.emailVerified) {
        context.go('/verify_email');
        return;
      }

      if (appState.isNewUser) {
        context.go('/routine_selection');
        return;
      }

      if (appState.hasOnboarded) {
        context.go('/home');
        return;
      }

      context.go('/boarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.primary,
      body: Center(
        child: Lottie.asset(
          'assets/json/phoenix.json',
          width: MediaQuery.of(context).size.width * 2,
          height: MediaQuery.of(context).size.width * 1,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
