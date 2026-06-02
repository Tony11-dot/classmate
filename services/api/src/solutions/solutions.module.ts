import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { SolutionsController } from './solutions.controller';
import { SolutionsStaffController } from './solutions.staff.controller';
import { SolutionsService } from './solutions.service';

@Module({
  imports: [PrismaModule],
  controllers: [SolutionsController, SolutionsStaffController],
  providers: [SolutionsService],
  exports: [SolutionsService],
})
export class SolutionsModule {}
