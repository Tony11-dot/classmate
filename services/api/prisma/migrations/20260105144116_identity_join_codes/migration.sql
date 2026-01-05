/*
  Warnings:

  - A unique constraint covering the columns `[parentId,childId]` on the table `ParentChild` will be added. If there are existing duplicate values, this will fail.
  - Added the required column `grade` to the `Cohort` table without a default value. This is not possible if the table is not empty.

*/
-- CreateEnum
CREATE TYPE "AccountStatus" AS ENUM ('AUTH_ONLY', 'PENDING', 'ACTIVE');

-- CreateEnum
CREATE TYPE "ParentChildStatus" AS ENUM ('PENDING', 'APPROVED');

-- AlterTable
ALTER TABLE "Cohort" ADD COLUMN     "grade" INTEGER NOT NULL;

-- AlterTable
ALTER TABLE "ParentChild" ADD COLUMN     "status" "ParentChildStatus" NOT NULL DEFAULT 'APPROVED';

-- AlterTable
ALTER TABLE "User" ADD COLUMN     "displayName" TEXT,
ADD COLUMN     "legalName" TEXT,
ADD COLUMN     "phone" TEXT,
ADD COLUMN     "status" "AccountStatus" NOT NULL DEFAULT 'AUTH_ONLY',
ADD COLUMN     "tzfonetEmail" TEXT,
ADD COLUMN     "tzfonetVerifiedAt" TIMESTAMP(3);

-- CreateTable
CREATE TABLE "CohortJoinCode" (
    "id" TEXT NOT NULL,
    "cohortId" TEXT NOT NULL,
    "codeHash" TEXT NOT NULL,
    "active" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expiresAt" TIMESTAMP(3),

    CONSTRAINT "CohortJoinCode_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "CohortJoinCode_cohortId_idx" ON "CohortJoinCode"("cohortId");

-- CreateIndex
CREATE UNIQUE INDEX "ParentChild_parentId_childId_key" ON "ParentChild"("parentId", "childId");

-- AddForeignKey
ALTER TABLE "CohortJoinCode" ADD CONSTRAINT "CohortJoinCode_cohortId_fkey" FOREIGN KEY ("cohortId") REFERENCES "Cohort"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ParentChild" ADD CONSTRAINT "ParentChild_parentId_fkey" FOREIGN KEY ("parentId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ParentChild" ADD CONSTRAINT "ParentChild_childId_fkey" FOREIGN KEY ("childId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
