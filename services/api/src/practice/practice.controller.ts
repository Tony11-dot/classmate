import { Body, Controller, Post } from '@nestjs/common';
import { PracticeService } from './practice.service';

@Controller('practice')
export class PracticeController {
  constructor(private readonly practiceService: PracticeService) {}

  @Post('generate')
  async generate(@Body() body: any) {
    return this.practiceService.generate(body ?? {});
  }
}
