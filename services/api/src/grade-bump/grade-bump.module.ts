import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { GradeBumpService } from './grade-bump.service';
import { GradeBumpController } from './grade-bump.controller';

@Module({
  imports: [PrismaModule],
  controllers: [GradeBumpController],
  providers: [GradeBumpService],
  exports: [GradeBumpService],
})
export class GradeBumpModule {}
