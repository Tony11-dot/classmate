import { Module } from '@nestjs/common';
import { AveragesController } from './averages.controller';
import { AveragesService } from './averages.service';
import { PrismaModule } from '../prisma/prisma.module';

@Module({
  imports: [PrismaModule],
  controllers: [AveragesController],
  providers: [AveragesService],
  exports: [AveragesService],
})
export class AveragesModule {}
