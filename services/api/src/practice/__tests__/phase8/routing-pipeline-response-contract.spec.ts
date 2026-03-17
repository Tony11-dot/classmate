import { Test } from '@nestjs/testing';
import { PracticeModule } from '../../practice.module';
import { PracticeService } from '../../practice.service';

describe('PHASE 8 — routing pipeline response contract', () => {
  it('keeps deterministic response contract intact', async () => {
    const mod = await Test.createTestingModule({
      imports: [PracticeModule],
    }).compile();

    const service = mod.get(PracticeService);

    const res = await service.generate({
      subject: 'Physics',
      topicLabel: 'motion',
      mode: 'practice',
      difficulty: 'medium',
      questionCount: 1,
    } as any);

    expect(res.questions).toHaveLength(1);
    expect(typeof res.questions[0].prompt).toBe('string');
    expect(res.questions[0].options).toHaveLength(4);
  });

  it('keeps conceptual response contract intact', async () => {
    const mod = await Test.createTestingModule({
      imports: [PracticeModule],
    }).compile();

    const service = mod.get(PracticeService);

    const res = await service.generate({
      subject: 'Computer Science',
      topicLabel: 'Big O notation',
      mode: 'practice',
      difficulty: 'medium',
      questionCount: 1,
    } as any);

    expect(res.questions).toHaveLength(1);
    expect(res.conceptual.ready).toBe(true);
    expect(res.questions[0].options).toHaveLength(4);
  });

  it('keeps factual response contract intact', async () => {
    const mod = await Test.createTestingModule({
      imports: [PracticeModule],
    }).compile();

    const service = mod.get(PracticeService);

    const res = await service.generate({
      subject: 'General Knowledge',
      topicLabel: 'world capitals',
      mode: 'practice',
      difficulty: 'medium',
      questionCount: 1,
    } as any);

    expect(res.questions).toHaveLength(1);
    expect(res.factual.ready).toBe(true);
    expect(Array.isArray(res.factual.gaps)).toBe(true);
  });
});
