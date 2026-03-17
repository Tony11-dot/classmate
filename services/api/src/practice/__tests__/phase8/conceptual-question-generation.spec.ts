import { Test } from '@nestjs/testing';
import { PracticeModule } from '../../practice.module';
import { PracticeService } from '../../practice.service';

describe('PHASE 8 — conceptual/custom generation', () => {
  it('returns real questions for Big O notation', async () => {
    const mod = await Test.createTestingModule({
      imports: [PracticeModule],
    }).compile();

    const service = mod.get(PracticeService);

    const res = await service.generate({
      subject: 'Computer Science',
      topicLabel: 'Big O notation',
      mode: 'practice',
      difficulty: 'medium',
      questionCount: 2,
      useAiTiming: true,
      maxLives: 3,
    } as any);

    expect(res.questions).toHaveLength(2);
    expect(res.conceptual.ready).toBe(true);
    expect(res.conceptual.gaps).toEqual([]);
  });

  it('returns real questions for music theory', async () => {
    const mod = await Test.createTestingModule({
      imports: [PracticeModule],
    }).compile();

    const service = mod.get(PracticeService);

    const res = await service.generate({
      subject: 'General Knowledge',
      topicLabel: 'music theory',
      mode: 'practice',
      difficulty: 'medium',
      questionCount: 2,
      useAiTiming: true,
      maxLives: 3,
    } as any);

    expect(res.questions).toHaveLength(2);
    expect(res.conceptual.ready).toBe(true);
  });

  it('returns real questions for conditional statements', async () => {
    const mod = await Test.createTestingModule({
      imports: [PracticeModule],
    }).compile();

    const service = mod.get(PracticeService);

    const res = await service.generate({
      subject: 'Computer Science',
      topicLabel: 'conditional statements',
      mode: 'practice',
      difficulty: 'medium',
      questionCount: 2,
      useAiTiming: true,
      maxLives: 3,
    } as any);

    expect(res.questions).toHaveLength(2);
    expect(res.conceptual.ready).toBe(true);
  });

  it('fails honestly for broad conceptual prompts', async () => {
    const mod = await Test.createTestingModule({
      imports: [PracticeModule],
    }).compile();

    const service = mod.get(PracticeService);

    const res = await service.generate({
      subject: 'General Knowledge',
      topicLabel: 'music',
      mode: 'practice',
      difficulty: 'medium',
      questionCount: 2,
      useAiTiming: true,
      maxLives: 3,
    } as any);

    expect(res.questions).toEqual([]);
    expect(res.conceptual.ready).toBe(false);
    expect(res.conceptual.gaps).toContain('broad_conceptual_topic');
  });
});
