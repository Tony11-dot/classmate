import { Module } from '@nestjs/common';
import { NotificationsController } from './notifications.controller';
import { NotificationsService } from './notifications.service';
import { PrismaModule } from '../prisma/prisma.module';
import { PrismaService } from '../prisma/prisma.service';

@Module({
  imports: [PrismaModule],
  controllers: [NotificationsController],
  providers: [ PrismaService, NotificationsService ],
  exports: [NotificationsService],
})
export class NotificationsModule {}
