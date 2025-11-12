import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phoenix/core/app_state.dart';
import 'package:phoenix/widgets/app_button.dart';
import 'package:phoenix/widgets/app_text_field.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pad = EdgeInsets.symmetric(horizontal: size.width * 0.08);

    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: pad.add(const EdgeInsets.symmetric(vertical: 24)),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: size.height * 0.02),
                  AppTextField(controller: _email, label: 'Email', keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),
                  AppTextField(controller: _password, label: 'Password', obscure: true),
                  const SizedBox(height: 16),
                  AppTextField(controller: _confirm, label: 'Confirm Password', obscure: true),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Create account',
                    onPressed: () async {
                      // TODO: Replace with real registration later.
                      final state = await AppState.create();
                      await state.setHasOnboarded(true);
                      await state.setLoggedIn(true);
                      if (context.mounted) context.go('/home');
                    },
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.go('/signin'),
                    child: const Text('Have an account? Sign in'),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
