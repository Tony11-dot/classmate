import { Module } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { ScheduleModule } from '../schedule/schedule.module';
import { StudentController } from './student.controller';
import { StudentService } from './student.service';

@Module({
  imports: [ScheduleModule],
  controllers: [StudentController],
  providers: [StudentService, PrismaService],
})
export class StudentModule {}
