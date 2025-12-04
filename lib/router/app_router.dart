import 'package:phoenix/screens/edit_journal_page.dart';
import 'package:phoenix/screens/settingprofile/notification_settings.dart';
import 'package:phoenix/screens/settingprofile/photo_archive_page.dart';
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
import 'package:phoenix/screens/tab_scaffold.dart';
import 'package:phoenix/screens/verify_email_page.dart';
import 'package:phoenix/screens/forgot_password_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:phoenix/screens/success_upload.dart';
import 'package:phoenix/screens/settingprofile/setting_profile.dart';
import 'package:phoenix/screens/settingprofile/edit_profile.dart';
import 'package:phoenix/screens/settingprofile/display.dart';
import 'package:phoenix/screens/settingprofile/account_setting.dart';
import 'package:phoenix/screens/settingprofile/information_page.dart';

class AppRouter {
  AppRouter(this.appState);

  final AppState appState;

  late final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: appState,
    routes: [
      GoRoute(
        path: '/photo_archive',
        name: 'photo_archive',
        builder: (context, state) => const PhotoArchivePage(),
      ),
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
        pageBuilder: (context, state) => NoTransitionPage(child: const SignInPage()),
      ),
      GoRoute(
        path: '/forgot_password',
        name: 'forgot_password',
        pageBuilder: (context, state) => NoTransitionPage(child: const ForgotPasswordPage()),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        pageBuilder: (context, state) => NoTransitionPage(child: const SignUpPage()),
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
        path: '/success_upload',
        builder: (context, state) => const SuccessUploadPage(),
      ),
      GoRoute(
        path: '/edit_profile',
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: '/account_setting',
        builder: (context, state) => const AccountSettingPage(),
      ),
      GoRoute(
        path: '/information_page',
        builder: (context, state) => const InformationPage(),
      ),
      GoRoute(
        path: '/notification_settings',
        builder: (context, state) => const NotificationSettingsPage(),
      ),
      GoRoute(
        path: '/display',
        builder: (context, state) => const DisplayPage(),
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
          //index ke-0
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/home',
              name: 'home',
              builder: (context, state) => const HomePage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/dummy-upload-tab', // Dummy route (never used)
              builder: (context, state) => const SizedBox.shrink(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/setting_profile',
              name: 'setting_profile',
              builder: (context, state) => const SettingProfile(),
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
      GoRoute(
        path: '/edit_journal',
        name: 'edit_journal',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return EditJournalPage(
            journalId: extra['journalId'],
            headline: extra['headline'],
            body: extra['body'],
            mood: extra['mood'],
            photoUrl: extra['photoUrl'],
          );
        },
      ),

    ],
    
    

    redirect: (context, state) {
      final loc = state.uri.path;
      final user = FirebaseAuth.instance.currentUser;
      final loggedIn = user != null;
      final atAuth = loc == '/signin' || loc == '/signup' || loc == '/forgot_password';



      DebugLog.d('Router', 'LOC=$loc | loggedIn=$loggedIn | onboarded=${appState.hasOnboarded} | newUser=${appState.isNewUser}');

      // ────────────────────────────────────────────────
      // 0. Splash screen → allow
      // ────────────────────────────────────────────────
      if (loc == '/') {
        return null;
      }

      // ────────────────────────────────────────────────
      // 1. NOT LOGGED IN
      // ────────────────────────────────────────────────
      if (!loggedIn) {
        // allow boarding always
        if (loc == '/boarding') return null;

        // allow auth pages
        if (atAuth) return null;

        // everything else → boarding
        return '/boarding';
      }

      // ────────────────────────────────────────────────
      // 2. LOGGED IN but Email Not Verified
      // ────────────────────────────────────────────────
      if (!user.emailVerified) {
        // only allow verify email
        if (loc != '/verify_email' || loc == 'signup') {
          return null;
        }
        return '/verify_email';
      }

      // ────────────────────────────────────────────────
      // 3. LOGGED IN + NEW USER (HAS NOT COMPLETED ONBOARDING)
      // ────────────────────────────────────────────────
      if (appState.isNewUser) {
        // prevent going to splash, boarding, signin/signup
        if (loc == '/' || loc == '/boarding' || atAuth) {
          return '/routine_selection';
        }

        // allowed onboarding pages
        const onboardingCore = {
          '/routine_selection',
          '/daily_setup',
          '/weekly_setup',
        };

        // success screen (with or without ?from=)
        final isSuccessScreen = loc == '/success_screen';

        if (onboardingCore.contains(loc) || isSuccessScreen) {
          return null;
        }

        // block everything else
        return '/routine_selection';
      }

      // ────────────────────────────────────────────────
      // 4. FULLY LOGGED IN USER (NORMAL USER)
      // ────────────────────────────────────────────────
      // prevent going back to splash / boarding / signin
      if (loc == '/' || loc == '/boarding' || atAuth) {
        return '/home';
      }

      // pages allowed for normal user
      const allowedLoggedIn = {
        '/home',
        '/upload_reflection',
        '/setting_profile',
        '/edit_profile',
        '/account_setting',
        '/notification_settings',
        '/display',
        '/edit_journal',
        '/information_page',
        '/success_upload',
      };

      if (!allowedLoggedIn.contains(loc)) {
        return '/home';
      }

      // allow all valid logged-in pages
      return null;
    },
  );
}