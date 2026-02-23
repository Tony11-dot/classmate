import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/theme_controller.dart';
import '../../core/ui/cm_scaffold.dart';
import '../../core/ui/glass.dart';

class CustomizationScreen extends ConsumerWidget {
  const CustomizationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeControllerProvider);
    final c = ref.read(themeControllerProvider.notifier);

    final accents = <int>[
      0xFF4F46E5,
      0xFF0EA5E9,
      0xFF10B981,
      0xFFF59E0B,
      0xFFEF4444,
      0xFFE11D48,
      0xFF7C5CFF,
      0xFF00C2A8,
    ];

    Widget presetChip(String label, String value) {
      final on = (t.preset == value);
      return ChoiceChip(
        label: Text(label),
        selected: on,
        onSelected: (_) => c.setPreset(value),
      );
    }

    Widget accentDot(int argb) {
      final on = (t.accent.value == argb);
      return InkWell(
        onTap: () => c.setAccent(Color(argb)),
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(argb),
            border: Border.all(
              width: on ? 3 : 1,
              color: on ? Theme.of(context).colorScheme.onSurface : Colors.white24,
            ),
          ),
          child: on ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
        ),
      );
    }

    return CMScaffold(
      title: 'Customization',
      actions: [
        IconButton(
          tooltip: 'Reset',
          onPressed: () async {
            await c.setPreset('glass');
            await c.setMode(ThemeMode.system);
            await c.setAccent(const Color(0xFF4F46E5));
            await c.setRadius(18);
            await c.setDensity(0);
            await c.setTextScale(1);
            await c.setReduceMotion(false);
          },
          icon: const Icon(Icons.restart_alt),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Preset', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    presetChip('Glass', 'glass'),
                    presetChip('Soft', 'soft'),
                    presetChip('Sharp', 'sharp'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Theme mode', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(value: ThemeMode.system, label: Text('System')),
                    ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                    ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                  ],
                  selected: {t.mode},
                  onSelectionChanged: (s) => c.setMode(s.first),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Accent', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                Wrap(spacing: 10, runSpacing: 10, children: accents.map(accentDot).toList()),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Corner radius', style: Theme.of(context).textTheme.titleMedium),
                Slider(
                  min: 8,
                  max: 28,
                  divisions: 20,
                  value: t.radius.clamp(8, 28),
                  label: t.radius.toStringAsFixed(0),
                  onChanged: (v) => c.setRadius(v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Density', style: Theme.of(context).textTheme.titleMedium),
                Slider(
                  min: -1,
                  max: 1,
                  divisions: 20,
                  value: t.density.clamp(-1, 1),
                  label: t.density.toStringAsFixed(1),
                  onChanged: (v) => c.setDensity(v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Text size', style: Theme.of(context).textTheme.titleMedium),
                Slider(
                  min: 0.9,
                  max: 1.3,
                  divisions: 8,
                  value: t.textScale.clamp(0.9, 1.3),
                  label: t.textScale.toStringAsFixed(2),
                  onChanged: (v) => c.setTextScale(v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            child: SwitchListTile(
              value: t.reduceMotion,
              onChanged: (v) => c.setReduceMotion(v),
              title: const Text('Reduce motion'),
              subtitle: const Text('Less animation / blur effects'),
            ),
          ),
        ],
      ),
    );
  }
}
