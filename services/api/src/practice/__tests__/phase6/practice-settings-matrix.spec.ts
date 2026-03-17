import { Test } from '@nestjs/testing';
import { PracticeModule } from '../../practice.module';
import { PracticeEngineRegistry } from '../../engine/practice-engine.registry';
import { PracticeService } from '../../practice.service';

const supportedCases = [
  { subject: 'Physics', topicLabel: 'Kinematics' },
  { subject: 'Physics', topicLabel: 'Magnetism' },
  { subject: 'Physics', topicLabel: 'Relativity' },
  { subject: 'Physics', topicLabel: 'Circuits' },
  { subject: 'Physics', topicLabel: 'Waves' },
  { subject: 'Physics', topicLabel: 'Optics' },
  { subject: 'Physics', topicLabel: 'Thermodynamics' },

  { subject: 'Math', topicLabel: 'Linear equations' },
  { subject: 'Math', topicLabel: 'Systems of equations' },
  { subject: 'Math', topicLabel: 'Probability' },
  { subject: 'Math', topicLabel: 'Geometry' },
  { subject: 'Math', topicLabel: 'Functions' },
  { subject: 'Math', topicLabel: 'Statistics' },
  { subject: 'Math', topicLabel: 'Sequences' },
  { subject: 'Math', topicLabel: 'Derivatives' },
  { subject: 'Math', topicLabel: 'Limits' },
  { subject: 'Math', topicLabel: 'Quadratic equations' },
  { subject: 'Math', topicLabel: 'Trigonometry' },
  { subject: 'Math', topicLabel: 'Polynomials' },
  { subject: 'Math', topicLabel: 'Set theory' },

  { subject: 'Electronics', topicLabel: 'Ohm’s Law' },
  { subject: 'Electronics', topicLabel: 'Series Circuits' },
  { subject: 'Electronics', topicLabel: 'Parallel Circuits' },
  { subject: 'Electronics', topicLabel: 'Current and Voltage' },
  { subject: 'Electronics', topicLabel: 'Resistors' },
  { subject: 'Electronics', topicLabel: 'Capacitors' },
  { subject: 'Electronics', topicLabel: 'Kirchhoff Laws' },
] as const;

const serviceCases = [
  { subject: 'Elictronics', topicLabel: 'Kirchhoff Laws' },
  { subject: 'math', topicLabel: 'Probability' },
  { subject: 'Physics', topicLabel: 'Random Topic That Does Not Exist' },
] as const;

const modes = ['practice', 'flashcards', 'speedRound'] as const;
const difficulties = ['easy', 'medium', 'hard'] as const;

describe('PHASE 6 — settings stress matrix', () => {
  it(
    'registry fast-path never breaks across supported combinations',
    async () => {
      const mod = await Test.createTestingModule({
        imports: [PracticeModule],
      }).compile();

      const registry = mod.get(PracticeEngineRegistry);

      let total = 0;

      for (const base of supportedCases) {
        for (const mode of modes) {
          for (const difficulty of difficulties) {
            total++;

            const questions = await registry.generate({
              subject: base.subject,
              topicLabel: base.topicLabel,
              topicPath: [base.topicLabel],
              topicPathText: base.topicLabel,
              strictPromptSummary: '',
              questionCount: 2,
              mode,
              difficulty,
              timePreferenceSeconds: null,
              useAiTiming: true,
              maxLives: 3,
            });

            expect(Array.isArray(questions)).toBe(true);
            if ((questions?.length ?? 0) !== 2) {
              console.log('PHASE6_REGISTRY_FAIL', JSON.stringify({
                subject,
                topic,
                mode,
                difficulty,
                returned: questions?.length ?? 0,
                prompts: (questions ?? []).map((q: any) => q.prompt),
              }));
            }
            expect(questions?.length).toBe(2);

            for (const q of questions ?? []) {
              expect(String(q.prompt ?? '').trim()).toBeTruthy();
              expect(Array.isArray(q.options)).toBe(true);
              expect(q.options).toHaveLength(4);
              expect(Number(q.correctIndex)).toBeGreaterThanOrEqual(0);
              expect(Number(q.correctIndex)).toBeLessThan(4);
              expect(String(q.correctAnswerText ?? '').trim()).toBeTruthy();
              expect(String(q.correctAnswerText)).toBe(String(q.options?.[q.correctIndex]));
              expect(Number(q.recommendedTimeSeconds)).toBeGreaterThan(0);
            }
          }
        }
      }

      console.log('PHASE6_REGISTRY_TOTAL_CASES', total);
      expect(total).toBe(supportedCases.length * modes.length * difficulties.length);
    },
    30000,
  );

  it(
    'service path normalizes and stays usable for sampled runtime cases',
    async () => {
      const mod = await Test.createTestingModule({
        imports: [PracticeModule],
      }).compile();

      const service = mod.get(PracticeService) as any;

      const requestQuestionSetSpy = jest
        .spyOn(service, 'requestQuestionSet')
        .mockImplementation(async (args: any) => {
          const rp = args.requestPayload ?? {};
          const topicLabel = String(rp.topicLabel ?? 'General');
          const subject = String(rp.subject ?? 'Math');
          const seconds = Number(rp.timePreferenceSeconds ?? 30) || 30;

          return [
            {
              prompt: `${subject} :: ${topicLabel} :: Q1`,
              options: ['A', 'B', 'C', 'D'],
              correctIndex: 0,
              correctAnswerText: 'A',
              explanation: `${topicLabel} explanation 1`,
              recommendedTimeSeconds: seconds,
              topicMatchNote: topicLabel,
            },
            {
              prompt: `${subject} :: ${topicLabel} :: Q2`,
              options: ['A', 'B', 'C', 'D'],
              correctIndex: 1,
              correctAnswerText: 'B',
              explanation: `${topicLabel} explanation 2`,
              recommendedTimeSeconds: seconds,
              topicMatchNote: topicLabel,
            },
          ];
        });

      const verifyQuestionSetSpy = jest
        .spyOn(service, 'verifyQuestionSet')
        .mockImplementation(async ({ questions }: any) => questions);

      let total = 0;

      for (const base of serviceCases) {
        for (const mode of modes) {
          for (const difficulty of difficulties) {
            total++;

            const res = await service.generate({
              subject: base.subject,
              topicLabel: base.topicLabel,
              topicPathText: base.topicLabel,
              mode,
              difficulty,
              questionCount: 2,
              useAiTiming: true,
              maxLives: 3,
            });

            expect(Array.isArray(res.questions)).toBe(true);
            expect(res.questions.length).toBe(2);

            for (const q of res.questions) {
              expect(String(q.subject ?? '').trim()).toBeTruthy();
              expect(String(q.topicLabel ?? '').trim()).toBeTruthy();
              expect(String(q.prompt ?? '').trim()).toBeTruthy();
              expect(Array.isArray(q.options)).toBe(true);
              expect(q.options.length).toBe(4);
              expect(Number(q.correctIndex)).toBeGreaterThanOrEqual(0);
              expect(Number(q.correctIndex)).toBeLessThan(4);
              expect(Number(q.recommendedTimeSeconds)).toBeGreaterThan(0);
            }
          }
        }
      }

      console.log('PHASE6_SERVICE_TOTAL_CASES', total);
      expect(requestQuestionSetSpy).toHaveBeenCalled();
      expect(verifyQuestionSetSpy).toHaveBeenCalled();
      expect(total).toBe(serviceCases.length * modes.length * difficulties.length);
    },
    30000,
  );
});
