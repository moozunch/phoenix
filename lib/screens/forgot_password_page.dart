import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:phoenix/styles/app_palette.dart';
import 'package:phoenix/widgets/app_text_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _email = TextEditingController();
  bool _loading = false;
  DateTime? _lastSent;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  bool _showSpamHint = false;

  Future<void> _submit() async {
    final email = _email.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email is required.')),
      );
      return;
    }
    // Basic format check (not exhaustive)
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid email address.')),
      );
      return;
    }
    final now = DateTime.now();
    if (_lastSent != null && now.difference(_lastSent!).inSeconds < 30) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please wait before requesting again.')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _lastSent = DateTime.now();
      if (!mounted) return;
      // Generic message: do not reveal if email exists.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('If an account exists, a reset link has been sent.')),
      );
      setState(() => _showSpamHint = true);
    } catch (_) {
      if (!mounted) return;
      // Same generic message to avoid user enumeration.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('If an account exists, a reset link has been sent.')),
      );
      setState(() => _showSpamHint = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
                'Forgot your password?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Enter your email address and we will send you a link to reset your password.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black87),
              ),
              const SizedBox(height: 32),
              AppTextField(
                controller: _email,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined, color: Colors.black54),
                // No need for obscure, suffixIcon, etc.
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPalette.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: AppPalette.primary),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _loading ? null : _submit,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      _loading ? 'Sending...' : 'Send Reset Link',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                  ),
                ),
              ),
              if (_showSpamHint) ...[
                const SizedBox(height: 8),
                Text(
                  'Check your spam folder if the email does not arrive.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black38, fontSize: 13),
                ),
              ],
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => context.go('/signin'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppPalette.primary,
                      textStyle: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    child: const Text('Back to Sign In'),
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
