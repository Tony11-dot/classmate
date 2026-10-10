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
    case 'counting':
      return l.practiceTopicCounting;
    case 'addition':
      return l.practiceTopicAddition;
    case 'subtraction':
      return l.practiceTopicSubtraction;
    case 'number bonds':
      return l.practiceTopicNumberBonds;
    case 'place value':
      return l.practiceTopicPlaceValue;
    case 'shapes':
      return l.practiceTopicShapes;
    case 'comparing numbers':
      return l.practiceTopicComparingNumbers;
    case 'time and money':
      return l.practiceTopicTimeAndMoney;
    case 'patterns':
      return l.practiceTopicPatterns;
    case 'multiplication':
      return l.practiceTopicMultiplication;
    case 'division':
      return l.practiceTopicDivision;
    case 'fractions':
      return l.practiceTopicFractions;
    case 'decimals':
      return l.practiceTopicDecimals;
    case 'percentages':
      return l.practiceTopicPercentages;
    case 'factors and multiples':
      return l.practiceTopicFactorsAndMultiples;
    case 'area and perimeter':
      return l.practiceTopicAreaAndPerimeter;
    case 'measurement':
      return l.practiceTopicMeasurement;
    case 'word problems':
      return l.practiceTopicWordProblems;
    case 'integers':
      return l.practiceTopicIntegers;
    case 'expressions':
      return l.practiceTopicExpressions;
    case 'ratios and proportion':
      return l.practiceTopicRatiosAndProportion;
    case 'exponents':
      return l.practiceTopicExponents;
    case 'angles':
      return l.practiceTopicAngles;
    case 'pythagoras':
      return l.practiceTopicPythagoras;
    case 'push and pull':
      return l.practiceTopicPushAndPull;
    case 'light and shadow':
      return l.practiceTopicLightAndShadow;
    case 'magnets':
      return l.practiceTopicMagnets;
    case 'floating and sinking':
      return l.practiceTopicFloatingAndSinking;
    case 'day and night':
      return l.practiceTopicDayAndNight;
    case 'forces and motion':
      return l.practiceTopicForcesAndMotion;
    case 'electricity basics':
      return l.practiceTopicElectricityBasics;
    case 'light and sound':
      return l.practiceTopicLightAndSound;
    case 'simple machines':
      return l.practiceTopicSimpleMachines;
    case 'heat and temperature':
      return l.practiceTopicHeatAndTemperature;
    case 'motion and speed':
      return l.practiceTopicMotionAndSpeed;
    case 'density':
      return l.practiceTopicDensity;
    case 'pressure':
      return l.practiceTopicPressure;
    case 'waves and sound':
      return l.practiceTopicWavesAndSound;
    case 'light and optics':
      return l.practiceTopicLightAndOptics;
    case 'materials around us':
      return l.practiceTopicMaterialsAroundUs;
    case 'solid, liquid, gas':
      return l.practiceTopicSolidLiquidGas;
    case 'water':
      return l.practiceTopicWater;
    case 'mixing things':
      return l.practiceTopicMixingThings;
    case 'states of matter':
      return l.practiceTopicStatesOfMatter;
    case 'properties of materials':
      return l.practiceTopicPropertiesOfMaterials;
    case 'mixtures and solutions':
      return l.practiceTopicMixturesAndSolutions;
    case 'changes of state':
      return l.practiceTopicChangesOfState;
    case 'acids and bases around us':
      return l.practiceTopicAcidsAndBasesAroundUs;
    case 'atoms and molecules':
      return l.practiceTopicAtomsAndMolecules;
    case 'elements and compounds':
      return l.practiceTopicElementsAndCompounds;
    case 'the periodic table':
      return l.practiceTopicThePeriodicTable;
    case 'mixtures and separation':
      return l.practiceTopicMixturesAndSeparation;
    case 'chemical reactions':
      return l.practiceTopicChemicalReactions;
    case 'atomic structure':
      return l.practiceTopicAtomicStructure;
    case 'oxidation and reduction':
      return l.practiceTopicOxidationAndReduction;
    case 'living things':
      return l.practiceTopicLivingThings;
    case 'plants':
      return l.practiceTopicPlants;
    case 'animals':
      return l.practiceTopicAnimals;
    case 'my body':
      return l.practiceTopicMyBody;
    case 'the senses':
      return l.practiceTopicTheSenses;
    case 'human body systems':
      return l.practiceTopicHumanBodySystems;
    case 'plants and photosynthesis':
      return l.practiceTopicPlantsAndPhotosynthesis;
    case 'animal groups':
      return l.practiceTopicAnimalGroups;
    case 'habitats and food chains':
      return l.practiceTopicHabitatsAndFoodChains;
    case 'health and nutrition':
      return l.practiceTopicHealthAndNutrition;
    case 'photosynthesis':
      return l.practiceTopicPhotosynthesis;
    case 'reproduction':
      return l.practiceTopicReproduction;
    case 'microorganisms':
      return l.practiceTopicMicroorganisms;
    case 'human physiology':
      return l.practiceTopicHumanPhysiology;
    case 'biochemistry':
      return l.practiceTopicBiochemistry;
    case 'body systems':
      return l.practiceTopicBodySystems;
    case 'what is a computer':
      return l.practiceTopicWhatIsAComputer;
    case 'mouse and keyboard':
      return l.practiceTopicMouseAndKeyboard;
    case 'patterns and sequences':
      return l.practiceTopicPatternsAndSequences;
    case 'staying safe online':
      return l.practiceTopicStayingSafeOnline;
    case 'block coding':
      return l.practiceTopicBlockCoding;
    case 'internet safety':
      return l.practiceTopicInternetSafety;
    case 'flowcharts':
      return l.practiceTopicFlowcharts;
    case 'object-oriented basics':
      return l.practiceTopicObjectOrientedBasics;
    case 'reading':
      return l.practiceTopicReading;
    case 'simple sentences':
      return l.practiceTopicSimpleSentences;
    case 'spelling':
      return l.practiceTopicSpelling;
    case 'literature':
      return l.practiceTopicLiterature;
    case 'writing and composition':
      return l.practiceTopicWritingAndComposition;
    case 'linguistics':
      return l.practiceTopicLinguistics;
    case 'my family and community':
      return l.practiceTopicMyFamilyAndCommunity;
    case 'holidays and traditions':
      return l.practiceTopicHolidaysAndTraditions;
    case 'long ago and today':
      return l.practiceTopicLongAgoAndToday;
    case 'ancient civilizations':
      return l.practiceTopicAncientCivilizations;
    case 'local history':
      return l.practiceTopicLocalHistory;
    case 'timelines':
      return l.practiceTopicTimelines;
    case 'explorers':
      return l.practiceTopicExplorers;
    case 'the ancient world':
      return l.practiceTopicTheAncientWorld;
    case 'the middle ages':
      return l.practiceTopicTheMiddleAges;
    case 'nationalism':
      return l.practiceTopicNationalism;
    case 'industrial revolution':
      return l.practiceTopicIndustrialRevolution;
    case 'modern history':
      return l.practiceTopicModernHistory;
    case 'world war i':
      return l.practiceTopicWorldWarI;
    case 'world war ii':
      return l.practiceTopicWorldWarII;
    case 'the holocaust':
      return l.practiceTopicTheHolocaust;
    case 'history of israel':
      return l.practiceTopicHistoryOfIsrael;
    case 'the modern middle east':
      return l.practiceTopicTheModernMiddleEast;
    case 'nationalism and democracy':
      return l.practiceTopicNationalismAndDemocracy;
    case 'the cold war':
      return l.practiceTopicTheColdWar;
    case 'my neighborhood':
      return l.practiceTopicMyNeighborhood;
    case 'maps basics':
      return l.practiceTopicMapsBasics;
    case 'weather':
      return l.practiceTopicWeather;
    case 'land and water':
      return l.practiceTopicLandAndWater;
    case 'continents and oceans':
      return l.practiceTopicContinentsAndOceans;
    case 'maps and globes':
      return l.practiceTopicMapsAndGlobes;
    case 'climate':
      return l.practiceTopicClimate;
    case 'natural resources':
      return l.practiceTopicNaturalResources;
    case 'physical geography':
      return l.practiceTopicPhysicalGeography;
    case 'climate and weather':
      return l.practiceTopicClimateAndWeather;
    case 'population':
      return l.practiceTopicPopulation;
    case 'settlement':
      return l.practiceTopicSettlement;
    case 'economic geography':
      return l.practiceTopicEconomicGeography;
    case 'human geography':
      return l.practiceTopicHumanGeography;
    case 'climate change':
      return l.practiceTopicClimateChange;
    case 'globalization':
      return l.practiceTopicGlobalization;
    case 'urban geography':
      return l.practiceTopicUrbanGeography;
    case 'geopolitics':
      return l.practiceTopicGeopolitics;
    case 'rules and fairness':
      return l.practiceTopicRulesAndFairness;
    case 'my community':
      return l.practiceTopicMyCommunity;
    case 'helping others':
      return l.practiceTopicHelpingOthers;
    case 'rights and responsibilities':
      return l.practiceTopicRightsAndResponsibilities;
    case 'government basics':
      return l.practiceTopicGovernmentBasics;
    case 'community and democracy':
      return l.practiceTopicCommunityAndDemocracy;
    case 'democracy':
      return l.practiceTopicDemocracy;
    case 'government and law':
      return l.practiceTopicGovernmentAndLaw;
    case 'rights and duties':
      return l.practiceTopicRightsAndDuties;
    case 'society and state':
      return l.practiceTopicSocietyAndState;
    case 'democracy and regime':
      return l.practiceTopicDemocracyAndRegime;
    case 'human and civil rights':
      return l.practiceTopicHumanAndCivilRights;
    case 'the state of israel':
      return l.practiceTopicTheStateOfIsrael;
    case 'law and government':
      return l.practiceTopicLawAndGovernment;
    case 'citizenship and society':
      return l.practiceTopicCitizenshipAndSociety;
    case 'batteries and bulbs':
      return l.practiceTopicBatteriesAndBulbs;
    case 'conductors and insulators':
      return l.practiceTopicConductorsAndInsulators;
    case 'simple circuits':
      return l.practiceTopicSimpleCircuits;
    case 'electric circuits':
      return l.practiceTopicElectricCircuits;
    case 'current and voltage':
      return l.practiceTopicCurrentAndVoltage;
    case 'resistors':
      return l.practiceTopicResistors;
    case 'series and parallel':
      return l.practiceTopicSeriesAndParallel;
    case 'components':
      return l.practiceTopicComponents;
    case 'series and parallel circuits':
      return l.practiceTopicSeriesAndParallelCircuits;
    case 'capacitors':
      return l.practiceTopicCapacitors;
    case 'diodes':
      return l.practiceTopicDiodes;
    case 'transistors':
      return l.practiceTopicTransistors;
    case 'logic gates':
      return l.practiceTopicLogicGates;
    case 'digital electronics':
      return l.practiceTopicDigitalElectronics;
    case 'levers and wheels':
      return l.practiceTopicLeversAndWheels;
    case 'gears':
      return l.practiceTopicGears;
    case 'gears and levers':
      return l.practiceTopicGearsAndLevers;
    case 'materials':
      return l.practiceTopicMaterials;
    case 'statics':
      return l.practiceTopicStatics;
    case 'forces and moments':
      return l.practiceTopicForcesAndMoments;
    case 'dynamics':
      return l.practiceTopicDynamics;
    case 'strength of materials':
      return l.practiceTopicStrengthOfMaterials;
    case 'machine elements':
      return l.practiceTopicMachineElements;
    case 'feelings and emotions':
      return l.practiceTopicFeelingsAndEmotions;
    case 'friendship':
      return l.practiceTopicFriendship;
    case 'getting along':
      return l.practiceTopicGettingAlong;
    case 'emotions and behavior':
      return l.practiceTopicEmotionsAndBehavior;
    case 'memory and learning':
      return l.practiceTopicMemoryAndLearning;
    case 'personality':
      return l.practiceTopicPersonality;
    case 'communication':
      return l.practiceTopicCommunication;
    case 'introduction to psychology':
      return l.practiceTopicIntroductionToPsychology;
    case 'learning and memory':
      return l.practiceTopicLearningAndMemory;
    case 'developmental psychology':
      return l.practiceTopicDevelopmentalPsychology;
    case 'social psychology':
      return l.practiceTopicSocialPsychology;
    case 'cognition':
      return l.practiceTopicCognition;
    case 'psychological disorders':
      return l.practiceTopicPsychologicalDisorders;
    case 'research methods':
      return l.practiceTopicResearchMethods;
    case 'family and community':
      return l.practiceTopicFamilyAndCommunity;
    case 'groups we belong to':
      return l.practiceTopicGroupsWeBelongTo;
    case 'society and groups':
      return l.practiceTopicSocietyAndGroups;
    case 'culture':
      return l.practiceTopicCulture;
    case 'family and institutions':
      return l.practiceTopicFamilyAndInstitutions;
    case 'norms and roles':
      return l.practiceTopicNormsAndRoles;
    case 'introduction to sociology':
      return l.practiceTopicIntroductionToSociology;
    case 'socialization':
      return l.practiceTopicSocialization;
    case 'social institutions':
      return l.practiceTopicSocialInstitutions;
    case 'culture and identity':
      return l.practiceTopicCultureAndIdentity;
    case 'social stratification':
      return l.practiceTopicSocialStratification;
    case 'deviance':
      return l.practiceTopicDeviance;
    case 'nature around us':
      return l.practiceTopicNatureAroundUs;
    case 'caring for plants and animals':
      return l.practiceTopicCaringForPlantsAndAnimals;
    case 'recycling':
      return l.practiceTopicRecycling;
    case 'ecosystems':
      return l.practiceTopicEcosystems;
    case 'recycling and waste':
      return l.practiceTopicRecyclingAndWaste;
    case 'water and energy':
      return l.practiceTopicWaterAndEnergy;
    case 'pollution':
      return l.practiceTopicPollution;
    case 'biodiversity':
      return l.practiceTopicBiodiversity;
    case 'sustainability':
      return l.practiceTopicSustainability;
    case 'pollution and remediation':
      return l.practiceTopicPollutionAndRemediation;
    case 'conservation':
      return l.practiceTopicConservation;
    case 'energy resources':
      return l.practiceTopicEnergyResources;
    case 'greetings':
      return l.practiceTopicGreetings;
    case 'numbers and colors':
      return l.practiceTopicNumbersAndColors;
    case 'basic vocabulary':
      return l.practiceTopicBasicVocabulary;
    case 'present tense':
      return l.practiceTopicPresentTense;
    case 'simple conversation':
      return l.practiceTopicSimpleConversation;
    case 'verb tenses':
      return l.practiceTopicVerbTenses;
    case 'conversation':
      return l.practiceTopicConversation;
    case 'stories and pictures':
      return l.practiceTopicStoriesAndPictures;
    case 'making a short video':
      return l.practiceTopicMakingAShortVideo;
    case 'media and messages':
      return l.practiceTopicMediaAndMessages;
    case 'film basics':
      return l.practiceTopicFilmBasics;
    case 'storytelling':
      return l.practiceTopicStorytelling;
    case 'advertising':
      return l.practiceTopicAdvertising;
    case 'film language':
      return l.practiceTopicFilmLanguage;
    case 'media analysis':
      return l.practiceTopicMediaAnalysis;
    case 'genres':
      return l.practiceTopicGenres;
    case 'production':
      return l.practiceTopicProduction;
    case 'journalism':
      return l.practiceTopicJournalism;
    case 'advertising and persuasion':
      return l.practiceTopicAdvertisingAndPersuasion;
    case 'holidays and stories':
      return l.practiceTopicHolidaysAndStories;
    case 'values':
      return l.practiceTopicValues;
    case 'traditions':
      return l.practiceTopicTraditions;
    case 'sacred texts':
      return l.practiceTopicSacredTexts;
    case 'holidays':
      return l.practiceTopicHolidays;
    case 'values and ethics':
      return l.practiceTopicValuesAndEthics;
    case 'scriptures':
      return l.practiceTopicScriptures;
    case 'traditions and practices':
      return l.practiceTopicTraditionsAndPractices;
    case 'ethics':
      return l.practiceTopicEthics;
    case 'history of religion':
      return l.practiceTopicHistoryOfReligion;
    case 'ethics and philosophy':
      return l.practiceTopicEthicsAndPhilosophy;
    case 'world religions':
      return l.practiceTopicWorldReligions;
    case 'religion and society':
      return l.practiceTopicReligionAndSociety;
    case 'ohm\'s law':
      return l.practiceTopicOhmsLaw;
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