import { Module } from '@nestjs/common';
import { AdminController } from './admin.controller';
import { ScheduleTemplatesController } from './schedule-templates/schedule-templates.controller';
import { AdminService } from './admin.service';
import { PrismaService } from '../prisma/prisma.service';

@Module({
  controllers: [AdminController,
    ScheduleTemplatesController,
  ],
  providers: [AdminService, PrismaService],
})
export class AdminModule {}
