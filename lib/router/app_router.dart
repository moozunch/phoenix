import 'package:go_router/go_router.dart';
import 'package:phoenix/core/app_state.dart';
import 'package:phoenix/screens/boarding_screen.dart';
import 'package:phoenix/screens/onboarding/weekly_setup.dart';
import 'package:phoenix/screens/sign_in_page.dart';
import 'package:phoenix/screens/sign_up_page.dart';
import 'package:phoenix/screens/splash_screen.dart';
import 'package:phoenix/screens/home.dart';
import 'package:phoenix/screens/onboarding/routine_selection.dart';
import 'package:phoenix/screens/onboarding/daily_setup.dart';


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
        name: 'routine_selection',
        builder: (context, state) => const RoutineSelection(),
      ),
      GoRoute(
        path: '/daily_setup',
        builder: (context, state) => const DailySetup(),
      ),
      GoRoute(
        path: '/weekly_setup',
        builder: (context, state) => const WeeklySetup(),
      ),
    ],

    redirect: (context, state) {
      final loc = state.uri.path;

      if (loc == '/') return null;
      if (loc == '/boarding') return null;

      final atAuth = loc == '/signin' || loc == '/signup';

      if (!appState.hasOnboarded) {
        return '/boarding';
      }

      if (!appState.isLoggedIn) {
        // allow signin and signup
        return atAuth ? null : '/signin';
      }

      if (appState.isNewUser) {
        if (loc != '/routine_selection' && loc != '/daily_setup' && loc != '/signup' && loc!= '/weekly_setup') {
          return '/routine_selection';
        }
        return null;
      }

      if (!appState.isNewUser && loc != '/home') {
        return '/home';
      }

      return null;
    },
  );
}