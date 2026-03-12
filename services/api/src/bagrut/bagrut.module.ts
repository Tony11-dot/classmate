import { Module } from '@nestjs/common';
import { BagrutController } from './bagrut.controller';
import { BagrutService } from './bagrut.service';
import { PrismaService } from '../prisma/prisma.service';

@Module({
  controllers: [BagrutController],
  providers: [BagrutService, PrismaService],
})
export class BagrutModule {}
