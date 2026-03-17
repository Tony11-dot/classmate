import { Test } from '@nestjs/testing';
import { PracticeModule } from '../../practice.module';
import { PracticeService } from '../../practice.service';

describe('PHASE 9 — symbolic question generation', () => {
  it('returns real questions for derivatives', async () => {
    const mod = await Test.createTestingModule({
      imports: [PracticeModule],
    }).compile();

    const service = mod.get(PracticeService);

    const res = await service.generate({
      subject: 'Math',
      topicLabel: 'derivatives',
      mode: 'practice',
      difficulty: 'medium',
      questionCount: 2,
      useAiTiming: true,
      maxLives: 3,
    } as any);

    expect(res.questions).toHaveLength(2);
    expect(res.symbolic.ready).toBe(true);
    expect(res.symbolic.gaps).toEqual([]);
  });

  it('returns real questions for limits', async () => {
    const mod = await Test.createTestingModule({
      imports: [PracticeModule],
    }).compile();

    const service = mod.get(PracticeService);

    const res = await service.generate({
      subject: 'Math',
      topicLabel: 'limits',
      mode: 'practice',
      difficulty: 'medium',
      questionCount: 2,
      useAiTiming: true,
      maxLives: 3,
    } as any);

    expect(res.questions).toHaveLength(2);
    expect(res.symbolic.ready).toBe(true);
    expect(res.symbolic.gaps).toEqual([]);
  });

  it('fails honestly for unsupported symbolic topics', async () => {
    const mod = await Test.createTestingModule({
      imports: [PracticeModule],
    }).compile();

    const service = mod.get(PracticeService);

    const res = await service.generate({
      subject: 'Math',
      topicLabel: 'tensor calculus',
      mode: 'practice',
      difficulty: 'medium',
      questionCount: 2,
      useAiTiming: true,
      maxLives: 3,
    } as any);

    expect(res.questions).toEqual([]);
    expect(res.symbolic.ready).toBe(false);
    expect(res.symbolic.gaps.length).toBeGreaterThan(0);
  });
});
