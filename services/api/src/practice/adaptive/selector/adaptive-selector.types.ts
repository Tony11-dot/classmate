export type AdaptiveDifficulty = 'easy' | 'medium' | 'hard';

export type AdaptiveSelectorInput = {
  masteryScore: number;
  streak: number;
  recentAccuracy: number;
};

export type AdaptiveSelectorOutput = {
  targetDifficulty: AdaptiveDifficulty;
  questionCountHint: number;
  shouldRepeatTopic: boolean;
};
