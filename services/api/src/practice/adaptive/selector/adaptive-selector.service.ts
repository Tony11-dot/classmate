import { Injectable } from '@nestjs/common';
import type {
  AdaptiveSelectorInput,
  AdaptiveSelectorOutput,
} from './adaptive-selector.types';

@Injectable()
export class AdaptiveSelectorService {
  choose(input: AdaptiveSelectorInput): AdaptiveSelectorOutput {
    const mastery = Number(input.masteryScore ?? 0);
    const streak = Number(input.streak ?? 0);
    const accuracy = Number(input.recentAccuracy ?? 0);

    if (mastery >= 0.8 && accuracy >= 0.8 && streak >= 3) {
      return {
        targetDifficulty: 'hard',
        questionCountHint: 5,
        shouldRepeatTopic: false,
      };
    }

    if (mastery <= 0.35 || accuracy <= 0.4) {
      return {
        targetDifficulty: 'easy',
        questionCountHint: 3,
        shouldRepeatTopic: true,
      };
    }

    return {
      targetDifficulty: 'medium',
      questionCountHint: 4,
      shouldRepeatTopic: streak < 2,
    };
  }
}
