import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget infoTile({
      required IconData icon,
      required String title,
      required String value,
      required bool isPublic,
    }) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: cs.primaryContainer.withValues(alpha: 0.8),
              child: Icon(icon, size: 18, color: cs.onPrimaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(color: cs.onSurfaceVariant, height: 1.3),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                isPublic ? 'Public' : 'Private',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  child: Text(
                    'TA',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tony Aboud',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text('Founder status • Building ClassMate'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => context.push('/profile/edit'),
          icon: const Icon(Icons.edit_rounded),
          label: const Text('Edit profile'),
        ),
        const SizedBox(height: 16),
        infoTile(
          icon: Icons.school_rounded,
          title: 'School',
          value: 'Technion / ClassMate demo school',
          isPublic: true,
        ),
        infoTile(
          icon: Icons.auto_stories_rounded,
          title: 'Grade / majors',
          value: 'CS • Physics • Mathematics',
          isPublic: true,
        ),
        infoTile(
          icon: Icons.person_outline_rounded,
          title: 'Bio',
          value: 'Builder, tennis player, physics/math/AI lover.',
          isPublic: true,
        ),
        infoTile(
          icon: Icons.bolt_rounded,
          title: 'Status',
          value: 'Shipping student app tonight.',
          isPublic: true,
        ),
      ],
    );
  }
}
