import { Test } from '@nestjs/testing';
import { PracticeModule } from '../practice.module';
import { PracticeService } from '../practice.service';

describe('unsupported custom topic policy', () => {
  it('rejects unknown low-quizzability custom topics instead of returning usable questions', async () => {
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
    expect((err?.response?.questions ?? []).length).toBe(0);
  });
});
