-- CreateTable
CREATE TABLE "AlertSettings" (
    "id" TEXT NOT NULL,
    "ownerId" TEXT NOT NULL,
    "studentId" TEXT NOT NULL,
    "minGrade" INTEGER NOT NULL DEFAULT 70,
    "maxAbsences" INTEGER NOT NULL DEFAULT 1,
    "maxLates" INTEGER NOT NULL DEFAULT 3,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "AlertSettings_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "AlertSettings_studentId_idx" ON "AlertSettings"("studentId");

-- CreateIndex
CREATE INDEX "AlertSettings_ownerId_idx" ON "AlertSettings"("ownerId");

-- CreateIndex
CREATE UNIQUE INDEX "AlertSettings_ownerId_studentId_key" ON "AlertSettings"("ownerId", "studentId");
