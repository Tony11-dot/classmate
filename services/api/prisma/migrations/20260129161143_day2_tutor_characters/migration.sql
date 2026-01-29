-- CreateEnum
CREATE TYPE "TutorCharacterSubject" AS ENUM ('GENERAL', 'MATH', 'PHYSICS', 'CS', 'ENGLISH', 'HEBREW', 'ARABIC');

-- AlterTable
ALTER TABLE "TutorSession" ADD COLUMN     "characterId" TEXT;

-- CreateTable
CREATE TABLE "TutorCharacter" (
    "id" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "cohortId" TEXT,
    "subject" "TutorCharacterSubject" NOT NULL DEFAULT 'GENERAL',
    "name" TEXT NOT NULL,
    "tone" TEXT,
    "verbosity" INTEGER,
    "explainStyle" TEXT,
    "curriculum" TEXT,
    "maxGrade" INTEGER,
    "language" TEXT,
    "systemNotes" TEXT,

    CONSTRAINT "TutorCharacter_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "TutorCharacter_cohortId_idx" ON "TutorCharacter"("cohortId");

-- CreateIndex
CREATE INDEX "TutorCharacter_subject_idx" ON "TutorCharacter"("subject");

-- AddForeignKey
ALTER TABLE "TutorSession" ADD CONSTRAINT "TutorSession_characterId_fkey" FOREIGN KEY ("characterId") REFERENCES "TutorCharacter"("id") ON DELETE SET NULL ON UPDATE CASCADE;
