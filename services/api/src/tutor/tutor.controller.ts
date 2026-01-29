import { Body, Controller, Get, Post, Query, Param, Req } from '@nestjs/common';
import { TutorService } from './tutor.service';
import { Roles } from '../auth/roles.decorator';

@Roles('STUDENT','ADMIN','SECRETARY')
@Controller('tutor')
export class TutorController {
  constructor(private svc: TutorService) {}

  // ---- Learning profile ----
  @Roles('STUDENT','ADMIN')
  @Get('me/profile')
  getMyProfile(@Req() req: any) {
    return this.svc.getMyLearningProfile(req.user);
  }

  @Roles('STUDENT','ADMIN')
  @Post('me/profile')
  upsertMyProfile(@Req() req: any, @Body() body: any) {
    return this.svc.upsertMyLearningProfile(req.user, body);
  }

  // ---- Brain snapshot (read) ----
  @Roles('STUDENT','ADMIN')
  @Get('me/brain')
  getMyBrain(@Req() req: any, @Query('subject') subject?: string) {
    return this.svc.getMyBrainSnapshot(req.user, subject);
  }

  // ---- Materials ----
  @Roles('STUDENT','ADMIN','SECRETARY')
  @Get('materials')
  listMaterials(
    @Query('subject') subject?: string,
    @Query('grade') grade?: string,
    @Query('language') language?: string,
    @Query('q') q?: string,
    @Query('take') take?: string,
  ) {
    return this.svc.listMaterials({
      subject,
      grade: typeof grade === 'string' ? Number(grade) : undefined,
      language,
      q,
      take: typeof take === 'string' ? Number(take) : undefined,
    });
  }

  @Roles('ADMIN','SECRETARY')
  @Post('materials')
  createMaterial(@Req() req: any, @Body() body: any) {
    return this.svc.createMaterial(req.user, body);
  }

  // ---- Sessions ----
  @Roles('STUDENT','ADMIN')
  @Post('sessions')
  createSession(@Req() req: any, @Body() body: any) {
    return this.svc.createSession(req.user, body);
  }

  @Roles('STUDENT','ADMIN')
  @Get('sessions')
  listSessions(@Req() req: any) {
    return this.svc.listSessions(req.user);
  }

  @Roles('STUDENT','ADMIN')
  @Get('sessions/:id')
  getSession(@Req() req: any, @Param('id') id: string) {
    return this.svc.getSession(req.user, id);
  }

  @Roles('STUDENT','ADMIN')
  @Post('sessions/:id/messages')
  addMessage(@Req() req: any, @Param('id') id: string, @Body() body: any) {
    return this.svc.addMessage(req.user, id, body);
  }
}
