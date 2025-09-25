import 'package:phoenix/screens/splashScreen.dart';
import 'package:phoenix/screens/HomePage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'phoenix',
      theme: ThemeData(
      ),
      initialRoute: '/',
            routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomePage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

