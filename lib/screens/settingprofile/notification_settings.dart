import 'package:flutter/material.dart';
// import 'package:android_intent_plus/android_intent.dart';
// import 'package:android_intent_plus/flag.dart';
import 'package:flutter/services.dart';

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notification Permissions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Card(
              color: Colors.yellow[50],
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('How to enable notifications:', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('1. Open your device Settings.'),
                    Text('2. Go to Apps > phoenix.'),
                    Text('3. Tap "Notifications".'),
                    Text('4. Enable notifications for this app.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // The following button is disabled because android_intent_plus is not available
            ElevatedButton.icon(
              icon: const Icon(Icons.alarm),
              label: const Text('Open Exact Alarm Settings (unavailable)'),
              onPressed: null,
            ),
            const SizedBox(height: 24),
            const Text('Reminder Type', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ReminderTypeSelector(),
          ],
        ),
      ),
    );
  }
}

class ReminderTypeSelector extends StatefulWidget {
  @override
  State<ReminderTypeSelector> createState() => _ReminderTypeSelectorState();
}

class _ReminderTypeSelectorState extends State<ReminderTypeSelector> {
  String _selected = 'daily';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RadioListTile<String>(
          title: const Text('Daily'),
          value: 'daily',
          groupValue: _selected,
          onChanged: (val) {
            setState(() => _selected = val!);
            // TODO: update reminder type in Supabase & reschedule notification
          },
        ),
        RadioListTile<String>(
          title: const Text('Weekly'),
          value: 'weekly',
          groupValue: _selected,
          onChanged: (val) {
            setState(() => _selected = val!);
            // TODO: update reminder type in Supabase & reschedule notification
          },
        ),
      ],
    );
  }
}
