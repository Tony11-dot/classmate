import { Module } from '@nestjs/common';
import { NovaController } from './nova.controller';
import { GradeService } from './grade.service';

@Module({
  controllers: [NovaController],
  providers: [GradeService],
})
export class NovaModule {}
