import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phoenix/core/app_state.dart';
import 'package:phoenix/widgets/app_button.dart';
import 'package:phoenix/widgets/app_text_field.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pad = EdgeInsets.symmetric(horizontal: size.width * 0.08);

    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
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
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Sign In',
                    onPressed: () async {
                      // TODO: Replace with real auth later.
                      final state = await AppState.create();
                      await state.setLoggedIn(true);
                      if (context.mounted) context.go('/home');
                    },
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.go('/signup'),
                    child: const Text("Don't have an account? Sign up"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
