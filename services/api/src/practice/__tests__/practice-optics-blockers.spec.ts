import { PracticeService } from '../practice.service';

describe('PracticeService optics blocker replays', () => {
  const engineRegistry = { generate: jest.fn(async () => null) };

  class TestPracticeService extends PracticeService {
    queue: any[] = [];
    verifierDecisions: any[] = [];

    async callResponsesJson(args: any): Promise<any> {
      if (args.schemaName === 'practice_questions') {
        const next = this.queue.shift();
        if (!next) return { questions: [] };
        return { questions: next };
      }

      if (args.schemaName === 'practice_verifier') {
        return {
          decisions:
            this.verifierDecisions.shift() ?? [
              { index: 0, verdict: 'accept', reason: 'ok' },
              { index: 1, verdict: 'accept', reason: 'ok' },
              { index: 2, verdict: 'accept', reason: 'ok' },
              { index: 3, verdict: 'accept', reason: 'ok' },
              { index: 4, verdict: 'accept', reason: 'ok' },
            ],
        };
      }

      return {};
    }
  }

  let service: TestPracticeService;

  beforeEach(() => {
    service = new TestPracticeService(engineRegistry as any);
    process.env.OPENAI_API_KEY = 'test-key';
  });

  it('recovers from bad optics first-pass items and returns a clean verified set', async () => {
    service.queue.push(
      [
        {
          prompt: 'How does lens thickness alone affect focal length if curvature is unchanged?',
          options: ['Always increases it', 'Always decreases it', 'No necessary direct rule', 'Makes it zero'],
          correctIndex: 1,
          correctAnswerText: 'Always decreases it',
          explanation: 'Greater thickness means shorter focal length.',
          recommendedTimeSeconds: 40,
          topicMatchNote: 'Optics',
        },
        {
          prompt: 'What is the critical angle from glass to air for n=1.5 to 1.0?',
          options: ['42°', '33°', '60°', '75°'],
          correctIndex: 0,
          correctAnswerText: '42°',
          explanation: 'Critical angle is approximately about nearly around 42°.',
          recommendedTimeSeconds: 50,
          topicMatchNote: 'Optics',
        },
        {
          prompt: 'A concave lens forms what image?',
          options: ['Virtual upright smaller', 'Real inverted', 'Virtual upright larger', 'Real upright'],
          correctIndex: 2,
          correctAnswerText: 'Virtual upright larger',
          explanation: 'Concave lenses form virtual upright larger images.',
          recommendedTimeSeconds: 35,
          topicMatchNote: 'Optics',
        },
        {
          prompt: 'Which phenomenon explains bent pencil in water?',
          options: ['Refraction', 'Diffraction', 'Polarization', 'Interference'],
          correctIndex: 0,
          correctAnswerText: 'Refraction',
          explanation: 'Light bends between media, so this is refraction.',
          recommendedTimeSeconds: 30,
          topicMatchNote: 'Optics',
        },
        {
          prompt: 'Plane mirror image type?',
          options: ['Virtual upright', 'Real upright', 'Real inverted', 'Virtual inverted'],
          correctIndex: 0,
          correctAnswerText: 'Virtual upright',
          explanation: 'Plane mirrors produce virtual upright images.',
          recommendedTimeSeconds: 30,
          topicMatchNote: 'Optics',
        },
      ],
      [
        {
          prompt: 'How does changing curvature affect the focal length of a converging lens?',
          options: ['Greater curvature gives shorter focal length', 'Greater curvature gives longer focal length', 'Curvature has no effect', 'Focal length becomes zero'],
          correctIndex: 0,
          correctAnswerText: 'Greater curvature gives shorter focal length',
          explanation: 'More strongly curved surfaces bend light more, so the focal length becomes shorter.',
          recommendedTimeSeconds: 40,
          topicMatchNote: 'Optics',
        },
        {
          prompt: 'What is the critical angle for light moving from glass (n=1.5) to air (n=1.0)?',
          options: ['42°', '33°', '60°', '75°'],
          correctIndex: 0,
          correctAnswerText: '42°',
          explanation: 'Using sin(c)=n2/n1=1/1.5, c≈41.8°, so about 42°.',
          recommendedTimeSeconds: 50,
          topicMatchNote: 'Optics',
        },
        {
          prompt: 'A concave lens always forms which image?',
          options: ['Virtual upright smaller', 'Real inverted', 'Virtual upright larger', 'Real upright'],
          correctIndex: 0,
          correctAnswerText: 'Virtual upright smaller',
          explanation: 'A concave lens diverges rays and always produces a virtual, upright, diminished image.',
          recommendedTimeSeconds: 35,
          topicMatchNote: 'Optics',
        },
        {
          prompt: 'Which phenomenon explains why a pencil looks bent in water?',
          options: ['Refraction', 'Diffraction', 'Polarization', 'Interference'],
          correctIndex: 0,
          correctAnswerText: 'Refraction',
          explanation: 'Light changes speed and bends at the boundary between air and water, so the pencil appears displaced.',
          recommendedTimeSeconds: 30,
          topicMatchNote: 'Optics',
        },
        {
          prompt: 'What type of image is formed by a plane mirror?',
          options: ['Virtual upright', 'Real upright', 'Real inverted', 'Virtual inverted'],
          correctIndex: 0,
          correctAnswerText: 'Virtual upright',
          explanation: 'A plane mirror forms a virtual, upright image the same size as the object.',
          recommendedTimeSeconds: 30,
          topicMatchNote: 'Optics',
        },
      ],
    );

    service.verifierDecisions.push(
      [
        { index: 0, verdict: 'reject', reason: 'Incorrect physics: thickness alone with same curvature does not determine shorter focal length.' },
        { index: 1, verdict: 'reject', reason: 'Bad phrasing / weak approximation wording.' },
        { index: 2, verdict: 'reject', reason: 'Concave lens image is not larger.' },
        { index: 3, verdict: 'accept', reason: 'ok' },
        { index: 4, verdict: 'accept', reason: 'ok' },
      ],
      [
        { index: 0, verdict: 'accept', reason: 'ok' },
        { index: 1, verdict: 'accept', reason: 'ok' },
        { index: 2, verdict: 'accept', reason: 'ok' },
        { index: 3, verdict: 'accept', reason: 'ok' },
        { index: 4, verdict: 'accept', reason: 'ok' },
      ],
    );

    const res = await service.generate({
      subject: 'Physics',
      topic: 'Optics',
      difficulty: 'medium',
      mode: 'practice',
      count: 5,
      timePreferenceSeconds: 40,
      useAiTiming: true,
      maxLives: 2,
    });

    expect(res.questions).toHaveLength(5);
    for (const q of res.questions as any[]) {
      expect(q.topicLabel).toBe('Optics');
      expect(String(q.explanation).toLowerCase()).not.toContain('correction');
      expect(String(q.explanation).toLowerCase()).not.toContain('reconsider');
      expect(String(q.explanation).toLowerCase()).not.toContain('adjust options');
      expect(String(q.explanation).toLowerCase()).not.toContain('approximately about');
    }
  });
});
