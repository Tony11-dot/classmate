import { PracticeService } from '../practice.service';

describe('factual placeholder distractors', () => {
  it('does not emit placeholder distractors for tennis history', async () => {
    const service = new PracticeService({} as any, {} as any, {} as any, {} as any);

    const out = await service.generatePractice({
      subject: 'General Knowledge',
      topic: 'tennis history',
      mode: 'practice',
      difficulty: 'medium',
      questionCount: 2,
    } as any);

    const flat = JSON.stringify(out);
    expect(flat).not.toContain('A later revision');
    expect(flat).not.toContain('An unrelated concept');
    expect(flat).not.toContain('None of the above');
    expect(flat).not.toContain('All of the above');
  });
});
