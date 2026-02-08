-- CreateTable
CREATE TABLE "TutorReplyCache" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "characterId" TEXT,
    "normalizedQuestion" TEXT NOT NULL,
    "topic" TEXT,
    "mode" TEXT NOT NULL,
    "content" TEXT NOT NULL,
    "refs" TEXT,
    "excerpt" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expiresAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "TutorReplyCache_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "TutorReplyCache_userId_characterId_idx" ON "TutorReplyCache"("userId", "characterId");

-- CreateIndex
CREATE UNIQUE INDEX "TutorReplyCache_userId_characterId_normalizedQuestion_mode_key" ON "TutorReplyCache"("userId", "characterId", "normalizedQuestion", "mode");
