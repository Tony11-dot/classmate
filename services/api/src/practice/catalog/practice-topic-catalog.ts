export type PracticeTopicCatalogRow = {
  subject: string;
  canonicalTopic: string;
  aliases: string[];
  deterministic: boolean;
};

export const PRACTICE_TOPIC_CATALOG: PracticeTopicCatalogRow[] = [
  { subject: 'Math', canonicalTopic: 'Linear equations', aliases: ['linear equations', 'linear equation'], deterministic: true },
  { subject: 'Math', canonicalTopic: 'Systems of equations', aliases: ['systems of equations', 'system of equations', 'simultaneous equations'], deterministic: true },
  { subject: 'Math', canonicalTopic: 'Probability', aliases: ['probability'], deterministic: true },
  { subject: 'Math', canonicalTopic: 'Geometry', aliases: ['geometry'], deterministic: true },
  { subject: 'Math', canonicalTopic: 'Functions', aliases: ['functions', 'function'], deterministic: true },
  { subject: 'Math', canonicalTopic: 'Statistics', aliases: ['statistics', 'stat'], deterministic: true },
  { subject: 'Math', canonicalTopic: 'Sequences', aliases: ['sequences', 'sequence', 'arithmetic sequence', 'geometric sequence'], deterministic: true },
  { subject: 'Math', canonicalTopic: 'Derivatives', aliases: ['derivatives', 'derivative'], deterministic: true },
  { subject: 'Math', canonicalTopic: 'Limits', aliases: ['limits', 'limit'], deterministic: true },
  { subject: 'Math', canonicalTopic: 'Quadratic equations', aliases: ['quadratic equations', 'quadratic equation', 'quadratics'], deterministic: true },
  { subject: 'Math', canonicalTopic: 'Trigonometry', aliases: ['trigonometry', 'trig'], deterministic: true },
  { subject: 'Math', canonicalTopic: 'Polynomials', aliases: ['polynomials', 'polynomial'], deterministic: true },
  { subject: 'Math', canonicalTopic: 'Set theory', aliases: ['set theory', 'sets'], deterministic: true },

  { subject: 'Physics', canonicalTopic: 'Kinematics', aliases: ['kinematics', 'motion'], deterministic: true },
  { subject: 'Physics', canonicalTopic: 'Newton laws', aliases: ["newton laws", "newton's laws", 'laws of motion'], deterministic: true },
  { subject: 'Physics', canonicalTopic: 'Forces', aliases: ['forces', 'force'], deterministic: true },
  { subject: 'Physics', canonicalTopic: 'Energy', aliases: ['energy', 'work and energy'], deterministic: true },
  { subject: 'Physics', canonicalTopic: 'Momentum', aliases: ['momentum'], deterministic: true },
  { subject: 'Physics', canonicalTopic: 'Magnetism', aliases: ['magnetism', 'magnetic fields'], deterministic: true },
  { subject: 'Physics', canonicalTopic: 'Relativity', aliases: ['relativity'], deterministic: true },
  { subject: 'Physics', canonicalTopic: 'Electricity', aliases: ['electricity'], deterministic: true },
  { subject: 'Physics', canonicalTopic: 'Electric field', aliases: ['electric field', 'electric fields'], deterministic: true },
  { subject: 'Physics', canonicalTopic: 'Circuits', aliases: ['circuits', 'electric circuits'], deterministic: true },
  { subject: 'Physics', canonicalTopic: 'Waves', aliases: ['waves', 'wave motion'], deterministic: true },
  { subject: 'Physics', canonicalTopic: 'Optics', aliases: ['optics', 'light'], deterministic: true },
  { subject: 'Physics', canonicalTopic: 'Thermodynamics', aliases: ['thermodynamics', 'heat'], deterministic: true },

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

export function isDeterministicPracticeTopic(subject: string, topicLike: string): boolean {
  const row = resolveCanonicalPracticeTopic(subject, topicLike);
  return Boolean(row?.deterministic);
}
