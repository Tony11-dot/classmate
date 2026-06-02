import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

/// The canonical, app-wide list of Solutions subjects. These are STABLE keys —
/// the key is what the backend stores on each solution + book (so the feed is
/// global and language-independent). The display name is always localized via
/// [solutionSubjectTitle]; never show the key or the English fallback directly
/// when an [AppLocalizations] is available.
const List<String> kSolutionSubjectKeys = <String>[
  'mathematics',
  'computerScience',
  'physics',
  'chemistry',
  'hebrew',
  'biology',
  'history',
  'arabic',
  'electronics',
  'mechanics',
  'french',
  'environmentalScience',
  'communicationCinema',
  'citizenship',
  'sociology',
  'religion',
  'geography',
];

/// English fallback names — used only when no [AppLocalizations] is in scope
/// (e.g. initial provider state before the first build).
const Map<String, String> kSolutionSubjectEnglish = <String, String>{
  'mathematics': 'Mathematics',
  'computerScience': 'Computer Science',
  'physics': 'Physics',
  'chemistry': 'Chemistry',
  'hebrew': 'Hebrew',
  'biology': 'Biology',
  'history': 'History',
  'arabic': 'Arabic',
  'electronics': 'Electronics',
  'mechanics': 'Mechanics',
  'french': 'French',
  'environmentalScience': 'Environmental Science',
  'communicationCinema': 'Communication and Cinema',
  'citizenship': 'Citizenship',
  'sociology': 'Sociology',
  'religion': 'Religion',
  'geography': 'Geography',
};

/// Localized display title for a subject key.
String solutionSubjectTitle(AppLocalizations l, String key) {
  switch (key) {
    case 'mathematics':
      return l.solSubjectMathematics;
    case 'computerScience':
      return l.solSubjectComputerScience;
    case 'physics':
      return l.solSubjectPhysics;
    case 'chemistry':
      return l.solSubjectChemistry;
    case 'hebrew':
      return l.solSubjectHebrew;
    case 'biology':
      return l.solSubjectBiology;
    case 'history':
      return l.solSubjectHistory;
    case 'arabic':
      return l.solSubjectArabic;
    case 'electronics':
      return l.solSubjectElectronics;
    case 'mechanics':
      return l.solSubjectMechanics;
    case 'french':
      return l.solSubjectFrench;
    case 'environmentalScience':
      return l.solSubjectEnvironmentalScience;
    case 'communicationCinema':
      return l.solSubjectCommunicationCinema;
    case 'citizenship':
      return l.solSubjectCitizenship;
    case 'sociology':
      return l.solSubjectSociology;
    case 'religion':
      return l.solSubjectReligion;
    case 'geography':
      return l.solSubjectGeography;
    default:
      return kSolutionSubjectEnglish[key] ?? key;
  }
}

/// A representative icon per subject for the subject grid.
IconData solutionSubjectIcon(String key) {
  switch (key) {
    case 'mathematics':
      return Icons.calculate_rounded;
    case 'computerScience':
      return Icons.memory_rounded;
    case 'physics':
      return Icons.science_rounded;
    case 'chemistry':
      return Icons.biotech_rounded;
    case 'hebrew':
      return Icons.menu_book_rounded;
    case 'biology':
      return Icons.eco_rounded;
    case 'history':
      return Icons.history_edu_rounded;
    case 'arabic':
      return Icons.translate_rounded;
    case 'electronics':
      return Icons.bolt_rounded;
    case 'mechanics':
      return Icons.settings_rounded;
    case 'french':
      return Icons.language_rounded;
    case 'environmentalScience':
      return Icons.public_rounded;
    case 'communicationCinema':
      return Icons.movie_rounded;
    case 'citizenship':
      return Icons.account_balance_rounded;
    case 'sociology':
      return Icons.groups_rounded;
    case 'religion':
      return Icons.auto_stories_rounded;
    case 'geography':
      return Icons.map_rounded;
    default:
      return Icons.menu_book_rounded;
  }
}
