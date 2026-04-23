import { PracticeService } from '../practice.service';
import { BadRequestException } from '@nestjs/common';
import { InternalServerErrorException } from '@nestjs/common';

describe('PracticeService topic integrity', () => {
  const engineRegistry = {
    generate: jest.fn(async () => null),
  };

  class TestPracticeService extends PracticeService {
    public calls: any[] = [];

    async callResponsesJson(args: any): Promise<any> {
      this.calls.push(args);

      if (args.schemaName === 'practice_questions') {
        const payload = JSON.parse(String(args.user ?? '{}'));
        if (payload.subject === 'Arabic') {
          return {
            questions: [
              {
                prompt: 'في مفردات العربية، ما المرادف الأقرب لكلمة "سريع"؟',
                options: ['عاجل', 'بطيء', 'هادئ', 'بعيد'],
                correctIndex: 0,
                correctAnswerText: 'عاجل',
                explanation: 'في مفردات العربية، كلمة "عاجل" هي الأقرب في المعنى إلى "سريع" في هذا السياق.',
                recommendedTimeSeconds: 18,
                topicMatchNote: 'Vocabulary',
              },
              {
                prompt: 'في مفردات العربية، أي كلمة تدل على معنى قريب من "جميل"؟',
                options: ['حسن', 'صعب', 'بعيد', 'ضيق'],
                correctIndex: 0,
                correctAnswerText: 'حسن',
                explanation: 'في مفردات العربية، كلمة "حسن" تحمل معنى قريبًا من "جميل".',
                recommendedTimeSeconds: 18,
                topicMatchNote: 'Vocabulary',
              },
              {
                prompt: 'في مفردات العربية، ما الكلمة الأقرب معنى إلى "قريب"؟',
                options: ['داني', 'بعيد', 'منخفض', 'متعب'],
                correctIndex: 0,
                correctAnswerText: 'داني',
                explanation: 'في مفردات العربية، كلمة "داني" تدل على القرب، لذا فهي الأقرب معنى.',
                recommendedTimeSeconds: 18,
                topicMatchNote: 'Vocabulary',
              },
            ],
          };
        }

        if (payload.topicLabel === 'Relativity') {
          return {
            questions: [
              {
                prompt: 'In special relativity, what happens to measured time for a fast-moving clock relative to a stationary observer?',
                options: ['It dilates', 'It stops completely', 'It reverses direction', 'It becomes independent of motion'],
                correctIndex: 0,
                correctAnswerText: 'It dilates',
                explanation: 'Special relativity predicts time dilation, so the moving clock is measured to run slower relative to the stationary observer.',
                recommendedTimeSeconds: 45,
                topicMatchNote: 'Relativity',
              },
              {
                prompt: 'Which quantity remains invariant for all inertial observers in special relativity?',
                options: ['The speed of light in vacuum', 'The measured length of every object', 'The simultaneity of all events', 'The mass number of any atom'],
                correctIndex: 0,
                correctAnswerText: 'The speed of light in vacuum',
                explanation: 'A central postulate of special relativity is that every inertial observer measures the same speed of light in vacuum.',
                recommendedTimeSeconds: 45,
                topicMatchNote: 'Relativity',
              },
              {
                prompt: 'What is the name of the effect in relativity where a moving object is measured shorter along the direction of motion?',
                options: ['Length contraction', 'Angular momentum', 'Thermal expansion', 'Wave interference'],
                correctIndex: 0,
                correctAnswerText: 'Length contraction',
                explanation: 'Length contraction describes the reduced measured length of an object along the direction of relative motion.',
                recommendedTimeSeconds: 45,
                topicMatchNote: 'Relativity',
              },
            ],
          };
        }

        if (payload.topicLabel === 'tuples in python') {
          return {
            questions: [
              {
                prompt:
                  'In Python, which statement about tuples is correct when working with tuple packing and unpacking?',
                options: [
                  'A tuple can be unpacked into multiple variables in Python',
                  'A tuple must always be converted to a list before reading values',
                  'A tuple can only store numbers in Python',
                  'A tuple always changes size after unpacking',
                ],
                correctIndex: 0,
                correctAnswerText:
                  'A tuple can be unpacked into multiple variables in Python',
                explanation:
                  'In Python, tuples support packing and unpacking, so a tuple like (1, 2) can be unpacked directly into variables such as a and b.',
                recommendedTimeSeconds: 30,
                topicMatchNote: 'tuples in python',
              },
            ],
          };
        }

        return {
          questions: [
            {
              prompt: 'What is the union of sets A and B?',
              options: ['Elements in A or B', 'Elements in both only', 'Elements in neither', 'Only elements in A'],
              correctIndex: 0,
              correctAnswerText: 'Elements in A or B',
              explanation: 'The union contains every element that appears in A or in B or in both.',
              recommendedTimeSeconds: 18,
              topicMatchNote: 'Set theory',
            },
            {
              prompt: 'What is the intersection of sets A and B?',
              options: ['Elements in both A and B', 'Elements only in A', 'Elements only in B', 'All subsets of A'],
              correctIndex: 0,
              correctAnswerText: 'Elements in both A and B',
              explanation: 'The intersection contains exactly the elements common to both sets.',
              recommendedTimeSeconds: 18,
              topicMatchNote: 'Set theory',
            },
            {
              prompt: 'If A = {1,2,3} and B = {2,3,4}, what is A \\ B?',
              options: ['{1}', '{4}', '{2,3}', '{1,4}'],
              correctIndex: 0,
              correctAnswerText: '{1}',
              explanation: 'A \\ B means elements in A that are not in B, so only 1 remains.',
              recommendedTimeSeconds: 18,
              topicMatchNote: 'Set theory',
            },
          ],
        };
      }

      if (args.schemaName === 'practice_verifier') {
        return {
          decisions: [
            { index: 0, verdict: 'accept', reason: 'ok' },
            { index: 1, verdict: 'accept', reason: 'ok' },
            { index: 2, verdict: 'accept', reason: 'ok' },
          ],
        };
      }

      return {};
    }
  }

  const service = new TestPracticeService(engineRegistry as any);

  beforeEach(() => {
    jest.clearAllMocks();
    service.calls = [];
    process.env.OPENAI_API_KEY = 'test-key';
  });

  it('sends exact topic fields for fallback generation', async () => {
    await service.generate({
      subject: 'Math',
      topic: 'Set theory',
      difficulty: 'medium',
      mode: 'flashcards',
      count: 3,
      timePreferenceSeconds: 18,
      useAiTiming: true,
      maxLives: 1,
    });

    const questionCall = service.calls.find((x) => x.schemaName === 'practice_questions');
    expect(questionCall).toBeTruthy();

    const payload = JSON.parse(questionCall.user);
    expect(payload.subject).toBe('Math');
    expect(payload.topicLabel).toBe('Set theory');
    expect(payload.topicPathText).toBe('Set theory');
    expect(payload.mode).toBe('flashcards');
    expect(payload.difficulty).toBe('medium');
    expect(payload.timePreferenceSeconds).toBe(18);
    expect(payload.maxLives).toBe(1);
    expect(payload.constraints.exactTopicMatch).toBe(true);
    expect(payload.constraints.noTopicDrift).toBe(true);
  });

  it('demands exact-topic wording in the system prompt', async () => {
    await service.generate({
      subject: 'Physics',
      topic: 'Relativity',
      difficulty: 'medium',
      mode: 'conceptBuilder',
      count: 3,
      timePreferenceSeconds: 45,
      useAiTiming: false,
      maxLives: 3,
    });

    const questionCall = service.calls.find((x) => x.schemaName === 'practice_questions');
    const system = String(questionCall.system);

    expect(system).toContain('Markdown and LaTeX are allowed inside JSON string fields when needed for correct rendering.');
    expect(system).toContain('Generate questions EXACTLY for the requested subject and EXACT requested topic. Do not drift.');
    expect(system).toContain('The topicLabel, topicPathText, topicPath, and strictPromptSummary are all hard constraints.');
    expect(system).toContain('If a prompt or explanation contains source code, put the code snippet in a fenced markdown code block inside the JSON string, with a language tag when obvious.');
    expect(system).toContain('If a prompt or explanation contains math notation such as \\frac, \\lim, or \\sqrt, wrap inline math in $...$ and display math in $$...$$. Do not leave raw LaTeX commands outside delimiters.');
    expect(system).toContain('topicMatchNote must be a very short phrase naming the exact requested topic only.');
    expect(system).toContain('Mode shaping: conceptBuilder must emphasize understanding, interpretation, and why/when a concept applies.');
  });

  it('sends explicit topic anchors for multi-token open-topic fallback', async () => {
    await service.generate({
      subject: 'Computer Science',
      topic: 'tuples in python',
      difficulty: 'medium',
      mode: 'practice',
      count: 1,
    });

    const questionCall = service.calls.find(
      (x) => x.schemaName === 'practice_questions',
    );
    expect(questionCall).toBeTruthy();

    const payload = JSON.parse(questionCall.user);
    expect(payload.constraints.requireBodyTopicAnchor).toBe(true);
    expect(payload.constraints.topicAnchorTokens).toEqual(['tuple', 'python']);
    expect(payload.constraints.topicAnchorMinCount).toBe(2);

    const system = String(questionCall.system);
    expect(system).toContain(
      "Open-topic anchor rule: each item's prompt or explanation must explicitly include at least 2 of these topic anchors: tuple, python.",
    );
  });

  it('sends and prompts for consistent response language on multilingual topics', async () => {
    await service.generate({
      subject: 'Arabic',
      topic: 'مفردات',
      difficulty: 'medium',
      mode: 'practice',
      count: 3,
      timePreferenceSeconds: 18,
      useAiTiming: true,
      maxLives: 3,
    });

    const questionCall = service.calls.find((x) => x.schemaName === 'practice_questions');
    expect(questionCall).toBeTruthy();

    const payload = JSON.parse(questionCall.user);
    expect(payload.responseLanguageHint).toBe('Arabic');

    const system = String(questionCall.system);
    expect(system).toContain('Write prompts, options, explanations, and topicMatchNote in Arabic when natural for the requested topic.');
  });

  it('rejects ambiguous fallback topics before calling the model when no API key is available', async () => {
    delete process.env.OPENAI_API_KEY;

    await expect(
      service.generate({
        subject: 'General Knowledge',
        topic: 'stuff',
        difficulty: 'medium',
        mode: 'practice',
        count: 3,
      }),
    ).rejects.toMatchObject({
      response: expect.objectContaining({
        reasonCode: 'TOPIC_NEEDS_CLARIFICATION',
      }),
    } satisfies Partial<BadRequestException>);

    expect(service.calls).toHaveLength(0);
  });

  it('fails cleanly for specific custom topics that require AI fallback when no API key is available', async () => {
    delete process.env.OPENAI_API_KEY;

    await expect(
      service.generate({
        subject: 'Business',
        topic: 'coffee trade routes in the 1600s',
        difficulty: 'medium',
        mode: 'practice',
        count: 1,
      }),
    ).rejects.toMatchObject({
      response: expect.objectContaining({
        reasonCode: 'UNSUPPORTED_TOPIC',
      }),
    } satisfies Partial<BadRequestException>);

    expect(service.calls).toHaveLength(0);
  });

  it('allows ambiguous custom topics to use verified AI fallback when an API key is available', async () => {
    const requestSpy = jest
      .spyOn(service as any, 'requestQuestionSet')
      .mockResolvedValue([
        {
          prompt: 'Which statement best matches the topic "stuff" as requested in this practice set?',
          options: [
            'It stays on the user-provided topic label',
            'It drifts to an unrelated catalog chapter',
            'It ignores the topic entirely',
            'It drops the topic from the session',
          ],
          correctIndex: 0,
          correctAnswerText: 'It stays on the user-provided topic label',
          explanation:
            'This item stays anchored to the requested custom topic label instead of drifting to a neighboring topic.',
          recommendedTimeSeconds: 30,
          topicMatchNote: 'stuff',
        },
      ]);
    const verifySpy = jest
      .spyOn(service as any, 'verifyQuestionSet')
      .mockResolvedValue([
        {
          prompt: 'Which statement best matches the topic "stuff" as requested in this practice set?',
          options: [
            'It stays on the user-provided topic label',
            'It drifts to an unrelated catalog chapter',
            'It ignores the topic entirely',
            'It drops the topic from the session',
          ],
          correctIndex: 0,
          correctAnswerText: 'It stays on the user-provided topic label',
          explanation:
            'This item stays anchored to the requested custom topic label instead of drifting to a neighboring topic.',
          recommendedTimeSeconds: 30,
          topicMatchNote: 'stuff',
        },
      ]);

    const res = await service.generate({
      subject: 'General Knowledge',
      topic: 'stuff',
      difficulty: 'medium',
      mode: 'practice',
      count: 1,
    });

    expect(requestSpy).toHaveBeenCalledTimes(1);
    expect(verifySpy).toHaveBeenCalledTimes(1);
    expect(res.questions).toHaveLength(1);
    expect(res.questions[0]).toMatchObject({
      subject: 'General Knowledge',
      topicLabel: 'stuff',
      mode: 'practice',
      difficulty: 'medium',
    });
  });

  it('rejects open-topic fallback items that fake the note but drift in the body', async () => {
    const requestSpy = jest
      .spyOn(service as any, 'requestQuestionSet')
      .mockResolvedValue([
        {
          prompt: 'Which CSS selector has the highest specificity in this stylesheet?',
          options: [
            'An inline style',
            'A class selector',
            'A type selector',
            'A universal selector',
          ],
          correctIndex: 0,
          correctAnswerText: 'An inline style',
          explanation:
            'CSS specificity ranks selectors so inline styles override lower-specificity rules in the cascade.',
          recommendedTimeSeconds: 30,
          topicMatchNote: 'javascript microtask starvation',
        },
      ]);
    const verifySpy = jest
      .spyOn(service as any, 'verifyQuestionSet')
      .mockResolvedValue([
        {
          prompt: 'Which CSS selector has the highest specificity in this stylesheet?',
          options: [
            'An inline style',
            'A class selector',
            'A type selector',
            'A universal selector',
          ],
          correctIndex: 0,
          correctAnswerText: 'An inline style',
          explanation:
            'CSS specificity ranks selectors so inline styles override lower-specificity rules in the cascade.',
          recommendedTimeSeconds: 30,
          topicMatchNote: 'javascript microtask starvation',
        },
      ]);

    await expect(
      service.generate({
        subject: 'Computer Science',
        topic: 'javascript microtask starvation',
        difficulty: 'medium',
        mode: 'practice',
        count: 1,
      }),
    ).rejects.toBeInstanceOf(InternalServerErrorException);

    expect(requestSpy).toHaveBeenCalledTimes(4);
    expect(verifySpy).toHaveBeenCalledTimes(0);
  });

  it('rejects single-token open-topic fallback items that fake the note but drift in the body', async () => {
    const requestSpy = jest
      .spyOn(service as any, 'requestQuestionSet')
      .mockResolvedValue([
        {
          prompt: 'Which CSS selector has the highest specificity in this stylesheet?',
          options: [
            'An inline style',
            'A class selector',
            'A type selector',
            'A universal selector',
          ],
          correctIndex: 0,
          correctAnswerText: 'An inline style',
          explanation:
            'CSS specificity ranks selectors so inline styles override lower-specificity rules in the cascade.',
          recommendedTimeSeconds: 30,
          topicMatchNote: 'microtasks',
        },
      ]);
    const verifySpy = jest
      .spyOn(service as any, 'verifyQuestionSet')
      .mockResolvedValue([
        {
          prompt: 'Which CSS selector has the highest specificity in this stylesheet?',
          options: [
            'An inline style',
            'A class selector',
            'A type selector',
            'A universal selector',
          ],
          correctIndex: 0,
          correctAnswerText: 'An inline style',
          explanation:
            'CSS specificity ranks selectors so inline styles override lower-specificity rules in the cascade.',
          recommendedTimeSeconds: 30,
          topicMatchNote: 'microtasks',
        },
      ]);

    await expect(
      service.generate({
        subject: 'Computer Science',
        topic: 'microtasks',
        difficulty: 'medium',
        mode: 'practice',
        count: 1,
      }),
    ).rejects.toBeInstanceOf(InternalServerErrorException);

    expect(requestSpy).toHaveBeenCalledTimes(4);
    expect(verifySpy).toHaveBeenCalledTimes(0);
  });

  it('rejects multi-token open-topic fallback items that only anchor one token in the body', async () => {
    const requestSpy = jest
      .spyOn(service as any, 'requestQuestionSet')
      .mockResolvedValue([
        {
          prompt: 'In Python, which method creates a copy of a list?',
          options: [
            'copy()',
            'clone()',
            'duplicate()',
            'fork()',
          ],
          correctIndex: 0,
          correctAnswerText: 'copy()',
          explanation:
            'In Python, list.copy() creates a shallow copy of the list.',
          recommendedTimeSeconds: 30,
          topicMatchNote: 'tuples in python',
        },
      ]);
    const verifySpy = jest
      .spyOn(service as any, 'verifyQuestionSet')
      .mockResolvedValue([
        {
          prompt: 'In Python, which method creates a copy of a list?',
          options: [
            'copy()',
            'clone()',
            'duplicate()',
            'fork()',
          ],
          correctIndex: 0,
          correctAnswerText: 'copy()',
          explanation:
            'In Python, list.copy() creates a shallow copy of the list.',
          recommendedTimeSeconds: 30,
          topicMatchNote: 'tuples in python',
        },
      ]);

    await expect(
      service.generate({
        subject: 'Computer Science',
        topic: 'tuples in python',
        difficulty: 'medium',
        mode: 'practice',
        count: 1,
      }),
    ).rejects.toBeInstanceOf(InternalServerErrorException);

    expect(requestSpy).toHaveBeenCalledTimes(4);
    expect(verifySpy).toHaveBeenCalledTimes(0);
  });

  it('accepts long custom topics when the body keeps the strongest anchors', async () => {
    const requestSpy = jest
      .spyOn(service as any, 'requestQuestionSet')
      .mockResolvedValue([
        {
          prompt:
            'What does this Python recursion trace show about the stopping condition? ```python\ndef f(n):\n    if n == 0:\n        return 1\n    return n * f(n-1)\n```',
          options: [
            'The recursion stops at a base case',
            'The recursion never terminates',
            'Python removes recursive calls before execution',
            'The function becomes iterative automatically',
          ],
          correctIndex: 0,
          correctAnswerText: 'The recursion stops at a base case',
          explanation:
            'In Python recursion, the base case ends the recursive chain before the stack unwinds.',
          recommendedTimeSeconds: 35,
          topicMatchNote: 'python recursion base case confusion',
        },
      ]);
    const verifySpy = jest
      .spyOn(service as any, 'verifyQuestionSet')
      .mockResolvedValue([
        {
          prompt:
            'What does this Python recursion trace show about the stopping condition? ```python\ndef f(n):\n    if n == 0:\n        return 1\n    return n * f(n-1)\n```',
          options: [
            'The recursion stops at a base case',
            'The recursion never terminates',
            'Python removes recursive calls before execution',
            'The function becomes iterative automatically',
          ],
          correctIndex: 0,
          correctAnswerText: 'The recursion stops at a base case',
          explanation:
            'In Python recursion, the base case ends the recursive chain before the stack unwinds.',
          recommendedTimeSeconds: 35,
          topicMatchNote: 'python recursion base case confusion',
        },
      ]);

    const res = await service.generate({
      subject: 'Computer Science',
      topic: 'python recursion base case confusion',
      difficulty: 'medium',
      mode: 'practice',
      count: 1,
    });

    expect(requestSpy).toHaveBeenCalledTimes(1);
    expect(verifySpy).toHaveBeenCalledTimes(1);
    expect(res.questions).toHaveLength(1);
    expect(res.questions[0]).toMatchObject({
      subject: 'Computer Science',
      topicLabel: 'python recursion base case confusion',
      mode: 'practice',
      difficulty: 'medium',
    });
  });
});
