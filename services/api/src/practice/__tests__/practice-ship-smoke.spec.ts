import { Test } from '@nestjs/testing';
import { PracticeModule } from '../practice.module';
import { PracticeService } from '../practice.service';

describe('practice ship smoke (no external deps)', () => {
  let service: PracticeService;

  beforeAll(async () => {
    const mod = await Test.createTestingModule({
      imports: [PracticeModule],
    }).compile();

    service = mod.get(PracticeService);
  });

  it('returns deterministic Math questions (NO AI)', async () => {
    const res = await service.generate({
      subject: 'Math',
      topicLabel: 'Polynomials', // deterministic
      mode: 'practice',
      difficulty: 'medium',
      questionCount: 2,
    } as any);

    expect(res.questions.length).toBe(2);
  });

  it('returns deterministic Physics questions (NO AI)', async () => {
    const res = await service.generate({
      subject: 'Physics',
      topicLabel: 'Optics', // deterministic
      mode: 'practice',
      difficulty: 'medium',
      questionCount: 2,
    } as any);

    expect(res.questions.length).toBe(2);
  });

  it('returns conceptual not-ready (NO AI)', async () => {
    const res = await service.generate({
      subject: 'General Knowledge',
      topicLabel: 'music',
      mode: 'practice',
      difficulty: 'medium',
      questionCount: 2,
    } as any);

    expect(res.questions).toEqual([]);
    expect(res.conceptual?.ready).toBe(false);
  });

  it('blocks unsupported nonsense topic cleanly', async () => {
    let err: any = null;

    try {
      await service.generate({
        subject: 'Math',
        topic: 'random thing maybe',
        mode: 'practice',
        difficulty: 'medium',
        questionCount: 2,
      } as any);
    } catch (e: any) {
      err = e;
    }

    expect(err).toBeTruthy();

    const body =
      typeof err?.getResponse === 'function' ? err.getResponse() : err?.response;

    expect((body?.questions ?? []).length).toBe(0);
  });
});
