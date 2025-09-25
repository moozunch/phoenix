import 'package:phoenix/screens/splashScreen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AnimeVerse',
      theme: ThemeData(
      ),
      initialRoute: '/',
            routes: {
        '/': (context) => const SplashScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}