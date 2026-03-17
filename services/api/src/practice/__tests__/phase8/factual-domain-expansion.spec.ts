import { Test } from '@nestjs/testing';
import { PracticeModule } from '../../practice.module';
import { FactualQuizService } from '../../factual/factual-quiz.service';
import { PracticeService } from '../../practice.service';

describe('PHASE 8 — factual domain expansion', () => {
  it('resolves World War II as a grounded-ready domain', async () => {
    const mod = await Test.createTestingModule({
      imports: [PracticeModule],
    }).compile();

    const factual = mod.get(FactualQuizService);

    const res = factual.resolve({
      subject: 'General Knowledge',
      topicLabel: 'world war 2',
    });

    expect(res.ready).toBe(true);
    expect(res.subject).toBe('History');
    expect(res.topic).toBe('World War II');
    expect(res.facts.length).toBeGreaterThanOrEqual(3);
    expect(res.gaps).toEqual([]);
  });

  it('resolves World Capitals as a grounded-ready domain', async () => {
    const mod = await Test.createTestingModule({
      imports: [PracticeModule],
    }).compile();

    const factual = mod.get(FactualQuizService);

    const res = factual.resolve({
      subject: 'General Knowledge',
      topicLabel: 'world capitals',
    });

    expect(res.ready).toBe(true);
    expect(res.subject).toBe('General Knowledge');
    expect(res.topic).toBe('World Capitals');
    expect(res.facts.length).toBeGreaterThanOrEqual(3);
    expect(res.gaps).toEqual([]);
  });

  it('generates real factual questions for World War II', async () => {
    const mod = await Test.createTestingModule({
      imports: [PracticeModule],
    }).compile();

    const service = mod.get(PracticeService);

    const res = await service.generate({
      subject: 'General Knowledge',
      topicLabel: 'world war 2',
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

  it('generates real factual questions for World Capitals', async () => {
    const mod = await Test.createTestingModule({
      imports: [PracticeModule],
    }).compile();

    const service = mod.get(PracticeService);

    const res = await service.generate({
      subject: 'General Knowledge',
      topicLabel: 'world capitals',
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
