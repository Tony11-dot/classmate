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

-- CreateIndex
CREATE INDEX "Assessment_courseId_idx" ON "Assessment"("courseId");

-- CreateIndex
CREATE INDEX "Assessment_createdBy_idx" ON "Assessment"("createdBy");

-- CreateIndex
CREATE INDEX "GradeRecord_studentId_idx" ON "GradeRecord"("studentId");

-- CreateIndex
CREATE UNIQUE INDEX "GradeRecord_assessmentId_studentId_key" ON "GradeRecord"("assessmentId", "studentId");

-- AddForeignKey
ALTER TABLE "Assessment" ADD CONSTRAINT "Assessment_courseId_fkey" FOREIGN KEY ("courseId") REFERENCES "Course"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Assessment" ADD CONSTRAINT "Assessment_createdBy_fkey" FOREIGN KEY ("createdBy") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "GradeRecord" ADD CONSTRAINT "GradeRecord_assessmentId_fkey" FOREIGN KEY ("assessmentId") REFERENCES "Assessment"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "GradeRecord" ADD CONSTRAINT "GradeRecord_studentId_fkey" FOREIGN KEY ("studentId") REFERENCES "StudentProfile"("userId") ON DELETE CASCADE ON UPDATE CASCADE;
