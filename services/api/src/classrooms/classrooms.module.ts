import { Module } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { ClassroomsController } from './classrooms.controller';
import { ClassroomsService } from './classrooms.service';

@Module({
  controllers: [ClassroomsController],
  providers: [ClassroomsService, PrismaService],
})
export class ClassroomsModule {}
