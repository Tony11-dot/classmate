/// School-year semester model + date partitioning.
///
/// Semesters are stored as month-range pairs, e.g. "9-1,2-6" → Semester 1 =
/// Sep→Jan, Semester 2 = Feb→Jun. A record belongs to a semester by its DATE,
/// so existing data is covered automatically (no per-record tagging).
library;

class SchoolSemester {
  const SchoolSemester({required this.number, required this.startMonth, required this.endMonth});
  final int number; // 1-based ("Semester N")
  final int startMonth; // 1-12
  final int endMonth; // 1-12
  bool get wraps => startMonth > endMonth; // e.g. 9→1 spans the new year
}

/// Parses "9-1,2-6" into ordered semesters (Semester 1, 2, … in author order).
List<SchoolSemester> parseSchoolSemesters(String raw) {
  final s = raw.trim();
  if (s.isEmpty) return const <SchoolSemester>[];
  final out = <SchoolSemester>[];
  var n = 1;
  for (final part in s.split(RegExp(r'[,;]+'))) {
    final p = part.trim();
    if (p.isEmpty) continue;
    final m = RegExp(r'^(\d{1,2})-(\d{1,2})$').firstMatch(p);
    if (m == null) continue;
    final a = int.parse(m.group(1)!);
    final b = int.parse(m.group(2)!);
    if (a < 1 || a > 12 || b < 1 || b > 12) continue;
    out.add(SchoolSemester(number: n++, startMonth: a, endMonth: b));
  }
  return out;
}

DateTime _endOfMonth(int year, int month) {
  final firstNext = (month == 12) ? DateTime(year + 1, 1, 1) : DateTime(year, month + 1, 1);
  return firstNext.subtract(const Duration(seconds: 1));
}

class SemesterWindow {
  const SemesterWindow({required this.number, required this.start, required this.end});
  final int number;
  final DateTime start; // inclusive
  final DateTime end; // inclusive
}

/// The concrete date window of the semester that contains [now], or null when
/// the school has no semesters configured / none matches.
SemesterWindow? currentSemesterWindow(List<SchoolSemester> sems, DateTime now) {
  for (final s in sems) {
    final mIn = s.wraps
        ? (now.month >= s.startMonth || now.month <= s.endMonth)
        : (now.month >= s.startMonth && now.month <= s.endMonth);
    if (!mIn) continue;
    if (!s.wraps) {
      return SemesterWindow(
        number: s.number,
        start: DateTime(now.year, s.startMonth, 1),
        end: _endOfMonth(now.year, s.endMonth),
      );
    }
    // Wrapping semester (e.g. Sep→Jan): figure out which side of the new year.
    if (now.month >= s.startMonth) {
      return SemesterWindow(number: s.number, start: DateTime(now.year, s.startMonth, 1), end: _endOfMonth(now.year + 1, s.endMonth));
    }
    return SemesterWindow(number: s.number, start: DateTime(now.year - 1, s.startMonth, 1), end: _endOfMonth(now.year, s.endMonth));
  }
  return null;
}

/// A concrete past semester window + the parts needed to label it
/// ("Semester {number} · {yearLabel}", e.g. "Semester 1 · 26/27").
class LabeledSemester {
  const LabeledSemester({required this.window, required this.number, required this.yearLabel});
  final SemesterWindow window;
  final int number;
  final String yearLabel; // "26/27"
}

/// Every PAST semester (strictly before the current one), most-recent first.
/// School-year label is anchored on the first semester's start month, so e.g.
/// with "9-1,2-6" the year running Sep 2026 → Jun 2027 is "26/27". Pure date
/// math — 100% accurate regardless of any per-student data.
List<LabeledSemester> enumeratePastSemesters(
  List<SchoolSemester> sems,
  DateTime now, {
  int maxYearsBack = 8,
}) {
  if (sems.isEmpty) return const <LabeledSemester>[];
  final cur = currentSemesterWindow(sems, now);
  final anchor = sems.first.startMonth; // academic-year start month
  final curAcadStart = (now.month >= anchor) ? now.year : now.year - 1;
  final boundary = cur?.start ?? DateTime(now.year, now.month, 1);
  final out = <LabeledSemester>[];
  for (int y = curAcadStart; y >= curAcadStart - maxYearsBack; y--) {
    for (final s in sems) {
      final startCalYear = (s.startMonth >= anchor) ? y : y + 1;
      final start = DateTime(startCalYear, s.startMonth, 1);
      final endCalYear = (s.endMonth >= s.startMonth) ? startCalYear : startCalYear + 1;
      final end = _endOfMonth(endCalYear, s.endMonth);
      if (!end.isBefore(boundary)) continue; // strictly past only
      final yy = (y % 100).toString().padLeft(2, '0');
      final yy2 = ((y + 1) % 100).toString().padLeft(2, '0');
      out.add(LabeledSemester(
        window: SemesterWindow(number: s.number, start: start, end: end),
        number: s.number,
        yearLabel: '$yy/$yy2',
      ));
    }
  }
  out.sort((a, b) => b.window.start.compareTo(a.window.start));
  return out;
}

/// The single source of truth for "what does this screen show right now",
/// given the pill state + an optional specific past semester chosen from the
/// dropdown:
///   • no semesters configured → everything
///   • This semester           → items on/after current.start
///   • Previous + specific      → items inside that exact window
///   • Previous (all)           → items before current.start
List<T> visibleForSemester<T>(
  List<T> items,
  DateTime? Function(T) dateOf,
  SemesterWindow? current,
  bool showingPrevious,
  SemesterWindow? selectedPast,
) {
  if (current == null) return List<T>.from(items);
  if (!showingPrevious) {
    return items.where((it) {
      final d = dateOf(it);
      return d == null || !d.isBefore(current.start);
    }).toList();
  }
  if (selectedPast != null) {
    return items.where((it) {
      final d = dateOf(it);
      return d != null && !d.isBefore(selectedPast.start) && !d.isAfter(selectedPast.end);
    }).toList();
  }
  return items.where((it) {
    final d = dateOf(it);
    return d != null && d.isBefore(current.start);
  }).toList();
}

/// Splits [items] into (thisSemester, previous) by each item's date.
/// "This semester" = on/after the current window's start; "previous" = before.
/// When there's no current window (no semesters), everything is "this".
({List<T> current, List<T> previous}) partitionBySemester<T>(
  List<T> items,
  DateTime? Function(T) dateOf,
  SemesterWindow? window,
) {
  if (window == null) return (current: List<T>.from(items), previous: const []);
  final current = <T>[];
  final previous = <T>[];
  for (final it in items) {
    final d = dateOf(it);
    if (d != null && d.isBefore(window.start)) {
      previous.add(it);
    } else {
      current.add(it);
    }
  }
  return (current: current, previous: previous);
}
