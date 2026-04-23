import { Test, TestingModule } from '@nestjs/testing';
import { PracticeModule } from '../../practice.module';
import { PracticeService } from '../../practice.service';

const MOBILE_CATALOG_SERVICE_CASES = [
  { subject: 'Math', topicLabel: 'Algebra', expectedTopicLabel: 'Algebra' },
  { subject: 'Math', topicLabel: 'Functions', expectedTopicLabel: 'Functions' },
  { subject: 'Math', topicLabel: 'Linear Equations', expectedTopicLabel: 'Linear equations' },
  { subject: 'Math', topicLabel: 'Quadratic Equations', expectedTopicLabel: 'Quadratic equations' },
  { subject: 'Math', topicLabel: 'Inequalities', expectedTopicLabel: 'Inequalities' },
  { subject: 'Math', topicLabel: 'Geometry', expectedTopicLabel: 'Geometry' },
  { subject: 'Math', topicLabel: 'Trigonometry', expectedTopicLabel: 'Trigonometry' },
  { subject: 'Math', topicLabel: 'Probability', expectedTopicLabel: 'Probability' },
  { subject: 'Math', topicLabel: 'Statistics', expectedTopicLabel: 'Statistics' },
  { subject: 'Math', topicLabel: 'Sequences', expectedTopicLabel: 'Sequences' },
  { subject: 'Physics', topicLabel: 'Mechanics', expectedTopicLabel: 'Mechanics' },
  { subject: 'Physics', topicLabel: 'Speed and Velocity', expectedTopicLabel: 'Kinematics' },
  { subject: 'Physics', topicLabel: 'Acceleration', expectedTopicLabel: 'Kinematics' },
  { subject: 'Physics', topicLabel: 'Newton Laws', expectedTopicLabel: 'Newton laws' },
  { subject: 'Physics', topicLabel: 'Forces', expectedTopicLabel: 'Forces' },
  { subject: 'Physics', topicLabel: 'Energy', expectedTopicLabel: 'Energy' },
  { subject: 'Physics', topicLabel: 'Momentum', expectedTopicLabel: 'Momentum' },
  { subject: 'Physics', topicLabel: 'Electricity', expectedTopicLabel: 'Electricity' },
  { subject: 'Physics', topicLabel: 'Electrostatics', expectedTopicLabel: 'Electric field' },
  { subject: 'Physics', topicLabel: 'Waves', expectedTopicLabel: 'Waves' },
  { subject: 'Computer Science', topicLabel: 'Conditions', expectedTopicLabel: 'Conditions' },
  { subject: 'Computer Science', topicLabel: 'If / Else', expectedTopicLabel: 'If / Else' },
  { subject: 'Computer Science', topicLabel: 'Nested Conditions', expectedTopicLabel: 'Nested Conditions' },
  { subject: 'Computer Science', topicLabel: 'Boolean Logic', expectedTopicLabel: 'Boolean Logic' },
  { subject: 'Computer Science', topicLabel: 'Loops', expectedTopicLabel: 'Loops' },
  { subject: 'Computer Science', topicLabel: 'Functions', expectedTopicLabel: 'Functions' },
  { subject: 'Computer Science', topicLabel: 'Arrays', expectedTopicLabel: 'Arrays' },
  { subject: 'Computer Science', topicLabel: 'Strings', expectedTopicLabel: 'Strings' },
  { subject: 'Computer Science', topicLabel: 'Variables', expectedTopicLabel: 'Variables' },
  { subject: 'Computer Science', topicLabel: 'Algorithms', expectedTopicLabel: 'Algorithms' },
  { subject: 'Chemistry', topicLabel: 'Atoms and Elements', expectedTopicLabel: 'Atoms and Elements' },
  { subject: 'Chemistry', topicLabel: 'Periodic Table', expectedTopicLabel: 'Periodic Table' },
  { subject: 'Chemistry', topicLabel: 'Chemical Bonds', expectedTopicLabel: 'Chemical Bonds' },
  { subject: 'Chemistry', topicLabel: 'Reactions', expectedTopicLabel: 'Reactions' },
  { subject: 'Chemistry', topicLabel: 'Stoichiometry', expectedTopicLabel: 'Stoichiometry' },
  { subject: 'Chemistry', topicLabel: 'Acids and Bases', expectedTopicLabel: 'Acids and Bases' },
  { subject: 'Biology', topicLabel: 'Cells', expectedTopicLabel: 'Cells' },
  { subject: 'Biology', topicLabel: 'Genetics', expectedTopicLabel: 'Genetics' },
  { subject: 'Biology', topicLabel: 'Ecology', expectedTopicLabel: 'Ecology' },
  { subject: 'Biology', topicLabel: 'Human Body', expectedTopicLabel: 'Human Body' },
  { subject: 'Biology', topicLabel: 'Photosynthesis', expectedTopicLabel: 'Photosynthesis' },
  { subject: 'English', topicLabel: 'Grammar', expectedTopicLabel: 'Grammar' },
  { subject: 'English', topicLabel: 'Tenses', expectedTopicLabel: 'Tenses' },
  { subject: 'English', topicLabel: 'Vocabulary', expectedTopicLabel: 'Vocabulary' },
  { subject: 'English', topicLabel: 'Reading Comprehension', expectedTopicLabel: 'Reading Comprehension' },
  { subject: 'English', topicLabel: 'Conditionals', expectedTopicLabel: 'Conditionals' },
  { subject: 'Arabic', topicLabel: 'Grammar', expectedTopicLabel: 'Grammar' },
  { subject: 'Arabic', topicLabel: 'Reading', expectedTopicLabel: 'Reading' },
  { subject: 'Arabic', topicLabel: 'Vocabulary', expectedTopicLabel: 'Vocabulary' },
  { subject: 'Arabic', topicLabel: 'Comprehension', expectedTopicLabel: 'Comprehension' },
  { subject: 'Arabic', topicLabel: 'Writing', expectedTopicLabel: 'Writing' },
  { subject: 'Hebrew', topicLabel: 'Grammar', expectedTopicLabel: 'Grammar' },
  { subject: 'Hebrew', topicLabel: 'Reading', expectedTopicLabel: 'Reading' },
  { subject: 'Hebrew', topicLabel: 'Vocabulary', expectedTopicLabel: 'Vocabulary' },
  { subject: 'Hebrew', topicLabel: 'Comprehension', expectedTopicLabel: 'Comprehension' },
  { subject: 'Hebrew', topicLabel: 'Writing', expectedTopicLabel: 'Writing' },
] as const;

describe('practice service no-fallback catalog routing', () => {
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
    'keeps every mobile catalog topic on deterministic routing through PracticeService.generate',
    async () => {
      const requestSpy = jest.spyOn(service as any, 'requestQuestionSet');
      const verifySpy = jest.spyOn(service as any, 'verifyQuestionSet');

      for (const item of MOBILE_CATALOG_SERVICE_CASES) {
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
        expect(res.questions.every((q: any) => q.subject === item.subject)).toBe(true);
        expect(
          res.questions.every(
            (q: any) => q.topicLabel === item.expectedTopicLabel,
          ),
        ).toBe(true);
        expect(
          res.questions.every(
            (q: any) =>
              Array.isArray(q.options) &&
              q.options.length === 4 &&
              Number.isInteger(q.correctIndex) &&
              q.correctIndex >= 0 &&
              q.correctIndex < 4,
          ),
        ).toBe(true);
      }

      expect(requestSpy).not.toHaveBeenCalled();
      expect(verifySpy).not.toHaveBeenCalled();
    },
    30000,
  );
});