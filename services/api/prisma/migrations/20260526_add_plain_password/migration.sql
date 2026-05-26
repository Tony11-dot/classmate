-- Adds User.plainPassword and PasswordChangeRequest.plainPassword. The
-- bcrypt hash in `password` is one-way, so admins who run the
-- student-directory export with passwords included previously had to
-- reset every selected user's password (destructive). Storing the
-- plaintext alongside the hash lets the export reuse the credential
-- the user is already using. Only the admin export endpoint reads
-- User.plainPassword; the PasswordChangeRequest.plainPassword is used
-- internally to propagate plaintext through admin-approved changes,
-- and is never returned to any API.

ALTER TABLE "User"
  ADD COLUMN IF NOT EXISTS "plainPassword" TEXT;

ALTER TABLE "PasswordChangeRequest"
  ADD COLUMN IF NOT EXISTS "plainPassword" TEXT;
