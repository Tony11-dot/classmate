import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/theme/theme_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeControllerProvider);
    final tc = ref.read(themeControllerProvider.notifier);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        _Section(
          title: 'Appearance',
          child: Column(
            children: [
              _Row(
                title: 'Theme',
                subtitle: 'System / Light / Dark',
                trailing: DropdownButton<ThemeMode>(
                  value: t.mode,
                  onChanged: (v) => v == null ? null : tc.setMode(v),
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('System'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('Light'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Dark'),
                    ),
                  ],
                ),
              ),
              _Divider(),
              _SliderRow(
                title: 'Text size',
                subtitle: 'Scale',
                value: t.textScale,
                min: 0.9,
                max: 1.3,
                onChanged: (v) => tc.setTextScale(v),
              ),
              _Divider(),
              _ToggleRow(
                title: 'Reduce motion',
                subtitle: 'Fewer animations',
                value: t.reduceMotion,
                onChanged: (v) => tc.setReduceMotion(v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _Section(
          title: 'Customization',
          child: Column(
            children: [
              _ColorRow(
                title: 'Accent',
                subtitle: 'App highlight color',
                value: t.accent,
                onPick: (c) => tc.setAccent(c),
              ),
              _Divider(),
              _SliderRow(
                title: 'Corner radius',
                subtitle: 'Cards & buttons',
                value: t.radius,
                min: 8,
                max: 28,
                onChanged: (v) => tc.setRadius(v),
              ),
              _Divider(),
              _SliderRow(
                title: 'Density',
                subtitle: 'Compact ↔ Comfortable',
                value: t.density,
                min: -1,
                max: 1,
                onChanged: (v) => tc.setDensity(v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _Section(
          title: 'Account',
          child: Column(
            children: [
              _Row(
                title: 'Log out',
                subtitle: 'Sign out of this device',
                trailing: const Icon(Icons.logout),
                onTap: () => ref.read(authControllerProvider).logout(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 6),
    child: Divider(height: 1),
  );
}

class _Row extends StatelessWidget {
  const _Row({
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

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

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: SizedBox(
        width: 180,
        child: Slider(value: value, min: min, max: max, onChanged: onChanged),
      ),
    );
  }
}

class _ColorRow extends StatelessWidget {
  const _ColorRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onPick,
  });

  final String title;
  final String subtitle;
  final Color value;
  final ValueChanged<Color> onPick;

  static const _swatches = <Color>[
    Color(0xFF4F46E5),
    Color(0xFF0EA5E9),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
  ];

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: _swatches
            .map(
              (c) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => onPick(c),
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: c.toARGB32() == value.toARGB32() ? 3 : 1,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
