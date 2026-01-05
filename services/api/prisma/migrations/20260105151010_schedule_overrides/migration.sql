-- CreateTable
CREATE TABLE "ScheduleOverride" (
    "id" TEXT NOT NULL,
    "cohortId" TEXT NOT NULL,
    "date" TIMESTAMP(3) NOT NULL,
    "period" INTEGER NOT NULL,
    "courseId" TEXT,

    CONSTRAINT "ScheduleOverride_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "ScheduleOverride_courseId_idx" ON "ScheduleOverride"("courseId");

-- CreateIndex
CREATE INDEX "ScheduleOverride_cohortId_date_idx" ON "ScheduleOverride"("cohortId", "date");

-- CreateIndex
CREATE UNIQUE INDEX "ScheduleOverride_cohortId_date_period_key" ON "ScheduleOverride"("cohortId", "date", "period");

-- AddForeignKey
ALTER TABLE "ScheduleOverride" ADD CONSTRAINT "ScheduleOverride_cohortId_fkey" FOREIGN KEY ("cohortId") REFERENCES "Cohort"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ScheduleOverride" ADD CONSTRAINT "ScheduleOverride_courseId_fkey" FOREIGN KEY ("courseId") REFERENCES "Course"("id") ON DELETE SET NULL ON UPDATE CASCADE;
