import { PhysicsElectricityDeterministicEngine } from '../../src/practice/engine/physics-electricity-deterministic.engine';
import { PhysicsCircuitsDeterministicEngine } from '../../src/practice/engine/physics-circuits-deterministic.engine';
import { PhysicsElectricFieldDeterministicEngine } from '../../src/practice/engine/physics-electric-field-deterministic.engine';

const baseReq = {
  subject: 'Physics',
  topicPath: ['Physics'],
  mode: 'practice',
  questionCount: 8,
  difficulty: 'medium',
  timePreferenceSeconds: 40,
  useAiTiming: false,
  maxLives: 3,
};

describe('practice option sanity', () => {
  it('electricity options are clean and unique', async () => {
    const engine = new PhysicsElectricityDeterministicEngine();
    const questions = await engine.generate({
      ...baseReq,
      topicLabel: 'Electricity',
      topicPathText: 'Physics > Electricity',
      strictPromptSummary: 'electric current voltage electrical power',
    } as any);

    for (const q of questions) {
      expect(q.options).toHaveLength(4);
      expect(new Set(q.options).size).toBe(4);
      for (const opt of q.options) {
        expect(opt).not.toMatch(/_/);
      }
    }
  });

  it('circuits options are clean and unique', async () => {
    const engine = new PhysicsCircuitsDeterministicEngine();
    const questions = await engine.generate({
      ...baseReq,
      topicLabel: 'Circuits',
      topicPathText: 'Physics > Electricity > Circuits',
      strictPromptSummary: 'series circuit resistance ohm law',
    } as any);

    for (const q of questions) {
      expect(q.options).toHaveLength(4);
      expect(new Set(q.options).size).toBe(4);
      for (const opt of q.options) {
        expect(opt).not.toMatch(/_/);
      }
    }
  });

  it('electric field options are clean and unique', async () => {
    const engine = new PhysicsElectricFieldDeterministicEngine();
    const questions = await engine.generate({
      ...baseReq,
      topicLabel: 'Electric field',
      topicPathText: 'Physics > Electricity > Electric field',
      strictPromptSummary: 'electric field strength force on charge',
    } as any);

    for (const q of questions) {
      expect(q.options).toHaveLength(4);
      expect(new Set(q.options).size).toBe(4);
      for (const opt of q.options) {
        expect(opt).not.toMatch(/_/);
      }
    }
  });
});


it('does not emit placeholder fallback distractors', async () => {
  const req = {
    subject: 'Physics',
    topicLabel: 'Electricity',
    topicPathText: 'Physics > Electricity',
    strictPromptSummary: 'electric current voltage resistance',
    questionCount: 5,
    difficulty: 'medium',
    mode: 'practice',
  } as any;

  const engines = [
    new PhysicsElectricityDeterministicEngine(),
    new PhysicsElectricFieldDeterministicEngine(),
    new PhysicsCircuitsDeterministicEngine(),
  ];

  for (const engine of engines) {
    const out = await engine.generate(req);
    for (const q of out) {
      for (const option of q.options) {
        expect(option).not.toContain('__BAD_DUP___');
        expect(option).not.toMatch(/_[0-9]+$/);
        expect(option).not.toMatch(/Ω_|N_|V_|C_|J_|W_/);
      }
    }
  }
});
