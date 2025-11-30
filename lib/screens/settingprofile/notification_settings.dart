import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:android_intent_plus/android_intent.dart';
// import 'package:android_intent_plus/flag.dart';

import 'package:phoenix/services/notification_service.dart';
import 'package:phoenix/services/supabase_user_service.dart';

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Notification Settings",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _NotificationSettingsContent(),
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
            _reminderTime = userModel.reminderTime.substring(0,5);
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
      if (_loading) {
        return const Center(child: CircularProgressIndicator());
      }
      return Column(
        children: [
          _menuItem(
            title: "Notification Permissions",
            value: "Enabled",
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('How to enable notifications'),
                  content: const Text(
                    '1. Open your device Settings.\n'
                    '2. Go to Apps > phoenix.\n'
                    '3. Tap "Notifications".\n'
                    '4. Enable notifications for this app.'
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
          _menuItem(
            title: "Reminder Type",
            value: _reminderType == 'weekly' ? 'Weekly' : 'Daily',
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: ReminderTypeSelector(
                    selected: _reminderType,
                    onChanged: (val) {
                      Navigator.pop(context);
                      _updateReminderType(val);
                    },
                  ),
                ),
              );
            },
          ),
          _menuItem(
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
              );
              if (picked != null) {
                final formatted = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                await _updateReminderTime(formatted);
              }
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDF2A00),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
                elevation: 0,
              ),
              onPressed: _testNotification,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.notifications_active, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text(
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
  Widget _menuItem({required String title, String? value, required Function() onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(13),
      ),
      child: ListTile(
        title: Text(title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (value != null) Text(value),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward_ios, size: 16),
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
  @override
  void initState() {
    super.initState();
    _selected = widget.selected ?? 'daily';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 12),
        RadioListTile<String>(
          title: const Text('Daily'),
          value: 'daily',
          groupValue: _selected,
          onChanged: (val) {
            setState(() => _selected = val!);
            if (widget.onChanged != null) widget.onChanged!(val!);
          },
        ),
        Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
        RadioListTile<String>(
          title: const Text('Weekly'),
          value: 'weekly',
          groupValue: _selected,
          onChanged: (val) {
            setState(() => _selected = val!);
            if (widget.onChanged != null) widget.onChanged!(val!);
          },
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Cancel",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
