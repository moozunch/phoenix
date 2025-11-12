import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phoenix/core/app_state.dart';
import 'package:phoenix/widgets/app_scaffold.dart';
import 'package:phoenix/widgets/app_button.dart';
import 'package:phoenix/widgets/boarding_header.dart';
import 'package:phoenix/styles/app_palette.dart';

class BoardingScreen extends StatelessWidget {
  const BoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
  // Padding handled by AppScaffold; keep media for sizing only
    final headerH = (media.height * 0.36).clamp(200.0, 380.0);
    return AppScaffold(
      scrollable: true,
      headerHeight: headerH,
      background: BoardingHeader(height: headerH),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: headerH * 0.45),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.auto_fix_high, size: (media.width * 0.14).clamp(40.0, 96.0), color: AppPalette.primary),
                const SizedBox(height: 12),
                Text('Welcome to', style: Theme.of(context).textTheme.titleMedium),
                Text('Phoenix!',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontStyle: FontStyle.italic, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(
                  'Track your thoughts, celebrate small victories, and begin seeing yourself with compassion. You\'re not alone, and you\'re not broken. You\'re becoming. Let this be the start of your healing.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: "Let's get started",
                  onPressed: () async {
                    final appState = await AppState.create();
                    await appState.setHasOnboarded(true);
                    if (context.mounted) context.go('/signin');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
