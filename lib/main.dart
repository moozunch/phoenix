import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phoenix/core/app_state.dart';
import 'package:phoenix/router/app_router.dart';
import 'package:phoenix/styles/app_palette.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase with generated options for each platform
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // App Check activation (stub). Enable in console first for services you use.
  // Uses debug provider in debug builds, and integrity provider in release.
  await FirebaseAppCheck.instance.activate(
    androidProvider: kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
    // Use App Attest in production, debug provider in debug builds. If App Attest unsupported it will internally fall back.
    appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.appAttest,
    // Web provider omitted for now; add reCAPTCHA when deploying web version.
  );
  final appState = await AppState.create();
  final appRouter = AppRouter(appState);
  runApp(MyApp(router: appRouter.router));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: 'PlusJakartaSans',
    );
    return MaterialApp.router(
      title: 'phoenix',
      theme: base.copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: AppPalette.primary,)
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

