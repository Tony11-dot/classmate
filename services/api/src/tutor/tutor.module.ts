import { AuthModule } from '../auth/auth.module';
import { PrismaModule } from '../prisma/prisma.module';
import { Module } from '@nestjs/common';
import { BrainModule } from '../brain/brain.module';
import { StudentModule } from '../student/student.module';
import { TutorController } from './tutor.controller';
import { TutorService } from './tutor.service';
import { BillingModule } from '../billing/billing.module';

@Module({
  imports: [BrainModule, AuthModule, PrismaModule, StudentModule, BillingModule],
  controllers: [TutorController],
  providers: [TutorService],
})
export class TutorModule {}
