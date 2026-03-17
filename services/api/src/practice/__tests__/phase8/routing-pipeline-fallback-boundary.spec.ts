import { Test } from '@nestjs/testing';
import { PracticeService } from '../../practice.service';
import { PracticeModule } from '../../practice.module';

describe('PHASE 8 — routing pipeline fallback boundary', () => {
  it('returns explicit symbolic-not-ready payload before AI fallback', async () => {
    const mod = await Test.createTestingModule({
      imports: [PracticeModule],
    }).compile();

    const service = mod.get(PracticeService);
    const requestSpy = jest.spyOn(service as any, 'requestQuestionSet');

    const res = await service.generate({
      subject: 'Math',
      topicLabel: 'vector spaces',
      mode: 'practice',
      difficulty: 'medium',
      questionCount: 1,
    } as any);

    expect(res.questions).toEqual([]);
    expect(res.symbolic.ready).toBe(false);
    expect(res.symbolic.gaps).toContain('symbolic_generation_not_ready');
    expect(requestSpy).not.toHaveBeenCalled();
  });
});
