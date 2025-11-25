import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phoenix/core/app_state.dart';
import 'package:phoenix/services/auth_service.dart';
import 'package:phoenix/widgets/app_button.dart';
import 'package:phoenix/widgets/app_text_field.dart';
import 'package:phoenix/widgets/app_scaffold.dart';
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

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
  // Padding handled by AppScaffold

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (context.mounted) context.go('/boarding');
      },
      child: AppScaffold(
        showBack: true,
        onBack: () => context.go('/boarding'),
        body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: size.height * 0.14),
          Text(
            'Welcome back!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: AppLinkButton(
              onPressed: () => context.go('/forgot_password'),
              text: 'Forgot Password?',
            ),
          ),
          const SizedBox(height: 8),
          AppButton(
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
                    ));
                  }
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
          ),
          const SizedBox(height: 12),
          const LinedLabel('or sign in with'),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _loading || _isLocked ? null : () async {
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/images/icon/google_logo_bw.svg',
                  height: 30,
                  width: 30,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 24),
        ],
        ),
      ),
    );
  }
}
