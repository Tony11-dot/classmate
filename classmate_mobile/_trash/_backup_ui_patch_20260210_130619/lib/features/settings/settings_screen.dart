import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../demo/demo_store.dart';
import '../../theme/theme_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ts = ref.watch(themeControllerProvider);

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        const Text(
          'More',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),

        Card(
          child: ListTile(
            leading: const Icon(Icons.cloud_sync_outlined),
            title: const Text(
              'Import',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            subtitle: const Text('Google Classroom sync (demo)'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/import'),
          ),
        ),

        Card(
          child: ListTile(
            leading: const Icon(Icons.light_mode_outlined),
            title: const Text(
              'Theme mode',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            subtitle: Text(ts.mode.name),
            onTap: () => _modeSheet(context, ref),
          ),
        ),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Presets',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children: [
                    ChoiceChip(
                      label: const Text('Super Minimal'),
                      selected: ts.preset == ThemePreset.minimal,
                      onSelected: (_) => ref
                          .read(themeControllerProvider.notifier)
                          .setPreset(ThemePreset.minimal),
                    ),
                    ChoiceChip(
                      label: const Text('iOS Cards'),
                      selected: ts.preset == ThemePreset.iosCards,
                      onSelected: (_) => ref
                          .read(themeControllerProvider.notifier)
                          .setPreset(ThemePreset.iosCards),
                    ),
                    ChoiceChip(
                      label: const Text('Sharp Contrast'),
                      selected: ts.preset == ThemePreset.sharpContrast,
                      onSelected: (_) => ref
                          .read(themeControllerProvider.notifier)
                          .setPreset(ThemePreset.sharpContrast),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                const Text(
                  'Radius',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                Slider(
                  min: 6,
                  max: 22,
                  divisions: 16,
                  value: ts.radius,
                  onChanged: (v) =>
                      ref.read(themeControllerProvider.notifier).setRadius(v),
                ),

                const Text(
                  'Density',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                Slider(
                  min: -2,
                  max: 2,
                  divisions: 8,
                  value: ts.density,
                  onChanged: (v) =>
                      ref.read(themeControllerProvider.notifier).setDensity(v),
                ),

                const SizedBox(height: 10),
                const Text(
                  'Accent',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  children: [
                    for (final c in const [
                      Colors.blue,
                      Colors.teal,
                      Colors.indigo,
                      Colors.purple,
                      Colors.pink,
                      Colors.orange,
                      Colors.green,
                    ])
                      InkWell(
                        onTap: () => ref
                            .read(themeControllerProvider.notifier)
                            .setSeed(c),
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),

        Card(
          child: ListTile(
            leading: const Icon(Icons.auto_fix_high_outlined),
            title: const Text(
              'Solutions',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            subtitle: const Text('Guided plan + rewards'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/solutions'),
          ),
        ),

        Card(
          child: ListTile(
            leading: const Icon(Icons.refresh_rounded),
            title: const Text(
              'Reset demo',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            subtitle: const Text('Restores points, submissions, notifications'),
            onTap: () {
              DemoStore.reset();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Demo reset.')));
            },
          ),
        ),
      ],
    );
  }

  void _modeSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('System'),
              onTap: () {
                ref
                    .read(themeControllerProvider.notifier)
                    .setMode(ThemeMode.system);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Light'),
              onTap: () {
                ref
                    .read(themeControllerProvider.notifier)
                    .setMode(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Dark'),
              onTap: () {
                ref
                    .read(themeControllerProvider.notifier)
                    .setMode(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
