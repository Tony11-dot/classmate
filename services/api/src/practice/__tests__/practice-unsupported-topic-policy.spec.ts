import { BadRequestException } from '@nestjs/common';
import { PracticeService } from '../practice.service';

describe('unsupported custom topic policy', () => {
  it('rejects unknown low-quizzability custom topics instead of generating fallback questions', async () => {
    const service = new PracticeService({} as any, {} as any, {} as any, {} as any);

    await expect(
      service.generatePractice({
        subject: 'Math',
        topic: 'random thing maybe',
        mode: 'practice',
        difficulty: 'medium',
        questionCount: 2,
      } as any),
    ).rejects.toBeInstanceOf(BadRequestException);
  });
});
