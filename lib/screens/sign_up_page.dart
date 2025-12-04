import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phoenix/core/app_state.dart';
import 'package:phoenix/styles/app_palette.dart';
import 'package:phoenix/core/password_policy.dart';
import 'package:phoenix/services/auth_service.dart';
import 'package:phoenix/widgets/app_text_field.dart';
import 'package:phoenix/widgets/lined_label.dart';
import 'package:phoenix/widgets/app_checkbox.dart';
import 'package:phoenix/widgets/app_link_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:phoenix/core/auth_error_mapper.dart';


class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Social sign-up button widget
  Widget _socialSignUpButton({
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
  bool _agree = false;
  bool _showPassword = false;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Padding handled by AppScaffold

    // return PopScope(
    //     //   canPop: false,
    //     //   onPopInvokedWithResult: (didPop, result) {
    //     //     if (didPop) return;
    //     //     if (context.mounted) context.go('/boarding');
    //     //   },
    return Theme(
      data: Theme.of(context).copyWith(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        canvasColor: Colors.white,
        colorScheme: const ColorScheme.light(),
        iconTheme: const IconThemeData(color: Colors.black),
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: Colors.black,
          displayColor: Colors.black,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          hintStyle: TextStyle(color: Colors.black54),
          labelStyle: TextStyle(color: Colors.black),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black26),
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black87),
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () => context.go('/signin'),
                    tooltip: 'Back',
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Create an account',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, color: Colors.black),
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    AppCheckbox(
                      value: _agree,
                      onChanged: (v) => setState(() => _agree = v ?? false),
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.black,
                          ),
                          children: [
                            const TextSpan(text: 'I agree to the '),
                            TextSpan(
                              text: 'terms and services',
                              style: const TextStyle(color: AppPalette.primary, fontWeight: FontWeight.w600, decoration: TextDecoration.underline),
                              recognizer: TapGestureRecognizer()..onTap = () {/* open terms */},
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _socialSignUpButton(
                  label: _loading ? 'Signing Up...' : 'Sign-Up',
                  onPressed: _loading ? null : () async {
                    final ctx = context; // capture before async gaps
                    final router = GoRouter.of(ctx);
                    final messenger = ScaffoldMessenger.of(ctx);
                    if (!_agree) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('You must accept the terms & conditions.')),
                      );
                      return;
                    }
                    final email = _email.text.trim();
                    final pass = _password.text;
                    if (email.isEmpty || pass.isEmpty) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Email and password are required.')),
                      );
                      return;
                    }
                    final policyError = PasswordPolicy.validate(pass);
                    if (policyError != null) {
                      messenger.showSnackBar(
                        SnackBar(content: Text(policyError)),
                      );
                      return;
                    }
                    setState(() => _loading = true);
                    try {
                      final user = await AuthService.instance.signUpEmail(email, pass);
                      if (!mounted) return;
                      if (user != null) {
                        // Kirim email verifikasi jika belum diverifikasi
                        if (!user.emailVerified) {
                          await user.sendEmailVerification();
                          if (!mounted) return;
                          messenger.showSnackBar(
                            const SnackBar(content: Text('Verification email sent. Please check your inbox.')),
                          );
                        }
                        final state = await AppState.create();
                        if (!mounted) return;
                        await state.setIsNewUser(true);
                        await state.setHasOnboarded(true); // ← wajib TRUE supaya router tidak lempar ke /boarding
                        // JANGAN setLoggedIn di signup email
                        // state.setLoggedIn(false);   // boleh hapus atau biarkan default

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) router.go('/verify_email');
                        });
                      } else {
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Registration failed.')),);
                      }
                    } on FirebaseAuthException catch (e) {
                      if (!mounted) return;
                      final msg = AuthErrorMapper.map(e, AuthContext.signUp);
                      messenger.showSnackBar(SnackBar(content: Text(msg)));
                    } catch (_) {
                      if (!mounted) return;
                      messenger.showSnackBar(
                        const SnackBar(content: Text('An internal error occurred.')),
                      );
                    } finally {
                      if (mounted) setState(() => _loading = false);
                    }
                  },
                  icon: Icon(Icons.person_add, size: 22, color: Colors.white),
                  backgroundColor: AppPalette.primary,
                  borderColor: AppPalette.primary,
                  textColor: Colors.white,
                ),
                const SizedBox(height: 12),
                const LinedLabel('or sign up with'),
                const SizedBox(height: 12),
                _socialSignUpButton(
                  label: 'Sign up with Google',
                  onPressed: _loading ? null : () async {
                    final ctx = context;
                    final router = GoRouter.of(ctx);
                    final messenger = ScaffoldMessenger.of(ctx);
                    setState(() => _loading = true);
                    try {
                      final user = await AuthService.instance.signInGoogle();
                      if (!mounted) return;
                      if (user != null) {
                        final state = await AppState.create();
                        if (!mounted) return;
                        state.setHasOnboarded(true);
                        state.setLoggedIn(true);
                        state.setIsNewUser(true);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) return;
                          router.go('/routine_selection');
                        });
                      } else {
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Google Sign-In failed.')),
                        );
                      }
                    } on FirebaseAuthException catch (e) {
                      if (!mounted) return;
                      final msg = AuthErrorMapper.map(e, AuthContext.google);
                      messenger.showSnackBar(SnackBar(content: Text(msg)));
                    } catch (_) {
                      if (!mounted) return;
                      messenger.showSnackBar(
                        const SnackBar(content: Text('An error occurred during Google Sign-In.')),
                      );
                    } finally {
                      if (mounted) setState(() => _loading = false);
                    }
                  },
                  icon: SvgPicture.asset('assets/images/icon/google_logo_bw.svg'),
                ),
                const SizedBox(height: 12),
                _socialSignUpButton(
                  label: 'Sign up with Apple',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.black87,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        content: const Text(
                          'Apple Sign-Up is coming soon!',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        duration: Duration(milliseconds: 1600),
                      ),
                    );
                  },
                    // UI only, no backend
                  icon: Icon(Icons.apple, size: 22, color: Colors.black),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? '),
                    AppLinkButton(
                      onPressed: () => context.go('/signin'),
                      text: 'Sign in',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}