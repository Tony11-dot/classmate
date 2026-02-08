-- Recreated local migration to match what already exists in DB.
-- NOTE: This migration should NOT be applied again; it is only to satisfy Prisma history.

-- CreateTable: Solution
CREATE TABLE "Solution" (
  "id" TEXT NOT NULL,
  "authorId" TEXT NOT NULL,
  "subject" TEXT NOT NULL,
  "sourceType" TEXT NOT NULL,
  "sourceName" TEXT,
  "page" INTEGER,
  "questionNumber" TEXT,
  "title" TEXT,
  "notes" TEXT,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,

  CONSTRAINT "Solution_pkey" PRIMARY KEY ("id")
);

ALTER TABLE "Solution"
ADD CONSTRAINT "Solution_authorId_fkey"
FOREIGN KEY ("authorId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

CREATE INDEX "Solution_subject_sourceType_idx" ON "Solution"("subject","sourceType");
CREATE INDEX "Solution_subject_sourceName_page_idx" ON "Solution"("subject","sourceName","page");
CREATE INDEX "Solution_subject_sourceName_page_questionNumber_idx" ON "Solution"("subject","sourceName","page","questionNumber");

CREATE INDEX "solution_author_createdat_idx" ON "Solution"("authorId","createdAt" DESC);
CREATE INDEX "solution_sourcename_page_question_createdat_idx" ON "Solution"("sourceName","page","questionNumber","createdAt" DESC);
CREATE INDEX "solution_subject_sourcename_createdat_idx" ON "Solution"("subject","sourceName","createdAt" DESC);

-- CreateTable: SolutionImage (CURRENT DB shape)
CREATE TABLE "SolutionImage" (
  "id" TEXT NOT NULL,
  "solutionId" TEXT NOT NULL,
  "url" TEXT NOT NULL,
  "width" INTEGER,
  "height" INTEGER,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT "SolutionImage_pkey" PRIMARY KEY ("id")
);

ALTER TABLE "SolutionImage"
ADD CONSTRAINT "SolutionImage_solutionId_fkey"
FOREIGN KEY ("solutionId") REFERENCES "Solution"("id") ON DELETE CASCADE ON UPDATE CASCADE;

CREATE INDEX "SolutionImage_solutionId_idx" ON "SolutionImage"("solutionId");
