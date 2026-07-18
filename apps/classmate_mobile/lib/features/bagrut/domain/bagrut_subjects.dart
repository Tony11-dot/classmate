import 'package:flutter/material.dart';

/// A fixed catalogue of bagrut subjects (Yoel-Geva style). Kept client-side —
/// the backend stores only the `key` string on each exam. English + Hebrew
/// display names are carried inline; other locales fall back to English.
class BagrutSubject {
  const BagrutSubject({
    required this.key,
    required this.en,
    required this.he,
    required this.icon,
  });

  final String key;
  final String en;
  final String he;
  final IconData icon;

  /// Localized title — Hebrew for the `he` locale, English otherwise.
  String title(String localeCode) => localeCode.toLowerCase().startsWith('he') ? he : en;
}

const List<BagrutSubject> kBagrutSubjects = <BagrutSubject>[
  BagrutSubject(key: 'math', en: 'Mathematics', he: 'מתמטיקה', icon: Icons.functions_rounded),
  BagrutSubject(key: 'english', en: 'English', he: 'אנגלית', icon: Icons.translate_rounded),
  BagrutSubject(key: 'hebrew', en: 'Hebrew Expression', he: 'הבעה עברית', icon: Icons.spellcheck_rounded),
  BagrutSubject(key: 'bible', en: 'Bible (Tanakh)', he: 'תנ״ך', icon: Icons.menu_book_rounded),
  BagrutSubject(key: 'physics', en: 'Physics', he: 'פיזיקה', icon: Icons.science_rounded),
  BagrutSubject(key: 'chemistry', en: 'Chemistry', he: 'כימיה', icon: Icons.biotech_rounded),
  BagrutSubject(key: 'biology', en: 'Biology', he: 'ביולוגיה', icon: Icons.eco_rounded),
  BagrutSubject(key: 'history', en: 'History', he: 'היסטוריה', icon: Icons.account_balance_rounded),
  BagrutSubject(key: 'civics', en: 'Civics', he: 'אזרחות', icon: Icons.gavel_rounded),
  BagrutSubject(key: 'literature', en: 'Literature', he: 'ספרות', icon: Icons.auto_stories_rounded),
  BagrutSubject(key: 'arabic', en: 'Arabic', he: 'ערבית', icon: Icons.language_rounded),
  BagrutSubject(key: 'computer_science', en: 'Computer Science', he: 'מדעי המחשב', icon: Icons.computer_rounded),
  BagrutSubject(key: 'geography', en: 'Geography', he: 'גאוגרפיה', icon: Icons.public_rounded),
  BagrutSubject(key: 'economics', en: 'Economics', he: 'כלכלה', icon: Icons.trending_up_rounded),
];

BagrutSubject? bagrutSubjectByKey(String key) {
  for (final s in kBagrutSubjects) {
    if (s.key == key) return s;
  }
  return null;
}

String bagrutSubjectTitle(String key, String localeCode) =>
    bagrutSubjectByKey(key)?.title(localeCode) ?? key;

/// The four file kinds an exam can carry.
class BagrutFileKind {
  static const String questions = 'questions';
  static const String answers = 'answers';
  static const String solution = 'solution';
  static const String advanced = 'advanced';

  static const List<String> all = <String>[questions, answers, solution, advanced];
}
