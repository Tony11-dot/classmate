-- CreateTable
CREATE TABLE "ParentNotification" (
    "id" TEXT NOT NULL,
    "parentId" TEXT NOT NULL,
    "studentId" TEXT,
    "type" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "message" TEXT,
    "data" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "seenAt" TIMESTAMP(3),

    CONSTRAINT "ParentNotification_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "ParentNotification_parentId_createdAt_idx" ON "ParentNotification"("parentId", "createdAt");

-- CreateIndex
CREATE INDEX "ParentNotification_parentId_seenAt_idx" ON "ParentNotification"("parentId", "seenAt");

-- CreateIndex
CREATE INDEX "ParentNotification_studentId_createdAt_idx" ON "ParentNotification"("studentId", "createdAt");

-- AddForeignKey
ALTER TABLE "ParentNotification" ADD CONSTRAINT "ParentNotification_parentId_fkey" FOREIGN KEY ("parentId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
