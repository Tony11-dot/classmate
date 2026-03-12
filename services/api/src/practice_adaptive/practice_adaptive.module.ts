import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { PracticeAdaptiveController } from './practice_adaptive.controller';
import { PracticeAdaptiveService } from './practice_adaptive.service';

@Module({
  imports: [PrismaModule],
  controllers: [PracticeAdaptiveController],
  providers: [PracticeAdaptiveService],
  exports: [PracticeAdaptiveService],
})
export class PracticeAdaptiveModule {}
