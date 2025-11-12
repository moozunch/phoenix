import 'package:flutter/material.dart';
import 'package:phoenix/core/app_state.dart';
import 'package:phoenix/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appState = await AppState.create();
  runApp(MyApp(appState: appState));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.appState});

  final AppState? appState;

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF5A1F)),
      useMaterial3: true,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );

    if (appState != null) {
      final router = AppRouter(appState!).router;
      return MaterialApp.router(
        title: 'phoenix',
        theme: baseTheme,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      );
    }

    return FutureBuilder<AppState>(
      future: AppState.create(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: baseTheme,
            home: const SizedBox.shrink(),
          );
        }
        final router = AppRouter(snapshot.data!).router;
        return MaterialApp.router(
          title: 'phoenix',
          theme: baseTheme,
          routerConfig: router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

