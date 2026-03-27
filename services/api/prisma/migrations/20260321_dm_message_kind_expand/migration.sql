-- dm message kind expand
DO $$ BEGIN
  ALTER TYPE "DmMessageKind" ADD VALUE 'VOICE';
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  ALTER TYPE "DmMessageKind" ADD VALUE 'VIDEO';
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  ALTER TYPE "DmMessageKind" ADD VALUE 'FILE';
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;
