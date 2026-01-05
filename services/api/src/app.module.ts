import { Module } from '@nestjs/common';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { StudentModule } from './student/student.module';
import { AdminModule } from './admin/admin.module';
import { ScheduleModule } from './schedule/schedule.module';
import { TeacherModule } from './teacher/teacher.module';

@Module({
  imports: [PrismaModule, AuthModule, StudentModule, AdminModule, ScheduleModule, TeacherModule],
})
export class AppModule {}
