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
