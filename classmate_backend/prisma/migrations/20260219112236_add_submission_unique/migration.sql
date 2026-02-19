/*
  Warnings:

  - A unique constraint covering the columns `[assessmentId,studentId]` on the table `Submission` will be added. If there are existing duplicate values, this will fail.

*/
-- CreateIndex
CREATE UNIQUE INDEX "Submission_assessmentId_studentId_key" ON "Submission"("assessmentId", "studentId");
