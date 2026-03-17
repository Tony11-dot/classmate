import { Test } from '@nestjs/testing';
import { PracticeModule } from '../../practice.module';
import { PracticeService } from '../../practice.service';

describe('PHASE 8 — factual domain clusters', () => {
  it('returns a real quiz for planets of the solar system', async () => {
    const mod = await Test.createTestingModule({
      imports: [PracticeModule],
    }).compile();

    const service = mod.get(PracticeService);

    const res = await service.generate({
      subject: 'General Knowledge',
      topicLabel: 'planets of the solar system',
      mode: 'practice',
      difficulty: 'medium',
      questionCount: 2,
      useAiTiming: true,
      maxLives: 3,
    } as any);

    expect(res.questions).toHaveLength(2);
    expect(res.factual.ready).toBe(true);
    expect(res.factual.gaps).toEqual([]);
  });

  it('returns a real quiz for flags of the world', async () => {
    const mod = await Test.createTestingModule({
      imports: [PracticeModule],
    }).compile();

    const service = mod.get(PracticeService);

    const res = await service.generate({
      subject: 'General Knowledge',
      topicLabel: 'flags of the world',
      mode: 'practice',
      difficulty: 'medium',
      questionCount: 2,
      useAiTiming: true,
      maxLives: 3,
    } as any);

    expect(res.questions).toHaveLength(2);
    expect(res.factual.ready).toBe(true);
    expect(res.factual.gaps).toEqual([]);
  });

  it('returns a real quiz for countries of the world', async () => {
    const mod = await Test.createTestingModule({
      imports: [PracticeModule],
    }).compile();

    const service = mod.get(PracticeService);

    const res = await service.generate({
      subject: 'General Knowledge',
      topicLabel: 'countries of the world',
      mode: 'practice',
      difficulty: 'medium',
      questionCount: 2,
      useAiTiming: true,
      maxLives: 3,
    } as any);

    expect(res.questions).toHaveLength(2);
    expect(res.factual.ready).toBe(true);
    expect(res.factual.gaps).toEqual([]);
  });
});
