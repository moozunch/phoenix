import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phoenix/core/app_state.dart';
import 'package:phoenix/widgets/bottom_rounded_container.dart';
import 'package:phoenix/widgets/time_picker.dart';
import 'package:phoenix/widgets/label_switch.dart';
import 'package:phoenix/widgets/onboarding_footer.dart';
import 'package:phoenix/styles/app_palette.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DailySetup extends StatefulWidget {
  const DailySetup({super.key});

  @override
  State<DailySetup> createState() => _DailySetupState();
}

class _DailySetupState extends State<DailySetup> {
  Future<User?> getCurrentUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  bool _allDayReminder = false;

  Future<void> _pickTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: const TimePickerThemeData(
              dialBackgroundColor: Colors.white,
              dialHandColor: AppPalette.primary,
              entryModeIconColor: AppPalette.primary,
              hourMinuteTextColor: Colors.black,
              helpTextStyle: TextStyle(color: Colors.black54),
            ),
            colorScheme: const ColorScheme.light(
              primary: AppPalette.primary,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (!mounted) return;
    if (result != null) {
      setState(() {
        _selectedTime = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // FULL SCREEN GRADIENT — same as RoutineSelection
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


          // DYNAMIC HEIGHT BOTTOM CONTAINER
          Column(
            children: [
              const Spacer(), // dorong card ke bawah (sama seperti RoutineSelection fix)
              BottomRoundedContainer(
                height: null,   // tetap flexible
                child: Column(
                  mainAxisSize: MainAxisSize.min, // IMPORTANT: biarkan konten shrink-wrap
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    const Text(
                      "Your Daily Check-in Setup",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Choose your preferred time.",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),

                    const SizedBox(height: 30),

                    TimePicker(
                      timeLabel:
                      context.mounted ? _selectedTime.format(context) : '',
                      onTap: _pickTime,
                    ),

                    const SizedBox(height: 24),

                    LabelSwitch(
                      label: "All-day reminder?",
                      value: _allDayReminder,
                      onChanged: (v) => setState(() => _allDayReminder = v),
                    ),

                    const SizedBox(height: 16), // optional spacing before footer
                    OnboardingFooter(
                      activeIndex: 1,
                      onSkip: () {
                        Navigator.of(context).maybePop();
                      },
                      onNext: () async {
                        final hour =
                        _selectedTime.hour.toString().padLeft(2, '0');
                        final minute =
                        _selectedTime.minute.toString().padLeft(2, '0');
                        final reminderTime = '$hour:$minute:00';

                        final appState = await AppState.create();
                        await appState.setReminderTime(reminderTime);

                        if (!context.mounted) return;
                        GoRouter.of(context)
                            .go('/success_screen?from=daily');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          // BACK BUTTON
          Positioned(
            top: statusBarHeight + 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () {
                GoRouter.of(context).go('/routine_selection');
              },
            ),
          ),
        ],
      ),
    );
  }
}
