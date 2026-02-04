import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { ParentNotificationsController } from './parent-notifications.controller';
import { ParentNotificationsService } from './parent-notifications.service';

@Module({
  imports: [PrismaModule],
  controllers: [ParentNotificationsController],
  providers: [ParentNotificationsService],
  exports: [ParentNotificationsService],
})
export class ParentModule {}
