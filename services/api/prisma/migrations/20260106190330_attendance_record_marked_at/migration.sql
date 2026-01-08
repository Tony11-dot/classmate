-- Add markedAt with a default so existing rows get a value
ALTER TABLE "AttendanceRecord"
ADD COLUMN "markedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP;

-- Add updatedAt with a default so existing rows get a value
ALTER TABLE "AttendanceRecord"
ADD COLUMN "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP;

-- Defensive backfill (covers partial/odd states)
UPDATE "AttendanceRecord"
SET "updatedAt" = CURRENT_TIMESTAMP
WHERE "updatedAt" IS NULL;

-- Indexes
CREATE INDEX IF NOT EXISTS "AttendanceRecord_sessionId_idx" ON "AttendanceRecord"("sessionId");
CREATE INDEX IF NOT EXISTS "AttendanceRecord_markedAt_idx" ON "AttendanceRecord"("markedAt");
