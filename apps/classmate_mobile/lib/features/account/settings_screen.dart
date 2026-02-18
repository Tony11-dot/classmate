import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _logout(BuildContext context) {
    // TODO: wire to auth state; for now just pop to root.
    Navigator.of(context).popUntil((r) => r.isFirst);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Logged out')));
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Customization', style: t.textTheme.titleMedium),
          const SizedBox(height: 8),
          _Card(
            child: Column(
              children: [
                _RowTile(
                  title: 'Theme mode',
                  subtitle: 'Light / Dark / System',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                _RowTile(
                  title: 'Preset',
                  subtitle: 'Apple clean (default)',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                _RowTile(
                  title: 'Accent color',
                  subtitle: 'Pick an accent',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                _RowTile(
                  title: 'Radius & density',
                  subtitle: 'Corners, spacing, text scale',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Account', style: t.textTheme.titleMedium),
          const SizedBox(height: 8),
          _Card(
            child: Column(
              children: [
                _RowTile(
                  title: 'Profile',
                  subtitle: 'Tony Aboud',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            label: const Text('Log out'),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(elevation: 0, clipBehavior: Clip.antiAlias, child: child);
  }
}

class _RowTile extends StatelessWidget {
  const _RowTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
