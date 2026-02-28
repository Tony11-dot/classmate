import { AuthModule } from '../auth/auth.module';
import { Module } from '@nestjs/common';
import { TutorController } from './tutor.controller';
import { TutorService } from './tutor.service';

@Module({
  imports: [AuthModule],
  controllers: [TutorController],
  providers: [TutorService],
})
export class TutorModule {}
