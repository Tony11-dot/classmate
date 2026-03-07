-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "public";

-- CreateEnum
CREATE TYPE "Role" AS ENUM ('STUDENT', 'TEACHER', 'ADMIN', 'PARENT', 'SECRETARY');

-- CreateEnum
CREATE TYPE "AccountStatus" AS ENUM ('AUTH_ONLY', 'PENDING', 'ACTIVE');

-- CreateEnum
CREATE TYPE "ParentChildStatus" AS ENUM ('PENDING', 'APPROVED');

-- CreateEnum
CREATE TYPE "CourseRuleType" AS ENUM ('COHORT', 'ENGLISH_LEVEL', 'MATH_LEVEL', 'MAJOR_REQUIRED', 'ELECTIVE_OPT_IN');

-- CreateEnum
CREATE TYPE "EnrollmentSource" AS ENUM ('AUTO', 'MANUAL');

-- CreateEnum
CREATE TYPE "AttendanceStatus" AS ENUM ('PRESENT', 'ABSENT', 'LATE', 'EXCUSED');

-- CreateEnum
CREATE TYPE "MaterialSource" AS ENUM ('BAGRUT', 'TEACHER', 'BOOK', 'OTHER');

-- CreateEnum
CREATE TYPE "TutorMessageRole" AS ENUM ('USER', 'ASSISTANT', 'SYSTEM');

-- CreateEnum
CREATE TYPE "AnalyticsActorRole" AS ENUM ('STUDENT', 'PARENT', 'TEACHER', 'SECRETARY', 'ADMIN');

-- CreateEnum
CREATE TYPE "BrainEventType" AS ENUM ('CHAT_MESSAGE', 'QUIZ_ATTEMPT', 'QUIZ_RESULT', 'MISTAKE', 'HINT_USED', 'CONCEPT_EXPLAINED', 'CONFUSION', 'PREFERENCE');

-- CreateEnum
CREATE TYPE "BrainSkillStatus" AS ENUM ('UNKNOWN', 'LEARNING', 'OK', 'STRONG');

-- CreateEnum
CREATE TYPE "TutorCharacterSubject" AS ENUM ('GENERAL', 'MATH', 'PHYSICS', 'CS', 'ENGLISH', 'HEBREW', 'ARABIC');

-- CreateEnum
CREATE TYPE "ScheduleTemplateKind" AS ENUM ('GRADE', 'MAJOR', 'COHORT', 'STUDENT');

-- CreateEnum
CREATE TYPE "ClassroomMessageKind" AS ENUM ('TEXT', 'VOICE', 'IMAGE', 'DOC');

-- CreateTable
CREATE TABLE "User" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "displayName" TEXT,
    "legalName" TEXT,
    "phone" TEXT,
    "status" "AccountStatus" NOT NULL DEFAULT 'AUTH_ONLY',
    "tzfonetEmail" TEXT,
    "tzfonetVerifiedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "UserRole" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "role" "Role" NOT NULL,

    CONSTRAINT "UserRole_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Cohort" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "grade" INTEGER NOT NULL,

    CONSTRAINT "Cohort_pkey" PRIMARY KEY ("id")
);

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

-- CreateTable
CREATE TABLE "StudentProfile" (
    "userId" TEXT NOT NULL,
    "cohortId" TEXT NOT NULL,
    "englishLevel" INTEGER NOT NULL,
    "mathLevel" INTEGER NOT NULL,

    CONSTRAINT "StudentProfile_pkey" PRIMARY KEY ("userId")
);

-- CreateTable
CREATE TABLE "ParentChild" (
    "id" TEXT NOT NULL,
    "parentId" TEXT NOT NULL,
    "childId" TEXT NOT NULL,
    "status" "ParentChildStatus" NOT NULL DEFAULT 'APPROVED',

    CONSTRAINT "ParentChild_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Major" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,

    CONSTRAINT "Major_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "StudentMajor" (
    "id" TEXT NOT NULL,
    "studentId" TEXT NOT NULL,
    "majorId" TEXT NOT NULL,

    CONSTRAINT "StudentMajor_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Course" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "subject" TEXT NOT NULL,
    "teacherId" TEXT,
    "cohortId" TEXT,
    "groupTag" TEXT,

    CONSTRAINT "Course_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CourseRule" (
    "id" TEXT NOT NULL,
    "courseId" TEXT NOT NULL,
    "type" "CourseRuleType" NOT NULL,
    "value" TEXT NOT NULL,

    CONSTRAINT "CourseRule_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Enrollment" (
    "id" TEXT NOT NULL,
    "courseId" TEXT NOT NULL,
    "studentId" TEXT NOT NULL,
    "source" "EnrollmentSource" NOT NULL DEFAULT 'AUTO',

    CONSTRAINT "Enrollment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ScheduleSlot" (
    "id" TEXT NOT NULL,
    "cohortId" TEXT NOT NULL,
    "dayOfWeek" INTEGER NOT NULL,
    "period" INTEGER NOT NULL,
    "courseId" TEXT,

    CONSTRAINT "ScheduleSlot_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ScheduleOverride" (
    "id" TEXT NOT NULL,
    "cohortId" TEXT NOT NULL,
    "date" TIMESTAMP(3) NOT NULL,
    "period" INTEGER NOT NULL,
    "courseId" TEXT,

    CONSTRAINT "ScheduleOverride_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AttendanceSession" (
    "id" TEXT NOT NULL,
    "cohortId" TEXT NOT NULL,
    "date" TIMESTAMP(3) NOT NULL,
    "period" INTEGER NOT NULL,
    "courseId" TEXT,

    CONSTRAINT "AttendanceSession_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AttendanceRecord" (
    "id" TEXT NOT NULL,
    "sessionId" TEXT NOT NULL,
    "studentId" TEXT NOT NULL,
    "status" "AttendanceStatus" NOT NULL DEFAULT 'PRESENT',
    "note" TEXT,
    "markedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "AttendanceRecord_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Assessment" (
    "id" TEXT NOT NULL,
    "courseId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "date" TIMESTAMP(3) NOT NULL,
    "maxGrade" INTEGER NOT NULL DEFAULT 100,
    "createdBy" TEXT NOT NULL,

    CONSTRAINT "Assessment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "GradeRecord" (
    "id" TEXT NOT NULL,
    "assessmentId" TEXT NOT NULL,
    "studentId" TEXT NOT NULL,
    "grade" INTEGER NOT NULL,
    "comment" TEXT,

    CONSTRAINT "GradeRecord_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ParentLinkCode" (
    "id" TEXT NOT NULL,
    "childId" TEXT NOT NULL,
    "codeHash" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ParentLinkCode_pkey" PRIMARY KEY ("id")
);

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

-- CreateTable
CREATE TABLE "ParentNotificationState" (
    "id" TEXT NOT NULL,
    "parentId" TEXT NOT NULL,
    "lastSeenAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ParentNotificationState_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Announcement" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "body" TEXT NOT NULL,
    "createdBy" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "publishAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expiresAt" TIMESTAMP(3),
    "pinned" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "Announcement_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AnnouncementTarget" (
    "id" TEXT NOT NULL,
    "announcementId" TEXT NOT NULL,
    "userId" TEXT,
    "role" "Role",
    "grade" INTEGER,
    "cohortId" TEXT,

    CONSTRAINT "AnnouncementTarget_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AnnouncementSeen" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "announcementId" TEXT NOT NULL,
    "seenAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AnnouncementSeen_pkey" PRIMARY KEY ("id")
);

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
    "source" "MaterialSource" NOT NULL DEFAULT 'BAGRUT',
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
CREATE TABLE "StudentBrainProfile" (
    "id" TEXT NOT NULL,
    "studentId" TEXT NOT NULL,
    "preferredLanguage" TEXT,
    "verbosity" TEXT,
    "quizFrequency" TEXT,
    "tone" TEXT,
    "humor" TEXT,
    "addressName" TEXT,
    "baselineSummary" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "StudentBrainProfile_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "StudentBrainSkill" (
    "id" TEXT NOT NULL,
    "studentId" TEXT NOT NULL,
    "subject" TEXT NOT NULL,
    "topic" TEXT NOT NULL,
    "status" "BrainSkillStatus" NOT NULL DEFAULT 'UNKNOWN',
    "strength" INTEGER NOT NULL DEFAULT 0,
    "lastSeenAt" TIMESTAMP(3),
    "evidenceCount" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "StudentBrainSkill_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "StudentBrainEvent" (
    "id" TEXT NOT NULL,
    "studentId" TEXT NOT NULL,
    "type" "BrainEventType" NOT NULL,
    "subject" TEXT,
    "topic" TEXT,
    "payload" TEXT,
    "tutorSessionId" TEXT,
    "tutorMessageId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "StudentBrainEvent_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "StudentBrainSummary" (
    "id" TEXT NOT NULL,
    "studentId" TEXT NOT NULL,
    "summary" TEXT NOT NULL,
    "lastEventAt" TIMESTAMP(3),
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "StudentBrainSummary_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TutorSession" (
    "id" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "characterId" TEXT,
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

-- CreateTable
CREATE TABLE "TutorCharacter" (
    "id" TEXT NOT NULL,
    "createdById" TEXT,
    "isPublic" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "cohortId" TEXT,
    "subject" "TutorCharacterSubject" NOT NULL DEFAULT 'GENERAL',
    "name" TEXT NOT NULL,
    "tone" TEXT,
    "verbosity" INTEGER,
    "explainStyle" TEXT,
    "curriculum" TEXT,
    "maxGrade" INTEGER,
    "language" TEXT,
    "systemNotes" TEXT,

    CONSTRAINT "TutorCharacter_pkey" PRIMARY KEY ("id")
);

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

-- CreateTable
CREATE TABLE "Solution" (
    "id" TEXT NOT NULL,
    "authorId" TEXT NOT NULL,
    "subject" TEXT NOT NULL,
    "sourceType" TEXT NOT NULL,
    "sourceName" TEXT,
    "page" INTEGER,
    "questionNumber" TEXT,
    "title" TEXT,
    "notes" TEXT,
    "body" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Solution_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SolutionImage" (
    "id" TEXT NOT NULL,
    "solutionId" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "storagePath" TEXT NOT NULL,
    "kind" TEXT NOT NULL,
    "mime" TEXT NOT NULL,
    "sizeBytes" INTEGER NOT NULL,
    "originalName" TEXT,
    "sha256" TEXT,
    "width" INTEGER,
    "height" INTEGER,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "SolutionImage_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SolutionLike" (
    "id" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "solutionId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,

    CONSTRAINT "SolutionLike_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SolutionComment" (
    "id" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "body" TEXT NOT NULL,
    "solutionId" TEXT NOT NULL,
    "authorId" TEXT NOT NULL,

    CONSTRAINT "SolutionComment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Notification" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "body" TEXT,
    "data" JSONB,
    "severity" TEXT NOT NULL DEFAULT 'info',
    "seenAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Notification_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SchoolGradeSubjectDefault" (
    "id" TEXT NOT NULL,
    "schoolId" TEXT NOT NULL,
    "grade" INTEGER NOT NULL,
    "subjects" TEXT[],
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "SchoolGradeSubjectDefault_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "StudentSubjectOverride" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "enabled" BOOLEAN NOT NULL DEFAULT true,
    "subjects" TEXT[],
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "StudentSubjectOverride_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ScheduleTemplate" (
    "id" TEXT NOT NULL,
    "schoolId" TEXT NOT NULL,
    "kind" "ScheduleTemplateKind" NOT NULL,
    "name" TEXT NOT NULL,
    "grade" INTEGER,
    "section" INTEGER,
    "major" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ScheduleTemplate_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ScheduleTemplateSlot" (
    "id" TEXT NOT NULL,
    "templateId" TEXT NOT NULL,
    "dayOfWeek" INTEGER NOT NULL,
    "period" INTEGER NOT NULL,
    "courseId" TEXT,
    "teacherId" TEXT,
    "location" TEXT,

    CONSTRAINT "ScheduleTemplateSlot_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CohortScheduleTemplate" (
    "id" TEXT NOT NULL,
    "cohortId" TEXT NOT NULL,
    "templateId" TEXT NOT NULL,
    "priority" INTEGER NOT NULL DEFAULT 50,

    CONSTRAINT "CohortScheduleTemplate_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "StudentScheduleTemplate" (
    "id" TEXT NOT NULL,
    "studentId" TEXT NOT NULL,
    "templateId" TEXT NOT NULL,
    "priority" INTEGER NOT NULL DEFAULT 10,

    CONSTRAINT "StudentScheduleTemplate_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ClassroomMessage" (
    "id" TEXT NOT NULL,
    "courseId" TEXT NOT NULL,
    "senderUserId" TEXT NOT NULL,
    "kind" "ClassroomMessageKind" NOT NULL DEFAULT 'TEXT',
    "text" TEXT,
    "mediaUrl" TEXT,
    "mediaMime" TEXT,
    "durationSec" INTEGER,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ClassroomMessage_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ClassroomAssignment" (
    "id" TEXT NOT NULL,
    "courseId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "body" TEXT,
    "dueAt" TIMESTAMP(3),
    "createdBy" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ClassroomAssignment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ClassroomMaterial" (
    "id" TEXT NOT NULL,
    "courseId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "url" TEXT NOT NULL,
    "mime" TEXT,
    "createdBy" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ClassroomMaterial_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ClassroomMeeting" (
    "id" TEXT NOT NULL,
    "courseId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "startsAt" TIMESTAMP(3) NOT NULL,
    "endsAt" TIMESTAMP(3),
    "link" TEXT NOT NULL,
    "createdBy" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ClassroomMeeting_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "outbox_events" (
    "id" UUID NOT NULL,
    "type" TEXT NOT NULL,
    "aggregate_id" UUID,
    "payload" JSONB NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "available_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "processed_at" TIMESTAMP(3),
    "failed_at" TIMESTAMP(3),
    "retry_count" INTEGER NOT NULL DEFAULT 0,
    "error" TEXT,

    CONSTRAINT "outbox_events_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "feed_solution_cards" (
    "solution_id" UUID NOT NULL,
    "school_id" UUID NOT NULL,
    "class_id" UUID,
    "author_id" UUID NOT NULL,
    "author_name" TEXT NOT NULL,
    "subject" TEXT NOT NULL,
    "source_type" TEXT NOT NULL,
    "source_name" TEXT,
    "page" INTEGER,
    "question_number" TEXT,
    "title" TEXT,
    "body_preview" TEXT,
    "primary_image_url" TEXT,
    "image_count" INTEGER NOT NULL DEFAULT 0,
    "like_count" INTEGER NOT NULL DEFAULT 0,
    "comment_count" INTEGER NOT NULL DEFAULT 0,
    "repost_count" INTEGER NOT NULL DEFAULT 0,
    "ranking_score" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "teacher_pick" BOOLEAN NOT NULL DEFAULT false,
    "best_solution" BOOLEAN NOT NULL DEFAULT false,
    "difficulty" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "feed_solution_cards_pkey" PRIMARY KEY ("solution_id")
);

-- CreateTable
CREATE TABLE "classroom_preview_cards" (
    "classroom_id" UUID NOT NULL,
    "school_id" UUID,
    "title" TEXT NOT NULL,
    "subject" TEXT,
    "latest_message_text" TEXT,
    "latest_message_at" TIMESTAMP(3),
    "latest_sender_name" TEXT,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "classroom_preview_cards_pkey" PRIMARY KEY ("classroom_id")
);

-- CreateTable
CREATE TABLE "classroom_user_counters" (
    "id" UUID NOT NULL,
    "classroom_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "unread_count" INTEGER NOT NULL DEFAULT 0,
    "last_seen_message_id" UUID,
    "last_seen_at" TIMESTAMP(3),
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "classroom_user_counters_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "weekly_solver_leaderboard" (
    "id" UUID NOT NULL,
    "school_id" UUID NOT NULL,
    "week_key" TEXT NOT NULL,
    "user_id" UUID NOT NULL,
    "user_name" TEXT NOT NULL,
    "solution_count" INTEGER NOT NULL DEFAULT 0,
    "like_count_received" INTEGER NOT NULL DEFAULT 0,
    "comment_count_received" INTEGER NOT NULL DEFAULT 0,
    "repost_count_received" INTEGER NOT NULL DEFAULT 0,
    "score" DOUBLE PRECISION NOT NULL DEFAULT 0,

    CONSTRAINT "weekly_solver_leaderboard_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- CreateIndex
CREATE UNIQUE INDEX "UserRole_userId_role_key" ON "UserRole"("userId", "role");

-- CreateIndex
CREATE UNIQUE INDEX "Cohort_name_key" ON "Cohort"("name");

-- CreateIndex
CREATE INDEX "CohortJoinCode_cohortId_idx" ON "CohortJoinCode"("cohortId");

-- CreateIndex
CREATE INDEX "StudentProfile_cohortId_idx" ON "StudentProfile"("cohortId");

-- CreateIndex
CREATE INDEX "ParentChild_parentId_idx" ON "ParentChild"("parentId");

-- CreateIndex
CREATE INDEX "ParentChild_childId_idx" ON "ParentChild"("childId");

-- CreateIndex
CREATE UNIQUE INDEX "ParentChild_parentId_childId_key" ON "ParentChild"("parentId", "childId");

-- CreateIndex
CREATE UNIQUE INDEX "Major_name_key" ON "Major"("name");

-- CreateIndex
CREATE INDEX "StudentMajor_majorId_idx" ON "StudentMajor"("majorId");

-- CreateIndex
CREATE UNIQUE INDEX "StudentMajor_studentId_majorId_key" ON "StudentMajor"("studentId", "majorId");

-- CreateIndex
CREATE INDEX "Course_teacherId_idx" ON "Course"("teacherId");

-- CreateIndex
CREATE INDEX "Course_cohortId_idx" ON "Course"("cohortId");

-- CreateIndex
CREATE INDEX "CourseRule_courseId_idx" ON "CourseRule"("courseId");

-- CreateIndex
CREATE INDEX "Enrollment_studentId_idx" ON "Enrollment"("studentId");

-- CreateIndex
CREATE UNIQUE INDEX "Enrollment_courseId_studentId_key" ON "Enrollment"("courseId", "studentId");

-- CreateIndex
CREATE INDEX "ScheduleSlot_courseId_idx" ON "ScheduleSlot"("courseId");

-- CreateIndex
CREATE UNIQUE INDEX "ScheduleSlot_cohortId_dayOfWeek_period_key" ON "ScheduleSlot"("cohortId", "dayOfWeek", "period");

-- CreateIndex
CREATE INDEX "ScheduleOverride_courseId_idx" ON "ScheduleOverride"("courseId");

-- CreateIndex
CREATE INDEX "ScheduleOverride_cohortId_date_idx" ON "ScheduleOverride"("cohortId", "date");

-- CreateIndex
CREATE UNIQUE INDEX "ScheduleOverride_cohortId_date_period_key" ON "ScheduleOverride"("cohortId", "date", "period");

-- CreateIndex
CREATE INDEX "AttendanceSession_courseId_idx" ON "AttendanceSession"("courseId");

-- CreateIndex
CREATE INDEX "AttendanceSession_cohortId_date_idx" ON "AttendanceSession"("cohortId", "date");

-- CreateIndex
CREATE UNIQUE INDEX "AttendanceSession_cohortId_date_period_key" ON "AttendanceSession"("cohortId", "date", "period");

-- CreateIndex
CREATE INDEX "AttendanceRecord_studentId_idx" ON "AttendanceRecord"("studentId");

-- CreateIndex
CREATE INDEX "AttendanceRecord_sessionId_idx" ON "AttendanceRecord"("sessionId");

-- CreateIndex
CREATE INDEX "AttendanceRecord_markedAt_idx" ON "AttendanceRecord"("markedAt");

-- CreateIndex
CREATE UNIQUE INDEX "AttendanceRecord_sessionId_studentId_key" ON "AttendanceRecord"("sessionId", "studentId");

-- CreateIndex
CREATE INDEX "Assessment_courseId_idx" ON "Assessment"("courseId");

-- CreateIndex
CREATE INDEX "Assessment_createdBy_idx" ON "Assessment"("createdBy");

-- CreateIndex
CREATE INDEX "GradeRecord_studentId_idx" ON "GradeRecord"("studentId");

-- CreateIndex
CREATE UNIQUE INDEX "GradeRecord_assessmentId_studentId_key" ON "GradeRecord"("assessmentId", "studentId");

-- CreateIndex
CREATE INDEX "ParentLinkCode_childId_idx" ON "ParentLinkCode"("childId");

-- CreateIndex
CREATE INDEX "ParentLinkCode_expiresAt_idx" ON "ParentLinkCode"("expiresAt");

-- CreateIndex
CREATE INDEX "ParentNotification_parentId_createdAt_idx" ON "ParentNotification"("parentId", "createdAt");

-- CreateIndex
CREATE INDEX "ParentNotification_parentId_seenAt_idx" ON "ParentNotification"("parentId", "seenAt");

-- CreateIndex
CREATE INDEX "ParentNotification_studentId_createdAt_idx" ON "ParentNotification"("studentId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "ParentNotificationState_parentId_key" ON "ParentNotificationState"("parentId");

-- CreateIndex
CREATE INDEX "Announcement_publishAt_idx" ON "Announcement"("publishAt");

-- CreateIndex
CREATE INDEX "Announcement_expiresAt_idx" ON "Announcement"("expiresAt");

-- CreateIndex
CREATE INDEX "Announcement_pinned_idx" ON "Announcement"("pinned");

-- CreateIndex
CREATE INDEX "Announcement_createdBy_idx" ON "Announcement"("createdBy");

-- CreateIndex
CREATE INDEX "AnnouncementTarget_announcementId_idx" ON "AnnouncementTarget"("announcementId");

-- CreateIndex
CREATE INDEX "AnnouncementTarget_userId_idx" ON "AnnouncementTarget"("userId");

-- CreateIndex
CREATE INDEX "AnnouncementTarget_role_idx" ON "AnnouncementTarget"("role");

-- CreateIndex
CREATE INDEX "AnnouncementTarget_grade_idx" ON "AnnouncementTarget"("grade");

-- CreateIndex
CREATE INDEX "AnnouncementTarget_cohortId_idx" ON "AnnouncementTarget"("cohortId");

-- CreateIndex
CREATE INDEX "AnnouncementSeen_userId_idx" ON "AnnouncementSeen"("userId");

-- CreateIndex
CREATE INDEX "AnnouncementSeen_announcementId_idx" ON "AnnouncementSeen"("announcementId");

-- CreateIndex
CREATE UNIQUE INDEX "AnnouncementSeen_userId_announcementId_key" ON "AnnouncementSeen"("userId", "announcementId");

-- CreateIndex
CREATE INDEX "AlertSettings_studentId_idx" ON "AlertSettings"("studentId");

-- CreateIndex
CREATE INDEX "AlertSettings_ownerId_idx" ON "AlertSettings"("ownerId");

-- CreateIndex
CREATE UNIQUE INDEX "AlertSettings_ownerId_studentId_key" ON "AlertSettings"("ownerId", "studentId");

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
CREATE UNIQUE INDEX "StudentBrainProfile_studentId_key" ON "StudentBrainProfile"("studentId");

-- CreateIndex
CREATE INDEX "StudentBrainProfile_studentId_idx" ON "StudentBrainProfile"("studentId");

-- CreateIndex
CREATE INDEX "StudentBrainSkill_studentId_subject_idx" ON "StudentBrainSkill"("studentId", "subject");

-- CreateIndex
CREATE UNIQUE INDEX "StudentBrainSkill_studentId_subject_topic_key" ON "StudentBrainSkill"("studentId", "subject", "topic");

-- CreateIndex
CREATE INDEX "StudentBrainEvent_studentId_createdAt_idx" ON "StudentBrainEvent"("studentId", "createdAt");

-- CreateIndex
CREATE INDEX "StudentBrainEvent_tutorSessionId_idx" ON "StudentBrainEvent"("tutorSessionId");

-- CreateIndex
CREATE UNIQUE INDEX "StudentBrainSummary_studentId_key" ON "StudentBrainSummary"("studentId");

-- CreateIndex
CREATE INDEX "StudentBrainSummary_studentId_idx" ON "StudentBrainSummary"("studentId");

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

-- CreateIndex
CREATE INDEX "TutorCharacter_cohortId_idx" ON "TutorCharacter"("cohortId");

-- CreateIndex
CREATE INDEX "TutorCharacter_subject_idx" ON "TutorCharacter"("subject");

-- CreateIndex
CREATE INDEX "TutorCharacter_cohortId_subject_idx" ON "TutorCharacter"("cohortId", "subject");

-- CreateIndex
CREATE INDEX "TutorCharacter_isPublic_subject_idx" ON "TutorCharacter"("isPublic", "subject");

-- CreateIndex
CREATE UNIQUE INDEX "TutorCharacter_cohortId_subject_name_key" ON "TutorCharacter"("cohortId", "subject", "name");

-- CreateIndex
CREATE INDEX "TutorReplyCache_userId_characterId_idx" ON "TutorReplyCache"("userId", "characterId");

-- CreateIndex
CREATE UNIQUE INDEX "TutorReplyCache_userId_characterId_normalizedQuestion_mode_key" ON "TutorReplyCache"("userId", "characterId", "normalizedQuestion", "mode");

-- CreateIndex
CREATE INDEX "Solution_createdAt_idx" ON "Solution"("createdAt");

-- CreateIndex
CREATE INDEX "Solution_subject_sourceType_idx" ON "Solution"("subject", "sourceType");

-- CreateIndex
CREATE INDEX "Solution_subject_sourceName_page_idx" ON "Solution"("subject", "sourceName", "page");

-- CreateIndex
CREATE INDEX "Solution_subject_sourceName_page_questionNumber_idx" ON "Solution"("subject", "sourceName", "page", "questionNumber");

-- CreateIndex
CREATE INDEX "Solution_createdAt_id_idx" ON "Solution"("createdAt", "id");

-- CreateIndex
CREATE UNIQUE INDEX "Solution_createdAt_id_key" ON "Solution"("createdAt", "id");

-- CreateIndex
CREATE INDEX "SolutionImage_solutionId_idx" ON "SolutionImage"("solutionId");

-- CreateIndex
CREATE INDEX "SolutionImage_kind_idx" ON "SolutionImage"("kind");

-- CreateIndex
CREATE INDEX "SolutionImage_mime_idx" ON "SolutionImage"("mime");

-- CreateIndex
CREATE INDEX "SolutionImage_sha256_idx" ON "SolutionImage"("sha256");

-- CreateIndex
CREATE INDEX "SolutionLike_solutionId_idx" ON "SolutionLike"("solutionId");

-- CreateIndex
CREATE INDEX "SolutionLike_userId_idx" ON "SolutionLike"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "SolutionLike_solutionId_userId_key" ON "SolutionLike"("solutionId", "userId");

-- CreateIndex
CREATE INDEX "SolutionComment_solutionId_createdAt_idx" ON "SolutionComment"("solutionId", "createdAt");

-- CreateIndex
CREATE INDEX "SolutionComment_authorId_idx" ON "SolutionComment"("authorId");

-- CreateIndex
CREATE INDEX "Notification_userId_createdAt_idx" ON "Notification"("userId", "createdAt");

-- CreateIndex
CREATE INDEX "Notification_userId_seenAt_idx" ON "Notification"("userId", "seenAt");

-- CreateIndex
CREATE INDEX "SchoolGradeSubjectDefault_schoolId_idx" ON "SchoolGradeSubjectDefault"("schoolId");

-- CreateIndex
CREATE UNIQUE INDEX "SchoolGradeSubjectDefault_schoolId_grade_key" ON "SchoolGradeSubjectDefault"("schoolId", "grade");

-- CreateIndex
CREATE INDEX "StudentSubjectOverride_userId_idx" ON "StudentSubjectOverride"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "StudentSubjectOverride_userId_key" ON "StudentSubjectOverride"("userId");

-- CreateIndex
CREATE INDEX "ScheduleTemplate_schoolId_kind_idx" ON "ScheduleTemplate"("schoolId", "kind");

-- CreateIndex
CREATE INDEX "ScheduleTemplate_schoolId_grade_section_idx" ON "ScheduleTemplate"("schoolId", "grade", "section");

-- CreateIndex
CREATE INDEX "ScheduleTemplate_schoolId_major_idx" ON "ScheduleTemplate"("schoolId", "major");

-- CreateIndex
CREATE INDEX "ScheduleTemplateSlot_templateId_dayOfWeek_period_idx" ON "ScheduleTemplateSlot"("templateId", "dayOfWeek", "period");

-- CreateIndex
CREATE UNIQUE INDEX "ScheduleTemplateSlot_templateId_dayOfWeek_period_key" ON "ScheduleTemplateSlot"("templateId", "dayOfWeek", "period");

-- CreateIndex
CREATE INDEX "CohortScheduleTemplate_cohortId_priority_idx" ON "CohortScheduleTemplate"("cohortId", "priority");

-- CreateIndex
CREATE INDEX "CohortScheduleTemplate_templateId_idx" ON "CohortScheduleTemplate"("templateId");

-- CreateIndex
CREATE UNIQUE INDEX "CohortScheduleTemplate_cohortId_templateId_key" ON "CohortScheduleTemplate"("cohortId", "templateId");

-- CreateIndex
CREATE INDEX "StudentScheduleTemplate_studentId_priority_idx" ON "StudentScheduleTemplate"("studentId", "priority");

-- CreateIndex
CREATE INDEX "StudentScheduleTemplate_templateId_idx" ON "StudentScheduleTemplate"("templateId");

-- CreateIndex
CREATE UNIQUE INDEX "StudentScheduleTemplate_studentId_templateId_key" ON "StudentScheduleTemplate"("studentId", "templateId");

-- CreateIndex
CREATE INDEX "ClassroomMessage_courseId_createdAt_idx" ON "ClassroomMessage"("courseId", "createdAt");

-- CreateIndex
CREATE INDEX "ClassroomMessage_senderUserId_createdAt_idx" ON "ClassroomMessage"("senderUserId", "createdAt");

-- CreateIndex
CREATE INDEX "ClassroomAssignment_courseId_createdAt_idx" ON "ClassroomAssignment"("courseId", "createdAt");

-- CreateIndex
CREATE INDEX "ClassroomAssignment_courseId_dueAt_idx" ON "ClassroomAssignment"("courseId", "dueAt");

-- CreateIndex
CREATE INDEX "ClassroomMaterial_courseId_createdAt_idx" ON "ClassroomMaterial"("courseId", "createdAt");

-- CreateIndex
CREATE INDEX "ClassroomMeeting_courseId_startsAt_idx" ON "ClassroomMeeting"("courseId", "startsAt");

-- CreateIndex
CREATE INDEX "ClassroomMeeting_courseId_createdAt_idx" ON "ClassroomMeeting"("courseId", "createdAt");

-- CreateIndex
CREATE INDEX "idx_outbox_process_queue" ON "outbox_events"("processed_at", "available_at", "created_at");

-- CreateIndex
CREATE INDEX "idx_outbox_type_created_at" ON "outbox_events"("type", "created_at");

-- CreateIndex
CREATE INDEX "idx_feed_solution_cards_school_rank_created" ON "feed_solution_cards"("school_id", "ranking_score", "created_at");

-- CreateIndex
CREATE INDEX "idx_feed_solution_cards_school_subject_rank" ON "feed_solution_cards"("school_id", "subject", "ranking_score");

-- CreateIndex
CREATE INDEX "idx_feed_solution_cards_lookup" ON "feed_solution_cards"("school_id", "source_name", "page", "question_number");

-- CreateIndex
CREATE INDEX "idx_classroom_preview_cards_school_latest" ON "classroom_preview_cards"("school_id", "latest_message_at");

-- CreateIndex
CREATE INDEX "idx_classroom_user_counters_user_unread" ON "classroom_user_counters"("user_id", "unread_count");

-- CreateIndex
CREATE UNIQUE INDEX "uq_classroom_user_counters_classroom_user" ON "classroom_user_counters"("classroom_id", "user_id");

-- CreateIndex
CREATE INDEX "idx_weekly_solver_leaderboard_rank" ON "weekly_solver_leaderboard"("school_id", "week_key", "score");

-- CreateIndex
CREATE UNIQUE INDEX "uq_weekly_solver_leaderboard_school_week_user" ON "weekly_solver_leaderboard"("school_id", "week_key", "user_id");

-- AddForeignKey
ALTER TABLE "UserRole" ADD CONSTRAINT "UserRole_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CohortJoinCode" ADD CONSTRAINT "CohortJoinCode_cohortId_fkey" FOREIGN KEY ("cohortId") REFERENCES "Cohort"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "StudentProfile" ADD CONSTRAINT "StudentProfile_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "StudentProfile" ADD CONSTRAINT "StudentProfile_cohortId_fkey" FOREIGN KEY ("cohortId") REFERENCES "Cohort"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ParentChild" ADD CONSTRAINT "ParentChild_parentId_fkey" FOREIGN KEY ("parentId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ParentChild" ADD CONSTRAINT "ParentChild_childId_fkey" FOREIGN KEY ("childId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "StudentMajor" ADD CONSTRAINT "StudentMajor_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "StudentProfile"("userId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "StudentMajor" ADD CONSTRAINT "StudentMajor_majorId_fkey" FOREIGN KEY ("majorId") REFERENCES "Major"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Course" ADD CONSTRAINT "Course_teacherId_fkey" FOREIGN KEY ("teacherId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Course" ADD CONSTRAINT "Course_cohortId_fkey" FOREIGN KEY ("cohortId") REFERENCES "Cohort"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CourseRule" ADD CONSTRAINT "CourseRule_courseId_fkey" FOREIGN KEY ("courseId") REFERENCES "Course"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Enrollment" ADD CONSTRAINT "Enrollment_courseId_fkey" FOREIGN KEY ("courseId") REFERENCES "Course"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Enrollment" ADD CONSTRAINT "Enrollment_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "StudentProfile"("userId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ScheduleSlot" ADD CONSTRAINT "ScheduleSlot_cohortId_fkey" FOREIGN KEY ("cohortId") REFERENCES "Cohort"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ScheduleSlot" ADD CONSTRAINT "ScheduleSlot_courseId_fkey" FOREIGN KEY ("courseId") REFERENCES "Course"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ScheduleOverride" ADD CONSTRAINT "ScheduleOverride_cohortId_fkey" FOREIGN KEY ("cohortId") REFERENCES "Cohort"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ScheduleOverride" ADD CONSTRAINT "ScheduleOverride_courseId_fkey" FOREIGN KEY ("courseId") REFERENCES "Course"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AttendanceSession" ADD CONSTRAINT "AttendanceSession_cohortId_fkey" FOREIGN KEY ("cohortId") REFERENCES "Cohort"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AttendanceSession" ADD CONSTRAINT "AttendanceSession_courseId_fkey" FOREIGN KEY ("courseId") REFERENCES "Course"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AttendanceRecord" ADD CONSTRAINT "AttendanceRecord_sessionId_fkey" FOREIGN KEY ("sessionId") REFERENCES "AttendanceSession"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AttendanceRecord" ADD CONSTRAINT "AttendanceRecord_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "StudentProfile"("userId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Assessment" ADD CONSTRAINT "Assessment_courseId_fkey" FOREIGN KEY ("courseId") REFERENCES "Course"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Assessment" ADD CONSTRAINT "Assessment_createdBy_fkey" FOREIGN KEY ("createdBy") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "GradeRecord" ADD CONSTRAINT "GradeRecord_assessmentId_fkey" FOREIGN KEY ("assessmentId") REFERENCES "Assessment"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "GradeRecord" ADD CONSTRAINT "GradeRecord_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "StudentProfile"("userId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ParentLinkCode" ADD CONSTRAINT "ParentLinkCode_childId_fkey" FOREIGN KEY ("childId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ParentNotification" ADD CONSTRAINT "ParentNotification_parentId_fkey" FOREIGN KEY ("parentId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ParentNotificationState" ADD CONSTRAINT "ParentNotificationState_parentId_fkey" FOREIGN KEY ("parentId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Announcement" ADD CONSTRAINT "Announcement_createdBy_fkey" FOREIGN KEY ("createdBy") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AnnouncementTarget" ADD CONSTRAINT "AnnouncementTarget_announcementId_fkey" FOREIGN KEY ("announcementId") REFERENCES "Announcement"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AnnouncementSeen" ADD CONSTRAINT "AnnouncementSeen_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AnnouncementSeen" ADD CONSTRAINT "AnnouncementSeen_announcementId_fkey" FOREIGN KEY ("announcementId") REFERENCES "Announcement"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "StudentBrainProfile" ADD CONSTRAINT "StudentBrainProfile_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "StudentProfile"("userId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "StudentBrainSkill" ADD CONSTRAINT "StudentBrainSkill_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "StudentProfile"("userId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "StudentBrainEvent" ADD CONSTRAINT "StudentBrainEvent_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "StudentProfile"("userId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "StudentBrainEvent" ADD CONSTRAINT "StudentBrainEvent_tutorSessionId_fkey" FOREIGN KEY ("tutorSessionId") REFERENCES "TutorSession"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "StudentBrainEvent" ADD CONSTRAINT "StudentBrainEvent_tutorMessageId_fkey" FOREIGN KEY ("tutorMessageId") REFERENCES "TutorMessage"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "StudentBrainSummary" ADD CONSTRAINT "StudentBrainSummary_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "StudentProfile"("userId") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TutorSession" ADD CONSTRAINT "TutorSession_characterId_fkey" FOREIGN KEY ("characterId") REFERENCES "TutorCharacter"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TutorMessage" ADD CONSTRAINT "TutorMessage_sessionId_fkey" FOREIGN KEY ("sessionId") REFERENCES "TutorSession"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Solution" ADD CONSTRAINT "Solution_authorId_fkey" FOREIGN KEY ("authorId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SolutionImage" ADD CONSTRAINT "SolutionImage_solutionId_fkey" FOREIGN KEY ("solutionId") REFERENCES "Solution"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SolutionLike" ADD CONSTRAINT "SolutionLike_solutionId_fkey" FOREIGN KEY ("solutionId") REFERENCES "Solution"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SolutionLike" ADD CONSTRAINT "SolutionLike_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SolutionComment" ADD CONSTRAINT "SolutionComment_solutionId_fkey" FOREIGN KEY ("solutionId") REFERENCES "Solution"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SolutionComment" ADD CONSTRAINT "SolutionComment_authorId_fkey" FOREIGN KEY ("authorId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Notification" ADD CONSTRAINT "Notification_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ScheduleTemplateSlot" ADD CONSTRAINT "ScheduleTemplateSlot_templateId_fkey" FOREIGN KEY ("templateId") REFERENCES "ScheduleTemplate"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ScheduleTemplateSlot" ADD CONSTRAINT "ScheduleTemplateSlot_courseId_fkey" FOREIGN KEY ("courseId") REFERENCES "Course"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ScheduleTemplateSlot" ADD CONSTRAINT "ScheduleTemplateSlot_teacherId_fkey" FOREIGN KEY ("teacherId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CohortScheduleTemplate" ADD CONSTRAINT "CohortScheduleTemplate_cohortId_fkey" FOREIGN KEY ("cohortId") REFERENCES "Cohort"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CohortScheduleTemplate" ADD CONSTRAINT "CohortScheduleTemplate_templateId_fkey" FOREIGN KEY ("templateId") REFERENCES "ScheduleTemplate"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "StudentScheduleTemplate" ADD CONSTRAINT "StudentScheduleTemplate_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "StudentScheduleTemplate" ADD CONSTRAINT "StudentScheduleTemplate_templateId_fkey" FOREIGN KEY ("templateId") REFERENCES "ScheduleTemplate"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ClassroomMessage" ADD CONSTRAINT "ClassroomMessage_courseId_fkey" FOREIGN KEY ("courseId") REFERENCES "Course"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ClassroomAssignment" ADD CONSTRAINT "ClassroomAssignment_courseId_fkey" FOREIGN KEY ("courseId") REFERENCES "Course"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ClassroomMaterial" ADD CONSTRAINT "ClassroomMaterial_courseId_fkey" FOREIGN KEY ("courseId") REFERENCES "Course"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ClassroomMeeting" ADD CONSTRAINT "ClassroomMeeting_courseId_fkey" FOREIGN KEY ("courseId") REFERENCES "Course"("id") ON DELETE CASCADE ON UPDATE CASCADE;
