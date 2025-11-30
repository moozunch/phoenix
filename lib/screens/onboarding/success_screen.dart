import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phoenix/models/user_model.dart';
import 'package:phoenix/services/notification_service.dart';
import 'package:phoenix/services/supabase_user_service.dart';
import 'package:phoenix/widgets/onboarding_footer.dart';
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
          // TOP GRADIENT BACKGROUND
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

          // MAIN CONTENT (CENTERED)
          Column(
            children: [
              SizedBox(height: size.height * 0.18),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/phoenix.png',
                      height: 110,
                    ),
                    const SizedBox(height: 22),
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
                  ],
                ),
              ),

              // FOOTER
              OnboardingFooter(
                activeIndex: 2,
                onSkip: () {
                  Navigator.of(context).maybePop();
                },
                onNext: () async {
                  final state = await AppState.create();
                  await state.setIsNewUser(false);

                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    final appState = await AppState.create();
                    final routine = appState.routine ?? 'daily';
                    String reminderTime = routine == 'weekly'
                        ? '08:00:00'
                        : appState.reminderTime ?? '08:00:00';

                    String name = user.displayName ?? '';
                    await SupabaseUserService().createUser(
                      UserModel(
                        uid: user.uid,
                        name: name,
                        username: '',
                        profilePicUrl: user.photoURL ?? '',
                        joinedAt: DateTime.now(),
                        routine: routine,
                        journalCount: 0,
                        photoCount: 0,
                        daysActive: 0,
                        reminderTime: reminderTime,
                      ),
                    );

                    final notif = NotificationService();
                    await notif.initialize();
                    await notif.cancelAll();

                    final quotes = [
                      "Small steps every day lead to big changes.",
                      "You are capable of amazing things.",
                      "Progress, not perfection.",
                      "Consistency is the key to success.",
                      "Believe in yourself and all that you are.",
                      "Every day is a new beginning.",
                      "Your future is created by what you do today."
                    ];
                    final quote = (quotes..shuffle()).first;

                    int hour = 8;
                    int minute = 0;
                    final parts = reminderTime.split(':');
                    if (parts.length >= 2) {
                      hour = int.tryParse(parts[0]) ?? 8;
                      minute = int.tryParse(parts[1]) ?? 0;
                    }

                    if (routine == 'daily') {
                      await notif.scheduleDailyNotification(
                        id: 1,
                        title: 'Ready to log today?',
                        body: quote,
                        hour: hour,
                        minute: minute,
                      );
                    } else if (routine == 'weekly') {
                      await notif.scheduleWeeklyNotification(
                        id: 2,
                        title: 'Ready to log this week?',
                        body: quote,
                        weekday: 1,
                        hour: hour,
                        minute: minute,
                      );
                    }
                  }

                  GoRouter.of(context).go('/home');
                },
              ),
            ],
          ),

          // BACK ARROW
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