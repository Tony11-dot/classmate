import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { NotificationsModule } from '../notifications/notifications.module';
import { CMailController } from './cmail.controller';
import { CMailService } from './cmail.service';

@Module({
  imports: [PrismaModule, NotificationsModule],
  controllers: [CMailController],
  providers: [CMailService],
})
export class CMailModule {}
