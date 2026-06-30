import { Body, Controller, Get, Post, Query, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '../auth/roles';
import { CertificatesService } from './certificates.service';
import { CreateCertificateDto } from './dto/certificate.dto';

@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(Role.ADMIN, Role.SECRETARY)
@Controller('certificates')
export class CertificatesController {
  constructor(private readonly certificates: CertificatesService) {}

  @Get('prefill')
  prefill(
    @Req() req: any,
    @Query('cohortId') cohortId: string,
    @Query('studentId') studentId?: string,
    @Query('semesterWeights') semesterWeights?: string,
  ) {
    return this.certificates.prefill(req.user, cohortId, studentId, semesterWeights);
  }

  @Get('cohorts')
  cohorts(@Req() req: any) {
    return this.certificates.cohorts(req.user);
  }

  @Get('students')
  students(@Req() req: any, @Query('cohortId') cohortId: string) {
    return this.certificates.studentsInCohort(req.user, cohortId);
  }

  @Get()
  list(@Req() req: any, @Query('cohortId') cohortId?: string) {
    return this.certificates.list(req.user, cohortId);
  }

  @Post()
  create(@Req() req: any, @Body() dto: CreateCertificateDto) {
    return this.certificates.create(req.user, dto);
  }
}
