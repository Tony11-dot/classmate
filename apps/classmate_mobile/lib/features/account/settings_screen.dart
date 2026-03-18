import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/theme/theme_controller.dart';
import '../../ui/widgets/liquid_glass_dropdown.dart';

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
              LiquidGlassDropdown<ThemeMode>(
                label: 'Theme',
                value: t.mode,
                items: const [
                  LiquidGlassDropdownItem(
                    value: ThemeMode.system,
                    label: 'System',
                    icon: Icons.settings_suggest_rounded,
                  ),
                  LiquidGlassDropdownItem(
                    value: ThemeMode.light,
                    label: 'Light',
                    icon: Icons.light_mode_rounded,
                  ),
                  LiquidGlassDropdownItem(
                    value: ThemeMode.dark,
                    label: 'Dark',
                    icon: Icons.dark_mode_rounded,
                  ),
                ],
                onChanged: tc.setMode,
                searchHint: 'System / Light / Dark',
              ),
              const _Divider(),
              _SliderRow(
                title: 'Text size',
                subtitle: 'Scale',
                value: t.textScale,
                min: 0.9,
                max: 1.3,
                onChanged: tc.setTextScale,
              ),
              const _Divider(),
              _ToggleRow(
                title: 'Reduce motion',
                subtitle: 'Fewer animations',
                value: t.reduceMotion,
                onChanged: tc.setReduceMotion,
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
                onPick: tc.setAccent,
              ),
              const _Divider(),
              _SliderRow(
                title: 'Corner radius',
                subtitle: 'Cards & buttons',
                value: t.radius,
                min: 8,
                max: 28,
                onChanged: tc.setRadius,
              ),
              const _Divider(),
              _SliderRow(
                title: 'Density',
                subtitle: 'Compact ↔ Comfortable',
                value: t.density,
                min: -1,
                max: 1,
                onChanged: tc.setDensity,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _Section(
          title: 'Privacy',
          child: Column(
            children: const [
              ListTile(
                title: Text('Profile field privacy'),
                subtitle: Text('Managed from Edit profile'),
                trailing: Icon(Icons.lock_rounded),
              ),
              Divider(height: 1),
              ListTile(
                title: Text('Messaging safety'),
                subtitle: Text('Block/unblock inside DM threads'),
                trailing: Icon(Icons.block_rounded),
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
                trailing: const Icon(Icons.logout_rounded),
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
  const _Divider();
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

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: value,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      onTap: () async {
        final picked = await showDialog<Color>(
          context: context,
          builder: (_) => _AccentPickerDialog(value: value),
        );
        if (picked != null) onPick(picked);
      },
    );
  }
}

class _AccentPickerDialog extends StatelessWidget {
  const _AccentPickerDialog({required this.value});
  final Color value;

  @override
  Widget build(BuildContext context) {
    final swatches = <Color>[
      const Color(0xFF4F46E5),
      const Color(0xFF0EA5E9),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFFEC4899),
      const Color(0xFF8B5CF6),
      const Color(0xFF111827),
    ];

    return AlertDialog(
      title: const Text('Pick accent'),
      content: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final c in swatches)
            InkWell(
              onTap: () => Navigator.of(context).pop(c),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: c,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: c == value
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outlineVariant,
                    width: c == value ? 2 : 1,
                  ),
                ),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
