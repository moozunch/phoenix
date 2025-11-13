import 'package:go_router/go_router.dart';
import 'package:phoenix/core/app_state.dart';
import 'package:phoenix/screens/boarding_screen.dart';
import 'package:phoenix/screens/sign_in_page.dart';
import 'package:phoenix/screens/sign_up_page.dart';
import 'package:phoenix/screens/splash_screen.dart';
import 'package:phoenix/screens/home.dart';
import 'package:phoenix/screens/onboarding/routine_selection.dart';

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
      GoRoute(
        path: '/routine_selection',
        builder: (context, state) => const RoutineSelection(),
      ),
    ],
    redirect: (context, state) {
      // Avoid redirect loops on splash and let SplashScreen decide where to go
      final loc = state.uri.path;
      if (loc == '/') return null; // always allow splash
      if (loc == '/boarding') return null; // always allow boarding per UX

      final atAuth = loc == '/signin' || loc == '/signup';

      // If not onboarded yet and trying to access other routes, send to boarding
      if (!appState.hasOnboarded) {
        return '/boarding';
      }

      // If not logged in, allow auth routes, otherwise go to signin
      if (!appState.isLoggedIn) {
        return atAuth ? null : '/signin';
      }

      // Logged in: allow everything, including boarding if user navigates back intentionally
      return null;
    },
  );
}
