import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { ClassnotesController } from './classnotes.controller';
import { ClassnotesService } from './classnotes.service';
import { ClassnotesAiService } from './classnotes.ai.service';

@Module({
  imports: [PrismaModule],
  controllers: [ClassnotesController],
  providers: [ClassnotesService, ClassnotesAiService],
})
export class ClassnotesModule {}
