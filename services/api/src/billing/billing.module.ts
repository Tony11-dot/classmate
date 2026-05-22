import { Module } from '@nestjs/common';
import { BillingController } from './billing.controller';
import { TokensService } from './tokens.service';
import { RevenueCatWebhookService } from './revenuecat.webhook';
import { PrismaModule } from '../prisma/prisma.module';

@Module({
  imports: [PrismaModule],
  controllers: [BillingController],
  providers: [TokensService, RevenueCatWebhookService],
  exports: [TokensService],
})
export class BillingModule {}
