import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phoenix/widgets/bottom_rounded_container.dart';
import 'package:phoenix/widgets/option_button.dart';
import 'package:phoenix/widgets/onboarding_footer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:phoenix/core/app_state.dart';
import 'package:phoenix/services/supabase_user_service.dart';

class RoutineSelection extends StatefulWidget {
  const RoutineSelection({super.key});

  @override
  State<RoutineSelection> createState() => _RoutineSelectionState();
}

class _RoutineSelectionState extends State<RoutineSelection> {
  String? selectedOption;

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Color(0xFFDF2A00),
                ],
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: BottomRoundedContainer(
              height: null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    "Personalize Your Check–In Routine",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Choose the rhythm that feels right to you.",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 30),

                  Row(
                    children: [
                      Expanded(
                        child: OptionButton(
                          text: "Daily",
                          selected: selectedOption == "Daily",
                          onTap: () => setState(() => selectedOption = "Daily"),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OptionButton(
                          text: "Weekly",
                          selected: selectedOption == "Weekly",
                          onTap: () => setState(() => selectedOption = "Weekly"),
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 24),

                  OnboardingFooter(
                    activeIndex: 0,
                    onSkip: () {
                      Navigator.of(context).maybePop();
                    },
                    onNext: () async {
                      if (selectedOption == "Daily" || selectedOption == "Weekly") {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          await SupabaseUserService().updateUser(user.uid, {
                            'routine': selectedOption!.toLowerCase(),
                          });
                        }

                        final appState = await AppState.create();
                        await appState.setRoutine(selectedOption!.toLowerCase());

                        if (context.mounted) {
                          if (selectedOption == "Daily") {
                            context.go('/daily_setup');
                          } else {
                            context.go('/weekly_setup');
                          }
                        }
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select one option')),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: statusBarHeight + 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () {
                GoRouter.of(context).go('/signup');
              },
            ),
          ),
        ],
      ),
    );
  }
}
