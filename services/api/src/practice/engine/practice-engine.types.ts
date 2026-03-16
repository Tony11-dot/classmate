export type EngineMode =
  | 'practice'
  | 'flashcards'
  | 'speedRound'
  | 'examPrep'
  | 'conceptBuilder'
  | 'adaptive';

export type EngineDifficulty =
  | 'easy'
  | 'medium'
  | 'hard'
  | 'olympiad'
  | 'adaptive';

export type PracticeEngineRequest = {
  subject: string;
  topicLabel: string;
  topicPath: string[];
  topicPathText: string;
  strictPromptSummary: string;
  questionCount: number;
  mode: EngineMode;
  difficulty: EngineDifficulty;
  timePreferenceSeconds: number | null;
  useAiTiming: boolean;
  maxLives: number;
};

export type ProblemSeed = {
  kind: string;
  prompt: string;
  topicMatchNote: string;
  metadata?: Record<string, unknown>;
};

export type SolvedQuestion = {
  prompt: string;
  options: string[];
  correctIndex: number;
  correctAnswerText: string;
  explanation: string;
  recommendedTimeSeconds: number;
  topicMatchNote: string;
};

export type GeneratedQuestion = SolvedQuestion;
