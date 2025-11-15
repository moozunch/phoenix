import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate right after first frame with only a tiny delay to avoid jank
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;
      // Always start at boarding; router allows it regardless of flags
      context.go('/boarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87, 
      body: Center(
        child: Lottie.asset(
          'assets/json/phoenix.json',
          width: MediaQuery.of(context).size.width * 1.5,  
          height: MediaQuery.of(context).size.width * 0.75,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
