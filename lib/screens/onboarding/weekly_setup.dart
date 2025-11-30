import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phoenix/core/app_state.dart';
import 'package:phoenix/widgets/bottom_rounded_container.dart';
import 'package:phoenix/widgets/time_picker.dart';
import 'package:phoenix/widgets/onboarding_footer.dart';
import 'package:phoenix/styles/app_palette.dart';

class WeeklySetup extends StatefulWidget {
  const WeeklySetup({super.key});

  @override
  State<WeeklySetup> createState() => _WeeklySetupState();
}

class _WeeklySetupState extends State<WeeklySetup> {
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);

  final List<String> _days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
  final Set<String> _selectedDays = {};

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
      setState(() => _selectedTime = result);
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
            height: size.height * 0.65,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text(
                  "Your Weekly Check-in Set Up",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Select your preferred days.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 20,
                  childAspectRatio: 2.5,
                  children: _days.map((day) {
                    final bool isSelected = _selectedDays.contains(day);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedDays.remove(day);
                          } else {
                            _selectedDays.add(day);
                          }
                        });
                      },
                      child: Row(
                        children: [
                          Container(
                            height: 22,
                            width: 22,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppPalette.primary,
                                width: 1.5,
                              ),
                              color: isSelected ? AppPalette.primary : Colors.white,
                            ),
                            child: isSelected
                                ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            day,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Choose your preferred time.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 16),
                TimePicker(
                  timeLabel: context.mounted ? _selectedTime.format(context) : '',
                  onTap: _pickTime,
                ),
                const Spacer(),
                OnboardingFooter(
                  activeIndex: 1, // Weekly is step 2
                  onSkip: () {
                    Navigator.of(context).maybePop();
                  },
                  onNext: () async {
                    if (_selectedDays.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select at least one day'),
                        ),
                      );
                      return;
                    }
                    final hour = _selectedTime.hour.toString().padLeft(2, '0');
                    final minute = _selectedTime.minute.toString().padLeft(2, '0');
                    final reminderTime = '$hour:$minute:00';
                    final appState = await AppState.create();
                    await appState.setReminderTime(reminderTime);
                    if (!context.mounted) return;
                    GoRouter.of(context).go('/success_screen?from=weekly');
                  },
                ),
              ],
            ),
          ),
          Positioned(
            top: statusBarHeight + 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => GoRouter.of(context).go('/routine_selection'),
            ),
          ),
        ],
      ),
    );
  }
}
