import { Injectable } from '@nestjs/common';
import type {
  AdaptiveQuestionPick,
  PracticeAttemptEvaluation,
  TopicMasteryState,
} from './mastery.types';

@Injectable()
export class MasteryService {
  createEmpty(subject: string, topicLabel: string): TopicMasteryState {
    return {
      subject,
      topicLabel,
      attempts: 0,
      correct: 0,
      streak: 0,
      lastOutcome: 'unknown',
      accuracy: 0,
      band: 'unknown',
    };
  }

  update(
    prev: TopicMasteryState,
    evaluation: PracticeAttemptEvaluation,
  ): TopicMasteryState {
    const attempts = prev.attempts + 1;
    const correct = prev.correct + (evaluation.isCorrect ? 1 : 0);
    const accuracy = correct / attempts;
    const streak = evaluation.isCorrect ? prev.streak + 1 : 0;

    let band: TopicMasteryState['band'] = 'developing';
    if (attempts < 2) band = 'unknown';
    else if (accuracy < 0.4) band = 'weak';
    else if (accuracy < 0.65) band = 'developing';
    else if (accuracy < 0.85) band = 'solid';
    else band = 'strong';

    return {
      ...prev,
      attempts,
      correct,
      streak,
      lastOutcome: evaluation.isCorrect ? 'correct' : 'incorrect',
      accuracy,
      band,
    };
  }

  chooseNext(state: TopicMasteryState): AdaptiveQuestionPick {
    if (state.band === 'unknown' || state.band === 'weak') {
      return {
        targetDifficulty: 'easy',
        rationale: 'stabilize foundations',
      };
    }

    if (state.band === 'developing') {
      return {
        targetDifficulty: 'medium',
        rationale: 'build reliable accuracy',
      };
    }

    return {
      targetDifficulty: 'hard',
      rationale: 'increase challenge for mastery growth',
    };
  }
}
