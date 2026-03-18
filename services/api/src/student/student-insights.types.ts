export type StudentInsightsGradeItem = {
  id: string;
  subject: string;
  courseName: string;
  assessmentTitle: string;
  grade: number;
  date: string | null;
};

export type StudentInsightsAttendanceItem = {
  date: string;
  period: number;
  status: string;
  subject: string | null;
  courseName: string | null;
};

export type StudentInsightsPracticeTopic = {
  subject: string;
  topicLabel: string;
  accuracy: number;
  totalAnswered: number;
};

export type StudentInsightsTrendWindow = {
  label: '7d' | '30d';
  attempts: number;
  correct: number;
  accuracy: number | null;
};

export type StudentInsightsPracticeTrend = {
  last7d: StudentInsightsTrendWindow;
  last30d: StudentInsightsTrendWindow;
  deltaAccuracy: number | null;
};

export type StudentInsightsPracticeSummary = {
  userId?: string;
  totalSessions: number;
  totalAttempts: number;
  totalCorrect: number;
  overallAccuracy: number;
  weakTopics: StudentInsightsPracticeTopic[];
  strongestTopics: StudentInsightsPracticeTopic[];
  trend?: StudentInsightsPracticeTrend;
};

export type StudentInsightsGradesSummary = {
  count: number;
  average: number | null;
  latest: StudentInsightsGradeItem[];
  bestSubject: string | null;
  weakestSubject: string | null;
};

export type StudentInsightsAttendanceSummary = {
  total: number;
  present: number;
  absent: number;
  late: number;
  justified: number;
  attendanceRate: number | null;
  latest: StudentInsightsAttendanceItem[];
};

export type StudentInsightsResponse = {
  ok: true;
  studentId: string;
  generatedAt: string;
  grades: StudentInsightsGradesSummary;
  attendance: StudentInsightsAttendanceSummary;
  practice: StudentInsightsPracticeSummary;
};
