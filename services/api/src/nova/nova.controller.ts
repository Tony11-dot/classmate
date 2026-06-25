import {
  BadRequestException,
  Body,
  Controller,
  Post,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '../auth/roles';
import { GradeService } from './grade.service';

// NOVA is the students-only AI tutor. Gate every (paid) route to STUDENT so
// teachers/parents/staff can't burn metered Anthropic spend.
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.STUDENT)
@Controller('nova')
export class NovaController {
  constructor(private readonly gradeService: GradeService) {}

  @Post('grade')
  @UseInterceptors(
    FileInterceptor('image', {
      limits: { fileSize: 10 * 1024 * 1024 }, // 10 MB
      fileFilter: (_req, file, cb) => {
        if (/^image\/(png|jpe?g|webp|heic|heif)$/i.test(file.mimetype)) {
          cb(null, true);
        } else {
          cb(new BadRequestException('Only image uploads are allowed'), false);
        }
      },
    }),
  )
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
