import 'package:flutter/material.dart';
import '../../../ui/glass/liquid_glass_card.dart';

class TeacherErrorBanner extends StatelessWidget {
  const TeacherErrorBanner({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: LiquidGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        color: cs.errorContainer,
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: cs.onErrorContainer, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message, style: TextStyle(color: cs.onErrorContainer, fontSize: 13)),
            ),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class TeacherEmptyState extends StatelessWidget {
  const TeacherEmptyState({super.key, required this.icon, required this.message, this.subtitle});
  final IconData icon;
  final String message;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: cs.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w500),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String initialsForName(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.first.isEmpty) return '?';
  if (parts.length == 1) return parts[0][0].toUpperCase();
  return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
}

Color avatarColorForName(String name, List<Color> palette) {
  if (name.isEmpty) return palette[0];
  final code = name.codeUnits.fold(0, (a, b) => a + b);
  return palette[code % palette.length];
}

abstract final class AttendanceStatus {
  static const present = 'PRESENT';
  static const absent = 'ABSENT';
  static const late = 'LATE';
  static const excused = 'EXCUSED';
  static const values = [present, absent, late, excused];
}
