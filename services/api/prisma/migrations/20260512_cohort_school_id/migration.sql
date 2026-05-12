-- AlterTable: add schoolId to Cohort for school isolation
ALTER TABLE "Cohort" ADD COLUMN IF NOT EXISTS "schoolId" TEXT;
