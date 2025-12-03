import 'package:flutter/material.dart';
import 'package:phoenix/styles/app_palette.dart';
import 'package:url_launcher/url_launcher.dart';

class InformationPage extends StatelessWidget {
  const InformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        title: Text(
          'Information',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: cs.onSurface),
            onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // App Info
            _sectionTitle('App Info', cs),
            _infoTile('App Name', 'Phoenix', cs, onTap: null),
            _infoTile('Version', '1.0.0', cs, onTap: null),

            const SizedBox(height: 20),

            // Legal / Policy
            _sectionTitle('Legal / Policy', cs),
            _infoTile(
              'Privacy Policy',
              '',
              cs,
              onTap: () => _showDialog(context, 'Privacy Policy', 'This is the privacy policy placeholder.'),
            ),
            _infoTile(
              'Terms & Conditions',
              '',
              cs,
              onTap: () => _showDialog(context, 'Terms & Conditions', 'This is the terms & conditions placeholder.'),
            ),

            const SizedBox(height: 20),

            // Support
            _sectionTitle('Support', cs),
            _infoTile(
              'Contact Email',
              'support@phoenixapp.com',
              cs,
              onTap: () => _launchEmail('support@phoenixapp.com'),
            ),
            _infoTile(
              'Feedback',
              '',
              cs,
              onTap: () => _showDialog(context, 'Feedback', 'This feature is coming soon!'),
            ),

            const SizedBox(height: 30),

            // Footer Version
            Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, ColorScheme cs) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: cs.onSurface,
      ),
    ),
  );

  Widget _infoTile(String title, String subtitle, ColorScheme cs, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(13),
      ),
      child: ListTile(
        title: Text(title, style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w500)),
        subtitle: subtitle.isNotEmpty ? Text(subtitle, style: TextStyle(color: cs.onSurfaceVariant)) : null,
        trailing: onTap != null ? Icon(Icons.arrow_forward_ios, size: 16, color: cs.onSurfaceVariant) : null,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }

  void _showDialog(BuildContext context, String title, String content) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cs.surface,
        title: Text(title, style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold)),
        content: Text(content, style: TextStyle(color: cs.onSurfaceVariant)),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: AppPalette.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
