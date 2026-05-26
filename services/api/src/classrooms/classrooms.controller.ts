import { Controller, Get, Param, Req, UseGuards } from '@nestjs/common';
import { SkipThrottle } from '@nestjs/throttler';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '../auth/roles';
import { ClassroomsService } from './classrooms.service';

// Read-only directory routes for students. Both endpoints are hit during
// normal tab navigation and don't mutate state — exempt from the default
// throttle bucket to match the pattern used on student/teacher/parent
// schedule reads.
@SkipThrottle()
@UseGuards(JwtAuthGuard)
@Controller('student/classrooms')
@Roles(Role.STUDENT, Role.ADMIN)
export class ClassroomsController {
  constructor(private readonly svc: ClassroomsService) {}

  @Get()
  list(@Req() req: any) {
    const studentUserId = String(req.user?.sub ?? req.user?.id ?? '');
    return this.svc.listStudentClassrooms(studentUserId);
  }

  @Get(':id')
  get(@Req() req: any, @Param('id') id: string) {
    const studentUserId = String(req.user?.sub ?? req.user?.id ?? '');
    return this.svc.getStudentClassroom(studentUserId, String(id || '').trim());
  }
}
