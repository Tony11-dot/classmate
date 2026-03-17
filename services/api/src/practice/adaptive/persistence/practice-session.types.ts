export type PracticeAttemptRecord = {
  questionId: string;
  subject: string;
  topicLabel: string;
  difficulty: string;
  mode: string;
  isCorrect: boolean;
  selectedIndex?: number | null;
  correctIndex?: number | null;
  answeredAt: string;
};

export type PracticeSessionRecord = {
  id: string;
  userId: string;
  subject: string;
  topicLabel: string;
  mode: string;
  startedAt: string;
  updatedAt: string;
  attempts: PracticeAttemptRecord[];
};

export type TopicMasteryRecord = {
  userId: string;
  subject: string;
  topicLabel: string;
  accuracy: number;
  streak: number;
  totalAnswered: number;
  correctAnswered: number;
  lastUpdatedAt: string;
};

export type UpsertPracticeAttemptInput = {
  userId: string;
  sessionId: string;
  subject: string;
  topicLabel: string;
  mode: string;
  difficulty: string;
  questionId: string;
  isCorrect: boolean;
  selectedIndex?: number | null;
  correctIndex?: number | null;
};

export type PracticeWeaknessSummary = {
  subject: string;
  topicLabel: string;
  accuracy: number;
  totalAnswered: number;
};

export type PracticeProgressSummary = {
  userId: string;
  totalSessions: number;
  totalAttempts: number;
  totalCorrect: number;
  overallAccuracy: number;
  weakTopics: PracticeWeaknessSummary[];
  strongestTopics: PracticeWeaknessSummary[];
};
