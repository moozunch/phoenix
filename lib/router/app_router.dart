import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
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
import 'package:phoenix/screens/settings_page.dart';
import 'package:phoenix/screens/tab_scaffold.dart';
import 'package:phoenix/screens/verify_email_page.dart';
import 'package:phoenix/screens/forgot_password_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
        path: '/forgot_password',
        name: 'forgot_password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: '/routine_selection',
        name: 'routine_selection',
        builder: (context, state) => const RoutineSelection(),
      ),
      GoRoute(
        path: '/verify_email',
        name: 'verify_email',
        builder: (context, state) => const VerifyEmailPage(),
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
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => TabScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/home',
              name: 'home',
              builder: (context, state) => const HomePage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/settings',
              name: 'settings',
              builder: (context, state) => const SettingsPage(),
            ),
          ]),
        ],
      ),
      // Standalone upload page (no bottom navigation shell)
      GoRoute(
        path: '/upload_reflection',
        name: 'upload_reflection',
        pageBuilder: (context, state) {
          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: const UploadReflectionPage(),
            barrierDismissible: false,
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(curved),
                child: FadeTransition(
                  opacity: Tween<double>(begin: 0, end: 1).animate(curved),
                  child: child,
                ),
              );
            },
          );
        },
      ),
    ],

    redirect: (context, state) {
      final loc = state.uri.path;
      final atAuth = loc == '/signin' || loc == '/signup' || loc == '/forgot_password';
      final user = FirebaseAuth.instance.currentUser;
      final loggedIn = user != null; // authoritative source (instead of appState.isLoggedIn)
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

      // Logged in flows (using FirebaseAuth directly)
      if (loggedIn) {
        // New user still completing routine setup
        if (appState.isNewUser) {
          final verified = user.emailVerified;
          // If email not verified, force user to stay on verify email page until verified
          if (!verified) {
            if (loc != '/verify_email' && loc != '/') {
              target = '/verify_email';
              DebugLog.d('Router', 'Email not verified redirect $loc -> $target');
              return target;
            }
            DebugLog.d('Router', 'Email not verified allow $loc');
            return null;
          }
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
        const allowedLoggedIn = {
          '/home',
          '/upload_reflection',
          '/settings'
        };
        if (!allowedLoggedIn.contains(loc)) {
          target = '/home';
          DebugLog.d('Router', 'LoggedIn restrict $loc -> $target');
          return target;
        }
        DebugLog.d('Router', 'LoggedIn allow $loc');
        return null;
      }

      // Not logged in but onboarded: allow auth pages; block others.
      if (!loggedIn) {
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