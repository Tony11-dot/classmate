-- CreateEnum
CREATE TYPE "CourseRuleType" AS ENUM ('COHORT', 'ENGLISH_LEVEL', 'MATH_LEVEL', 'MAJOR_REQUIRED', 'ELECTIVE_OPT_IN');

-- CreateEnum
CREATE TYPE "EnrollmentSource" AS ENUM ('AUTO', 'MANUAL');

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
