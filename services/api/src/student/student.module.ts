import { Module } from '@nestjs/common';
import { StudentController } from './student.controller';
import { StudentService } from './student.service';
import { StudentInsightsService } from './student-insights.service';
import { StudentAttendanceController } from './student.attendance.controller';
import { StudentScheduleController } from './student.schedule.controller';
import { StudentClassroomsController } from './student.classrooms.controller';
import { ScheduleModule } from '../schedule/schedule.module';
import { PracticeModule } from '../practice/practice.module';

@Module({
  imports: [ScheduleModule, PracticeModule],
  controllers: [
    StudentController,
    StudentAttendanceController,
    StudentScheduleController,
    StudentClassroomsController,
  ],
  providers: [StudentService, StudentInsightsService],
  exports: [StudentService, StudentInsightsService],
})
export class StudentModule {}
