/*
  Warnings:

  - A unique constraint covering the columns `[submissionId,isFinal]` on the table `Grade` will be added. If there are existing duplicate values, this will fail.

*/
-- CreateIndex
CREATE UNIQUE INDEX "Grade_submissionId_isFinal_key" ON "Grade"("submissionId", "isFinal");
