import { Body, Controller, Get, Param, Patch, Post, Query, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '../auth/roles';
import { CertificatesService } from './certificates.service';
import { CreateCertificateDto } from './dto/certificate.dto';

@UseGuards(JwtAuthGuard, RolesGuard)
// Class default covers staff routes; STUDENT is granted only on `mine` below.
@Roles(Role.ADMIN, Role.SECRETARY, Role.TEACHER)
@Controller('certificates')
export class CertificatesController {
  constructor(private readonly certificates: CertificatesService) {}

  // ── Student: their own published certificates (declared before ':id') ──
  @Get('mine')
  @Roles(Role.STUDENT)
  mine(@Req() req: any) {
    return this.certificates.studentCertificates(req.user);
  }

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

  // Published certificates for a cohort — secretary/admin "print all".
  @Get('print')
  print(@Req() req: any, @Query('cohortId') cohortId: string) {
    return this.certificates.byCohortForPrint(req.user, cohortId);
  }

  @Get()
  list(@Req() req: any, @Query('cohortId') cohortId?: string) {
    return this.certificates.list(req.user, cohortId);
  }

  // One certificate for the edit form (admin / owner teacher).
  @Get(':id')
  @Roles(Role.ADMIN, Role.TEACHER)
  getOne(@Req() req: any, @Param('id') id: string) {
    return this.certificates.getOne(req.user, id);
  }

  @Post()
  @Roles(Role.ADMIN, Role.TEACHER) // secretaries are read-only
  create(@Req() req: any, @Body() dto: CreateCertificateDto) {
    return this.certificates.create(req.user, dto);
  }

  @Patch(':id')
  @Roles(Role.ADMIN, Role.TEACHER)
  update(@Req() req: any, @Param('id') id: string, @Body() dto: CreateCertificateDto) {
    return this.certificates.update(req.user, id, dto);
  }
}
