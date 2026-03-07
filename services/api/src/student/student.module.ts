import { Module } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { ScheduleModule } from '../schedule/schedule.module';
import { StudentController } from './student.controller';
import { StudentAttendanceController } from './student.attendance.controller';
import { StudentScheduleController } from './student.schedule.controller';
import { StudentService } from './student.service';

@Module({
  imports: [ScheduleModule],
  controllers: [
    StudentController,
    StudentAttendanceController,
    StudentScheduleController,  ],
  providers: [StudentService, PrismaService],
})
export class StudentModule {}
