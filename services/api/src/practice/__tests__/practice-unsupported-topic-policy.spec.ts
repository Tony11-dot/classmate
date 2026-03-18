import { Test } from '@nestjs/testing';
import { PracticeModule } from '../practice.module';
import { PracticeService } from '../practice.service';

describe('unsupported custom topic policy', () => {
  it('does not return usable questions for unknown low-quizzability custom topics', async () => {
    const mod = await Test.createTestingModule({
      imports: [PracticeModule],
    }).compile();

    const service = mod.get(PracticeService);

    let err: any = null;
    let res: any = null;

    try {
      res = await service.generate({
        subject: 'Math',
        topic: 'random thing maybe',
        mode: 'practice',
        difficulty: 'medium',
        questionCount: 2,
      } as any);
    } catch (e: any) {
      err = e;
    }

    expect(res).toBeNull();
    expect(err).toBeTruthy();

    const body =
      typeof err?.getResponse === 'function' ? err.getResponse() : err?.response;

    expect((body?.questions ?? []).length).toBe(0);
  });
});
