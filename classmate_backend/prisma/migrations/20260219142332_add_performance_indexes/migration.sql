-- Performance indexes (safe + fast)
CREATE INDEX IF NOT EXISTS "Grade_submissionId_idx" ON "Grade" ("submissionId");
CREATE INDEX IF NOT EXISTS "Submission_studentId_idx" ON "Submission" ("studentId");
CREATE INDEX IF NOT EXISTS "Submission_assessmentId_idx" ON "Submission" ("assessmentId");
