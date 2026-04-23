import { ElectronicsDeterministicEngine } from '../electronics-deterministic.engine';
import { PhysicsCircuitsDeterministicEngine } from '../physics-circuits-deterministic.engine';
import { PhysicsMagnetismDeterministicEngine } from '../physics-magnetism-deterministic.engine';
import { PhysicsOpticsDeterministicEngine } from '../physics-optics-deterministic.engine';
import { PhysicsRelativityDeterministicEngine } from '../physics-relativity-deterministic.engine';
import { PhysicsThermodynamicsDeterministicEngine } from '../physics-thermodynamics-deterministic.engine';
import { QuadraticDeterministicEngine } from '../quadratic-deterministic.engine';
import { SetTheoryDeterministicEngine } from '../set-theory-deterministic.engine';
import { TrigonometryDeterministicEngine } from '../trigonometry-deterministic.engine';
import type { PracticeEngineRequest } from '../practice-engine.types';

function makeRequest(
  overrides: Partial<PracticeEngineRequest>,
): PracticeEngineRequest {
  return {
    subject: 'Math',
    topicLabel: 'General',
    topicPath: [],
    topicPathText: 'General',
    strictPromptSummary: '',
    questionCount: 6,
    mode: 'practice',
    difficulty: 'medium',
    timePreferenceSeconds: null,
    useAiTiming: true,
    maxLives: 3,
    ...overrides,
  };
}

describe('banked deterministic engines', () => {
  it('keeps set theory practice-only and keys subset count correctly', async () => {
    const engine = new SetTheoryDeterministicEngine();
    const questions = await engine.generate(
      makeRequest({
        subject: 'Math',
        topicLabel: 'Set theory',
        topicPath: ['Math', 'Set theory'],
        topicPathText: 'Math > Set theory',
      }),
    );

    const subsetQuestion = questions.find((question) =>
      question.prompt.includes('How many subsets does a set with 2 elements have?'),
    );

    expect(engine.supportedModes).toEqual(['practice']);
    expect(subsetQuestion).toBeTruthy();
    expect(subsetQuestion?.recommendedTimeSeconds).toBe(18);
    expect(subsetQuestion?.correctAnswerText).toBe('4');
    expect(subsetQuestion?.options[subsetQuestion.correctIndex]).toBe('4');
  });

  it('keeps relativity practice-only and uses its default timing', async () => {
    const engine = new PhysicsRelativityDeterministicEngine();
    const questions = await engine.generate(
      makeRequest({
        subject: 'Physics',
        topicLabel: 'Relativity',
        topicPath: ['Physics', 'Relativity'],
        topicPathText: 'Physics > Relativity',
      }),
    );

    const timeDilationQuestion = questions.find((question) =>
      question.prompt.includes('What does time dilation mean in special relativity?'),
    );

    expect(engine.supportedModes).toEqual(['practice']);
    expect(timeDilationQuestion).toBeTruthy();
    expect(timeDilationQuestion?.recommendedTimeSeconds).toBe(45);
    expect(timeDilationQuestion?.correctAnswerText).toBe(
      'Moving clocks run slower relative to a stationary observer',
    );
  });

  it('keeps magnetism practice-only and honors difficulty-based default timing', async () => {
    const engine = new PhysicsMagnetismDeterministicEngine();
    const easyQuestions = await engine.generate(
      makeRequest({
        subject: 'Physics',
        topicLabel: 'Magnetism',
        topicPath: ['Physics', 'Magnetism'],
        topicPathText: 'Physics > Magnetism',
        difficulty: 'easy',
      }),
    );
    const mediumQuestions = await engine.generate(
      makeRequest({
        subject: 'Physics',
        topicLabel: 'Magnetism',
        topicPath: ['Physics', 'Magnetism'],
        topicPathText: 'Physics > Magnetism',
        difficulty: 'medium',
      }),
    );

    const attractionQuestion = mediumQuestions.find((question) =>
      question.prompt.includes('Which poles attract each other?'),
    );

    expect(engine.supportedModes).toEqual(['practice']);
    expect(easyQuestions[0].recommendedTimeSeconds).toBe(20);
    expect(mediumQuestions[0].recommendedTimeSeconds).toBe(30);
    expect(attractionQuestion).toBeTruthy();
    expect(attractionQuestion?.correctAnswerText).toBe('North and south');
    expect(attractionQuestion?.options[attractionQuestion.correctIndex]).toBe('North and south');
  });

  it('keeps thermodynamics practice-only and keys a heat-capacity item correctly', async () => {
    const engine = new PhysicsThermodynamicsDeterministicEngine();
    const questions = await engine.generate(
      makeRequest({
        subject: 'Physics',
        topicLabel: 'Thermodynamics',
        topicPath: ['Physics', 'Thermodynamics'],
        topicPathText: 'Physics > Thermodynamics',
        difficulty: 'easy',
      }),
    );

    const heatQuestion = questions.find((question) =>
      question.prompt.includes('What happens to the temperature of an object when it gains thermal energy'),
    );

    expect(engine.supportedModes).toEqual(['practice']);
    expect(heatQuestion).toBeTruthy();
    expect(heatQuestion?.recommendedTimeSeconds).toBe(25);
    expect(heatQuestion?.correctAnswerText).toBe('It increases');
    expect(heatQuestion?.options[heatQuestion.correctIndex]).toBe('It increases');
  });

  it('keeps optics practice-only and keys the law of reflection correctly', async () => {
    const engine = new PhysicsOpticsDeterministicEngine();
    const questions = await engine.generate(
      makeRequest({
        subject: 'Physics',
        topicLabel: 'Optics',
        topicPath: ['Physics', 'Optics'],
        topicPathText: 'Physics > Optics',
        difficulty: 'easy',
      }),
    );

    const reflectionQuestion = questions.find((question) =>
      question.prompt.includes('What is the angle of reflection?'),
    );

    expect(engine.supportedModes).toEqual(['practice']);
    expect(reflectionQuestion).toBeTruthy();
    expect(reflectionQuestion?.recommendedTimeSeconds).toBe(25);
    expect(reflectionQuestion?.correctAnswerText).toBe('20°');
    expect(reflectionQuestion?.options[reflectionQuestion.correctIndex]).toBe('20°');
  });

  it('keeps circuits practice-only and keys an ohms-law current item correctly', async () => {
    const engine = new PhysicsCircuitsDeterministicEngine();
    const questions = await engine.generate(
      makeRequest({
        subject: 'Physics',
        topicLabel: 'Circuits',
        topicPath: ['Physics', 'Circuits'],
        topicPathText: 'Physics > Circuits',
        difficulty: 'easy',
      }),
    );

    const currentQuestion = questions.find((question) =>
      question.prompt.includes('A resistor of 2 Ω is connected to a 8 V battery.'),
    );

    expect(engine.supportedModes).toEqual(['practice']);
    expect(currentQuestion).toBeTruthy();
    expect(currentQuestion?.recommendedTimeSeconds).toBe(25);
    expect(currentQuestion?.correctAnswerText).toBe('4 A');
    expect(currentQuestion?.options[currentQuestion.correctIndex]).toBe('4 A');
  });

  it('filters electronics output to the requested topic and keys ohm-law values correctly', async () => {
    const engine = new ElectronicsDeterministicEngine();
    const questions = await engine.generate(
      makeRequest({
        subject: 'Electronics',
        topicLabel: 'Ohm’s Law',
        topicPath: ['Electronics', 'Ohm’s Law'],
        topicPathText: 'Electronics > Ohm’s Law',
      }),
    );

    const voltageQuestion = questions.find((question) =>
      question.prompt.includes('A resistor has resistance 6 Ω and current 2 A.'),
    );

    expect(engine.supportedModes).toEqual(['practice']);
    expect(questions.every((question) => question.topicMatchNote === 'Ohm’s Law')).toBe(true);
    expect(voltageQuestion).toBeTruthy();
    expect(voltageQuestion?.recommendedTimeSeconds).toBe(40);
    expect(voltageQuestion?.correctAnswerText).toBe('12 V');
    expect(voltageQuestion?.options[voltageQuestion.correctIndex]).toBe('12 V');
  });

  it('keeps quadratic equations practice-only and keys a known easy root correctly', async () => {
    const engine = new QuadraticDeterministicEngine();
    const [question] = await engine.generate(
      makeRequest({
        subject: 'Math',
        topicLabel: 'Quadratic equations',
        topicPath: ['Math', 'Quadratic equations'],
        topicPathText: 'Math > Quadratic equations',
        difficulty: 'easy',
        questionCount: 1,
      }),
    );

    expect(engine.supportedModes).toEqual(['practice']);
    expect(question.recommendedTimeSeconds).toBe(25);
    expect(question.prompt).toContain('1x² - 5x + 6 = 0');
    expect(question.correctAnswerText).toBe('2');
    expect(question.options[question.correctIndex]).toBe('2');
  });

  it('keeps trigonometry practice-only and keys special-angle answers correctly', async () => {
    const engine = new TrigonometryDeterministicEngine();
    const questions = await engine.generate(
      makeRequest({
        subject: 'Math',
        topicLabel: 'Trigonometry',
        topicPath: ['Math', 'Trigonometry'],
        topicPathText: 'Math > Trigonometry',
        difficulty: 'hard',
      }),
    );

    const specialAngleQuestion = questions.find((question) =>
      question.prompt.includes('Find the exact value of sin(75°).'),
    );

    expect(engine.supportedModes).toEqual(['practice']);
    expect(specialAngleQuestion).toBeTruthy();
    expect(specialAngleQuestion?.recommendedTimeSeconds).toBe(60);
    expect(specialAngleQuestion?.correctAnswerText).toBe('(√6+√2)/4');
    expect(specialAngleQuestion?.options[specialAngleQuestion.correctIndex]).toBe('(√6+√2)/4');
  });
});