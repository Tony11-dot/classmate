-- CreateTable
CREATE TABLE "SolutionRepost" (
    "id" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "solutionId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,

    CONSTRAINT "SolutionRepost_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "SolutionRepost_solutionId_idx" ON "SolutionRepost"("solutionId");

-- CreateIndex
CREATE INDEX "SolutionRepost_userId_idx" ON "SolutionRepost"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "SolutionRepost_solutionId_userId_key" ON "SolutionRepost"("solutionId", "userId");

-- AddForeignKey
ALTER TABLE "SolutionRepost" ADD CONSTRAINT "SolutionRepost_solutionId_fkey" FOREIGN KEY ("solutionId") REFERENCES "Solution"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SolutionRepost" ADD CONSTRAINT "SolutionRepost_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
