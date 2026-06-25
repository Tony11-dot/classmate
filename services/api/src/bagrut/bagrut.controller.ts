import { Body, Controller, Post, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '../auth/roles';
import { BagrutService } from './bagrut.service';

// AI question/exam generation (metered Anthropic spend) — students only.
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.STUDENT)
@Controller('bagrut')
export class BagrutController {
  constructor(private service: BagrutService) {}

  @Post('question')
  async question(@Body() body: any) {
    return this.service.getQuestion(body.subject, body.topicLabel);
  }

  @Post('exam')
  async exam(@Body() body: any) {
    return this.service.getExam(body.subject);
  }
}
