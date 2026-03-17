export type TopicMasterySnapshot = {
  subject: string;
  topic: string;
  accuracy: number;
  streak: number;
  attempts: number;
  correct: number;
  lastDifficulty?: 'easy' | 'medium' | 'hard' | 'olympiad' | 'adaptive';
};

export type WeaknessItem = {
  subject: string;
  topic: string;
  accuracy: number;
  attempts: number;
  recommendedDifficulty: 'easy' | 'medium' | 'hard';
  reason: string;
};

export type StrengthItem = {
  subject: string;
  topic: string;
  accuracy: number;
  streak: number;
  attempts: number;
};

export type ProgressSummary = {
  totalTopics: number;
  totalAttempts: number;
  totalCorrect: number;
  overallAccuracy: number;
  weakTopics: WeaknessItem[];
  strongTopics: StrengthItem[];
  recommendedFocus: string[];
};
