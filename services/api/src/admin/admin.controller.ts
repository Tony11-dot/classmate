import { Controller, Post, Get, Body, UseGuards, Req } from '@nestjs/common';
import { CreateAdminUserDto } from './dto/create-user.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';
import { AdminService } from './admin.service';

@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('admin')
export class AdminController {
  constructor(private readonly admin: AdminService) {}

  @Roles('ADMIN')
  @Post('cohorts')
  createCohort(@Req() req: any, @Body() body: { name: string; grade: number }) {
    return this.admin.createCohort(req.user, body);
  }

  @Roles('ADMIN')
  @Get('cohorts')
  listCohorts() {
    return this.admin.listCohorts();
  }

  @Roles('ADMIN')
  @Get('users')
  listUsers() {
    return this.admin.listUsers();
  }

  @Roles('ADMIN')
  @Post('users')
  createUser(@Body() body: CreateAdminUserDto) {
    return this.admin.createUser(body);
  }
}
