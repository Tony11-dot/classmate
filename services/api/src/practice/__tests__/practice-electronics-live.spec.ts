import { Test } from '@nestjs/testing';
import { PracticeModule } from '../practice.module';
import { PracticeService } from '../practice.service';

describe('practice electronics live', () => {
  it('routes Electronics subject into deterministic engine', async () => {
    const mod = await Test.createTestingModule({
      imports: [PracticeModule],
    }).compile();

    const service = mod.get(PracticeService);
    const res = await service.generate({
      subject: 'Electronics',
      topicLabel: 'Ohm’s Law',
      topicPathText: 'Electronics > Ohm’s Law',
      mode: 'practice',
      difficulty: 'medium',
      questionCount: 3,
      count: 3,
      timePreferenceSeconds: 35,
      useAiTiming: true,
      maxLives: 2,
    } as any);

    expect(Array.isArray(res.questions)).toBe(true);
    expect(res.questions).toHaveLength(3);
    expect(res.questions.every((q: any) => q.subject === 'Electronics')).toBe(true);
  });
});
