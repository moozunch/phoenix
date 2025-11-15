import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phoenix/core/app_state.dart';
import 'package:phoenix/widgets/app_scaffold.dart';
import 'package:phoenix/widgets/app_button.dart';
// import 'package:phoenix/widgets/boarding_header.dart';
// import 'package:phoenix/widgets/overlap_stars_header.dart';
import 'package:phoenix/styles/app_palette.dart';
import 'package:lottie/lottie.dart';

const double kBoardingLogoScale = 0.80; 
const double kBoardingLogoMin = 120.0;  
const double kBoardingLogoMax = 360.0; 

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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: headerH * 0.45),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Builder(
                  builder: (context) {
                    final logoHeight = (media.width * kBoardingLogoScale)
                        .clamp(kBoardingLogoMin, kBoardingLogoMax);
                    return SizedBox(
                      height: logoHeight,
                      width: logoHeight,
                      child: Lottie.asset(
                        'assets/json/starselfie.json',
                        fit: BoxFit.contain,
                        repeat: true,
                        errorBuilder: (context, error, stack) => Icon(
                          Icons.auto_fix_high,
                          size: logoHeight * 0.3,
                          color: AppPalette.primary,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Text('Welcome to', style: Theme.of(context).textTheme.titleMedium),
                Text(
                  'Phoenix!',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontStyle: FontStyle.italic, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Soft light finds you. No angles, no filters, just a face learning kindness. Worth lives in small moments, confidence returns gently, one little step at a time.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                    AppButton(
                  label: "Let's get started",
                  onPressed: () async {
                        final state = await AppState.create();
                        await state.setHasOnboarded(true);
                        // Do not mark logged in; send user to sign in.
                        if (!context.mounted) return;
                        context.go('/signin');
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
