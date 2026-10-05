import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/cm_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/widgets/cm_press.dart';

/// Classroom join-code card shared by the teacher and student People tabs, so
/// everyone sees the same server-issued code rendered the same way.
class ClassroomCodeCard extends StatelessWidget {
  const ClassroomCodeCard({super.key, required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final text = code.trim().toUpperCase();
    if (text.isEmpty) return const SizedBox.shrink();

    Future<void> copy() async {
      await Clipboard.setData(ClipboardData(text: text));
      HapticFeedback.selectionClick();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.teacherClassroomCodeCopied),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 6, 12),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(CmTokens.radiusLg),
      ),
      child: Row(
        children: [
          Icon(Icons.vpn_key_rounded, size: 18, color: cs.onSecondaryContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.classroomCodeLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: cs.onSecondaryContainer.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                // Code is always LTR, even in he/ar.
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: [
                      for (final ch in text.split(''))
                        Container(
                          width: 26,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: cs.surface.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            ch,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: cs.onSurface,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: copy,
            tooltip: l.teacherClassroomCopyCodeTooltip,
            icon: Icon(Icons.copy_rounded, size: 20, color: cs.onSecondaryContainer),
          ),
        ],
      ),
    );
  }
}

/// A titled group of people rows inside one rounded card, separated by
/// hairlines (instead of a separate boxed card per person).
class ClassroomPeopleGroup extends StatelessWidget {
  const ClassroomPeopleGroup({
    super.key,
    required this.title,
    required this.children,
    this.trailing,
  });

  final String title;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 6, bottom: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: cs.onSurfaceVariant,
                          letterSpacing: 0.3,
                        ),
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
          if (children.isNotEmpty)
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(CmTokens.radiusLg),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.35),
                  width: 0.8,
                ),
              ),
              child: Material(
                type: MaterialType.transparency,
                child: Column(
                  children: [
                    for (var i = 0; i < children.length; i++) ...[
                      if (i > 0)
                        Divider(
                          height: 1,
                          thickness: 0.6,
                          indent: 58,
                          color: cs.outlineVariant.withValues(alpha: 0.45),
                        ),
                      children[i],
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// One compact person row: avatar, name (+ optional secondary line), and an
/// optional trailing widget.
class ClassroomPersonRow extends StatelessWidget {
  const ClassroomPersonRow({
    super.key,
    required this.name,
    this.subtitle = '',
    this.isTeacher = false,
    this.onTap,
    this.trailing,
  });

  final String name;
  final String subtitle;
  final bool isTeacher;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final row = Padding(
      padding: EdgeInsetsDirectional.fromSTEB(12, 8, trailing == null ? 14 : 4, 8),
      child: Row(
        children: [
          ClassroomInitialsAvatar(name: name, isTeacher: isTeacher),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (subtitle.trim().isNotEmpty)
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
    if (onTap == null) return row;
    return CmPress(onTap: onTap, child: row);
  }
}

class ClassroomInitialsAvatar extends StatelessWidget {
  const ClassroomInitialsAvatar({
    super.key,
    required this.name,
    this.isTeacher = false,
    this.size = 34,
  });

  final String name;
  final bool isTeacher;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = isTeacher ? cs.primary : _avatarColorForName(name);
    final fg = isTeacher
        ? cs.onPrimary
        : (ThemeData.estimateBrightnessForColor(bg) == Brightness.dark
            ? Colors.white
            : Colors.black87);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Text(
        _initialsForName(name),
        style: TextStyle(
          fontSize: size * 0.36,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}

/// Small "Teacher" pill used as a row trailing badge.
class ClassroomRoleBadge extends StatelessWidget {
  const ClassroomRoleBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: cs.onPrimaryContainer,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

Color _avatarColorForName(String name) {
  const palette = <Color>[
    Color(0xFF9CCC65),
    Color(0xFF4FC3F7),
    Color(0xFFFFB74D),
    Color(0xFFBA68C8),
    Color(0xFFFF8A65),
    Color(0xFF4DB6AC),
    Color(0xFFA1887F),
    Color(0xFF7986CB),
  ];
  final seed = name.trim().toLowerCase().runes.fold<int>(0, (a, b) => a + b);
  return palette[seed % palette.length];
}

String _initialsForName(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((e) => e.trim().isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    final v = parts.first.trim();
    return v.length >= 2 ? v.substring(0, 2).toUpperCase() : v.toUpperCase();
  }
  return (parts.first[0] + parts.last[0]).toUpperCase();
}
