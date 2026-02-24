import { JwtAuthGuard } from './../auth/jwt-auth.guard';
import { Controller, Get, Param, Req, UseGuards } from '@nestjs/common';
import { ClassroomsService } from './classrooms.service';

@Controller()
export class ClassroomsController {
  constructor(private readonly svc: ClassroomsService) {}

  // STUDENT
  @UseGuards(JwtAuthGuard)
  @Get('student/classrooms')
  listStudent(@Req() req: any) {
    const uid = String((req as any).user?.id ?? '');
    return this.svc.listForStudent(uid);
  }
  @UseGuards(JwtAuthGuard)
  @Get('student/classrooms/:id')
  getStudent(@Req() req: any, @Param('id') id: string) {
    return this.svc.getForStudent(String((req as any).user?.id), String(id));
  }

  // PARENT
  @UseGuards(JwtAuthGuard)
  @Get('parent/classrooms')
  listParent(@Req() req: any) {
    return this.svc.listForParent(String((req as any).user?.id));
  }
  @UseGuards(JwtAuthGuard)
  @Get('parent/classrooms/:id')
  getParent(@Req() req: any, @Param('id') id: string) {
    return this.svc.getForParent(String((req as any).user?.id), String(id));
  }

  // ADMIN
  @UseGuards(JwtAuthGuard)
  @Get('admin/classrooms')
  listAdmin(@Req() req: any) {
    return this.svc.listForAdmin(String((req as any).user?.id));
  }
  @UseGuards(JwtAuthGuard)
  @Get('admin/classrooms/:id')
  getAdmin(@Req() req: any, @Param('id') id: string) {
    return this.svc.getForAdmin(String((req as any).user?.id), String(id));
  }
}
