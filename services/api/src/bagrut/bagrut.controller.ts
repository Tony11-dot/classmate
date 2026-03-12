import { Body, Controller, Post } from '@nestjs/common';
import { BagrutService } from './bagrut.service';

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
