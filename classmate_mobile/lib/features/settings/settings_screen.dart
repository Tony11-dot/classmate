import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/pilot_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(themeControllerProvider);
    final c = ref.read(themeControllerProvider.notifier);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Design',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        const SizedBox(height: 10),

        Card(
          child: ListTile(
            title: const Text('Theme preset'),
            subtitle: Text(s.preset.name),
            trailing: DropdownButton<ThemePreset>(
              value: s.preset,
              items: const [
                DropdownMenuItem(
                  value: ThemePreset.appleClean,
                  child: Text('Apple Clean'),
                ),
                DropdownMenuItem(
                  value: ThemePreset.sharpContrast,
                  child: Text('Sharp / High Contrast'),
                ),
                DropdownMenuItem(
                  value: ThemePreset.softFriendly,
                  child: Text('Soft / Friendly'),
                ),
              ],
              onChanged: (v) => c.setPreset(v ?? ThemePreset.appleClean),
            ),
          ),
        ),

        Card(
          child: ListTile(
            title: const Text('Mode'),
            subtitle: Text(s.mode.name),
            trailing: DropdownButton<ThemeMode>(
              value: s.mode,
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('System'),
                ),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
              ],
              onChanged: (v) => c.setMode(v ?? ThemeMode.system),
            ),
          ),
        ),

        Card(
          child: ListTile(
            title: const Text('Accent'),
            subtitle: const Text('Tap to cycle (pilot)'),
            trailing: CircleAvatar(backgroundColor: s.accent),
            onTap: () {
              const accents = [
                Color(0xFF3B82F6),
                Color(0xFF22C55E),
                Color(0xFFF97316),
                Color(0xFFA855F7),
                Color(0xFFEF4444),
              ];
              final i = accents.indexOf(s.accent);
              c.setAccent(accents[(i + 1) % accents.length]);
            },
          ),
        ),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Radius: ${s.radius.toStringAsFixed(0)}'),
                Slider(
                  value: s.radius,
                  min: 8,
                  max: 24,
                  divisions: 16,
                  onChanged: c.setRadius,
                ),
                const SizedBox(height: 6),
                Text('Density: ${s.density.toStringAsFixed(0)}'),
                Slider(
                  value: s.density,
                  min: -1,
                  max: 1,
                  divisions: 4,
                  onChanged: c.setDensity,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
