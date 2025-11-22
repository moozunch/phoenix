import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phoenix/core/app_state.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>{

  Future<void> _logout(BuildContext context) async {
    final state = await AppState.create();
    await state.signOut();
    if (context.mounted) context.go('/signin');

}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          )
        ],
      ),
      body: Center(
        child: FilledButton.icon(
          onPressed: () => _logout(context),
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
        ),
      ),

      //bottom nav bar
      // Nav handled by shell
    );
  }
}