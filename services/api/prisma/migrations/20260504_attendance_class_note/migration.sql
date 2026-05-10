-- Add class-level notes to attendance sessions
ALTER TABLE "AttendanceSession" ADD COLUMN IF NOT EXISTS "classNote" TEXT;
