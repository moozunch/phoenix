import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phoenix/core/app_state.dart';
import 'package:phoenix/router/app_router.dart';
import 'package:phoenix/styles/app_palette.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase with generated options for each platform
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
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

