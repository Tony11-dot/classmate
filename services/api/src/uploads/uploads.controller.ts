import {
  BadRequestException,
  Controller,
  Post,
  Req,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { Role } from '../auth/roles';
import { diskStorage } from 'multer';
import { extname } from 'path';
import { mkdirSync } from 'fs';

function ensureUploadsDir() {
  mkdirSync('uploads', { recursive: true });
  mkdirSync('uploads/solutions', { recursive: true });
  mkdirSync('uploads/attachments', { recursive: true });
}

function safeName(raw: string) {
  return raw.replace(/[^a-zA-Z0-9._-]/g, '_');
}

@Controller('uploads')
@UseGuards(JwtAuthGuard)
export class UploadsController {
  @Roles(Role.STUDENT, Role.ADMIN, Role.TEACHER, Role.SECRETARY)
  @Post('solution-file')
  @UseInterceptors(
    FileInterceptor('file', {
      storage: diskStorage({
        destination: (_req, _file, cb) => {
          ensureUploadsDir();
          cb(null, 'uploads/solutions');
        },
        filename: (_req, file, cb) => {
          const stamp = `${Date.now()}-${Math.round(Math.random() * 1e9)}`;
          const base = safeName(file.originalname || 'upload');
          const ext = extname(base);
          const stem = ext ? base.slice(0, -ext.length) : base;
          cb(null, `${stem}-${stamp}${ext}`);
        },
      }),
      limits: { fileSize: 20 * 1024 * 1024 },
      fileFilter: (_req, file, cb) => {
        const mime = String(file.mimetype || '').toLowerCase();
        const ok =
          mime.startsWith('image/') || mime === 'application/pdf';
        cb(ok ? null : new BadRequestException('Only image/pdf allowed'), ok);
      },
    }),
  )
  uploadSolutionFile(@UploadedFile() file: Express.Multer.File, @Req() _req: any) {
    if (!file) throw new BadRequestException('file is required');
    const kind = file.mimetype === 'application/pdf' ? 'pdf' : 'image';
    return {
      ok: true,
      file: { url: `/uploads/solutions/${file.filename}`, fileName: file.originalname, mimeType: file.mimetype, kind, fileSize: file.size },
    };
  }

  @Roles(Role.STUDENT, Role.ADMIN, Role.TEACHER, Role.SECRETARY)
  @Post('attachment')
  @UseInterceptors(
    FileInterceptor('file', {
      storage: diskStorage({
        destination: (_req, _file, cb) => { ensureUploadsDir(); cb(null, 'uploads/attachments'); },
        filename: (_req, file, cb) => {
          const stamp = `${Date.now()}-${Math.round(Math.random() * 1e9)}`;
          const base = safeName(file.originalname || 'upload');
          const ext = extname(base);
          const stem = ext ? base.slice(0, -ext.length) : base;
          cb(null, `${stem}-${stamp}${ext}`);
        },
      }),
      limits: { fileSize: 50 * 1024 * 1024 },
    }),
  )
  uploadAttachment(@UploadedFile() file: Express.Multer.File, @Req() _req: any) {
    if (!file) throw new BadRequestException('file is required');
    return {
      ok: true,
      url: `/uploads/attachments/${file.filename}`,
      fileUrl: `/uploads/attachments/${file.filename}`,
      fileName: file.originalname,
      mimeType: file.mimetype,
      fileSize: file.size,
    };
  }
}
