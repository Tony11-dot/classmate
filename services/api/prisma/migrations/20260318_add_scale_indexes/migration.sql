CREATE INDEX IF NOT EXISTS idx_practice_attempt_user_created_at
ON "PracticeAttempt" ("userId", "createdAt" DESC);

CREATE INDEX IF NOT EXISTS idx_practice_attempt_subject_topic
ON "PracticeAttempt" ("subject", "topicLabel");

CREATE INDEX IF NOT EXISTS idx_practice_session_user_updated_at
ON "PracticeSession" ("userId", "updatedAt" DESC);

CREATE INDEX IF NOT EXISTS idx_notification_user_created_at
ON "Notification" ("userId", "createdAt" DESC);

CREATE INDEX IF NOT EXISTS idx_assignment_classroom_due_date
ON "Assignment" ("classroomId", "dueDate");

CREATE INDEX IF NOT EXISTS idx_grade_student_created_at
ON "Grade" ("studentId", "createdAt" DESC);

CREATE INDEX IF NOT EXISTS idx_attendance_student_date
ON "Attendance" ("studentId", "date");
