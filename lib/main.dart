import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phoenix/core/app_state.dart';
import 'package:phoenix/router/app_router.dart';
import 'package:phoenix/styles/app_palette.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://uvsqahwelajbwtclahzj.supabase.co',
    anonKey: 'sb_publishable_iueVZL8L2y2tIpzjriVEJw_raDjwSiR',
  );
  // App Check activation (stub). Enable in console first for services you use.
  FirebaseAppCheck.instance.activate(
    webProvider: null,
    androidProvider: AndroidProvider.debug, // ← disable strict check
    appleProvider: AppleProvider.debug,
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

