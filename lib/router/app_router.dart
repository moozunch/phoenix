import 'package:go_router/go_router.dart';
import 'package:phoenix/core/app_state.dart';
import 'package:phoenix/screens/boarding_screen.dart';
import 'package:phoenix/screens/sign_in_page.dart';
import 'package:phoenix/screens/sign_up_page.dart';
import 'package:phoenix/screens/splash_screen.dart';
import 'package:phoenix/screens/home.dart';

class AppRouter {
  AppRouter(this.appState);

  final AppState appState;

  late final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: appState,
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/boarding',
        name: 'boarding',
        builder: (context, state) => const BoardingScreen(),
      ),
      GoRoute(
        path: '/signin',
        name: 'signin',
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
    ],
    redirect: (context, state) {
      // Avoid redirect loops on splash and let SplashScreen decide where to go
      final loc = state.uri.path;
      final atSplash = loc == '/';
      if (atSplash) return null;

      final atBoarding = loc == '/boarding';
      final atAuth = loc == '/signin' || loc == '/signup';

      if (!appState.hasOnboarded) {
        return atBoarding ? null : '/boarding';
      }

      if (!appState.isLoggedIn) {
        return atAuth ? null : '/signin';
      }

      // If authenticated and onboarded, prevent going back to auth/boarding
      if (atBoarding || atAuth) {
        return '/home';
      }

      return null;
    },
  );
}
