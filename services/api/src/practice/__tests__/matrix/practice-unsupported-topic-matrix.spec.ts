import { Test } from '@nestjs/testing';
import { PracticeModule } from '../../practice.module';
import { PracticeEngineRegistry } from '../../engine/practice-engine.registry';

const CASES = [
  { subject: 'Physics', topicLabel: 'Kinematics', mode: 'practice', difficulty: 'medium' },
  { subject: 'Physics', topicLabel: 'Magnetism', mode: 'practice', difficulty: 'medium' },
  { subject: 'Physics', topicLabel: 'Relativity', mode: 'conceptBuilder', difficulty: 'medium' },
  { subject: 'Physics', topicLabel: 'Circuits', mode: 'practice', difficulty: 'medium' },
  { subject: 'Physics', topicLabel: 'Waves', mode: 'practice', difficulty: 'medium' },
  { subject: 'Physics', topicLabel: 'Optics', mode: 'practice', difficulty: 'medium' },
  { subject: 'Physics', topicLabel: 'Thermodynamics', mode: 'practice', difficulty: 'medium' },

  { subject: 'Math', topicLabel: 'Linear equations', mode: 'practice', difficulty: 'medium' },
  { subject: 'Math', topicLabel: 'Systems of equations', mode: 'practice', difficulty: 'medium' },
  { subject: 'Math', topicLabel: 'Probability', mode: 'practice', difficulty: 'medium' },
  { subject: 'Math', topicLabel: 'Geometry', mode: 'practice', difficulty: 'medium' },
  { subject: 'Math', topicLabel: 'Functions', mode: 'practice', difficulty: 'medium' },
  { subject: 'Math', topicLabel: 'Statistics', mode: 'practice', difficulty: 'medium' },
  { subject: 'Math', topicLabel: 'Sequences', mode: 'practice', difficulty: 'medium' },
  { subject: 'Math', topicLabel: 'Derivatives', mode: 'practice', difficulty: 'medium' },
  { subject: 'Math', topicLabel: 'Limits', mode: 'practice', difficulty: 'medium' },
  { subject: 'Math', topicLabel: 'Quadratic equations', mode: 'practice', difficulty: 'medium' },
  { subject: 'Math', topicLabel: 'Trigonometry', mode: 'practice', difficulty: 'medium' },
  { subject: 'Math', topicLabel: 'Polynomials', mode: 'examPrep', difficulty: 'hard' },
  { subject: 'Math', topicLabel: 'Set theory', mode: 'flashcards', difficulty: 'medium' },

  { subject: 'Electronics', topicLabel: 'Ohm’s Law', mode: 'practice', difficulty: 'medium' },
  { subject: 'Electronics', topicLabel: 'Series Circuits', mode: 'practice', difficulty: 'medium' },
  { subject: 'Electronics', topicLabel: 'Parallel Circuits', mode: 'practice', difficulty: 'medium' },
  { subject: 'Electronics', topicLabel: 'Current and Voltage', mode: 'practice', difficulty: 'medium' },
  { subject: 'Electronics', topicLabel: 'Resistors', mode: 'practice', difficulty: 'medium' },
  { subject: 'Electronics', topicLabel: 'Capacitors', mode: 'practice', difficulty: 'medium' },
  { subject: 'Electronics', topicLabel: 'Kirchhoff Laws', mode: 'practice', difficulty: 'medium' },
];

describe('practice unsupported-topic matrix', () => {
  it(
    'documents deterministic coverage without touching AI fallback',
    async () => {
      const mod = await Test.createTestingModule({
        imports: [PracticeModule],
      }).compile();

      const registry = mod.get(PracticeEngineRegistry);

      const rows: Array<Record<string, unknown>> = [];

      for (const c of CASES) {
        const questions = await registry.generate({
          subject: c.subject,
          topicLabel: c.topicLabel,
          topicPath: [],
          topicPathText: c.topicLabel,
          strictPromptSummary: '',
          questionCount: 2,
          mode: c.mode as any,
          difficulty: c.difficulty as any,
          timePreferenceSeconds: 30,
          useAiTiming: true,
          maxLives: 2,
        });

        rows.push({
          subject: c.subject,
          topicLabel: c.topicLabel,
          deterministic: Boolean(questions && questions.length > 0),
          returned: questions?.length ?? 0,
        });
      }

      const supported = rows.filter((r) => r.deterministic === true).length;
      const total = rows.length;
      const pct = Math.round((supported / total) * 100);

      console.table(rows);
      console.log(`practice_deterministic_coverage=${supported}/${total} (${pct}%)`);

      expect(rows).toHaveLength(CASES.length);
    },
    30000,
  );
});
