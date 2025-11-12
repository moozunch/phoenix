import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phoenix/core/app_state.dart';

class BoardingScreen extends StatelessWidget {
  const BoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final pad = media.width * 0.08;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxW = constraints.maxWidth;
            final isWide = maxW > 600;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: pad, vertical: pad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  // Branding/logo placeholder
                  Center(
                    child: Icon(Icons.local_fire_department,
                        size: media.width * 0.25, color: Colors.deepOrange),
                  ),
                  SizedBox(height: media.height * 0.03),
                  Text(
                    'Welcome to\nPhoenix!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: media.height * 0.015),
                  Text(
                    'Track your thoughts, optimize your habits, and rise to your best self.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () async {
                      // mark onboarded and go to auth or home via redirect
                      final appState = await AppState.create();
                      await appState.setHasOnboarded(true);
                      if (context.mounted) context.go('/signin');
                    },
                    style: FilledButton.styleFrom(
                      minimumSize: Size(double.infinity, isWide ? 56 : 48),
                    ),
                    child: const Text("Let's get started"),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
