import { PracticeService } from '../practice.service';

describe('factual placeholder options', () => {
  it('does not emit banned placeholder distractors for factual topics', async () => {
    const service = new PracticeService(
      {} as any,
      {} as any,
      {} as any,
      {} as any,
      {} as any,
      {} as any,
      {} as any,
      {} as any,
      {} as any,
      {} as any,
      {} as any,
    );

    const out = await service.generate({
      subject: 'General Knowledge',
      topic: 'tennis history',
      mode: 'practice',
      difficulty: 'medium',
      questionCount: 2,
    } as any);

    const flat = (out.questions ?? []).flatMap((q: any) => q.options ?? []);
    expect(flat).not.toContain('A later revision');
    expect(flat).not.toContain('An unrelated concept');
    expect(flat).not.toContain('None of the above');
    expect(flat).not.toContain('All of the above');
  });
});
