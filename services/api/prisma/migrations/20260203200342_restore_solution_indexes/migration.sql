-- Restore indexes that were accidentally dropped
CREATE INDEX IF NOT EXISTS "solution_author_createdat_idx"
  ON "Solution"("authorId","createdAt" DESC);

CREATE INDEX IF NOT EXISTS "solution_sourcename_page_question_createdat_idx"
  ON "Solution"("sourceName", page, "questionNumber", "createdAt" DESC);

CREATE INDEX IF NOT EXISTS "solution_subject_sourcename_createdat_idx"
  ON "Solution"(subject, "sourceName", "createdAt" DESC);
