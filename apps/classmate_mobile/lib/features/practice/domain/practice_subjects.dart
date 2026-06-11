import '../../solutions/domain/solution_subjects.dart';
import '../ui/practice_display_text.dart' show practiceGeneralKnowledgeSubject;

/// ── Practice subjects = Books subjects + Psychology ───────────────────────────
///
/// Practice now uses the EXACT same canonical subject keys as the Books
/// (Solutions) feature, plus `psychology`. The keys are stable and language
/// independent; the display name is always localized via [practiceSubjectTitle]
/// (which delegates to the shared Books localization in [solutionSubjectTitle]).
///
/// The order below is the practice ordering — by how common / important each
/// subject is for self-practice (core STEM first, then languages, humanities,
/// technical, electives). This is intentionally DIFFERENT from the Books grid
/// order.
const List<String> kPracticeSubjectKeys = <String>[
  'mathematics',
  'physics',
  'chemistry',
  'biology',
  'computerScience',
  'hebrew',
  'arabic',
  'history',
  'geography',
  'citizenship',
  'electronics',
  'mechanics',
  'psychology',
  'sociology',
  'environmentalScience',
  'french',
  'communicationCinema',
  'religion',
];

/// The English subject name we send to the question-generation AI. The backend
/// canonicalizes `mathematics → Math`, `physics → Physics`, `electronics →
/// Electronics`; every other subject passes through to the AI generator as-is.
String practiceSubjectAiName(String keyOrName) {
  final key = keyOrName.trim();
  if (key == practiceGeneralKnowledgeSubject) return key;
  // kSolutionSubjectEnglish already includes every practice subject (Psychology
  // included), since the two feature share one canonical subject set.
  return kSolutionSubjectEnglish[key] ?? key;
}

/// A grade band with the topics that are appropriate for students inside it.
/// [min]/[max] are inclusive school grades (1–12).
class PracticeGradeBand {
  const PracticeGradeBand(this.min, this.max, this.topics);

  final int min;
  final int max;
  final List<List<String>> topics;

  bool covers(int grade) => grade >= min && grade <= max;
}

/// Resolve the topic list for a subject at a given grade. When [grade] is null
/// (e.g. staff browsing practice) we fall back to the middle-school band, which
/// is the most broadly representative.
List<List<String>> practiceTopicsFor(String subjectKey, int? grade) {
  final bands = _gradeTopicCatalog[subjectKey];
  if (bands == null || bands.isEmpty) {
    return const <List<String>>[
      <String>['General'],
    ];
  }
  final g = (grade == null) ? 8 : grade.clamp(1, 12);
  for (final band in bands) {
    if (band.covers(g)) return band.topics;
  }
  // Grade sits outside every band: clamp to nearest band.
  if (g < bands.first.min) return bands.first.topics;
  return bands.last.topics;
}

/// The first / default topic for a subject at a grade.
List<String> practiceDefaultTopicFor(String subjectKey, int? grade) {
  final topics = practiceTopicsFor(subjectKey, grade);
  return topics.isEmpty ? const <String>['General'] : topics.first;
}

/// Free-text custom-topic example chips, by grade band, per subject.
List<String> practiceCustomTopicExamplesFor(String subjectKey, int? grade) {
  final topics = practiceTopicsFor(subjectKey, grade);
  return topics
      .map((path) => path.join(' · '))
      .take(3)
      .toList(growable: false);
}

// ── The grade-aware topic catalog ────────────────────────────────────────────
//
// Bands: 1–3 (lower elementary), 4–6 (upper elementary), 7–9 (middle), 10–12
// (high school). Subjects that are only formally taught from middle/high school
// still expose a gentle, age-appropriate band for younger students so practice
// never shows an empty topic list.

const Map<String, List<PracticeGradeBand>> _gradeTopicCatalog = {
  'mathematics': [
    PracticeGradeBand(1, 3, [
      ['Counting'],
      ['Addition'],
      ['Subtraction'],
      ['Number bonds'],
      ['Place value'],
      ['Shapes'],
      ['Comparing numbers'],
      ['Time and money'],
      ['Patterns'],
    ]),
    PracticeGradeBand(4, 6, [
      ['Multiplication'],
      ['Division'],
      ['Fractions'],
      ['Decimals'],
      ['Percentages'],
      ['Factors and multiples'],
      ['Area and perimeter'],
      ['Measurement'],
      ['Word problems'],
    ]),
    PracticeGradeBand(7, 9, [
      ['Integers'],
      ['Algebra', 'Expressions'],
      ['Algebra', 'Linear equations'],
      ['Ratios and proportion'],
      ['Percentages'],
      ['Exponents'],
      ['Geometry', 'Angles'],
      ['Geometry', 'Triangles'],
      ['Pythagoras'],
      ['Statistics'],
      ['Probability'],
    ]),
    PracticeGradeBand(10, 12, [
      ['Algebra'],
      ['Functions'],
      ['Algebra', 'Quadratic equations'],
      ['Sequences'],
      ['Trigonometry'],
      ['Geometry', 'Analytic geometry'],
      ['Probability'],
      ['Statistics'],
      ['Calculus', 'Limits'],
      ['Calculus', 'Derivatives'],
    ]),
  ],
  'physics': [
    PracticeGradeBand(1, 3, [
      ['Push and pull'],
      ['Light and shadow'],
      ['Magnets'],
      ['Floating and sinking'],
      ['Day and night'],
    ]),
    PracticeGradeBand(4, 6, [
      ['Forces and motion'],
      ['Energy'],
      ['Electricity basics'],
      ['Light and sound'],
      ['Simple machines'],
      ['Heat and temperature'],
    ]),
    PracticeGradeBand(7, 9, [
      ['Motion and speed'],
      ['Forces'],
      ['Energy'],
      ['Density'],
      ['Pressure'],
      ['Electricity'],
      ['Waves and sound'],
      ['Light and optics'],
    ]),
    PracticeGradeBand(10, 12, [
      ['Mechanics', 'Kinematics'],
      ['Mechanics', 'Newton laws'],
      ['Mechanics', 'Forces'],
      ['Mechanics', 'Energy'],
      ['Mechanics', 'Momentum'],
      ['Electricity', 'Electric field'],
      ['Electricity', 'Circuits'],
      ['Waves'],
      ['Optics'],
      ['Thermodynamics'],
    ]),
  ],
  'chemistry': [
    PracticeGradeBand(1, 3, [
      ['Materials around us'],
      ['Solid, liquid, gas'],
      ['Water'],
      ['Mixing things'],
    ]),
    PracticeGradeBand(4, 6, [
      ['States of matter'],
      ['Properties of materials'],
      ['Mixtures and solutions'],
      ['Changes of state'],
      ['Acids and bases around us'],
    ]),
    PracticeGradeBand(7, 9, [
      ['Atoms and molecules'],
      ['Elements and compounds'],
      ['The periodic table'],
      ['Mixtures and separation'],
      ['Acids and bases'],
      ['Chemical reactions'],
    ]),
    PracticeGradeBand(10, 12, [
      ['Atomic structure'],
      ['Periodic table'],
      ['Chemical bonds'],
      ['Reactions'],
      ['Stoichiometry'],
      ['Acids and bases'],
      ['Oxidation and reduction'],
      ['Organic chemistry'],
    ]),
  ],
  'biology': [
    PracticeGradeBand(1, 3, [
      ['Living things'],
      ['Plants'],
      ['Animals'],
      ['My body'],
      ['The senses'],
    ]),
    PracticeGradeBand(4, 6, [
      ['Human body systems'],
      ['Plants and photosynthesis'],
      ['Animal groups'],
      ['Habitats and food chains'],
      ['Health and nutrition'],
    ]),
    PracticeGradeBand(7, 9, [
      ['Cells'],
      ['Human body systems'],
      ['Photosynthesis'],
      ['Reproduction'],
      ['Ecology'],
      ['Microorganisms'],
    ]),
    PracticeGradeBand(10, 12, [
      ['Cells'],
      ['Genetics'],
      ['Human physiology'],
      ['Ecology'],
      ['Evolution'],
      ['Biochemistry'],
      ['Body systems'],
    ]),
  ],
  'computerScience': [
    PracticeGradeBand(1, 3, [
      ['What is a computer'],
      ['Mouse and keyboard'],
      ['Patterns and sequences'],
      ['Staying safe online'],
    ]),
    PracticeGradeBand(4, 6, [
      ['Algorithms'],
      ['Block coding'],
      ['Loops'],
      ['Conditions'],
      ['Internet safety'],
    ]),
    PracticeGradeBand(7, 9, [
      ['Variables'],
      ['Conditions', 'if / else'],
      ['Conditions', 'Boolean logic'],
      ['Loops'],
      ['Functions'],
      ['Arrays'],
      ['Flowcharts'],
    ]),
    PracticeGradeBand(10, 12, [
      ['Conditions'],
      ['Loops'],
      ['Functions'],
      ['Arrays'],
      ['Strings'],
      ['Algorithms'],
      ['Complexity'],
      ['Recursion'],
      ['Object-oriented basics'],
    ]),
  ],
  'hebrew': [
    PracticeGradeBand(1, 3, [
      ['Reading'],
      ['Vocabulary'],
      ['Simple sentences'],
      ['Reading comprehension'],
    ]),
    PracticeGradeBand(4, 6, [
      ['Grammar'],
      ['Reading comprehension'],
      ['Vocabulary'],
      ['Spelling'],
      ['Writing'],
    ]),
    PracticeGradeBand(7, 9, [
      ['Grammar'],
      ['Reading comprehension'],
      ['Vocabulary'],
      ['Writing'],
      ['Literature'],
    ]),
    PracticeGradeBand(10, 12, [
      ['Grammar'],
      ['Reading comprehension'],
      ['Literature'],
      ['Writing and composition'],
      ['Linguistics'],
    ]),
  ],
  'arabic': [
    PracticeGradeBand(1, 3, [
      ['Reading'],
      ['Vocabulary'],
      ['Simple sentences'],
      ['Reading comprehension'],
    ]),
    PracticeGradeBand(4, 6, [
      ['Grammar'],
      ['Reading comprehension'],
      ['Vocabulary'],
      ['Writing'],
    ]),
    PracticeGradeBand(7, 9, [
      ['Grammar'],
      ['Reading comprehension'],
      ['Vocabulary'],
      ['بلاغة'],
      ['Writing'],
    ]),
    PracticeGradeBand(10, 12, [
      ['Grammar'],
      ['Reading comprehension'],
      ['بلاغة'],
      ['Literature'],
      ['Writing'],
    ]),
  ],
  'history': [
    PracticeGradeBand(1, 3, [
      ['My family and community'],
      ['Holidays and traditions'],
      ['Long ago and today'],
    ]),
    PracticeGradeBand(4, 6, [
      ['Ancient civilizations'],
      ['Local history'],
      ['Timelines'],
      ['Explorers'],
    ]),
    PracticeGradeBand(7, 9, [
      ['The ancient world'],
      ['The Middle Ages'],
      ['Nationalism'],
      ['Industrial revolution'],
      ['Modern history'],
    ]),
    PracticeGradeBand(10, 12, [
      ['World War I'],
      ['World War II'],
      ['The Holocaust'],
      ['History of Israel'],
      ['The modern Middle East'],
      ['Nationalism and democracy'],
      ['The Cold War'],
    ]),
  ],
  'geography': [
    PracticeGradeBand(1, 3, [
      ['My neighborhood'],
      ['Maps basics'],
      ['Weather'],
      ['Land and water'],
    ]),
    PracticeGradeBand(4, 6, [
      ['Continents and oceans'],
      ['Maps and globes'],
      ['Climate'],
      ['Natural resources'],
    ]),
    PracticeGradeBand(7, 9, [
      ['Physical geography'],
      ['Climate and weather'],
      ['Population'],
      ['Settlement'],
      ['Economic geography'],
    ]),
    PracticeGradeBand(10, 12, [
      ['Physical geography'],
      ['Human geography'],
      ['Climate change'],
      ['Globalization'],
      ['Urban geography'],
      ['Geopolitics'],
    ]),
  ],
  'citizenship': [
    PracticeGradeBand(1, 3, [
      ['Rules and fairness'],
      ['My community'],
      ['Helping others'],
    ]),
    PracticeGradeBand(4, 6, [
      ['Rights and responsibilities'],
      ['Government basics'],
      ['Community and democracy'],
    ]),
    PracticeGradeBand(7, 9, [
      ['Democracy'],
      ['Government and law'],
      ['Rights and duties'],
      ['Society and state'],
    ]),
    PracticeGradeBand(10, 12, [
      ['Democracy and regime'],
      ['Human and civil rights'],
      ['The State of Israel'],
      ['Law and government'],
      ['Citizenship and society'],
    ]),
  ],
  'electronics': [
    PracticeGradeBand(1, 6, [
      ['Batteries and bulbs'],
      ['Conductors and insulators'],
      ['Simple circuits'],
    ]),
    PracticeGradeBand(7, 9, [
      ['Electric circuits'],
      ['Current and voltage'],
      ['Resistors'],
      ['Series and parallel'],
      ['Components'],
    ]),
    PracticeGradeBand(10, 12, [
      ["Ohm's law"],
      ['Series and parallel circuits'],
      ['Capacitors'],
      ['Diodes'],
      ['Transistors'],
      ['Logic gates'],
      ['Digital electronics'],
    ]),
  ],
  'mechanics': [
    PracticeGradeBand(1, 6, [
      ['Simple machines'],
      ['Levers and wheels'],
      ['Gears'],
    ]),
    PracticeGradeBand(7, 9, [
      ['Forces and motion'],
      ['Simple machines'],
      ['Gears and levers'],
      ['Materials'],
    ]),
    PracticeGradeBand(10, 12, [
      ['Statics'],
      ['Forces and moments'],
      ['Kinematics'],
      ['Dynamics'],
      ['Strength of materials'],
      ['Machine elements'],
    ]),
  ],
  'psychology': [
    PracticeGradeBand(1, 6, [
      ['Feelings and emotions'],
      ['Friendship'],
      ['Getting along'],
    ]),
    PracticeGradeBand(7, 9, [
      ['Emotions and behavior'],
      ['Memory and learning'],
      ['Personality'],
      ['Communication'],
    ]),
    PracticeGradeBand(10, 12, [
      ['Introduction to psychology'],
      ['Learning and memory'],
      ['Personality'],
      ['Developmental psychology'],
      ['Social psychology'],
      ['Cognition'],
      ['Psychological disorders'],
      ['Research methods'],
    ]),
  ],
  'sociology': [
    PracticeGradeBand(1, 6, [
      ['Family and community'],
      ['Groups we belong to'],
    ]),
    PracticeGradeBand(7, 9, [
      ['Society and groups'],
      ['Culture'],
      ['Family and institutions'],
      ['Norms and roles'],
    ]),
    PracticeGradeBand(10, 12, [
      ['Introduction to sociology'],
      ['Socialization'],
      ['Social institutions'],
      ['Culture and identity'],
      ['Social stratification'],
      ['Deviance'],
      ['Research methods'],
    ]),
  ],
  'environmentalScience': [
    PracticeGradeBand(1, 3, [
      ['Nature around us'],
      ['Caring for plants and animals'],
      ['Recycling'],
    ]),
    PracticeGradeBand(4, 6, [
      ['Ecosystems'],
      ['Recycling and waste'],
      ['Water and energy'],
      ['Pollution'],
    ]),
    PracticeGradeBand(7, 9, [
      ['Ecosystems'],
      ['Biodiversity'],
      ['Pollution'],
      ['Climate'],
      ['Sustainability'],
      ['Natural resources'],
    ]),
    PracticeGradeBand(10, 12, [
      ['Ecology'],
      ['Climate change'],
      ['Sustainability'],
      ['Pollution and remediation'],
      ['Conservation'],
      ['Energy resources'],
    ]),
  ],
  'french': [
    PracticeGradeBand(1, 3, [
      ['Greetings'],
      ['Numbers and colors'],
      ['Basic vocabulary'],
    ]),
    PracticeGradeBand(4, 6, [
      ['Vocabulary'],
      ['Present tense'],
      ['Simple conversation'],
      ['Reading'],
    ]),
    PracticeGradeBand(7, 9, [
      ['Grammar'],
      ['Verb tenses'],
      ['Vocabulary'],
      ['Reading comprehension'],
      ['Writing'],
    ]),
    PracticeGradeBand(10, 12, [
      ['Grammar'],
      ['Tenses'],
      ['Reading comprehension'],
      ['Writing'],
      ['Literature'],
      ['Conversation'],
    ]),
  ],
  'communicationCinema': [
    PracticeGradeBand(1, 6, [
      ['Stories and pictures'],
      ['Making a short video'],
    ]),
    PracticeGradeBand(7, 9, [
      ['Media and messages'],
      ['Film basics'],
      ['Storytelling'],
      ['Advertising'],
    ]),
    PracticeGradeBand(10, 12, [
      ['Film language'],
      ['Media analysis'],
      ['Genres'],
      ['Production'],
      ['Journalism'],
      ['Advertising and persuasion'],
    ]),
  ],
  'religion': [
    PracticeGradeBand(1, 3, [
      ['Holidays and stories'],
      ['Values'],
      ['Traditions'],
    ]),
    PracticeGradeBand(4, 6, [
      ['Sacred texts'],
      ['Holidays'],
      ['Values and ethics'],
    ]),
    PracticeGradeBand(7, 9, [
      ['Scriptures'],
      ['Traditions and practices'],
      ['Ethics'],
      ['History of religion'],
    ]),
    PracticeGradeBand(10, 12, [
      ['Sacred texts'],
      ['Ethics and philosophy'],
      ['World religions'],
      ['Religion and society'],
    ]),
  ],
};
