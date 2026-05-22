-- Billing layer: NOVA + Practice token economy.
-- Adds the four billing tables (UserSubscription, TokenBalance, TokenUsage,
-- StoreWebhookEvent) + the SubscriptionStatus enum. Idempotent via IF NOT
-- EXISTS guards so re-running on a partially-migrated DB is safe.

DO $$ BEGIN
  CREATE TYPE "SubscriptionStatus" AS ENUM (
    'ACTIVE',
    'IN_GRACE_PERIOD',
    'ON_HOLD',
    'CANCELLED',
    'EXPIRED',
    'REFUNDED'
  );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE TABLE IF NOT EXISTS "UserSubscription" (
  "id"                  TEXT NOT NULL PRIMARY KEY,
  "userId"              TEXT NOT NULL,
  "planTier"            TEXT NOT NULL,
  "status"              "SubscriptionStatus" NOT NULL DEFAULT 'ACTIVE',
  "store"               TEXT NOT NULL,
  "storeTransactionId"  TEXT,
  "rcSubscriptionId"    TEXT,
  "storeProductId"      TEXT,
  "currentPeriodEnd"    TIMESTAMP(3) NOT NULL,
  "startedAt"           TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "cancelledAt"         TIMESTAMP(3),
  "updatedAt"           TIMESTAMP(3) NOT NULL,
  CONSTRAINT "UserSubscription_userId_fkey"
    FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX IF NOT EXISTS "UserSubscription_userId_status_idx"
  ON "UserSubscription"("userId", "status");
CREATE INDEX IF NOT EXISTS "UserSubscription_storeTransactionId_idx"
  ON "UserSubscription"("storeTransactionId");
CREATE INDEX IF NOT EXISTS "UserSubscription_rcSubscriptionId_idx"
  ON "UserSubscription"("rcSubscriptionId");

CREATE TABLE IF NOT EXISTS "TokenBalance" (
  "userId"               TEXT NOT NULL PRIMARY KEY,
  "planTokensRemaining"  INTEGER NOT NULL DEFAULT 0,
  "topupTokensRemaining" INTEGER NOT NULL DEFAULT 0,
  "resetAt"              TIMESTAMP(3),
  "updatedAt"            TIMESTAMP(3) NOT NULL,
  CONSTRAINT "TokenBalance_userId_fkey"
    FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS "TokenUsage" (
  "id"                TEXT NOT NULL PRIMARY KEY,
  "userId"            TEXT NOT NULL,
  "source"            TEXT NOT NULL,
  "model"             TEXT NOT NULL,
  "inputTokens"       INTEGER NOT NULL DEFAULT 0,
  "cachedInputTokens" INTEGER NOT NULL DEFAULT 0,
  "outputTokens"      INTEGER NOT NULL DEFAULT 0,
  "tokensCharged"     INTEGER NOT NULL DEFAULT 0,
  "costUsd"           DOUBLE PRECISION NOT NULL DEFAULT 0,
  "createdAt"         TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "TokenUsage_userId_fkey"
    FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX IF NOT EXISTS "TokenUsage_userId_createdAt_idx"
  ON "TokenUsage"("userId", "createdAt");
CREATE INDEX IF NOT EXISTS "TokenUsage_source_createdAt_idx"
  ON "TokenUsage"("source", "createdAt");

CREATE TABLE IF NOT EXISTS "StoreWebhookEvent" (
  "id"          TEXT NOT NULL PRIMARY KEY,
  "provider"    TEXT NOT NULL,
  "eventType"   TEXT NOT NULL,
  "rcEventId"   TEXT,
  "userId"      TEXT,
  "rawPayload"  JSONB NOT NULL,
  "processedAt" TIMESTAMP(3),
  "receivedAt"  TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX IF NOT EXISTS "StoreWebhookEvent_rcEventId_key"
  ON "StoreWebhookEvent"("rcEventId");
CREATE INDEX IF NOT EXISTS "StoreWebhookEvent_provider_eventType_idx"
  ON "StoreWebhookEvent"("provider", "eventType");
CREATE INDEX IF NOT EXISTS "StoreWebhookEvent_userId_receivedAt_idx"
  ON "StoreWebhookEvent"("userId", "receivedAt");
