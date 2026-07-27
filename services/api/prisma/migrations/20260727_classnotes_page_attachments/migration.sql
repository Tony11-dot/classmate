-- ClassNotes page attachments: the voice notes, files and links on a page, so
-- the ClassMate ClassNotes tab can play and open them instead of only showing a
-- flat render of the page. Nullable — pages synced before this have none.
ALTER TABLE "ClassNotesPage" ADD COLUMN IF NOT EXISTS "attachments" JSONB;
