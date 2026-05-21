-- Adds a "Grades" option to the audience picker on TeacherAssignment,
-- TeacherExam, TeacherMaterial, TeacherMeeting, and SchoolForm. Empty
-- array means "no grade-based targeting" (the existing
-- EVERYONE/COHORT/STUDENTS scopes still apply unchanged). Server resolvers
-- treat targetGrades as a union OR'd onto the audience match so a
-- student whose StudentProfile.grade is listed sees the item even when
-- they aren't in any matching cohort or student list.

ALTER TABLE "TeacherAssignment"
  ADD COLUMN IF NOT EXISTS "targetGrades" INTEGER[] NOT NULL DEFAULT '{}';

ALTER TABLE "TeacherExam"
  ADD COLUMN IF NOT EXISTS "targetGrades" INTEGER[] NOT NULL DEFAULT '{}';

ALTER TABLE "TeacherMaterial"
  ADD COLUMN IF NOT EXISTS "targetGrades" INTEGER[] NOT NULL DEFAULT '{}';

ALTER TABLE "TeacherMeeting"
  ADD COLUMN IF NOT EXISTS "targetGrades" INTEGER[] NOT NULL DEFAULT '{}';

ALTER TABLE "SchoolForm"
  ADD COLUMN IF NOT EXISTS "targetGrades" INTEGER[] NOT NULL DEFAULT '{}';
