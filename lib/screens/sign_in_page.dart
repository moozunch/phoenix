import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phoenix/core/app_state.dart';
import 'package:phoenix/services/auth_service.dart';
import 'package:phoenix/services/notification_service.dart';
import 'package:phoenix/widgets/app_text_field.dart';
// Removed AppScaffold import
import 'package:phoenix/widgets/lined_label.dart';
import 'package:phoenix/widgets/app_link_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:phoenix/core/auth_error_mapper.dart';
import 'package:phoenix/services/supabase_user_service.dart';
import 'package:phoenix/models/user_model.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  // Social sign-in button widget (lowerCamelCase)
  Widget _socialSignInButton({
    required String label,
    required VoidCallback? onPressed,
    required Widget icon,
    Color? backgroundColor,
    Color? borderColor,
    Color? textColor,
  }) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.grey[100],
          foregroundColor: textColor ?? Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: borderColor ?? Colors.grey[300]!),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 22, height: 22, child: icon),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: textColor ?? Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _showPassword = false;
  bool _loading = false;
  int _failCount = 0; // consecutive failures (resets on success)
  DateTime? _lockUntil; // when user can attempt again

  static const List<int> _delaysSeconds = [0, 2, 4, 8, 16, 32, 60]; // capped exponential

  bool get _isLocked {
    if (_lockUntil == null) return false;
    return DateTime.now().isBefore(_lockUntil!);
  }

  int get _remainingLockSeconds {
    if (!_isLocked) return 0;
    return _lockUntil!.difference(DateTime.now()).inSeconds + 1;
  }

  void _registerFailure(ScaffoldMessengerState messenger) {
    _failCount++;
    final idx = _failCount.clamp(0, _delaysSeconds.length - 1);
    final delay = _delaysSeconds[idx];
    if (delay > 0) {
      _lockUntil = DateTime.now().add(Duration(seconds: delay));
      messenger.showSnackBar(
        SnackBar(content: Text('Too many failed attempts. Please wait $delay seconds.')),
      );
    }
  }

  void _resetFailures() {
    _failCount = 0;
    _lockUntil = null;
  }

  Future<void> _setupRoutineNotification(String uid) async {
    final supaUser = await SupabaseUserService().getUser(uid);
    if (supaUser == null) return;
    final routine = supaUser.routine;
    final notif = NotificationService();
    await notif.initialize();
    await notif.cancelAll();
    final quotes = [
      "Small steps every day lead to big changes.",
      "You are capable of amazing things.",
      "Progress, not perfection.",
      "Consistency is the key to success.",
      "Believe in yourself and all that you are.",
      "Every day is a new beginning.",
      "Your future is created by what you do today."
    ];
    final quote = (quotes..shuffle()).first;
    if (routine == 'daily') {
      await notif.scheduleDailyNotification(
        id: 1,
        title: 'Ready to log today?',
        body: quote,
        hour: 8,
        minute: 0,
      );
    } else if (routine == 'weekly') {
      // Weekly routine: still schedule daily notification, but with weekly message
      await notif.scheduleDailyNotification(
        id: 2,
        title: 'Weekly goal: Log your photo!',
        body: quote,
        hour: 8,
        minute: 0,
      );
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              Text(
                'Welcome back!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 40),
              AppTextField(
                controller: _email,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _password,
                label: 'Password',
                obscure: !_showPassword,
                prefixIcon: const Icon(Icons.lock_outline, color: Colors.black54),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _showPassword = !_showPassword),
                  icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: AppLinkButton(
                  onPressed: () => context.go('/forgot_password'),
                  text: 'Forgot Password?',
                ),
              ),
              const SizedBox(height: 24),
              _socialSignInButton(
                label: _loading
                    ? 'Signing In...'
                    : _isLocked
                        ? 'Locked (${_remainingLockSeconds}s)'
                        : 'Sign In',
                onPressed: _loading || _isLocked
                    ? null
                    : () async {
                  final ctx = context; // capture before async gaps
                  final router = GoRouter.of(ctx);
                  final messenger = ScaffoldMessenger.of(ctx);
                  final email = _email.text.trim();
                  final pass = _password.text;
                  if (email.isEmpty || pass.isEmpty) {
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Email and password are required.')),
                    );
                    return;
                  }
                  setState(() => _loading = true);
                  try {
                    final user = await AuthService.instance.signInEmail(email, pass);
                    if (!mounted) return; // ensure state still active
                    if (user != null) {
                      // Insert user to Supabase if not exists
                      final supaUser = await SupabaseUserService().getUser(user.uid);
                      if (supaUser == null) {
                        await SupabaseUserService().createUser(UserModel(
                          uid: user.uid,
                          name: '',
                          username: '',
                          profilePicUrl: '',
                          joinedAt: DateTime.now(),
                          routine: 'daily',
                          journalCount: 0,
                          photoCount: 0,
                          daysActive: 0,
                          reminderTime: '08:00:00',
                        ));
                      }
                      // Setup notification based on routine
                      await _setupRoutineNotification(user.uid);
                      final state = await AppState.create();
                      if (!mounted) return;
                      // Fire-and-forget persistence
                      state.setLoggedIn(true);
                      state.setIsNewUser(false);
                      _resetFailures();
                      // Navigasi ditunda ke frame berikut supaya aman dari lint async context
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        router.go('/home');
                      });
                    } else {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Authentication failed. Please check your credentials.')),
                      );
                      _registerFailure(messenger);
                    }
                  } on FirebaseAuthException catch (e) {
                    if (!mounted) return;
                    final msg = AuthErrorMapper.map(e, AuthContext.signIn);
                    messenger.showSnackBar(SnackBar(content: Text(msg)));
                    _registerFailure(messenger);
                  } catch (e) {
                    if (!mounted) return;
                    messenger.showSnackBar(
                      const SnackBar(content: Text('An internal error occurred.')),
                    );
                    _registerFailure(messenger);
                  } finally {
                    if (mounted) setState(() => _loading = false);
                  }
                },
                icon: Icon(Icons.login, size: 22, color: Colors.black),
                backgroundColor: Colors.grey[100],
                borderColor: Colors.grey[300],
                textColor: Colors.black87,
              ),
              const SizedBox(height: 20),
              const LinedLabel('or sign in with'),
              const SizedBox(height: 16),
              _socialSignInButton(
                label: 'Sign in with Google',
                onPressed: _loading || _isLocked
                    ? null
                    : () async {
                  final ctx = context; // capture BuildContext synchronously
                  final router = GoRouter.of(ctx);
                  final messenger = ScaffoldMessenger.of(ctx);
                  setState(() => _loading = true);
                  try {
                    final user = await AuthService.instance.signInGoogle();
                    if (!mounted) return;
                    if (user != null) {
                      // Insert user to Supabase if not exists
                      final supaUser = await SupabaseUserService().getUser(user.uid);
                      if (supaUser == null) {
                        await SupabaseUserService().createUser(UserModel(
                          uid: user.uid,
                          name: user.displayName ?? '',
                          username: '',
                          profilePicUrl: user.photoURL ?? '',
                          joinedAt: DateTime.now(),
                          routine: 'daily',
                          journalCount: 0,
                          photoCount: 0,
                          daysActive: 0,
                          reminderTime: '08:00:00',
                        ));
                      }
                      final state = await AppState.create();
                      if (!mounted) return;
                      state.setLoggedIn(true);
                      state.setIsNewUser(false);
                      _resetFailures();
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        router.go('/home');
                      });
                    } else {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Google Sign-In failed.')),
                      );
                      _registerFailure(messenger);
                    }
                  } on FirebaseAuthException catch (e) {
                    if (!mounted) return;
                    final msg = AuthErrorMapper.map(e, AuthContext.google);
                    messenger.showSnackBar(SnackBar(content: Text(msg)));
                    _registerFailure(messenger);
                  } catch (_) {
                    if (!mounted) return;
                    messenger.showSnackBar(
                      const SnackBar(content: Text('An error occurred during Google Sign-In.')),
                    );
                    _registerFailure(messenger);
                  } finally {
                    if (mounted) setState(() => _loading = false);
                  }
                },
                icon: SvgPicture.asset('assets/images/icon/google_logo_bw.svg'),
              ),
              const SizedBox(height: 12),
              _socialSignInButton(
                label: 'Sign in with Apple',
                onPressed: null, // UI only, no backend
                icon: Icon(Icons.apple, size: 22, color: Colors.black),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  AppLinkButton(
                    onPressed: () => context.go('/signup'),
                    text: 'Sign Up',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
