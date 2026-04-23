import { PracticeEngineRegistry } from '../practice-engine.registry';
import type { PracticeEngine } from '../practice-engine.interface';
import type { GeneratedQuestion, PracticeEngineRequest } from '../practice-engine.types';

function makeQuestion(topicMatchNote: string): GeneratedQuestion {
  return {
    prompt: `Question about ${topicMatchNote}`,
    options: ['A', 'B', 'C', 'D'],
    correctIndex: 0,
    correctAnswerText: 'A',
    explanation: `Explanation about ${topicMatchNote}`,
    recommendedTimeSeconds: 30,
    topicMatchNote,
  };
}

function makeRequest(
  overrides: Partial<PracticeEngineRequest>,
): PracticeEngineRequest {
  return {
    subject: 'Math',
    topicLabel: 'Polynomials',
    topicPath: ['Math', 'Polynomials'],
    topicPathText: 'Math > Polynomials',
    strictPromptSummary: '',
    questionCount: 2,
    mode: 'practice',
    difficulty: 'medium',
    timePreferenceSeconds: null,
    useAiTiming: true,
    maxLives: 3,
    ...overrides,
  };
}

function makeRegistry(args: {
  polynomials?: PracticeEngine;
  setTheory?: PracticeEngine;
}) {
  const noop: PracticeEngine = {
    supports: () => false,
    generate: async () => [],
  };

  return new PracticeEngineRegistry(
    noop as any,
    noop as any,
    noop as any,
    noop as any,
    noop as any,
    noop as any,
    noop as any,
    noop as any,
    noop as any,
    noop as any,
    noop as any,
    (args.polynomials ?? noop) as any,
    (args.setTheory ?? noop) as any,
    noop as any,
    noop as any,
    noop as any,
    noop as any,
    noop as any,
    noop as any,
    noop as any,
    noop as any,
    noop as any,
    noop as any,
    noop as any,
    noop as any,
    noop as any,
    noop as any,
    noop as any,
  );
}

describe('PracticeEngineRegistry mode gating', () => {
  it('skips practice-only deterministic engines for non-practice modes', async () => {
    const setTheoryGenerate = jest.fn(async () => [makeQuestion('Set theory')]);
    const setTheoryEngine: PracticeEngine = {
      supports: () => true,
      generate: setTheoryGenerate,
    };

    const registry = makeRegistry({ setTheory: setTheoryEngine });

    const res = await registry.generate(
      makeRequest({
        topicLabel: 'Set theory',
        topicPath: ['Math', 'Set theory'],
        topicPathText: 'Math > Set theory',
        mode: 'flashcards',
      }),
    );

    expect(setTheoryGenerate).not.toHaveBeenCalled();
    expect(res).toBeNull();
  });

  it('allows deterministic engines that explicitly support examPrep', async () => {
    const polynomialQuestions = [makeQuestion('Polynomials'), makeQuestion('Polynomials')];
    const polynomialGenerate = jest.fn(async () => polynomialQuestions);
    const polynomialsEngine: PracticeEngine = {
      supportedModes: ['practice', 'examPrep'],
      supports: () => true,
      generate: polynomialGenerate,
    };

    const registry = makeRegistry({ polynomials: polynomialsEngine });

    const res = await registry.generate(
      makeRequest({
        mode: 'examPrep',
        difficulty: 'hard',
      }),
    );

    expect(polynomialGenerate).toHaveBeenCalledTimes(1);
    expect(res).toHaveLength(2);
    expect(res?.every((question) => question.topicMatchNote === 'Polynomials')).toBe(true);
  });
});