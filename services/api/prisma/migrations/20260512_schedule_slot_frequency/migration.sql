-- AlterTable: add frequencyWeeks column with default 1 (every week)
ALTER TABLE "ScheduleSlot" ADD COLUMN IF NOT EXISTS "frequencyWeeks" INTEGER NOT NULL DEFAULT 1;
