export type PracticeTopicCatalogRow = {
  subject: string;
  canonicalTopic: string;
  aliases: string[];
  deterministic: boolean;
};

export const PRACTICE_TOPIC_CATALOG: PracticeTopicCatalogRow[] = [
  { subject: 'Math', canonicalTopic: 'Algebra', aliases: ['algebra'], deterministic: true },
  { subject: 'Math', canonicalTopic: 'Linear equations', aliases: ['linear equations', 'linear equation'], deterministic: true },
  { subject: 'Math', canonicalTopic: 'Systems of equations', aliases: ['systems of equations', 'system of equations', 'simultaneous equations'], deterministic: true },
  { subject: 'Math', canonicalTopic: 'Probability', aliases: ['probability'], deterministic: true },
  { subject: 'Math', canonicalTopic: 'Geometry', aliases: ['geometry'], deterministic: true },
  { subject: 'Math', canonicalTopic: 'Functions', aliases: ['functions', 'function'], deterministic: true },
  { subject: 'Math', canonicalTopic: 'Inequalities', aliases: ['inequalities', 'inequality'], deterministic: true },
  {
    subject: 'Math',
    canonicalTopic: 'Statistics',
    aliases: [
      'statistics',
      'stat',
      'mean',
      'average',
      'median',
      'mode',
      'range',
      'data analysis',
      'frequency table',
    ],
    deterministic: true,
  },
  { subject: 'Math', canonicalTopic: 'Sequences', aliases: ['sequences', 'sequence', 'arithmetic sequence', 'geometric sequence'], deterministic: true },
  { subject: 'Math', canonicalTopic: 'Derivatives', aliases: ['derivatives', 'derivative'], deterministic: true },
  { subject: 'Math', canonicalTopic: 'Limits', aliases: ['limits', 'limit'], deterministic: true },
  { subject: 'Math', canonicalTopic: 'Quadratic equations', aliases: ['quadratic equations', 'quadratic equation', 'quadratics'], deterministic: true },
  { subject: 'Math', canonicalTopic: 'Trigonometry', aliases: ['trigonometry', 'trig'], deterministic: true },
  { subject: 'Math', canonicalTopic: 'Polynomials', aliases: ['polynomials', 'polynomial'], deterministic: true },
  { subject: 'Math', canonicalTopic: 'Set theory', aliases: ['set theory', 'sets'], deterministic: true },

  { subject: 'Physics', canonicalTopic: 'Mechanics', aliases: ['mechanics'], deterministic: true },
  { subject: 'Physics', canonicalTopic: 'Kinematics', aliases: ['kinematics', 'motion'], deterministic: true },
  { subject: 'Physics', canonicalTopic: 'Kinematics', aliases: ['speed and velocity', 'speed', 'velocity', 'acceleration'], deterministic: true },
  { subject: 'Physics', canonicalTopic: 'Newton laws', aliases: ["newton laws", "newton's laws", 'laws of motion'], deterministic: true },
  { subject: 'Physics', canonicalTopic: 'Forces', aliases: ['forces', 'force'], deterministic: true },
  { subject: 'Physics', canonicalTopic: 'Energy', aliases: ['energy', 'work and energy'], deterministic: true },
  { subject: 'Physics', canonicalTopic: 'Momentum', aliases: ['momentum'], deterministic: true },
  { subject: 'Physics', canonicalTopic: 'Magnetism', aliases: ['magnetism', 'magnetic fields', 'magnetic field', 'magnet', 'magnets'], deterministic: true },
  { subject: 'Physics', canonicalTopic: 'Relativity', aliases: ['relativity', 'special relativity', 'general relativity', 'time dilation', 'length contraction'], deterministic: true },
  { subject: 'Physics', canonicalTopic: 'Electricity', aliases: ['electricity'], deterministic: true },
  { subject: 'Physics', canonicalTopic: 'Electric field', aliases: ['electric field', 'electric fields', 'electrostatics', 'electrostatic'], deterministic: true },
  { subject: 'Physics', canonicalTopic: 'Circuits', aliases: ['circuits', 'electric circuits'], deterministic: true },
  { subject: 'Physics', canonicalTopic: 'Waves', aliases: ['waves', 'wave motion'], deterministic: true },
  { subject: 'Physics', canonicalTopic: 'Optics', aliases: ['optics', 'light', 'reflection', 'refraction', 'mirror', 'mirrors', 'lens', 'lenses'], deterministic: true },
  { subject: 'Physics', canonicalTopic: 'Thermodynamics', aliases: ['thermodynamics', 'heat', 'heat transfer', 'temperature', 'specific heat'], deterministic: true },

  { subject: 'Computer Science', canonicalTopic: 'Conditions', aliases: ['conditions', 'condition', 'conditional'], deterministic: true },
  { subject: 'Computer Science', canonicalTopic: 'If / Else', aliases: ['if / else', 'if else', 'if/else'], deterministic: true },
  { subject: 'Computer Science', canonicalTopic: 'Nested Conditions', aliases: ['nested conditions', 'nested condition'], deterministic: true },
  { subject: 'Computer Science', canonicalTopic: 'Boolean Logic', aliases: ['boolean logic', 'boolean'], deterministic: true },
  { subject: 'Computer Science', canonicalTopic: 'Loops', aliases: ['loops', 'loop', 'iteration', 'iterative'], deterministic: true },
  { subject: 'Computer Science', canonicalTopic: 'Functions', aliases: ['functions', 'function'], deterministic: true },
  { subject: 'Computer Science', canonicalTopic: 'Arrays', aliases: ['arrays', 'array'], deterministic: true },
  { subject: 'Computer Science', canonicalTopic: 'Strings', aliases: ['strings', 'string'], deterministic: true },
  { subject: 'Computer Science', canonicalTopic: 'Variables', aliases: ['variables', 'variable'], deterministic: true },
  { subject: 'Computer Science', canonicalTopic: 'Algorithms', aliases: ['algorithms', 'algorithm'], deterministic: true },
  { subject: 'Computer Science', canonicalTopic: 'Big O', aliases: ['big o', 'time complexity', 'space complexity', 'algorithmic complexity', 'complexity'], deterministic: false },

  { subject: 'Chemistry', canonicalTopic: 'Atoms and Elements', aliases: ['atoms and elements', 'atoms', 'elements'], deterministic: true },
  { subject: 'Chemistry', canonicalTopic: 'Periodic Table', aliases: ['periodic table'], deterministic: true },
  { subject: 'Chemistry', canonicalTopic: 'Chemical Bonds', aliases: ['chemical bonds', 'chemical bond', 'bonds'], deterministic: true },
  { subject: 'Chemistry', canonicalTopic: 'Reactions', aliases: ['reactions', 'reaction'], deterministic: true },
  { subject: 'Chemistry', canonicalTopic: 'Stoichiometry', aliases: ['stoichiometry'], deterministic: true },
  { subject: 'Chemistry', canonicalTopic: 'Acids and Bases', aliases: ['acids and bases', 'acids', 'bases'], deterministic: true },

  { subject: 'Biology', canonicalTopic: 'Cells', aliases: ['cells', 'cell'], deterministic: true },
  { subject: 'Biology', canonicalTopic: 'Genetics', aliases: ['genetics', 'genetic'], deterministic: true },
  { subject: 'Biology', canonicalTopic: 'Ecology', aliases: ['ecology'], deterministic: true },
  { subject: 'Biology', canonicalTopic: 'Human Body', aliases: ['human body', 'body systems'], deterministic: true },
  { subject: 'Biology', canonicalTopic: 'Photosynthesis', aliases: ['photosynthesis'], deterministic: true },

  { subject: 'English', canonicalTopic: 'Grammar', aliases: ['grammar'], deterministic: true },
  { subject: 'English', canonicalTopic: 'Tenses', aliases: ['tenses', 'tense'], deterministic: true },
  { subject: 'English', canonicalTopic: 'Vocabulary', aliases: ['vocabulary'], deterministic: true },
  { subject: 'English', canonicalTopic: 'Reading Comprehension', aliases: ['reading comprehension', 'reading', 'comprehension'], deterministic: true },
  { subject: 'English', canonicalTopic: 'Conditionals', aliases: ['conditionals', 'conditional'], deterministic: true },

  { subject: 'Arabic', canonicalTopic: 'Grammar', aliases: ['grammar', 'نحو', 'إعراب', 'اعراب'], deterministic: true },
  { subject: 'Arabic', canonicalTopic: 'Reading', aliases: ['reading', 'قراءة'], deterministic: true },
  { subject: 'Arabic', canonicalTopic: 'Vocabulary', aliases: ['vocabulary', 'مفردات'], deterministic: true },
  { subject: 'Arabic', canonicalTopic: 'Comprehension', aliases: ['comprehension', 'فهم'], deterministic: true },
  { subject: 'Arabic', canonicalTopic: 'Writing', aliases: ['writing', 'كتابة'], deterministic: true },

  { subject: 'Hebrew', canonicalTopic: 'Grammar', aliases: ['grammar', 'תחביר', 'לשון'], deterministic: true },
  { subject: 'Hebrew', canonicalTopic: 'Reading', aliases: ['reading', 'קריאה'], deterministic: true },
  { subject: 'Hebrew', canonicalTopic: 'Vocabulary', aliases: ['vocabulary', 'אוצר מילים'], deterministic: true },
  { subject: 'Hebrew', canonicalTopic: 'Comprehension', aliases: ['comprehension', 'הבנת הנקרא'], deterministic: true },
  { subject: 'Hebrew', canonicalTopic: 'Writing', aliases: ['writing', 'כתיבה'], deterministic: true },

  { subject: 'Electronics', canonicalTopic: 'Ohm’s Law', aliases: ['ohm’s law', "ohm's law", 'ohms law', 'ohm law'], deterministic: true },
  { subject: 'Electronics', canonicalTopic: 'Series Circuits', aliases: ['series circuits', 'series circuit'], deterministic: true },
  { subject: 'Electronics', canonicalTopic: 'Parallel Circuits', aliases: ['parallel circuits', 'parallel circuit'], deterministic: true },
  { subject: 'Electronics', canonicalTopic: 'Current and Voltage', aliases: ['current and voltage', 'current', 'voltage'], deterministic: true },
  { subject: 'Electronics', canonicalTopic: 'Resistors', aliases: ['resistors', 'resistor'], deterministic: true },
  { subject: 'Electronics', canonicalTopic: 'Capacitors', aliases: ['capacitors', 'capacitor'], deterministic: true },
  { subject: 'Electronics', canonicalTopic: 'Kirchhoff Laws', aliases: ['kirchhoff laws', 'kirchhoff', 'kcl', 'kvl'], deterministic: true },
];

function norm(x: string): string {
  return String(x ?? '')
    .toLowerCase()
    .replace(/[’']/g, "'")
    .replace(/\s+/g, ' ')
    .trim();
}

function normLoose(x: string): string {
  return norm(x)
    .replace(/[>\\/·•,:;()[\]{}|_-]+/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

function tokens(x: string): string[] {
  return normLoose(x).split(' ').filter(Boolean);
}

function phraseContains(input: string, candidate: string): boolean {
  if (!input || !candidate) return false;
  return ` ${input} `.includes(` ${candidate} `);
}

function scoreLooseCandidate(input: string, candidate: string): number {
  if (!input || !candidate) return -1;
  if (input === candidate) return 1000 + candidate.length;
  if (phraseContains(input, candidate)) return 800 + candidate.length;

  const inputTokens = tokens(input);
  const candidateTokens = tokens(candidate);
  const significantCandidateTokens = candidateTokens.filter(
    (token) => token.length >= 4 || /[^\u0000-\u007f]/.test(token),
  );

  const basis = significantCandidateTokens.length
    ? significantCandidateTokens
    : candidateTokens;

  const matched = basis.filter((token) => inputTokens.includes(token));
  if (!matched.length) return -1;

  if (basis.length > 1 && matched.length < basis.length) return -1;

  return matched.length * 100 + candidate.length;
}

export function resolveCanonicalPracticeTopic(subject: string, topicLike: string) {
  const s = String(subject ?? '').trim();
  const t = norm(topicLike);
  return (
    PRACTICE_TOPIC_CATALOG.find(
      (row) =>
        row.subject === s &&
        (norm(row.canonicalTopic) === t || row.aliases.some((a) => norm(a) === t)),
    ) ?? null
  );
}

export function resolveCanonicalPracticeTopicLoose(
  subject: string,
  ...topicLikes: string[]
) {
  const s = String(subject ?? '').trim();
  const inputs = topicLikes.map(normLoose).filter(Boolean);

  for (const input of inputs) {
    const exact = resolveCanonicalPracticeTopic(s, input);
    if (exact) return exact;
  }

  let best:
    | {
        row: PracticeTopicCatalogRow;
        score: number;
      }
    | undefined;

  for (const row of PRACTICE_TOPIC_CATALOG) {
    if (row.subject !== s) continue;

    const candidates = [row.canonicalTopic, ...row.aliases].map(normLoose);

    for (const input of inputs) {
      for (const candidate of candidates) {
        const score = scoreLooseCandidate(input, candidate);
        if (score < 0) continue;
        if (!best || score > best.score) {
          best = { row, score };
        }
      }
    }
  }

  return best?.row ?? null;
}

export function inferCanonicalPracticeSubjectFromTopicLoose(
  ...topicLikes: string[]
): string | null {
  const inputs = topicLikes.map(normLoose).filter(Boolean);
  let best:
    | {
        row: PracticeTopicCatalogRow;
        score: number;
      }
    | undefined;
  let ambiguous = false;

  for (const row of PRACTICE_TOPIC_CATALOG) {
    const candidates = [row.canonicalTopic, ...row.aliases].map(normLoose);

    for (const input of inputs) {
      for (const candidate of candidates) {
        const score = scoreLooseCandidate(input, candidate);
        if (score < 0) continue;

        if (!best || score > best.score) {
          best = { row, score };
          ambiguous = false;
          continue;
        }

        if (
          score === best.score &&
          (row.subject !== best.row.subject ||
              row.canonicalTopic !== best.row.canonicalTopic)
        ) {
          ambiguous = true;
        }
      }
    }
  }

  if (!best || ambiguous) return null;
  return best.row.subject;
}

export function isDeterministicPracticeTopic(subject: string, topicLike: string): boolean {
  const row = resolveCanonicalPracticeTopic(subject, topicLike);
  return Boolean(row?.deterministic);
}

export function isDeterministicPracticeTopicLoose(
  subject: string,
  ...topicLikes: string[]
): boolean {
  const row = resolveCanonicalPracticeTopicLoose(subject, ...topicLikes);
  return Boolean(row?.deterministic);
}
