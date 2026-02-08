-- DropIndex
DROP INDEX "solution_author_createdat_idx";

-- DropIndex
DROP INDEX "solution_sourcename_page_question_createdat_idx";

-- DropIndex
DROP INDEX "solution_subject_sourcename_createdat_idx";

-- AlterTable
ALTER TABLE "SolutionImage" ALTER COLUMN "storagePath" DROP DEFAULT,
ALTER COLUMN "kind" DROP DEFAULT,
ALTER COLUMN "mime" DROP DEFAULT,
ALTER COLUMN "sizeBytes" DROP DEFAULT;
