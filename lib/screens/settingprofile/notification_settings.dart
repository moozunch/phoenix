import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:phoenix/styles/app_palette.dart';
import 'package:phoenix/services/notification_service.dart';
import 'package:phoenix/services/supabase_user_service.dart';

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text(
          "Notification Settings",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _NotificationSettingsContent(),
        ),
      ),
    );
  }
}

class _NotificationSettingsContent extends StatefulWidget {
  @override
  State<_NotificationSettingsContent> createState() => _NotificationSettingsContentState();
}

class _NotificationSettingsContentState extends State<_NotificationSettingsContent> {
  String _reminderType = 'daily';
  String _reminderTime = '08:00';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
  }

  Future<void> _loadUserSettings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userModel = await SupabaseUserService().getUser(user.uid);
      if (userModel != null) {
        setState(() {
          _reminderType = userModel.routine;
          _reminderTime = userModel.reminderTime.substring(0, 5);
        });
      }
    }
    setState(() => _loading = false);
  }

  Future<void> _updateReminderType(String type) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await SupabaseUserService().updateUser(user.uid, {'routine': type});
      setState(() => _reminderType = type);
      await _rescheduleNotification();
    }
  }

  Future<void> _updateReminderTime(String time) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await SupabaseUserService().updateUser(user.uid, {'reminder_time': '$time:00'});
      setState(() => _reminderTime = time);
      await _rescheduleNotification();
    }
  }

  Future<void> _rescheduleNotification() async {
    final notif = NotificationService();
    await notif.initialize();
    await notif.cancelAll();

    final hour = int.tryParse(_reminderTime.split(':')[0]) ?? 8;
    final minute = int.tryParse(_reminderTime.split(':')[1]) ?? 0;

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

    if (_reminderType == 'daily') {
      await notif.scheduleDailyNotification(
        id: 1,
        title: 'Ready to log today?',
        body: quote,
        hour: hour,
        minute: minute,
      );
    } else {
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

  Future<void> _testNotification() async {
    final notif = NotificationService();
    await notif.initialize();
    await notif.showNotification(
      id: 99,
      title: 'Test Notification',
      body: 'Notification will look like this. This is a test.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        _menuItem(
          context,
          title: "Notification Permissions",
          value: "Enabled",
          onTap: () {
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (ctx) {
                final theme = Theme.of(context);
                return Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "How to enable notifications",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),

                        Text(
                          "1. Open your device Settings.\n"
                              "2. Go to Apps > Phoenix.\n"
                              "3. Tap “Notifications”.\n"
                              "4. Enable notifications for this app.",
                          style: TextStyle(
                            height: 1.5,
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                          ),
                        ),

                        const SizedBox(height: 24),

                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppPalette.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 26,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "OK",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
        _menuItem(
          context,
          title: "Reminder Type",
          value: _reminderType == 'weekly' ? 'Weekly' : 'Daily',
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (_) {
                final theme = Theme.of(context);
                return Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: ReminderTypeSelector(
                    selected: _reminderType,
                    onChanged: (val) {
                      Navigator.pop(context);
                      _updateReminderType(val);
                    },
                  ),
                );
              },
            );
          },
        ),
        _menuItem(
          context,
          title: "Reminder Time",
          value: _reminderTime,
          onTap: () async {
            final initial = TimeOfDay(
              hour: int.tryParse(_reminderTime.split(':')[0]) ?? 8,
              minute: int.tryParse(_reminderTime.split(':')[1]) ?? 0,
            );

            final picked = await showTimePicker(
              context: context,
              initialTime: initial,
              builder: (context, child) {
                final theme = Theme.of(context);
                return Theme(
                  data: theme.copyWith(
                    colorScheme: theme.colorScheme.copyWith(
                      primary: AppPalette.primary,
                      onPrimary: Colors.white,
                    ),
                  ),
                  child: child!,
                );
              },
            );

            if (picked != null) {
              final formatted =
                  '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
              await _updateReminderTime(formatted);
            }
          },
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPalette.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
              elevation: 0,
            ),
            onPressed: _testNotification,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_active, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Test Notification',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _menuItem(BuildContext context,
      {required String title, String? value, required Function() onTap}) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(13),
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (value != null)
              Text(
                value,
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.onSurface),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

class ReminderTypeSelector extends StatefulWidget {
  final String? selected;
  final ValueChanged<String>? onChanged;
  const ReminderTypeSelector({this.selected, this.onChanged, super.key});
  @override
  State<ReminderTypeSelector> createState() => _ReminderTypeSelectorState();
}

class _ReminderTypeSelectorState extends State<ReminderTypeSelector> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected ?? 'daily';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 5,
          decoration: BoxDecoration(
            color: theme.dividerColor.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 12),
        RadioListTile<String>(
          title: Text('Daily', style: TextStyle(color: theme.colorScheme.onSurface)),
          value: 'daily',
          activeColor: AppPalette.primary,
          groupValue: _selected,
          onChanged: (val) {
            setState(() => _selected = val!);
            widget.onChanged?.call(val!);
          },
        ),
        Divider(height: 1, thickness: 1, color: theme.dividerColor.withValues(alpha: 0.2)),
        RadioListTile<String>(
          title: Text('Weekly', style: TextStyle(color: theme.colorScheme.onSurface)),
          value: 'weekly',
          activeColor: AppPalette.primary,
          groupValue: _selected,
          onChanged: (val) {
            setState(() => _selected = val!);
            widget.onChanged?.call(val!);
          },
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Cancel",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
