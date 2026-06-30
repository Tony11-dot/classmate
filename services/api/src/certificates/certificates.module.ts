import { Module } from '@nestjs/common';
import { CertificatesController } from './certificates.controller';
import { CertificatesService } from './certificates.service';
import { PrismaModule } from '../prisma/prisma.module';
import { AveragesModule } from '../averages/averages.module';

@Module({
  imports: [PrismaModule, AveragesModule],
  controllers: [CertificatesController],
  providers: [CertificatesService],
})
export class CertificatesModule {}
