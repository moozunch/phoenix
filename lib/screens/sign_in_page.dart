import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phoenix/core/app_state.dart';
import 'package:phoenix/widgets/app_button.dart';
import 'package:phoenix/widgets/app_text_field.dart';
import 'package:phoenix/widgets/app_scaffold.dart';
import 'package:phoenix/widgets/lined_label.dart';
import 'package:phoenix/widgets/app_link_button.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
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
            child: AppLinkButton(onPressed: () {}, text: 'Forgot Password?'),
          ),
          const SizedBox(height: 8),
          AppButton(
            label: 'Sign In',
            onPressed: () async {
              final state = await AppState.create();
              await state.setLoggedIn(true);
              await state.setIsNewUser(false);
              if (context.mounted) context.go('/home');
            },
          ),
          const SizedBox(height: 12),
          const LinedLabel('or sign in with'),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/icon/google_logo_bw.svg',
                height: 30,
                width: 30,
              ),
            ],
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
