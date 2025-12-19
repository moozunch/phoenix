import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phoenix/core/app_state.dart';
import 'package:phoenix/router/app_router.dart';
import 'package:phoenix/styles/app_palette.dart';
import 'package:firebase_core/firebase_core.dart';
// firebase_options.dart is untracked; mobile will use native config.
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:phoenix/services/display_settings_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DisplaySettingsController.init();
  // Initialize Firebase
  await Firebase.initializeApp();
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://uvsqahwelajbwtclahzj.supabase.co',
    anonKey: 'sb_publishable_iueVZL8L2y2tIpzjriVEJw_raDjwSiR',
  );
  // Firebase App Check removed (not used). Re-enable if needed.

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
    return ValueListenableBuilder<bool>(
      valueListenable: DisplaySettingsController.theme,
      builder: (context, isDark, _) {
        return MaterialApp.router(
          title: 'phoenix',
          debugShowCheckedModeBanner: false,
          routerConfig: router,

          theme: base.copyWith(
            scaffoldBackgroundColor: Colors.white,
            canvasColor: AppPalette.surface,
            iconTheme: const IconThemeData(color: Colors.black),

            colorScheme: ColorScheme.fromSeed(
              seedColor: AppPalette.primary,
              surface: Colors.white,
            ).copyWith(
              surfaceContainerLowest: const Color(0xFFF7F7F7),
              surfaceContainerLow: const Color(0xFFF7F7F7),
              surfaceContainer: const Color(0xFFF7F7F7),
              surfaceContainerHigh: const Color(0xFFF7F7F7),
              surfaceContainerHighest: const Color(0xFFF7F7F7),
            ),


            cardColor: Colors.white,
          ),


          darkTheme: base.copyWith(
            brightness: Brightness.dark,
            iconTheme: const IconThemeData(color: Colors.white),

            // Warna dasar seluruh dark theme
            scaffoldBackgroundColor: const Color(0xFF212121),
            canvasColor: const Color(0xFF212121),

            colorScheme: ColorScheme.fromSeed(
              seedColor: AppPalette.primary,
              brightness: Brightness.dark,
              // background: const Color(0xFF212121),
              surface: const Color(0xFF212121),
              onSurface: Colors.white,
            ),

            cardColor: const Color(0xFF2C2C2C), // sedikit lebih terang untuk card

            textTheme: base.textTheme.apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),

            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF212121),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        );
      },
    );
  }
}

