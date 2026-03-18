export type PracticeProgressTopicDto = {
  subject: string;
  topicLabel: string;
  accuracy: number;
  totalAnswered: number;
};

export type PracticeProgressSummaryDto = {
  userId: string;
  totalSessions: number;
  totalAttempts: number;
  totalCorrect: number;
  overallAccuracy: number;
  weakTopics: PracticeProgressTopicDto[];
  strongestTopics: PracticeProgressTopicDto[];
};
