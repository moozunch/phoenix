import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phoenix/core/app_state.dart';
import 'package:phoenix/widgets/app_button.dart';
import 'package:phoenix/widgets/app_text_field.dart';
import 'package:phoenix/widgets/app_scaffold.dart';


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
          AppTextField(controller: _email, label: 'Email', keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 16),
          AppTextField(controller: _password, label: 'Password', obscure: true),
          const SizedBox(height: 16),
          AppTextField(controller: _confirm, label: 'Confirm Password', obscure: true),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(value: true, onChanged: (_) {}),
              const Expanded(child: Text('I agree to the terms and services')),
            ],
          ),
          const SizedBox(height: 8),
          AppButton(
            label: 'Sign up',
            onPressed: () async {
              final state = await AppState.create();
              await state.setHasOnboarded(true);
              await state.setLoggedIn(true);
              await state.setIsNewUser(true);
              if (context.mounted) context.go('/routine_selection');
            },
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context.go('/signin'),
            child: const Text('Already have an account? Sign in'),
          ),
          const SizedBox(height: 24),
        ],
        ),
      ),
    );
  }
}
