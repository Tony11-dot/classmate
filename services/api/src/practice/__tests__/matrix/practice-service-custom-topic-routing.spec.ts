import { Test, TestingModule } from '@nestjs/testing';
import { PracticeModule } from '../../practice.module';
import { PracticeService } from '../../practice.service';

const CUSTOM_TOPIC_CASES = [
  {
    subject: 'English',
    topicLabel: 'reading comprehension passages about climate',
    expectedSubject: 'English',
    expectedTopicLabel: 'Reading Comprehension',
  },
  {
    subject: 'Biology',
    topicLabel: 'dna and genetics basics',
    expectedSubject: 'Biology',
    expectedTopicLabel: 'Genetics',
  },
  {
    subject: 'Physics',
    topicLabel: 'laws of thermodynamics and heat transfer',
    expectedSubject: 'Physics',
    expectedTopicLabel: 'Thermodynamics',
  },
  {
    subject: 'General Knowledge',
    topicLabel: 'reflection and refraction basics',
    expectedSubject: 'Physics',
    expectedTopicLabel: 'Optics',
  },
  {
    subject: 'Computer Science',
    topicLabel: 'if else branching practice',
    expectedSubject: 'Computer Science',
    expectedTopicLabel: 'If / Else',
  },
  {
    subject: 'Computer Science',
    topicLabel: 'time complexity of loops',
    expectedSubject: 'Computer Science',
        expectedTopicLabel: 'Big O',
  },
  {
    subject: 'Math',
    topicLabel: 'quadratics word problems',
    expectedSubject: 'Math',
    expectedTopicLabel: 'Quadratic equations',
  },
  {
    subject: 'Math',
    topicLabel: 'median and mean practice',
    expectedSubject: 'Math',
    expectedTopicLabel: 'Statistics',
  },
  {
    subject: 'General Knowledge',
    topicLabel: 'periodic table trends',
    expectedSubject: 'Chemistry',
    expectedTopicLabel: 'Periodic Table',
  },
] as const;

describe('practice service custom topic routing', () => {
  let mod: TestingModule;
  let service: PracticeService;

  beforeAll(async () => {
    mod = await Test.createTestingModule({
      imports: [PracticeModule],
    }).compile();

    service = mod.get(PracticeService);
  });

  afterAll(async () => {
    await mod.close();
  });

  it(
    'routes phrase-style custom prompts to deterministic owned topics without AI fallback',
    async () => {
      const requestSpy = jest.spyOn(service as any, 'requestQuestionSet');
      const verifySpy = jest.spyOn(service as any, 'verifyQuestionSet');

      for (const item of CUSTOM_TOPIC_CASES) {
        const res = await service.generate({
          subject: item.subject,
          topicLabel: item.topicLabel,
          topicPathText: item.topicLabel,
          mode: 'practice',
          difficulty: 'medium',
          questionCount: 2,
          count: 2,
          useAiTiming: true,
          maxLives: 3,
        } as any);

        expect(res.questions).toHaveLength(2);
        expect(
          res.questions.every((q: any) => q.subject === item.expectedSubject),
        ).toBe(true);
        expect(
          res.questions.every((q: any) => q.topicLabel === item.expectedTopicLabel),
        ).toBe(true);
      }

      expect(requestSpy).not.toHaveBeenCalled();
      expect(verifySpy).not.toHaveBeenCalled();
    },
    30000,
  );

  it(
    'keeps strong custom prompts on deterministic routing even outside practice mode',
    async () => {
      const requestSpy = jest.spyOn(service as any, 'requestQuestionSet');
      const verifySpy = jest.spyOn(service as any, 'verifyQuestionSet');
      const cases = [
        {
          subject: 'General Knowledge',
          topicLabel: 'periodic table trends',
          topicPathText: 'periodic table trends',
          mode: 'flashcards',
          expectedSubject: 'Chemistry',
          expectedTopicLabel: 'Periodic Table',
        },
        {
          subject: 'Math',
          topicLabel: 'quadratics word problems',
          topicPathText: 'quadratics word problems',
          mode: 'examPrep',
          expectedSubject: 'Math',
          expectedTopicLabel: 'Quadratic equations',
        },
      ];

      for (const item of cases) {
        const res = await service.generate({
          ...item,
          difficulty: 'medium',
          questionCount: 2,
          count: 2,
          useAiTiming: true,
          maxLives: 3,
        } as any);

        expect(res.questions).toHaveLength(2);
        expect(
          res.questions.every((q: any) => q.subject === item.expectedSubject),
        ).toBe(true);
        expect(
          res.questions.every((q: any) => q.topicLabel === item.expectedTopicLabel),
        ).toBe(true);
        expect(res.questions.every((q: any) => q.mode === item.mode)).toBe(true);
      }

      expect(requestSpy).not.toHaveBeenCalled();
      expect(verifySpy).not.toHaveBeenCalled();
    },
    30000,
  );
});