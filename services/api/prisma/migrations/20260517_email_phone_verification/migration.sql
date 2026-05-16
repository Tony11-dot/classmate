-- Email + phone verification. Adds two timestamp columns on User to track
-- the last successful verification, and a VerificationCode table holding
-- short-lived 6-digit codes used for both "verify current value" and
-- "change to a new value" flows. The code itself is sent over the matching
-- channel (email or SMS) and only its SHA-256 hash lives in the DB.

ALTER TABLE "User"
  ADD COLUMN IF NOT EXISTS "emailVerifiedAt" TIMESTAMP(3),
  ADD COLUMN IF NOT EXISTS "phoneVerifiedAt" TIMESTAMP(3);

CREATE TABLE IF NOT EXISTS "VerificationCode" (
  "id"        TEXT NOT NULL,
  "userId"    TEXT NOT NULL,
  "channel"   TEXT NOT NULL,
  "kind"      TEXT NOT NULL,
  "target"    TEXT NOT NULL,
  "newValue"  TEXT,
  "codeHash"  TEXT NOT NULL,
  "expiresAt" TIMESTAMP(3) NOT NULL,
  "usedAt"    TIMESTAMP(3),
  "attempts"  INTEGER NOT NULL DEFAULT 0,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "VerificationCode_pkey" PRIMARY KEY ("id"),
  CONSTRAINT "VerificationCode_userId_fkey"
    FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX IF NOT EXISTS "VerificationCode_userId_channel_kind_idx"
  ON "VerificationCode"("userId", "channel", "kind");
CREATE INDEX IF NOT EXISTS "VerificationCode_expiresAt_idx"
  ON "VerificationCode"("expiresAt");
