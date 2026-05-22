-- Backfills School.logoUrl — declared in schema.prisma since the
-- school-branding feature landed but never had a migration file.
-- Without this column, /auth/me's school lookup silently fails in the
-- try/catch and returns logoUrl=null, which is one of the paths that
-- can blank the drawer logo on refresh.

ALTER TABLE "School"
  ADD COLUMN IF NOT EXISTS "logoUrl" TEXT;
