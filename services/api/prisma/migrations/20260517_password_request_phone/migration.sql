-- Captures the phone number the requester typed when filing an Ask-Admin
-- password change request. Admin sees it on their request card and can call
-- or text it to verify identity before approving — defends against someone
-- filing a request using only a username they happen to know.

ALTER TABLE "PasswordChangeRequest"
  ADD COLUMN IF NOT EXISTS "requesterPhone" TEXT;
