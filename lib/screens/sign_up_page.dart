import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phoenix/core/app_state.dart';
import 'package:phoenix/styles/app_palette.dart';
import 'package:phoenix/core/password_policy.dart';
import 'package:phoenix/services/auth_service.dart';
import 'package:phoenix/widgets/app_button.dart';
import 'package:phoenix/widgets/app_text_field.dart';
import 'package:phoenix/widgets/app_scaffold.dart';
import 'package:phoenix/widgets/lined_label.dart';
// Removed SocialIconButton in favor of direct SVG icon.
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
            'Create an account',
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
          Row(
            children: [
              AppCheckbox(
                value: _agree,
                onChanged: (v) => setState(() => _agree = v ?? false),
              ),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium,
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
          AppButton(
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
          ),
          const SizedBox(height: 12),
          const LinedLabel('or sign up with'),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _loading ? null : () async {
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
    );
  }
}
