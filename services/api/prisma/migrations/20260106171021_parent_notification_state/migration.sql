-- CreateTable
CREATE TABLE "ParentNotificationState" (
    "id" TEXT NOT NULL,
    "parentId" TEXT NOT NULL,
    "lastSeenAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ParentNotificationState_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "ParentNotificationState_parentId_key" ON "ParentNotificationState"("parentId");

-- AddForeignKey
ALTER TABLE "ParentNotificationState" ADD CONSTRAINT "ParentNotificationState_parentId_fkey"
FOREIGN KEY ("parentId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
