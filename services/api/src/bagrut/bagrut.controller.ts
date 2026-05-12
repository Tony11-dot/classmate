import { Body, Controller, Post, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { BagrutService } from './bagrut.service';

@UseGuards(JwtAuthGuard)
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
