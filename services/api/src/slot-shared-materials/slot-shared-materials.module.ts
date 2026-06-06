import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { SlotSharedMaterialsController } from './slot-shared-materials.controller';
import { SlotSharedMaterialsService } from './slot-shared-materials.service';

@Module({
  imports: [PrismaModule],
  controllers: [SlotSharedMaterialsController],
  providers: [SlotSharedMaterialsService],
})
export class SlotSharedMaterialsModule {}
