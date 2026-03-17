export type PracticeGenerationStrategy =
  | 'deterministic'
  | 'grounded_factual'
  | 'conceptual'
  | 'symbolic'
  | 'fallback';

export type TopicBreadth = 'narrow' | 'medium' | 'broad';
export type TopicQuizzability = 'high' | 'medium' | 'low';

export type CustomTopicIntakeResult = {
  rawSubject: string;
  rawTopic: string;
  normalizedSubject: string;
  normalizedTopic: string;
  effectiveSubject: string;
  effectiveTopic: string;
  topicType:
    | 'school_stem'
    | 'factual_history'
    | 'factual_general'
    | 'conceptual'
    | 'symbolic'
    | 'unknown';
  breadth: TopicBreadth;
  quizzability: TopicQuizzability;
  confidence: number;
  generationStrategy: PracticeGenerationStrategy;
  needsClarification: boolean;
  reasons: string[];
};

function norm(x: unknown): string {
  return String(x ?? '')
    .trim()
    .replace(/\s+/g, ' ');
}

function lower(x: unknown): string {
  return norm(x).toLowerCase();
}

export function normalizePracticeSubjectLoose(raw: unknown): string {
  const v = lower(raw);
  if (!v) return 'General Knowledge';

  const map: Record<string, string> = {
    math: 'Math',
    mathematics: 'Math',
    maths: 'Math',

    physics: 'Physics',
    physic: 'Physics',

    electronics: 'Electronics',
    elictronics: 'Electronics',
    electroncis: 'Electronics',
    eletronics: 'Electronics',
    electronic: 'Electronics',

    chemistry: 'Chemistry',
    chem: 'Chemistry',

    biology: 'Biology',
    bio: 'Biology',

    history: 'History',
    geography: 'Geography',

    'general knowledge': 'General Knowledge',
    general: 'General Knowledge',
    gk: 'General Knowledge',

    sport: 'Sports',
    sports: 'Sports',

    'computer science': 'Computer Science',
    cs: 'Computer Science',
  };

  return map[v] ?? norm(raw);
}

export function normalizeCustomTopicText(raw: unknown): string {
  const v = norm(raw)
    .replace(/[·•]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();

  if (!v) return 'General';

  const aliasMap: Array<[RegExp, string]> = [
    [/\bohm('?|’)s?\s*law\b/i, 'Ohm’s Law'],
    [/\bkirchhoff('?|’)s?\s*laws?\b/i, 'Kirchhoff Laws'],
    [/\bkcl\b|\bkvl\b/i, 'Kirchhoff Laws'],
    [/\bquadratics?\b/i, 'Quadratic equations'],
    [/\bpolynomials?\b/i, 'Polynomials'],
    [/\bprobability\b/i, 'Probability'],
    [/\brelativity\b/i, 'Relativity'],
    [/\bkinematics?\b|\bmotion\b/i, 'Kinematics'],
    [/\btennis history\b/i, 'Tennis History'],
    [/\bworld\s+war\s*(ii|2)\b/i, 'World War II'],
    [/\b(world capitals|capitals of the world)\b/i, 'World Capitals'],
  ];

  for (const [rx, target] of aliasMap) {
    if (rx.test(v)) return target;
  }

  return v
    .split(' ')
    .map((w) => (w ? w[0].toUpperCase() + w.slice(1).toLowerCase() : w))
    .join(' ');
}

function inferSubjectFromTopic(topic: string): string | null {
  const t = lower(topic);

  if (
    /\b(ohm|kirchhoff|resistor|resistors|capacitor|capacitors|series circuit|parallel circuit|voltage|current)\b/.test(t)
  ) return 'Electronics';

  if (
    /\b(kinematics|relativity|magnetism|waves|optics|thermodynamics|circuits|electric field|momentum|energy|newton)\b/.test(t)
  ) return 'Physics';

  if (
    /\b(polynomial|quadratic|probability|statistics|geometry|trigonometry|derivative|derivatives|limits|sequence|sequences|function|functions|linear equation|systems of equations)\b/.test(t)
  ) return 'Math';

  if (
    /\b(tennis|football|soccer|basketball|nba|fifa|world cup|olympics|grand slam)\b/.test(t)
  ) return 'Sports';

  if (
    /\b(history|empire|war|dynasty|revolution|ancient|medieval|open era)\b/.test(t)
  ) return 'History';

  return null;
}



function isLowSignalTopicText(raw: string): boolean {
  const t = String(raw ?? '').trim().toLowerCase();
  if (!t) return true;

  const weak = [
    'random','thing','maybe','stuff','something','anything','whatever',
    'etc','misc','unknown','general','topic'
  ];

  const words = t.split(/\s+/).filter(Boolean);

  let hits = 0;
  for (const w of weak) {
    if (t.includes(w)) hits++;
  }

  if (hits >= 2) return true;
  if (words.length <= 2 && hits >= 1) return true;
  if (t.length < 6) return true;

  return false;
}

function inferTopicType(subject: string, topic: string): CustomTopicIntakeResult['topicType'] {
  const s = lower(subject);
  const t = lower(topic);

  if (
    ['math', 'physics', 'electronics', 'chemistry', 'biology', 'computer science'].includes(s)
  ) {
    if (/\b(equation|equations|derivative|derivatives|limit|limits|polynomial|quadratic|integral|vector|matrix|circuit|resistor|ohm|kirchhoff)\b/.test(t)) {
      return 'symbolic';
    }
    return 'school_stem';
  }

  if (/\b(history|era|war|revolution|timeline|champion|championship|grand slam|biography)\b/.test(t)) {
    return 'factual_history';
  }

  

  if (
    /\b(meaning|concept|theory|idea|principle|overview|basics|introduction|music theory|big o|algorithmic complexity|time complexity|space complexity|conditional|conditionals|if statements)\b/.test(t)
  ) {
    return 'conceptual';
  }

  // =========================
  // GK_FORCE_BLOCK
  // =========================
  const gkForce =
    ['general knowledge','sports','history','geography'].includes(s) &&
    /\b(flags|countries|planets|capitals)\b/.test(t);

  if (gkForce) {
    return 'factual_general';
  }

  if (['general knowledge', 'sports', 'history', 'geography'].includes(s)) {
    // prevent garbage topics from becoming "factual"
    if (isLowSignalTopicText(topic)) {
      return 'unknown';
    }
    return 'factual_general';
  }

  return 'unknown';
}



function isBroadFactualTopicText(raw: string): boolean {
  const t = lower(raw);
  if (!t) return true;

  const broad_exact = new Set([
    'history',
    'sports',
    'general knowledge',
    'geography',
    'countries',
    'flags',
    'planets',
    'capital cities',
    'capitals',
  ]);

  if (broad_exact.has(t.trim())) return true;

  if (/^(history|sports|geography|countries|flags|planets|capitals)(\s+(basics|overview|introduction))?$/.test(t)) {
    return true;
  }

  return false;
}

function inferBreadth(topic: string): TopicBreadth {
  const words = lower(topic).split(/\s+/).filter(Boolean);

  if (words.length <= 1) return 'broad';
  if (words.length >= 4) return 'narrow';

  if (
    /\b(history|physics|math|sports|biology|chemistry|geography|computer science)\b/.test(lower(topic))
  ) return 'broad';

  return 'medium';
}

function inferQuizzability(topicType: CustomTopicIntakeResult['topicType'], topic: string): TopicQuizzability {
  const t = lower(topic);

  if (!t || t === 'general') return 'low';
  if (topicType === 'symbolic' || topicType === 'school_stem' || topicType === 'factual_history' || topicType === 'factual_general') return 'high';
  if (topicType === 'conceptual') return 'medium';
  return 'low';
}

function inferStrategy(topicType: CustomTopicIntakeResult['topicType']): PracticeGenerationStrategy {
  switch (topicType) {
    case 'school_stem':
      return 'deterministic';
    case 'symbolic':
      return 'symbolic';
    case 'factual_history':
    case 'factual_general':
      return 'grounded_factual';
    case 'conceptual':
      return 'conceptual';
    default:
      return 'fallback';
  }
}

export function analyzeCustomPracticeTopic(input: {
  subject?: unknown;
  topic?: unknown;
  topicLabel?: unknown;
  topicPathText?: unknown;
}): CustomTopicIntakeResult {
  const rawSubject = norm(input.subject);
  const rawTopic =
    norm(input.topicLabel) ||
    norm(input.topicPathText) ||
    norm(input.topic);

  const normalizedSubject = normalizePracticeSubjectLoose(rawSubject);
  const normalizedTopic = normalizeCustomTopicText(rawTopic);

  const subjectFromTopic = inferSubjectFromTopic(normalizedTopic);
  const effectiveSubject =
    normalizedSubject === 'General Knowledge' && subjectFromTopic
      ? subjectFromTopic
      : normalizedSubject;

  const effectiveTopic = normalizedTopic || 'General';
  
  // GK_CLUSTER_FORCE
  const lowerTopic = effectiveTopic.toLowerCase();

  const isGKCluster =
    lowerTopic.includes('flags') ||
    lowerTopic.includes('countries') ||
    lowerTopic.includes('planets') ||
    lowerTopic.includes('capitals');


  const topicType = inferTopicType(effectiveSubject, effectiveTopic);
  const breadth = inferBreadth(effectiveTopic);
  const quizzability = inferQuizzability(topicType, effectiveTopic);
  const generationStrategy = inferStrategy(topicType);

  const reasons: string[] = [];
  // GK_CLUSTER_CONFIDENCE
  let confidence =
    isGKCluster ? 0.95 : 0.45;

  if (rawSubject) confidence += 0.08;
  if (rawTopic) confidence += 0.10;
  if (subjectFromTopic) confidence += 0.15;
  if (topicType !== 'unknown') confidence += 0.15;
  if (generationStrategy !== 'fallback') confidence += 0.12;
  if (breadth === 'medium' || breadth === 'narrow') confidence += 0.08;
  if (quizzability === 'high') confidence += 0.10;

  if (!rawTopic) reasons.push('missing_topic');
  if (breadth === 'broad') reasons.push('broad_topic');
  if (generationStrategy === 'grounded_factual' && isBroadFactualTopicText(effectiveTopic)) {
    reasons.push('broad_factual_topic');
  }
  if (topicType === 'unknown') reasons.push('unknown_topic_type');
  if (quizzability === 'low') reasons.push('low_quizzability');
  if (normalizedSubject !== effectiveSubject) reasons.push('subject_inferred_from_topic');
  if (normalizedSubject !== rawSubject && rawSubject) reasons.push('subject_normalized');
  if (normalizedTopic !== rawTopic && rawTopic) reasons.push('topic_normalized');

  confidence = Math.max(0, Math.min(0.99, Number(confidence.toFixed(2))));

  const needsClarification =
    !rawTopic ||
    confidence < 0.6 ||
    quizzability === 'low' ||
    (breadth === 'broad' && generationStrategy !== 'deterministic');

  return {
    rawSubject,
    rawTopic,
    normalizedSubject,
    normalizedTopic,
    effectiveSubject,
    effectiveTopic,
    topicType,
    breadth,
    quizzability,
    confidence,
    generationStrategy,
    needsClarification,
    reasons,
  };
}
