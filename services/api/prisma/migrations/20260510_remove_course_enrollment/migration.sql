-- Remove Course, CourseRule, and Enrollment models.
-- Rename courseId → cohortId on Classroom* tables and Assessment.
-- Drop courseId from Material, TutorSession, AnalyticsEvent, ScheduleTemplateSlot, MessageThread, Teacher* tables.

-- 1. Drop FK constraints that reference Course (Postgres drops them with the table, but be explicit)

-- 2. Drop Enrollment table
DROP TABLE IF EXISTS "Enrollment";

-- 3. Drop CourseRule table
DROP TABLE IF EXISTS "CourseRule";

-- 4. Drop enums used only by dropped tables
DROP TYPE IF EXISTS "CourseRuleType";
DROP TYPE IF EXISTS "EnrollmentSource";

-- 5. Assessment: courseId → cohortId, add subject column
ALTER TABLE "Assessment" RENAME COLUMN "courseId" TO "cohortId";
ALTER TABLE "Assessment" ADD COLUMN IF NOT EXISTS "subject" TEXT;
ALTER TABLE "Assessment" DROP CONSTRAINT IF EXISTS "Assessment_courseId_fkey";
ALTER TABLE "Assessment" ADD CONSTRAINT "Assessment_cohortId_fkey"
  FOREIGN KEY ("cohortId") REFERENCES "Cohort"("id") ON DELETE CASCADE ON UPDATE CASCADE;
DROP INDEX IF EXISTS "Assessment_courseId_idx";
CREATE INDEX IF NOT EXISTS "Assessment_cohortId_idx" ON "Assessment"("cohortId");

-- 6. ClassroomMessage: courseId → cohortId
ALTER TABLE "ClassroomMessage" RENAME COLUMN "courseId" TO "cohortId";
ALTER TABLE "ClassroomMessage" DROP CONSTRAINT IF EXISTS "ClassroomMessage_courseId_fkey";
ALTER TABLE "ClassroomMessage" ADD CONSTRAINT "ClassroomMessage_cohortId_fkey"
  FOREIGN KEY ("cohortId") REFERENCES "Cohort"("id") ON DELETE CASCADE ON UPDATE CASCADE;
DROP INDEX IF EXISTS "ClassroomMessage_courseId_createdAt_idx";
CREATE INDEX IF NOT EXISTS "ClassroomMessage_cohortId_createdAt_idx" ON "ClassroomMessage"("cohortId", "createdAt");

-- 7. ClassroomAssignment: courseId → cohortId
ALTER TABLE "ClassroomAssignment" RENAME COLUMN "courseId" TO "cohortId";
ALTER TABLE "ClassroomAssignment" DROP CONSTRAINT IF EXISTS "ClassroomAssignment_courseId_fkey";
ALTER TABLE "ClassroomAssignment" ADD CONSTRAINT "ClassroomAssignment_cohortId_fkey"
  FOREIGN KEY ("cohortId") REFERENCES "Cohort"("id") ON DELETE CASCADE ON UPDATE CASCADE;
DROP INDEX IF EXISTS "ClassroomAssignment_courseId_createdAt_idx";
DROP INDEX IF EXISTS "ClassroomAssignment_courseId_dueAt_idx";
CREATE INDEX IF NOT EXISTS "ClassroomAssignment_cohortId_createdAt_idx" ON "ClassroomAssignment"("cohortId", "createdAt");
CREATE INDEX IF NOT EXISTS "ClassroomAssignment_cohortId_dueAt_idx" ON "ClassroomAssignment"("cohortId", "dueAt");

-- 8. ClassroomMaterial: courseId → cohortId
ALTER TABLE "ClassroomMaterial" RENAME COLUMN "courseId" TO "cohortId";
ALTER TABLE "ClassroomMaterial" DROP CONSTRAINT IF EXISTS "ClassroomMaterial_courseId_fkey";
ALTER TABLE "ClassroomMaterial" ADD CONSTRAINT "ClassroomMaterial_cohortId_fkey"
  FOREIGN KEY ("cohortId") REFERENCES "Cohort"("id") ON DELETE CASCADE ON UPDATE CASCADE;
DROP INDEX IF EXISTS "ClassroomMaterial_courseId_createdAt_idx";
CREATE INDEX IF NOT EXISTS "ClassroomMaterial_cohortId_createdAt_idx" ON "ClassroomMaterial"("cohortId", "createdAt");

-- 9. ClassroomMeeting: courseId → cohortId
ALTER TABLE "ClassroomMeeting" RENAME COLUMN "courseId" TO "cohortId";
ALTER TABLE "ClassroomMeeting" DROP CONSTRAINT IF EXISTS "ClassroomMeeting_courseId_fkey";
ALTER TABLE "ClassroomMeeting" ADD CONSTRAINT "ClassroomMeeting_cohortId_fkey"
  FOREIGN KEY ("cohortId") REFERENCES "Cohort"("id") ON DELETE CASCADE ON UPDATE CASCADE;
DROP INDEX IF EXISTS "ClassroomMeeting_courseId_startsAt_idx";
DROP INDEX IF EXISTS "ClassroomMeeting_courseId_createdAt_idx";
CREATE INDEX IF NOT EXISTS "ClassroomMeeting_cohortId_startsAt_idx" ON "ClassroomMeeting"("cohortId", "startsAt");
CREATE INDEX IF NOT EXISTS "ClassroomMeeting_cohortId_createdAt_idx" ON "ClassroomMeeting"("cohortId", "createdAt");

-- 10. ScheduleTemplateSlot: drop courseId
ALTER TABLE "ScheduleTemplateSlot" DROP CONSTRAINT IF EXISTS "ScheduleTemplateSlot_courseId_fkey";
ALTER TABLE "ScheduleTemplateSlot" DROP COLUMN IF EXISTS "courseId";

-- 11. Material: drop courseId
DROP INDEX IF EXISTS "Material_courseId_idx";
ALTER TABLE "Material" DROP COLUMN IF EXISTS "courseId";

-- 12. TutorSession: drop courseId
DROP INDEX IF EXISTS "TutorSession_courseId_idx";
ALTER TABLE "TutorSession" DROP COLUMN IF EXISTS "courseId";

-- 13. AnalyticsEvent: drop courseId
DROP INDEX IF EXISTS "AnalyticsEvent_courseId_idx";
ALTER TABLE "AnalyticsEvent" DROP COLUMN IF EXISTS "courseId";

-- 14. MessageThread: drop classroomCourseId
DROP INDEX IF EXISTS "MessageThread_classroomCourseId_idx";
ALTER TABLE "MessageThread" DROP CONSTRAINT IF EXISTS "MessageThread_classroomCourseId_fkey";
ALTER TABLE "MessageThread" DROP COLUMN IF EXISTS "classroomCourseId";

-- 15. TeacherAssignment: drop courseId
DROP INDEX IF EXISTS "TeacherAssignment_courseId_idx";
ALTER TABLE "TeacherAssignment" DROP CONSTRAINT IF EXISTS "TeacherAssignment_courseId_fkey";
ALTER TABLE "TeacherAssignment" DROP COLUMN IF EXISTS "courseId";

-- 16. TeacherExam: drop courseId
DROP INDEX IF EXISTS "TeacherExam_courseId_idx";
ALTER TABLE "TeacherExam" DROP CONSTRAINT IF EXISTS "TeacherExam_courseId_fkey";
ALTER TABLE "TeacherExam" DROP COLUMN IF EXISTS "courseId";

-- 17. TeacherMaterial: drop courseId
DROP INDEX IF EXISTS "TeacherMaterial_courseId_idx";
ALTER TABLE "TeacherMaterial" DROP CONSTRAINT IF EXISTS "TeacherMaterial_courseId_fkey";
ALTER TABLE "TeacherMaterial" DROP COLUMN IF EXISTS "courseId";

-- 18. TeacherMeeting: drop courseId
DROP INDEX IF EXISTS "TeacherMeeting_courseId_idx";
ALTER TABLE "TeacherMeeting" DROP CONSTRAINT IF EXISTS "TeacherMeeting_courseId_fkey";
ALTER TABLE "TeacherMeeting" DROP COLUMN IF EXISTS "courseId";

-- 19. Drop Course table last (after all FK references removed)
DROP TABLE IF EXISTS "Course";
