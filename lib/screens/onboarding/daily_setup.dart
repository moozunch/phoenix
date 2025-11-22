import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phoenix/widgets/bottom_rounded_container.dart';
import 'package:phoenix/widgets/time_picker.dart';
import 'package:phoenix/widgets/label_switch.dart';
import 'package:phoenix/widgets/onboarding_footer.dart';
import 'package:phoenix/styles/app_palette.dart';

class DailySetup extends StatefulWidget {
  const DailySetup({super.key});

  @override
  State<DailySetup> createState() => _DailySetupState();
}

class _DailySetupState extends State<DailySetup> {
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

    if (result != null) {
      setState(() {
        _selectedTime = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          BottomRoundedContainer(
            height: size.height * 0.55,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16), // spacing below the back arrow
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
                  timeLabel: _selectedTime.format(context),
                  onTap: _pickTime,
                ),
                const SizedBox(height: 24),
                LabelSwitch(
                  label: "All-day reminder?",
                  value: _allDayReminder,
                  onChanged: (v) => setState(() => _allDayReminder = v),
                ),
                const Spacer(),
                OnboardingFooter(
                  activeIndex: 1,
                  onSkip: () {
                    Navigator.of(context).maybePop();
                  },
                  onNext: () {
                    GoRouter.of(context).go('/success_screen?from=daily');
                  },
                ),
              ],
            ),
          ),
          // Back arrow button
          Positioned(
            top: statusBarHeight + 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () {
                GoRouter.of(context).go('/routine_selection'); // go back to routine_selection
              },
            ),
          ),
        ],
      ),
    );
  }
}
