import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final String avatarUrl;
  final String name;
  final String tagline;
  final VoidCallback onSettings;
  final VoidCallback onLogout;
  const HomeHeader({
    super.key,
    required this.avatarUrl,
    required this.name,
    required this.tagline,
    required this.onSettings,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 26,
          backgroundImage: NetworkImage(avatarUrl),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                tagline,
                style: t.bodySmall?.copyWith(
                  color: t.bodySmall?.color?.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Settings',
          onPressed: onSettings,
          icon: Icon(Icons.settings_outlined,
              color: t.bodyMedium?.color),
        ),
        IconButton(
          tooltip: 'Logout',
          onPressed: onLogout,
          icon: Icon(Icons.logout, color: t.bodyMedium?.color),
        ),
      ],
    );
  }
}