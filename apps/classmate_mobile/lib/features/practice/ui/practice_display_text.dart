import 'package:flutter/widgets.dart';

import '../../../l10n/app_localizations.dart';
import '../../solutions/domain/solution_subjects.dart';

const practiceGeneralKnowledgeSubject = 'General Knowledge';
const practiceGeneralTopicPath = <String>['General'];

/// Resolve any subject string (canonical key, English name, or legacy practice
/// display name) to the canonical Books/practice subject key — or null when it
/// is a free-text custom subject.
String? practiceSubjectKeyOf(String subject) {
  final raw = subject.trim();
  if (raw.isEmpty) return null;
  if (kSolutionSubjectEnglish.containsKey(raw) || raw == 'psychology') {
    return raw;
  }
  switch (raw.toLowerCase()) {
    case 'math':
    case 'maths':
    case 'mathematics':
      return 'mathematics';
    case 'physics':
      return 'physics';
    case 'computer science':
    case 'computerscience':
      return 'computerScience';
    case 'chemistry':
      return 'chemistry';
    case 'biology':
      return 'biology';
    case 'hebrew':
      return 'hebrew';
    case 'arabic':
      return 'arabic';
    case 'history':
      return 'history';
    case 'geography':
      return 'geography';
    case 'electronics':
      return 'electronics';
    case 'mechanics':
      return 'mechanics';
    case 'french':
      return 'french';
    case 'citizenship':
      return 'citizenship';
    case 'sociology':
      return 'sociology';
    case 'religion':
      return 'religion';
    case 'psychology':
      return 'psychology';
    case 'environmental science':
    case 'environmentalscience':
      return 'environmentalScience';
    case 'communication and cinema':
    case 'communicationcinema':
      return 'communicationCinema';
    default:
      return null;
  }
}

/// Practice subjects now mirror the Books subjects exactly, so display uses the
/// shared [solutionSubjectTitle]. Free-text custom subjects pass through.
String localizedPracticeSubject(BuildContext context, String subject) {
  final l = AppLocalizations.of(context)!;
  final raw = subject.trim();
  if (raw.toLowerCase() == 'general knowledge') {
    return l.practiceSubjectGeneralKnowledge;
  }
  final key = practiceSubjectKeyOf(raw);
  if (key != null) return solutionSubjectTitle(l, key);
  return subject;
}

String localizedPracticeTopicSegment(BuildContext context, String segment) {
  final l = AppLocalizations.of(context)!;
  switch (segment.trim().toLowerCase()) {
    case 'general':
      return l.practiceSessionGeneralTopic;
    case 'all topics':
      return l.practiceTopicAllTopics;
    case 'algebra':
      return l.practiceTopicAlgebra;
    case 'linear equations':
      return l.practiceTopicLinearEquations;
    case 'quadratic equations':
      return l.practiceTopicQuadraticEquations;
    case 'functions':
      return l.practiceTopicFunctions;
    case 'geometry':
      return l.practiceTopicGeometry;
    case 'triangles':
      return l.practiceTopicTriangles;
    case 'circles':
      return l.practiceTopicCircles;
    case 'analytic geometry':
      return l.practiceTopicAnalyticGeometry;
    case 'trigonometry':
      return l.practiceTopicTrigonometry;
    case 'probability':
      return l.practiceTopicProbability;
    case 'statistics':
      return l.practiceTopicStatistics;
    case 'sequences':
      return l.practiceTopicSequences;
    case 'calculus':
      return l.practiceTopicCalculus;
    case 'limits':
      return l.practiceTopicLimits;
    case 'derivatives':
      return l.practiceTopicDerivatives;
    case 'mechanics':
      return l.practiceTopicMechanics;
    case 'kinematics':
      return l.practiceTopicKinematics;
    case 'newton laws':
      return l.practiceTopicNewtonLaws;
    case 'forces':
      return l.practiceTopicForces;
    case 'energy':
      return l.practiceTopicEnergy;
    case 'momentum':
      return l.practiceTopicMomentum;
    case 'electricity':
      return l.practiceTopicElectricity;
    case 'electric field':
      return l.practiceTopicElectricField;
    case 'circuits':
      return l.practiceTopicCircuits;
    case 'waves':
      return l.practiceTopicWaves;
    case 'optics':
      return l.practiceTopicOptics;
    case 'thermodynamics':
      return l.practiceTopicThermodynamics;
    case 'conditions':
      return l.practiceTopicConditions;
    case 'boolean logic':
      return l.practiceTopicBooleanLogic;
    case 'if / else':
      return l.practiceTopicIfElse;
    case 'nested conditions':
      return l.practiceTopicNestedConditions;
    case 'loops':
      return l.practiceTopicLoops;
    case 'variables':
      return l.practiceTopicVariables;
    case 'arrays':
      return l.practiceTopicArrays;
    case 'strings':
      return l.practiceTopicStrings;
    case 'algorithms':
      return l.practiceTopicAlgorithms;
    case 'complexity':
      return l.practiceTopicComplexity;
    case 'recursion':
      return l.practiceTopicRecursion;
    case 'atoms':
      return l.practiceTopicAtoms;
    case 'periodic table':
      return l.practiceTopicPeriodicTable;
    case 'chemical bonds':
      return l.practiceTopicChemicalBonds;
    case 'reactions':
      return l.practiceTopicReactions;
    case 'stoichiometry':
      return l.practiceTopicStoichiometry;
    case 'acids and bases':
      return l.practiceTopicAcidsAndBases;
    case 'organic chemistry':
      return l.practiceTopicOrganicChemistry;
    case 'cells':
      return l.practiceTopicCells;
    case 'genetics':
      return l.practiceTopicGenetics;
    case 'human body':
      return l.practiceTopicHumanBody;
    case 'ecology':
      return l.practiceTopicEcology;
    case 'evolution':
      return l.practiceTopicEvolution;
    case 'systems':
      return l.practiceTopicSystems;
    case 'grammar':
      return l.practiceTopicGrammar;
    case 'reading comprehension':
      return l.practiceTopicReadingComprehension;
    case 'vocabulary':
      return l.practiceTopicVocabulary;
    case 'tenses':
      return l.practiceTopicTenses;
    case 'writing':
      return l.practiceTopicWriting;
    case 'بلاغة':
      return l.practiceTopicRhetoric;
    default:
      return segment;
  }
}

String localizedPracticeTopicPath(
  BuildContext context,
  List<String> topicPath,
) {
  final l = AppLocalizations.of(context)!;
  if (topicPath.isEmpty) {
    return l.practiceSessionGeneralTopic;
  }

  return topicPath
      .map((segment) => localizedPracticeTopicSegment(context, segment))
      .join(' · ');
}

String localizedPracticeTopicLabel(BuildContext context, String topicLabel) {
  final trimmed = topicLabel.trim();
  if (trimmed.isEmpty) {
    return AppLocalizations.of(context)!.practiceSessionGeneralTopic;
  }

  if (trimmed.contains(' · ')) {
    return localizedPracticeTopicPath(context, trimmed.split(' · '));
  }

  return localizedPracticeTopicSegment(context, trimmed);
}

String localizedPracticeSubjectAndTopic(
  BuildContext context, {
  required String subject,
  required String topicLabel,
}) {
  return '${localizedPracticeSubject(context, subject)} • ${localizedPracticeTopicLabel(context, topicLabel)}';
}