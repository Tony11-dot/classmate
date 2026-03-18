import { Body, Controller, Post } from '@nestjs/common';
import { HttpException } from '@nestjs/common';
import { PracticeService } from './practice.service';
import { isPracticeHttpException } from './errors/practice-error.util';

@Controller('practice')
export class PracticeController {
  constructor(private readonly practiceService: PracticeService) {}

  @Post('generate')
  async generate(@Body() body: any) {
    return this.practiceService.generate(body ?? {});
  }
}