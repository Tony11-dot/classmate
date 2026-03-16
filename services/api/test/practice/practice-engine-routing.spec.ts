import { PhysicsElectricityDeterministicEngine } from '../../src/practice/engine/physics-electricity-deterministic.engine';
import { PhysicsEnergyDeterministicEngine } from '../../src/practice/engine/physics-energy-deterministic.engine';
import { PhysicsCircuitsDeterministicEngine } from '../../src/practice/engine/physics-circuits-deterministic.engine';
import { PhysicsElectricFieldDeterministicEngine } from '../../src/practice/engine/physics-electric-field-deterministic.engine';

describe('practice engine routing guards', () => {
  const electricity = new PhysicsElectricityDeterministicEngine();
  const energy = new PhysicsEnergyDeterministicEngine();
  const circuits = new PhysicsCircuitsDeterministicEngine();
  const electricField = new PhysicsElectricFieldDeterministicEngine();

  const req = (overrides: Partial<any> = {}) => ({
    subject: 'Physics',
    topicLabel: 'Electricity',
    topicPath: ['Physics', 'Electricity'],
    topicPathText: 'Physics > Electricity',
    strictPromptSummary: 'electricity basics',
    questionCount: 5,
    mode: 'practice',
    difficulty: 'medium',
    timePreferenceSeconds: 40,
    useAiTiming: false,
    maxLives: 3,
    ...overrides,
  });

  it('electricity supports actual electricity topics', () => {
    expect(
      electricity.supports(
        req({
          topicLabel: 'Electricity',
          topicPathText: 'Physics > Electricity',
          strictPromptSummary: 'electric current voltage and electrical power',
        }),
      ),
    ).toBe(true);
  });

  it('electricity does not capture energy topics', () => {
    expect(
      electricity.supports(
        req({
          topicLabel: 'Energy',
          topicPathText: 'Physics > Energy',
          strictPromptSummary: 'kinetic potential work and conservation of energy',
        }),
      ),
    ).toBe(false);
  });

  it('energy supports energy topics', () => {
    expect(
      energy.supports(
        req({
          topicLabel: 'Energy',
          topicPathText: 'Physics > Energy',
          strictPromptSummary: 'kinetic potential work and conservation of energy',
        }),
      ),
    ).toBe(true);
  });

  it('electricity does not capture electric field topics', () => {
    expect(
      electricity.supports(
        req({
          topicLabel: 'Electric field',
          topicPathText: 'Physics > Electricity > Electric field',
          strictPromptSummary: 'electric field strength force on charge',
        }),
      ),
    ).toBe(false);
  });

  it('electric field supports electric field topics', () => {
    expect(
      electricField.supports(
        req({
          topicLabel: 'Electric field',
          topicPathText: 'Physics > Electricity > Electric field',
          strictPromptSummary: 'electric field strength force on charge',
        }),
      ),
    ).toBe(true);
  });

  it('electricity does not capture circuit topics', () => {
    expect(
      electricity.supports(
        req({
          topicLabel: 'Circuits',
          topicPathText: 'Physics > Electricity > Circuits',
          strictPromptSummary: 'series circuit resistance ohm law',
        }),
      ),
    ).toBe(false);
  });

  it('circuits supports circuit topics', () => {
    expect(
      circuits.supports(
        req({
          topicLabel: 'Circuits',
          topicPathText: 'Physics > Electricity > Circuits',
          strictPromptSummary: 'series circuit resistance ohm law',
        }),
      ),
    ).toBe(true);
  });

  it('energy does not capture electricity topics with potential difference wording', () => {
    expect(
      energy.supports(
        req({
          topicLabel: 'Electricity',
          topicPathText: 'Physics > Electricity',
          strictPromptSummary: 'potential difference voltage electric current electric charge',
        }),
      ),
    ).toBe(false);
  });

  it('electricity supports electricity topics with potential difference wording', () => {
    expect(
      electricity.supports(
        req({
          topicLabel: 'Electricity',
          topicPathText: 'Physics > Electricity',
          strictPromptSummary: 'potential difference voltage electric current electric charge',
        }),
      ),
    ).toBe(true);
  });
});
