/*
  Warnings:

  - Added the required column `kind` to the `SolutionImage` table without a default value. This is not possible if the table is not empty.
  - Added the required column `mime` to the `SolutionImage` table without a default value. This is not possible if the table is not empty.
  - Added the required column `sizeBytes` to the `SolutionImage` table without a default value. This is not possible if the table is not empty.
  - Added the required column `storagePath` to the `SolutionImage` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "SolutionImage"
  ADD COLUMN "storagePath" TEXT NOT NULL DEFAULT '',
  ADD COLUMN "kind" TEXT NOT NULL DEFAULT 'image',
  ADD COLUMN "mime" TEXT NOT NULL DEFAULT 'application/octet-stream',
  ADD COLUMN "sizeBytes" INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN "originalName" TEXT,
  ADD COLUMN "sha256" TEXT;

-- CreateIndex
CREATE INDEX "SolutionImage_kind_idx" ON "SolutionImage"("kind");

-- CreateIndex
CREATE INDEX "SolutionImage_mime_idx" ON "SolutionImage"("mime");

-- CreateIndex
CREATE INDEX "SolutionImage_sha256_idx" ON "SolutionImage"("sha256");
