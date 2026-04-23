import { PolynomialsDeterministicEngine } from '../polynomials-deterministic.engine';
import type { PracticeEngineRequest } from '../practice-engine.types';

function makeRequest(
  overrides: Partial<PracticeEngineRequest> = {},
): PracticeEngineRequest {
  return {
    subject: 'Math',
    topicLabel: 'Polynomials',
    topicPath: ['Math', 'Polynomials'],
    topicPathText: 'Math > Polynomials',
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

describe('PolynomialsDeterministicEngine', () => {
  it('declares practice and examPrep as its supported modes', () => {
    const engine = new PolynomialsDeterministicEngine();

    expect(engine.supportedModes).toEqual(['practice', 'examPrep']);
  });

  it('uses longer default timing for examPrep than practice', async () => {
    const engine = new PolynomialsDeterministicEngine();

    const [practiceQuestion] = await engine.generate(
      makeRequest({ mode: 'practice', questionCount: 1 }),
    );
    const [examPrepQuestion] = await engine.generate(
      makeRequest({ mode: 'examPrep', questionCount: 1, difficulty: 'hard' }),
    );

    expect(practiceQuestion.recommendedTimeSeconds).toBe(45);
    expect(examPrepQuestion.recommendedTimeSeconds).toBe(75);
  });

  it('keys the polynomial evaluation item correctly', async () => {
    const engine = new PolynomialsDeterministicEngine();
    const questions = await engine.generate(makeRequest());
    const evaluationQuestion = questions.find((question) =>
      question.prompt.includes('What is P(2) if P(x) = x^2 - 3x + 4?'),
    );

    expect(evaluationQuestion).toBeTruthy();
    expect(evaluationQuestion?.correctAnswerText).toBe('2');
    expect(evaluationQuestion?.options[evaluationQuestion.correctIndex]).toBe('2');
    expect(evaluationQuestion?.explanation).toContain('= 2.');
  });
});