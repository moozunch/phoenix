import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phoenix/widgets/onboarding_footer.dart';
import 'package:phoenix/widgets/bottom_rounded_container.dart';
import 'package:phoenix/styles/app_palette.dart';
import 'package:phoenix/core/app_state.dart';

class SuccessScreen extends StatelessWidget {
  final String from;

  const SuccessScreen({super.key, required this.from});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // top gradient background
          Container(
            height: size.height * 0.45,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE7B0A6),
                  Colors.white,
                ],
              ),
            ),
          ),

          // ✨ MATCH DailySetup: half-rounded bottom container
          BottomRoundedContainer(
            height: size.height * 0.55,
            child: Column(
              children: [
                const SizedBox(height: 40),

                // logo
                Image.asset(
                  'assets/images/phoenix.png',
                  height: 110,
                ),
                const SizedBox(height: 22),

                // title
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: "Stay consistent, ",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppPalette.primary,
                        ),
                      ),
                      TextSpan(
                        text: "progress will follow.",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    "We have saved your schedule according to your time preference.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                    ),
                  ),
                ),

                const Spacer(),

                // ✨ Footer now automatically aligns perfectly
                OnboardingFooter(
                  activeIndex: 2,
                  onSkip: () {
                    Navigator.of(context).maybePop();
                  },
                  onNext: () {
                    // Mark onboarding/setup complete so routing no longer treats user as new.
                    AppState.create().then((state) {
                      state.setIsNewUser(false);
                    });
                    GoRouter.of(context).go('/home');
                  },
                ),
              ],
            ),
          ),

          // Back arrow
          Positioned(
            top: statusBarHeight + 16,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () {
                if (from == "weekly") {
                  GoRouter.of(context).go('/weekly_setup');
                } else {
                  GoRouter.of(context).go('/daily_setup');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
