-- ClassroomAssignment: add attachments JSON column
ALTER TABLE "ClassroomAssignment" ADD COLUMN IF NOT EXISTS "attachments" JSONB NOT NULL DEFAULT '[]';
-- AssignmentSubmission: add files JSON column
ALTER TABLE "AssignmentSubmission" ADD COLUMN IF NOT EXISTS "files" JSONB NOT NULL DEFAULT '[]';
