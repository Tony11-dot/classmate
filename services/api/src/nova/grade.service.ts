import { Injectable } from '@nestjs/common';

@Injectable()
export class GradeService {
  async gradeSolution(image: Buffer) {
    return {
      score: 8,
      feedback: [
        'Step 1 correct',
        'Algebra mistake in step 2',
        'Final answer incorrect',
      ],
      stepDetections: [
        {
          step: 1,
          verdict: 'correct',
          note: 'Good setup.',
        },
        {
          step: 2,
          verdict: 'mistake',
          note: 'Sign error / algebra slip detected.',
        },
        {
          step: 3,
          verdict: 'follow-through',
          note: 'Final answer inherits the earlier mistake.',
        },
      ],
    };
  }
}
