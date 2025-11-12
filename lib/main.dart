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
    if (appState != null) {
      final router = AppRouter(appState!).router;
      return MaterialApp.router(
        title: 'phoenix',
        theme: ThemeData(),
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      );
    }

    return FutureBuilder<AppState>(
      future: AppState.create(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: SizedBox.shrink(),
          );
        }
        final router = AppRouter(snapshot.data!).router;
        return MaterialApp.router(
          title: 'phoenix',
          theme: ThemeData(),
          routerConfig: router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

