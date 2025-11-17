import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phoenix/core/app_state.dart';
import 'package:phoenix/styles/app_palette.dart';
import 'package:phoenix/services/auth_service.dart';
import 'package:phoenix/widgets/app_button.dart';
import 'package:phoenix/widgets/app_text_field.dart';
import 'package:phoenix/widgets/app_scaffold.dart';
import 'package:phoenix/widgets/lined_label.dart';
// Removed SocialIconButton in favor of direct SVG icon.
import 'package:phoenix/widgets/app_checkbox.dart';
import 'package:phoenix/widgets/app_link_button.dart';
import 'package:flutter_svg/flutter_svg.dart';


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
            label: 'Sign-Up',
            onPressed: () async {
              if (!_agree) return;
              final email = _email.text.trim();
              final pass = _password.text;
              if (email.isEmpty || pass.isEmpty) return;
              try {
                final user = await AuthService.instance.signUpEmail(email, pass);
                if (user != null) {
                  final state = await AppState.create();
                  await state.setHasOnboarded(true);
                  await state.setLoggedIn(true);
                  await state.setIsNewUser(true);
                  if (mounted) context.go('/routine_selection');
                }
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Sign up failed: ${e.toString()}')),
                );
              }
            },
          ),
          const SizedBox(height: 12),
          const LinedLabel('or sign up with'),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () async {
              try {
                final user = await AuthService.instance.signInGoogle();
                if (user != null) {
                  final state = await AppState.create();
                  await state.setHasOnboarded(true); // treat google sign-up as onboarded
                  await state.setLoggedIn(true);
                  await state.setIsNewUser(true);
                  if (mounted) context.go('/routine_selection');
                }
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Google sign-in failed: ${e.toString()}')),
                );
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
