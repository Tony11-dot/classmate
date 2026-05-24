import 'package:flutter/material.dart';

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

  static const Map<String, _RoleStyle> _styles = {
    'STUDENT': _RoleStyle(label: 'Student', color: Color(0xFF1976D2)),
    'TEACHER': _RoleStyle(label: 'Teacher', color: Color(0xFF2E7D32)),
    'ADMIN': _RoleStyle(label: 'Admin', color: Color(0xFFD32F2F)),
    'SECRETARY': _RoleStyle(label: 'Secretary', color: Color(0xFF7B1FA2)),
    'PARENT': _RoleStyle(label: 'Parent', color: Color(0xFFE65100)),
  };

  @override
  Widget build(BuildContext context) {
    final key = role.trim().toUpperCase();
    final style = _styles[key] ?? const _RoleStyle(label: 'Member', color: Color(0xFF607D8B));
    final fontSize = compact ? 10.0 : 11.0;
    final hPad = compact ? 6.0 : 8.0;
    final vPad = compact ? 2.0 : 3.0;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: style.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: style.color.withValues(alpha: 0.35), width: 0.8),
      ),
      child: Text(
        style.label,
        style: TextStyle(
          color: style.color,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
          height: 1.0,
        ),
      ),
    );
  }
}

class _RoleStyle {
  const _RoleStyle({required this.label, required this.color});
  final String label;
  final Color color;
}
