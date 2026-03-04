import { AuthModule } from '../auth/auth.module';
import { PrismaModule } from '../prisma/prisma.module';
import { Module } from '@nestjs/common';
import { BrainModule } from '../brain/brain.module';
import { TutorController } from './tutor.controller';
import { TutorService } from './tutor.service';

@Module({
  imports: [BrainModule, AuthModule, PrismaModule],
  controllers: [TutorController],
  providers: [TutorService],
})
export class TutorModule {}
