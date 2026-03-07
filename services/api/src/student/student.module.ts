import { Module } from '@nestjs/common';
import { StudentController } from './student.controller';
import { StudentService } from './student.service';
import { StudentAttendanceController } from './student.attendance.controller';
import { StudentScheduleController } from './student.schedule.controller';
import { StudentClassroomsController } from './student.classrooms.controller';
import { ScheduleModule } from '../schedule/schedule.module';

@Module({
  imports: [ScheduleModule],
  controllers: [
    StudentController,
    StudentAttendanceController,
    StudentScheduleController,
    StudentClassroomsController,
  ],
  providers: [StudentService],
  exports: [StudentService],
})
export class StudentModule {}
