-- AlterTable: add per-school grade range (default 5..12 matches the previous hardcoded range)
ALTER TABLE "School" ADD COLUMN IF NOT EXISTS "minGrade" INTEGER NOT NULL DEFAULT 5;
ALTER TABLE "School" ADD COLUMN IF NOT EXISTS "maxGrade" INTEGER NOT NULL DEFAULT 12;
