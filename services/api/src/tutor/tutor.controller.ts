import {
  Body,
  Controller,
  Get,
  Post,
  Query,
  Param,
  Req,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { TutorService } from './tutor.service';
import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '../auth/roles';
@UseGuards(JwtAuthGuard)
@Roles(Role.STUDENT, Role.ADMIN, Role.SECRETARY)
@Controller('tutor')
export class TutorController {
  constructor(private svc: TutorService) {}

  // ---- Learning profile ----
  @Roles(Role.STUDENT, Role.ADMIN)
  @Get('me/profile')
  getMyProfile(@Req() req: any) {
    return this.svc.getMyLearningProfile(req.user);
  }

  @Roles(Role.STUDENT, Role.ADMIN)
  @Post('me/profile')
  upsertMyProfile(@Req() req: any, @Body() body: any) {
    return this.svc.upsertMyLearningProfile(req.user, body);
  }

  // ---- Brain snapshot (read) ----
  @Roles(Role.STUDENT, Role.ADMIN)
  @Get('me/brain')
  getMyBrain(@Req() req: any) {
    return this.svc.getMyBrainSnapshot(req.user);
  }

  @Post('me/brain/rebuild')
  rebuildMyBrain(@Req() req: any) {
    return this.svc.rebuildMyBrainSnapshot(req.user);
  }

  // ---- Materials ----
  @Roles(Role.STUDENT, Role.ADMIN, Role.SECRETARY)
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

  @Roles(Role.ADMIN, Role.SECRETARY)
  @Post('materials')
  createMaterial(@Req() req: any, @Body() body: any) {
    return this.svc.createMaterial(req.user, body);
  }

  // ---- Sessions ----
  @Roles(Role.STUDENT, Role.ADMIN)
  @Post('sessions')
  createSession(@Req() req: any, @Body() body: any) {
    return this.svc.createSession(req.user, body);
  }

  @Roles(Role.STUDENT, Role.ADMIN)
  @Get('sessions')
  listSessions(@Req() req: any, @Query('characterId') characterId?: string) {
    return this.svc.listSessions(req.user, { characterId });
  }

  @Roles(Role.STUDENT, Role.ADMIN)
  @Get('sessions/:id')
  getSession(@Req() req: any, @Param('id') id: string) {
    return this.svc.getSession(req.user, id);
  }

  @Roles(Role.STUDENT, Role.ADMIN)
  @Post('sessions/:id/messages')
  addMessage(@Req() req: any, @Param('id') id: string, @Body() body: any) {
    return this.svc.addMessage(req.user, id, body);
  }
  @Roles(Role.STUDENT, Role.ADMIN)
  @Post('sessions/:id/reply')
  reply(@Req() req: any, @Param('id') id: string, @Body() body: any) {
    return this.svc.replyToSession(req.user, id, body);
  }
}
