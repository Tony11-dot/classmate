import 'package:flutter/material.dart';

import '../../core/semester/school_semester.dart';
import '../../l10n/app_localizations.dart';
import 'liquid_glass_dropdown.dart';

/// Number of semesters the school has configured (admin-defined). Default 2 when
/// none are set. A school can have 1, 2, 3, … semesters.
int schoolSemesterCount(String rawSemesters) {
  final n = parseSchoolSemesters(rawSemesters).length;
  return n > 0 ? n : 2;
}

/// Liquid-glass dropdown to pick which semester a grade counts toward:
/// "Auto (by date)" or Semester 1..[count].
class SemesterSelectField extends StatelessWidget {
  const SemesterSelectField({
    super.key,
    required this.count,
    required this.value,
    required this.onChanged,
  });

  final int count;
  final int? value; // null = auto
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final n = count < 1 ? 2 : count;
    return LiquidGlassSelectField<int>(
      label: l.gradeSemesterLabel,
      value: value ?? 0,
      items: [
        LiquidGlassDropdownItem(value: 0, label: l.gradeSemesterAuto),
        for (int i = 1; i <= n; i++) LiquidGlassDropdownItem(value: i, label: l.adminSchoolSemesterN('$i')),
      ],
      onChanged: (v) => onChanged(v == 0 ? null : v),
    );
  }
}
