export type AdaptiveAttemptInput = {
  sessionId: string;
  subject: string;
  topicLabel: string;
  questionId: string;
  selectedIndex?: number;
  correctIndex?: number;
  difficulty?: 'easy' | 'medium' | 'hard' | 'olympiad' | 'adaptive';
  responseTimeMs?: number;
};

export type AdaptiveAttemptResult = {
  sessionId: string;
  topicKey: string;
  isCorrect: boolean;
  awardedScore: number;
  targetDifficulty: 'easy' | 'medium' | 'hard';
  streak: number;
  accuracy: number;
  recommendedFocus: string[];
};

export type AdaptiveSessionSummary = {
  sessionId: string;
  subject: string;
  topicLabel: string;
  attempts: number;
  correct: number;
  accuracy: number;
  currentDifficulty: 'easy' | 'medium' | 'hard';
  weakAreas: string[];
  strengths: string[];
};
