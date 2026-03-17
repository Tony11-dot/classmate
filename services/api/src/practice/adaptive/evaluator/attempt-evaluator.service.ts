import { Injectable } from '@nestjs/common';
import type { PracticeAttemptEvaluation } from '../mastery.types';

@Injectable()
export class AttemptEvaluatorService {
  evaluate(input: {
    selectedIndex?: number;
    correctIndex?: number;
    responseTimeSeconds?: number;
  }): PracticeAttemptEvaluation {
    const isCorrect =
      typeof input.selectedIndex === 'number' &&
      typeof input.correctIndex === 'number' &&
      input.selectedIndex === input.correctIndex;

    return {
      isCorrect,
      selectedIndex: input.selectedIndex,
      correctIndex: input.correctIndex,
      responseTimeSeconds: input.responseTimeSeconds,
    };
  }
}
