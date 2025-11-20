import 'package:go_router/go_router.dart';
import 'package:phoenix/core/app_state.dart';
import 'package:phoenix/core/debug_log.dart';
import 'package:phoenix/screens/boarding_screen.dart';
import 'package:phoenix/screens/onboarding/weekly_setup.dart';
import 'package:phoenix/screens/sign_in_page.dart';
import 'package:phoenix/screens/sign_up_page.dart';
import 'package:phoenix/screens/splash_screen.dart';
import 'package:phoenix/screens/home.dart';
import 'package:phoenix/screens/onboarding/routine_selection.dart';
import 'package:phoenix/screens/onboarding/daily_setup.dart';
import 'package:phoenix/screens/onboarding/success_screen.dart';
import 'package:phoenix/screens/upload_reflection_page.dart';

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
      GoRoute(
        path: '/success_screen',
        builder: (context, state) {
          final from = state.uri.queryParameters['from'] ?? 'daily_setup';
          return SuccessScreen(from: from);
        },
      ),
      GoRoute(
        path: '/upload_reflection',
        builder: (context, state) => const UploadReflectionPage(),
      )
    ],

    redirect: (context, state) {
      final loc = state.uri.path;
      final atAuth = loc == '/signin' || loc == '/signup';
      String? target;

      // If user not onboarded yet, always go to boarding (except splash root which will redirect below)
      if (!appState.hasOnboarded) {
        // Allow splash ('/') to fall through so splash screen itself can handle timing, but block other screens.
        if (loc == '/' || loc == '/boarding') {
          DebugLog.d('Router', 'Unauth onboard=false allow $loc');
          return null; // let splash / boarding render
        }
        target = '/boarding';
        DebugLog.d('Router', 'Redirect $loc -> $target (not onboarded)');
        return target;
      }

      // Logged in flows
      if (appState.isLoggedIn) {
        // New user still completing routine setup
        if (appState.isNewUser) {
          // Prevent navigating back to auth or boarding or splash
          if (loc == '/' || loc == '/boarding' || atAuth) {
            target = '/routine_selection';
            DebugLog.d('Router', 'NewUser redirect $loc -> $target');
            return target;
          }
          // Allow defined onboarding pages + home + upload_reflection
          const allowed = {
            '/routine_selection',
            '/daily_setup',
            '/weekly_setup',
            '/success_screen',
            '/home',
            '/upload_reflection'
          };
          if (!allowed.contains(loc)) {
            target = '/routine_selection';
            DebugLog.d('Router', 'NewUser restrict $loc -> $target');
            return target;
          }
          DebugLog.d('Router', 'NewUser allow $loc');
          return null;
        }

        // Fully onboarded user: never show splash/boarding/auth again; send to home if accessing them.
        if (loc == '/' || loc == '/boarding' || atAuth) {
          target = '/home';
          DebugLog.d('Router', 'LoggedIn redirect $loc -> $target');
          return target;
        }
        if (loc != '/home') {
          target = '/home';
          DebugLog.d('Router', 'LoggedIn force-home $loc -> $target');
          return target;
        }
        DebugLog.d('Router', 'LoggedIn stay $loc');
        return null;
      }

      // Not logged in but onboarded: allow auth pages; block others.
      if (!appState.isLoggedIn) {
        // Allow boarding even after user previously onboarded (marketing / info screen revisit)
        if (loc == '/boarding') {
          DebugLog.d('Router', 'NotLoggedIn allow boarding');
          return null;
        }
        if (atAuth) {
          DebugLog.d('Router', 'Auth screen allowed: $loc');
          return null;
        }
        if (loc == '/') {
          target = '/boarding';
          DebugLog.d('Router', 'Root redirect (not logged in) -> $target');
          return target;
        }
        // Any other route force to signin
        target = '/signin';
        DebugLog.d('Router', 'NotLoggedIn redirect $loc -> $target');
        return target;
      }

      DebugLog.d('Router', 'Fall-through allow $loc');
      return null; // default fall-through
    },
  );
}