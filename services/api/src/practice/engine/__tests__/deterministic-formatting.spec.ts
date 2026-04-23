import { BroadCatalogDeterministicEngine } from '../broad-catalog-deterministic.engine';
import { FunctionsDeterministicEngine } from '../functions-deterministic.engine';
import { LimitsDeterministicEngine } from '../limits-deterministic.engine';
import type { PracticeEngineRequest } from '../practice-engine.types';

function makeRequest(overrides: Partial<PracticeEngineRequest>): PracticeEngineRequest {
  return {
    subject: 'Computer Science',
    topicLabel: 'Nested Conditions',
    topicPath: ['Conditions', 'Nested Conditions'],
    topicPathText: 'Conditions · Nested Conditions',
    strictPromptSummary: 'Use the requested topic exactly.',
    questionCount: 1,
    mode: 'practice',
    difficulty: 'medium',
    timePreferenceSeconds: null,
    useAiTiming: true,
    maxLives: 3,
    ...overrides,
  };
}

describe('deterministic engine formatting', () => {
  it('emits C# fenced code for nested conditions when the request asks for c#', async () => {
    const engine = new BroadCatalogDeterministicEngine();
    const [question] = await engine.generate(
      makeRequest({
        topicLabel: 'Nested Conditions C#',
        topicPathText: 'Conditions · Nested Conditions C#',
        strictPromptSummary: 'Generate the code in c#.',
      }),
    );

    expect(question.prompt).toContain('```csharp');
    expect(question.prompt).toContain('Console.WriteLine("A");');
    expect(question.topicMatchNote).toBe('Nested Conditions C#');
  });

  it('recovers python fences from common custom-topic typos', async () => {
    const engine = new BroadCatalogDeterministicEngine();
    const [question] = await engine.generate(
      makeRequest({
        topicLabel: 'Nested Conditions',
        topicPathText: 'Conditions · Nested conditions in pyhon',
        strictPromptSummary:
          'STRICT_FILTER_SECTION_DO_NOT_IGNORE\n\nTopic: Conditions > Nested conditions in pyhon',
      }),
    );

    expect(question.prompt).toContain('```python');
    expect(question.prompt).toContain('print("A")');
    expect(question.topicMatchNote).toBe('Nested Conditions');
  });

  it('emits inline LaTeX delimiters for deterministic limits prompts', async () => {
    const engine = new LimitsDeterministicEngine();
    const [question] = await engine.generate(
      makeRequest({
        subject: 'Math',
        topicLabel: 'Limits',
        topicPath: ['Calculus', 'Limits'],
        topicPathText: 'Calculus · Limits',
        difficulty: 'easy',
      }),
    );

    expect(question.prompt).toContain('$\\lim_{x \\to');
    expect(question.prompt).toContain('$.');
    expect(question.prompt).not.toContain('\\\\\\lim');
    expect(question.prompt).not.toContain('\\.');
  });

  it('supports broad-catalog non-practice modes so deterministic formatting is preserved', () => {
    const engine = new BroadCatalogDeterministicEngine();

    expect(
      engine.supports(
        makeRequest({
          subject: 'English',
          topicLabel: 'Vocabulary',
          topicPath: ['Vocabulary'],
          topicPathText: 'Vocabulary',
          mode: 'flashcards',
        }),
      ),
    ).toBe(true);

    expect(
      engine.supports(
        makeRequest({
          subject: 'English',
          topicLabel: 'Vocabulary',
          topicPath: ['Vocabulary'],
          topicPathText: 'Vocabulary',
          mode: 'practice',
        }),
      ),
    ).toBe(true);
  });

  it('keeps four unique options in deterministic functions output when distractors collide', async () => {
    const engine = new FunctionsDeterministicEngine();
    const [question] = await engine.generate(
      makeRequest({
        subject: 'Math',
        topicLabel: 'Functions',
        topicPath: ['Algebra', 'Functions'],
        topicPathText: 'Algebra · Functions',
        difficulty: 'easy',
        questionCount: 1,
      }),
    );

    expect(question.options).toHaveLength(4);
    expect(new Set(question.options).size).toBe(4);
    expect(question.options).toContain(question.correctAnswerText);
  });
});