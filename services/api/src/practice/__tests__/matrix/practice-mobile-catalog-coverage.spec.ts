import { Test } from '@nestjs/testing';
import { PracticeModule } from '../../practice.module';
import { PracticeEngineRegistry } from '../../engine/practice-engine.registry';

const MOBILE_CATALOG_CASES = [
  { subject: 'Math', topicLabel: 'Algebra' },
  { subject: 'Math', topicLabel: 'Functions' },
  { subject: 'Math', topicLabel: 'Linear Equations' },
  { subject: 'Math', topicLabel: 'Quadratic Equations' },
  { subject: 'Math', topicLabel: 'Inequalities' },
  { subject: 'Math', topicLabel: 'Geometry' },
  { subject: 'Math', topicLabel: 'Trigonometry' },
  { subject: 'Math', topicLabel: 'Probability' },
  { subject: 'Math', topicLabel: 'Statistics' },
  { subject: 'Math', topicLabel: 'Sequences' },
  { subject: 'Physics', topicLabel: 'Mechanics' },
  { subject: 'Physics', topicLabel: 'Speed and Velocity' },
  { subject: 'Physics', topicLabel: 'Acceleration' },
  { subject: 'Physics', topicLabel: 'Newton Laws' },
  { subject: 'Physics', topicLabel: 'Forces' },
  { subject: 'Physics', topicLabel: 'Energy' },
  { subject: 'Physics', topicLabel: 'Momentum' },
  { subject: 'Physics', topicLabel: 'Electricity' },
  { subject: 'Physics', topicLabel: 'Electrostatics' },
  { subject: 'Physics', topicLabel: 'Waves' },
  { subject: 'Computer Science', topicLabel: 'Conditions' },
  { subject: 'Computer Science', topicLabel: 'If / Else' },
  { subject: 'Computer Science', topicLabel: 'Nested Conditions' },
  { subject: 'Computer Science', topicLabel: 'Boolean Logic' },
  { subject: 'Computer Science', topicLabel: 'Loops' },
  { subject: 'Computer Science', topicLabel: 'Functions' },
  { subject: 'Computer Science', topicLabel: 'Arrays' },
  { subject: 'Computer Science', topicLabel: 'Strings' },
  { subject: 'Computer Science', topicLabel: 'Variables' },
  { subject: 'Computer Science', topicLabel: 'Algorithms' },
  { subject: 'Chemistry', topicLabel: 'Atoms and Elements' },
  { subject: 'Chemistry', topicLabel: 'Periodic Table' },
  { subject: 'Chemistry', topicLabel: 'Chemical Bonds' },
  { subject: 'Chemistry', topicLabel: 'Reactions' },
  { subject: 'Chemistry', topicLabel: 'Stoichiometry' },
  { subject: 'Chemistry', topicLabel: 'Acids and Bases' },
  { subject: 'Biology', topicLabel: 'Cells' },
  { subject: 'Biology', topicLabel: 'Genetics' },
  { subject: 'Biology', topicLabel: 'Ecology' },
  { subject: 'Biology', topicLabel: 'Human Body' },
  { subject: 'Biology', topicLabel: 'Photosynthesis' },
  { subject: 'English', topicLabel: 'Grammar' },
  { subject: 'English', topicLabel: 'Tenses' },
  { subject: 'English', topicLabel: 'Vocabulary' },
  { subject: 'English', topicLabel: 'Reading Comprehension' },
  { subject: 'English', topicLabel: 'Conditionals' },
  { subject: 'Arabic', topicLabel: 'Grammar' },
  { subject: 'Arabic', topicLabel: 'Reading' },
  { subject: 'Arabic', topicLabel: 'Vocabulary' },
  { subject: 'Arabic', topicLabel: 'Comprehension' },
  { subject: 'Arabic', topicLabel: 'Writing' },
  { subject: 'Hebrew', topicLabel: 'Grammar' },
  { subject: 'Hebrew', topicLabel: 'Reading' },
  { subject: 'Hebrew', topicLabel: 'Vocabulary' },
  { subject: 'Hebrew', topicLabel: 'Comprehension' },
  { subject: 'Hebrew', topicLabel: 'Writing' },
] as const;

describe('practice mobile catalog deterministic coverage', () => {
  it(
    'returns deterministic questions for every in-app catalog topic',
    async () => {
      const mod = await Test.createTestingModule({
        imports: [PracticeModule],
      }).compile();

      const registry = mod.get(PracticeEngineRegistry);

      for (const item of MOBILE_CATALOG_CASES) {
        const questions = await registry.generate({
          subject: item.subject,
          topicLabel: item.topicLabel,
          topicPath: [],
          topicPathText: item.topicLabel,
          strictPromptSummary: '',
          questionCount: 2,
          mode: 'practice',
          difficulty: 'medium',
          timePreferenceSeconds: 30,
          useAiTiming: true,
          maxLives: 3,
        });

        if (!Array.isArray(questions) || questions.length === 0) {
          throw new Error(
            `Missing deterministic coverage for ${item.subject} :: ${item.topicLabel}`,
          );
        }
      }
    },
    30000,
  );
});