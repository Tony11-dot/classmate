-- Admin-mediated password change. User types the desired password, admin
-- approves blind (server never reveals the raw value to the admin).
CREATE TABLE IF NOT EXISTS "PasswordChangeRequest" (
  "id"           TEXT PRIMARY KEY,
  "userId"       TEXT NOT NULL,
  "toAdminId"    TEXT NOT NULL,
  "passwordHash" TEXT NOT NULL,
  "status"       TEXT NOT NULL DEFAULT 'PENDING',
  "expiresAt"    TIMESTAMP(3) NOT NULL,
  "createdAt"    TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "resolvedAt"   TIMESTAMP(3),
  CONSTRAINT "PCR_user_fk"  FOREIGN KEY ("userId")    REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT "PCR_admin_fk" FOREIGN KEY ("toAdminId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX IF NOT EXISTS "PasswordChangeRequest_userId_idx"
  ON "PasswordChangeRequest" ("userId");

CREATE INDEX IF NOT EXISTS "PasswordChangeRequest_toAdminId_status_idx"
  ON "PasswordChangeRequest" ("toAdminId", "status");
