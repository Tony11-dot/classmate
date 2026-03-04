import { Module } from '@nestjs/common';
import { BrainService } from './brain.service';
import { BrainController } from './brain.controller';
import { PrismaModule } from '../prisma/prisma.module';

@Module({
  imports: [PrismaModule],
  providers: [BrainService],
  controllers: [BrainController],
  exports: [BrainService],
})
export class BrainModule {}
