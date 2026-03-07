import { Module } from '@nestjs/common';
import { SolutionsService } from './solutions.service';
import { SolutionsController } from './solutions.controller';
import { ProjectionsModule } from '../modules/projections/projections.module';

@Module({
  imports: [ProjectionsModule],
  controllers: [SolutionsController],
  providers: [SolutionsService],
})
export class SolutionsModule {}
