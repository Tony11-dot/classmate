import {
  Body,
  Controller,
  Get,
  Delete,
  Param,
  Post,
  Query,
  Req,
  Sse,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname } from 'path';
import { mkdirSync } from 'fs';
import { SkipThrottle } from '@nestjs/throttler';
import { Observable } from 'rxjs';
import type { MessageEvent } from '@nestjs/common';

import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '../auth/roles';
import { TutorService } from './tutor.service';

function ensureNovaUploadsDir() {
  mkdirSync('uploads', { recursive: true });
  mkdirSync('uploads/nova', { recursive: true });
}

function safeNovaName(raw: string) {
  return String(raw || 'upload').replace(/[^a-zA-Z0-9._-]/g, '_');
}

function novaDiskStorage() {
  return diskStorage({
    destination: (_req, _file, cb) => {
      ensureNovaUploadsDir();
      cb(null, 'uploads/nova');
    },
    filename: (_req, file, cb) => {
      const stamp = `${Date.now()}-${Math.round(Math.random() * 1e9)}`;
      const base = safeNovaName(file.originalname || 'upload');
      const ext = extname(base);
      const stem = ext ? base.slice(0, -ext.length) : base;
      cb(null, `${stem}-${stamp}${ext}`);
    },
  });
}

@SkipThrottle()
@UseGuards(JwtAuthGuard)
// NOVA is a STUDENTS-ONLY feature. Teachers / parents / staff bring no
// NOVA revenue, so the AI tutor (and the AI + Whisper spend it drives) is
// locked to students — at the API, not just hidden in the UI, so a stray
// deep link or old client can't burn tokens. This class default covers
// every endpoint; the three content-management routes that admins /
// secretaries legitimately need (list materials / list characters / create
// material) re-grant their roles explicitly, and method-level @Roles fully
// overrides this default (RolesGuard uses getAllAndOverride).
@Roles(Role.STUDENT)
@Controller('tutor')
export class TutorController {
  constructor(private svc: TutorService) {}

  @Roles(Role.STUDENT)
  @Get('me/profile')
  getMyProfile(@Req() req: any) {
    return this.svc.getMyLearningProfile(req.user);
  }

  @Roles(Role.STUDENT)
  @Post('me/profile')
  upsertMyProfile(@Req() req: any, @Body() body: any) {
    return this.svc.upsertMyLearningProfile(req.user, body);
  }

  @Roles(Role.STUDENT)
  @Get('me/academic-context')
  getMyAcademicContext(@Req() req: any) {
    return this.svc.getMyAcademicContext(req.user);
  }

  @Roles(Role.STUDENT)
  @Get('me/brain')
  getMyBrain(@Req() req: any) {
    return this.svc.getMyBrainSnapshot(req.user);
  }

  @Post('me/brain/rebuild')
  rebuildMyBrain(@Req() req: any) {
    return this.svc.rebuildMyBrainSnapshot(req.user);
  }

  @Roles(Role.STUDENT, Role.TEACHER, Role.ADMIN, Role.SECRETARY, Role.PARENT)
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

  @Roles(Role.STUDENT, Role.TEACHER, Role.ADMIN, Role.SECRETARY, Role.PARENT)
  @Get('characters')
  listCharacters(@Req() req: any, @Query('subject') subject?: string) {
    return this.svc.listCharacters(req.user, { subject });
  }

  @Roles(Role.STUDENT)
  @Post('sessions')
  createSession(@Req() req: any, @Body() body: any) {
    return this.svc.createSession(req.user, body);
  }

  @Roles(Role.STUDENT)
  @Get('sessions')
  listSessions(@Req() req: any, @Query('characterId') characterId?: string) {
    return this.svc.listSessions(req.user, { characterId });
  }

  @Roles(Role.STUDENT)
  @Get('sessions/:id')
  getSession(@Req() req: any, @Param('id') id: string) {
    return this.svc.getSession(req.user, id);
  }

  @Roles(Role.STUDENT)
  @Post('sessions/:id/messages')
  @UseInterceptors(
    FileInterceptor('file', {
      storage: novaDiskStorage(),
      limits: { fileSize: 30 * 1024 * 1024 },
    }),
  )
  addMessage(
    @Req() req: any,
    @Param('id') id: string,
    @Body() body: any,
    @UploadedFile() file?: Express.Multer.File,
  ) {
    return this.svc.addMessage(req.user, id, body, file);
  }

  @Roles(Role.STUDENT)
  @Delete('sessions/:id')
  deleteSession(@Req() req: any, @Param('id') id: string) {
    return this.svc.deleteSession(req.user, String(id));
  }

  @Post('transcribe')
  @UseInterceptors(FileInterceptor('file'))
  async transcribeAudio(
    @Req() req: any,
    @UploadedFile() file?: any,
  ) {
    return this.svc.transcribeAudio(req.user, file);
  }

  @Post('sessions/:id/reply')
  reply(@Req() req: any, @Param('id') id: string, @Body() body: any) {
    return this.svc.replyToSession(req.user, id, body);
  }

  @Roles(Role.STUDENT)
  @Sse('sessions/:id/reply/stream')
  replyStream(
    @Req() req: any,
    @Param('id') id: string,
    @Query('displayName') displayName?: string,
    @Query('novaSettings') novaSettings?: string,
  ): Observable<MessageEvent> {
    return this.svc.replyToSessionStream(req.user, id, {
      displayName,
      novaSettings,
    });
  }

  @Post('sessions/:id/followup-suggestions')
  generateFollowupSuggestions(
    @Req() req: any,
    @Param('id') id: string,
    @Body() body: any,
  ) {
    return this.svc.generateFollowupSuggestions(req.user, String(id), body);
  }

  @Post('sessions/:sessionId/upload')
  @UseInterceptors(
    FileInterceptor('file', {
      storage: novaDiskStorage(),
      limits: { fileSize: 30 * 1024 * 1024 },
    }),
  )
  uploadSessionFile(
    @Req() req: any,
    @Param('sessionId') sessionId: string,
    @UploadedFile() file: Express.Multer.File,
    @Body() body: any,
  ) {
    return this.svc.uploadSessionFile(
      req.user,
      String(sessionId || '').trim(),
      file,
      body,
    );
  }
}