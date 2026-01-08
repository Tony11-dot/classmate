-- AlterEnum
ALTER TYPE "Role" ADD VALUE 'SECRETARY';

-- AlterTable
ALTER TABLE "AttendanceRecord" ALTER COLUMN "updatedAt" DROP DEFAULT;

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

-- AddForeignKey
ALTER TABLE "Announcement" ADD CONSTRAINT "Announcement_createdBy_fkey" FOREIGN KEY ("createdBy") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AnnouncementTarget" ADD CONSTRAINT "AnnouncementTarget_announcementId_fkey" FOREIGN KEY ("announcementId") REFERENCES "Announcement"("id") ON DELETE CASCADE ON UPDATE CASCADE;
