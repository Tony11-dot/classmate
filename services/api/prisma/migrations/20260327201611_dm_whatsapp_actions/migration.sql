-- dm whatsapp actions
DO $$ BEGIN
  CREATE TYPE "DmMessageDeleteMode" AS ENUM (
    'VISIBLE',
    'DELETED_FOR_ME',
    'DELETED_FOR_EVERYONE',
    'MODERATOR_REMOVED'
  );
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

ALTER TABLE "DmMessage"
  ADD COLUMN IF NOT EXISTS "isPinned" BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS "editedAt" TIMESTAMP(3),
  ADD COLUMN IF NOT EXISTS "deletedAt" TIMESTAMP(3),
  ADD COLUMN IF NOT EXISTS "deleteMode" "DmMessageDeleteMode" NOT NULL DEFAULT 'VISIBLE',
  ADD COLUMN IF NOT EXISTS "forwardedFromId" TEXT;

DO $$ BEGIN
  ALTER TABLE "DmMessage"
    ADD CONSTRAINT "DmMessage_forwardedFromId_fkey"
    FOREIGN KEY ("forwardedFromId") REFERENCES "DmMessage"("id")
    ON DELETE SET NULL ON UPDATE CASCADE;
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

CREATE INDEX IF NOT EXISTS "DmMessage_forwardedFromId_idx" ON "DmMessage"("forwardedFromId");
CREATE INDEX IF NOT EXISTS "DmMessage_replyToMessageId_idx" ON "DmMessage"("replyToMessageId");
CREATE INDEX IF NOT EXISTS "DmMessage_threadId_createdAt_idx" ON "DmMessage"("threadId", "createdAt");
