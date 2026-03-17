export type MasteryBand = 'unknown' | 'weak' | 'developing' | 'solid' | 'strong';

export type TopicMasteryState = {
  subject: string;
  topicLabel: string;
  attempts: number;
  correct: number;
  streak: number;
  lastOutcome: 'correct' | 'incorrect' | 'unknown';
  accuracy: number;
  band: MasteryBand;
};

export type PracticeAttemptEvaluation = {
  isCorrect: boolean;
  selectedIndex?: number;
  correctIndex?: number;
  responseTimeSeconds?: number;
};

export type AdaptiveQuestionPick = {
  targetDifficulty: 'easy' | 'medium' | 'hard';
  rationale: string;
};
