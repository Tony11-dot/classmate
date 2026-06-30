import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '../auth/roles';
import { AveragesService } from './averages.service';
import { CreateGradeFormulaDto, UpdateGradeFormulaDto } from './dto/grade-formula.dto';

@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.TEACHER, Role.ADMIN, Role.SECRETARY)
@Controller('averages')
export class AveragesController {
  constructor(private readonly averages: AveragesService) {}

  @Get('cohorts')
  cohorts(@Req() req: any) {
    return this.averages.cohorts(req.user);
  }

  @Get('options')
  options(@Req() req: any, @Query('cohortId') cohortId: string) {
    return this.averages.options(req.user, cohortId);
  }

  @Get('grades')
  grades(
    @Req() req: any,
    @Query('cohortId') cohortId: string,
    @Query('subject') subject: string,
    @Query('semester') semester?: string,
  ) {
    const sem = semester ? Number(semester) : null;
    return this.averages.grades(req.user, cohortId, subject, Number.isFinite(sem as number) ? sem : null);
  }

  @Get()
  list(@Req() req: any, @Query('cohortId') cohortId?: string, @Query('subject') subject?: string) {
    return this.averages.list(req.user, cohortId, subject);
  }

  @Post()
  create(@Req() req: any, @Body() dto: CreateGradeFormulaDto) {
    return this.averages.create(req.user, dto);
  }

  @Patch(':id')
  update(@Req() req: any, @Param('id') id: string, @Body() dto: UpdateGradeFormulaDto) {
    return this.averages.update(req.user, id, dto);
  }

  @Delete(':id')
  remove(@Req() req: any, @Param('id') id: string) {
    return this.averages.remove(req.user, id);
  }

  @Post(':id/compute')
  compute(
    @Req() req: any,
    @Param('id') id: string,
    @Body() body: { studentIds?: string[]; semesterNumber?: number },
  ) {
    return this.averages.compute(req.user, id, body?.studentIds ?? [], body?.semesterNumber ?? null);
  }
}
