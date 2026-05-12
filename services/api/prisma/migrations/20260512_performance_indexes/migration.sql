-- Add missing indexes for 1000-student scale performance
-- StudentCohort: index on studentId for reverse lookups
CREATE INDEX IF NOT EXISTS "StudentCohort_studentId_idx" ON "StudentCohort"("studentId");
-- AttendanceRecord: compound index for student+time queries
CREATE INDEX IF NOT EXISTS "AttendanceRecord_studentId_markedAt_idx" ON "AttendanceRecord"("studentId", "markedAt");
