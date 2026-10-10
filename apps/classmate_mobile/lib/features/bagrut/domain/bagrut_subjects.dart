import 'package:flutter/material.dart';

/// A fixed catalogue of bagrut subjects (Yoel-Geva style). Kept client-side —
/// the backend stores only the `key` string on each exam. Display names for
/// every app language are carried inline (the pseudo-locale falls back to
/// English).
class BagrutSubject {
  const BagrutSubject({
    required this.key,
    required this.en,
    required this.he,
    required this.ar,
    required this.fr,
    required this.ru,
    required this.icon,
  });

  final String key;
  final String en;
  final String he;
  final String ar;
  final String fr;
  final String ru;
  final IconData icon;

  /// Localized title for a language code ("he", "he_IL", …).
  String title(String localeCode) {
    final code = localeCode.toLowerCase();
    if (code.startsWith('he')) return he;
    if (code.startsWith('ar')) return ar;
    if (code.startsWith('fr')) return fr;
    if (code.startsWith('ru')) return ru;
    return en;
  }

  /// Every name, for search.
  List<String> get allTitles => [en, he, ar, fr, ru];
}

const List<BagrutSubject> kBagrutSubjects = <BagrutSubject>[
  BagrutSubject(key: 'math', en: 'Mathematics', he: 'מתמטיקה', ar: 'الرياضيات', fr: 'Mathématiques', ru: 'Математика', icon: Icons.functions_rounded),
  BagrutSubject(key: 'english', en: 'English', he: 'אנגלית', ar: 'الإنجليزية', fr: 'Anglais', ru: 'Английский', icon: Icons.translate_rounded),
  BagrutSubject(key: 'hebrew', en: 'Hebrew Expression', he: 'הבעה עברית', ar: 'التعبير العبري', fr: 'Expression hébraïque', ru: 'Иврит (речь и письмо)', icon: Icons.spellcheck_rounded),
  BagrutSubject(key: 'bible', en: 'Bible (Tanakh)', he: 'תנ״ך', ar: 'التناخ (الكتاب المقدس)', fr: 'Bible (Tanakh)', ru: 'Танах (Библия)', icon: Icons.menu_book_rounded),
  BagrutSubject(key: 'physics', en: 'Physics', he: 'פיזיקה', ar: 'الفيزياء', fr: 'Physique', ru: 'Физика', icon: Icons.science_rounded),
  BagrutSubject(key: 'chemistry', en: 'Chemistry', he: 'כימיה', ar: 'الكيمياء', fr: 'Chimie', ru: 'Химия', icon: Icons.biotech_rounded),
  BagrutSubject(key: 'biology', en: 'Biology', he: 'ביולוגיה', ar: 'الأحياء', fr: 'Biologie', ru: 'Биология', icon: Icons.eco_rounded),
  BagrutSubject(key: 'history', en: 'History', he: 'היסטוריה', ar: 'التاريخ', fr: 'Histoire', ru: 'История', icon: Icons.account_balance_rounded),
  BagrutSubject(key: 'civics', en: 'Civics', he: 'אזרחות', ar: 'المدنيات', fr: 'Éducation civique', ru: 'Граждановедение', icon: Icons.gavel_rounded),
  BagrutSubject(key: 'literature', en: 'Literature', he: 'ספרות', ar: 'الأدب', fr: 'Littérature', ru: 'Литература', icon: Icons.auto_stories_rounded),
  BagrutSubject(key: 'arabic', en: 'Arabic', he: 'ערבית', ar: 'العربية', fr: 'Arabe', ru: 'Арабский', icon: Icons.language_rounded),
  BagrutSubject(key: 'computer_science', en: 'Computer Science', he: 'מדעי המחשב', ar: 'علوم الحاسوب', fr: 'Informatique', ru: 'Информатика', icon: Icons.computer_rounded),
  BagrutSubject(key: 'geography', en: 'Geography', he: 'גאוגרפיה', ar: 'الجغرافيا', fr: 'Géographie', ru: 'География', icon: Icons.public_rounded),
  BagrutSubject(key: 'economics', en: 'Economics', he: 'כלכלה', ar: 'الاقتصاد', fr: 'Économie', ru: 'Экономика', icon: Icons.trending_up_rounded),
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
