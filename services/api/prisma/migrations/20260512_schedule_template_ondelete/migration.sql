-- Fix ScheduleTemplateSlot teacher relation to use SetNull on cascade delete
-- This prevents orphaned records when a teacher user is deleted
ALTER TABLE "ScheduleTemplateSlot" DROP CONSTRAINT IF EXISTS "ScheduleTemplateSlot_teacherId_fkey";
ALTER TABLE "ScheduleTemplateSlot" ADD CONSTRAINT "ScheduleTemplateSlot_teacherId_fkey" 
  FOREIGN KEY ("teacherId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;
