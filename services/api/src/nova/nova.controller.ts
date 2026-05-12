import {
  Body,
  Controller,
  Post,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { GradeService } from './grade.service';

@UseGuards(JwtAuthGuard)
@Controller('nova')
export class NovaController {
  constructor(private readonly gradeService: GradeService) {}

  @Post('grade')
  @UseInterceptors(FileInterceptor('image'))
  async grade(@UploadedFile() file?: Express.Multer.File, @Body() body?: any) {
    const steps = Array.isArray(body?.steps) ? body.steps : [];
    const graded = await this.gradeService.gradeSolution(file?.buffer ?? Buffer.from(''));

    return {
      status: 'ok',
      mode: 'step-by-step',
      extractedSteps: steps,
      ...graded,
    };
  }
}
