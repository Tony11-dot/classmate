-- CreateEnum
CREATE TYPE "MaterialSource" AS ENUM ('BAGrut', 'TEACHER', 'BOOK', 'OTHER');

-- CreateEnum
CREATE TYPE "TutorMessageRole" AS ENUM ('USER', 'ASSISTANT', 'SYSTEM');

-- CreateEnum
CREATE TYPE "AnalyticsActorRole" AS ENUM ('STUDENT', 'PARENT', 'TEACHER', 'SECRETARY', 'ADMIN');

-- CreateTable
CREATE TABLE "Material" (
    "id" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "cohortId" TEXT,
    "courseId" TEXT,
    "title" TEXT NOT NULL,
    "subject" TEXT,
    "grade" INTEGER,
    "language" TEXT,
    "source" "MaterialSource" NOT NULL DEFAULT 'BAGrut',
    "content" TEXT NOT NULL,
    "tags" TEXT[] DEFAULT ARRAY[]::TEXT[],

    CONSTRAINT "Material_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "LearningProfile" (
    "id" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "userId" TEXT NOT NULL,
    "targetCurriculum" TEXT,
    "targetGrade" INTEGER,
    "preferredLanguage" TEXT,
    "tone" TEXT,
    "verbosity" INTEGER,
    "explainStyle" TEXT,
    "emojiOk" BOOLEAN NOT NULL DEFAULT true,
    "strengths" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "weaknesses" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "goals" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "maxDepth" INTEGER,

    CONSTRAINT "LearningProfile_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "StudentBrainSnapshot" (
    "id" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "userId" TEXT NOT NULL,
    "cohortId" TEXT,
    "metrics" JSONB NOT NULL,

    CONSTRAINT "StudentBrainSnapshot_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TutorSession" (
    "id" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "userId" TEXT NOT NULL,
    "courseId" TEXT,
    "cohortId" TEXT,
    "title" TEXT,
    "topic" TEXT,

    CONSTRAINT "TutorSession_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TutorMessage" (
    "id" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "sessionId" TEXT NOT NULL,
    "role" "TutorMessageRole" NOT NULL,
    "content" TEXT NOT NULL,
    "sources" TEXT[] DEFAULT ARRAY[]::TEXT[],

    CONSTRAINT "TutorMessage_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AnalyticsEvent" (
    "id" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "actorUserId" TEXT,
    "actorRole" "AnalyticsActorRole",
    "cohortId" TEXT,
    "courseId" TEXT,
    "studentId" TEXT,
    "name" TEXT NOT NULL,
    "payload" JSONB,

    CONSTRAINT "AnalyticsEvent_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "Material_cohortId_idx" ON "Material"("cohortId");

-- CreateIndex
CREATE INDEX "Material_courseId_idx" ON "Material"("courseId");

-- CreateIndex
CREATE INDEX "Material_subject_idx" ON "Material"("subject");

-- CreateIndex
CREATE UNIQUE INDEX "LearningProfile_userId_key" ON "LearningProfile"("userId");

-- CreateIndex
CREATE INDEX "StudentBrainSnapshot_userId_createdAt_idx" ON "StudentBrainSnapshot"("userId", "createdAt");

-- CreateIndex
CREATE INDEX "StudentBrainSnapshot_cohortId_idx" ON "StudentBrainSnapshot"("cohortId");

-- CreateIndex
CREATE INDEX "TutorSession_userId_updatedAt_idx" ON "TutorSession"("userId", "updatedAt");

-- CreateIndex
CREATE INDEX "TutorSession_cohortId_idx" ON "TutorSession"("cohortId");

-- CreateIndex
CREATE INDEX "TutorSession_courseId_idx" ON "TutorSession"("courseId");

-- CreateIndex
CREATE INDEX "TutorMessage_sessionId_createdAt_idx" ON "TutorMessage"("sessionId", "createdAt");

-- CreateIndex
CREATE INDEX "AnalyticsEvent_name_createdAt_idx" ON "AnalyticsEvent"("name", "createdAt");

-- CreateIndex
CREATE INDEX "AnalyticsEvent_cohortId_idx" ON "AnalyticsEvent"("cohortId");

-- CreateIndex
CREATE INDEX "AnalyticsEvent_courseId_idx" ON "AnalyticsEvent"("courseId");

-- CreateIndex
CREATE INDEX "AnalyticsEvent_studentId_idx" ON "AnalyticsEvent"("studentId");

-- AddForeignKey
ALTER TABLE "TutorMessage" ADD CONSTRAINT "TutorMessage_sessionId_fkey" FOREIGN KEY ("sessionId") REFERENCES "TutorSession"("id") ON DELETE CASCADE ON UPDATE CASCADE;
