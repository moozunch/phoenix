import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 4), () {
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87, 
      body: Center(
        child: Lottie.asset(
          'assets/json/phoenix.json',
          width: MediaQuery.of(context).size.width * 0.6,  
          height: MediaQuery.of(context).size.width * 0.3,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
