import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Tiny role chip shown next to a user's name in chat threads, member
/// lists, profile sheets, and @mentions. Single source of truth for
/// role colour + display label so a role rename is a one-file change.
///
/// Why this exists: until today the codebase rendered the role as
/// plain text in three different spots with three different formats
/// ("Secretary", "secretary", "SECRETARY"). This unifies them.
class RoleBadge extends StatelessWidget {
  const RoleBadge({
    super.key,
    required this.role,
    this.compact = false,
  });

  /// The raw role string from the server. Case-insensitive.
  final String role;

  /// Compact = smaller font, tighter padding. Use inside dense lists.
  final bool compact;

  static const Map<String, Color> _colors = {
    'STUDENT': Color(0xFF1976D2),
    'TEACHER': Color(0xFF2E7D32),
    'ADMIN': Color(0xFFD32F2F),
    'SECRETARY': Color(0xFF7B1FA2),
    'PARENT': Color(0xFFE65100),
  };

  String _label(AppLocalizations l, String key) {
    switch (key) {
      case 'STUDENT':
        return l.roleBadgeStudent;
      case 'TEACHER':
        return l.roleBadgeTeacher;
      case 'ADMIN':
        return l.roleBadgeAdmin;
      case 'SECRETARY':
        return l.roleBadgeSecretary;
      case 'PARENT':
        return l.roleBadgeParent;
      default:
        return l.roleBadgeMember;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final key = role.trim().toUpperCase();
    final color = _colors[key] ?? const Color(0xFF607D8B);
    final label = _label(l, key);
    final fontSize = compact ? 10.0 : 11.0;
    final hPad = compact ? 6.0 : 8.0;
    final vPad = compact ? 2.0 : 3.0;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
          height: 1.0,
        ),
      ),
    );
  }
}
