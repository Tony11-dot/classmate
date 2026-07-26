import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { ClassnotesController } from './classnotes.controller';
import { ClassnotesService } from './classnotes.service';

@Module({
  imports: [PrismaModule],
  controllers: [ClassnotesController],
  providers: [ClassnotesService],
})
export class ClassnotesModule {}
