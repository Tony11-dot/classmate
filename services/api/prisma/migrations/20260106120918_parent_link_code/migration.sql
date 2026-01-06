-- CreateTable
CREATE TABLE "ParentLinkCode" (
    "id" TEXT NOT NULL,
    "childId" TEXT NOT NULL,
    "codeHash" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ParentLinkCode_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "ParentLinkCode_childId_idx" ON "ParentLinkCode"("childId");

-- CreateIndex
CREATE INDEX "ParentLinkCode_expiresAt_idx" ON "ParentLinkCode"("expiresAt");

-- AddForeignKey
ALTER TABLE "ParentLinkCode" ADD CONSTRAINT "ParentLinkCode_childId_fkey" FOREIGN KEY ("childId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
