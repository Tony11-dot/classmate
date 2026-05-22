import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { SolutionsController } from './solutions.controller';
import { SolutionsStaffController } from './solutions.staff.controller';
import { SolutionsService } from './solutions.service';
import { NovaVerifyService } from '../nova/nova.verify.service';
import { BillingModule } from '../billing/billing.module';

@Module({
  imports: [PrismaModule, BillingModule],
  controllers: [SolutionsController, SolutionsStaffController],
  providers: [SolutionsService, NovaVerifyService],
  exports: [SolutionsService],
})
export class SolutionsModule {}
