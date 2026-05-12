import { BadRequestException, Controller, Post, Req, UploadedFile, UseGuards, UseInterceptors } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname } from 'path';
import { mkdirSync } from 'fs';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

const ALLOWED_MIMES = new Set([
  'image/jpeg', 'image/png', 'image/webp', 'image/gif', 'image/heic', 'image/heif',
  'audio/mpeg', 'audio/mp4', 'audio/wav', 'audio/aac', 'audio/ogg', 'audio/webm',
  'video/mp4', 'video/quicktime', 'video/webm', 'video/3gpp',
  'application/pdf',
  'application/msword',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  'application/vnd.ms-excel',
  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  'application/vnd.ms-powerpoint',
  'application/vnd.openxmlformats-officedocument.presentationml.presentation',
  'application/zip',
  'text/plain',
]);

const MAX_FILE_SIZE = 50 * 1024 * 1024; // 50 MB

function ensureDir() {
  mkdirSync('uploads/dm', { recursive: true });
}

@Controller('uploads')
@UseGuards(JwtAuthGuard)
export class DmUploadController {
  @Post('dm-media')
  @UseInterceptors(
    FileInterceptor('file', {
      storage: diskStorage({
        destination: (_req, _file, cb) => {
          ensureDir();
          cb(null, 'uploads/dm');
        },
        filename: (req, file, cb) => {
          const uid = String((req as any)?.user?.sub ?? (req as any)?.user?.id ?? 'anon');
          const stamp = `${Date.now()}-${uid}`;
          const base = (file.originalname || 'upload').replace(/[^a-zA-Z0-9._-]/g, '_');
          const ext = extname(base);
          const stem = ext ? base.slice(0, -ext.length) : base;
          cb(null, `${stem}-${stamp}${ext}`);
        },
      }),
      limits: { fileSize: MAX_FILE_SIZE },
      fileFilter: (_req, file, cb) => {
        const mime = String(file.mimetype || '').toLowerCase();
        if (!ALLOWED_MIMES.has(mime)) {
          cb(new BadRequestException(`File type "${mime}" is not allowed`), false);
          return;
        }
        cb(null, true);
      },
    }),
  )
  async upload(@Req() _req: any, @UploadedFile() file: Express.Multer.File) {
    if (!file) throw new BadRequestException('file is required');
    return {
      ok: true,
      file: {
        url: `/uploads/dm/${file.filename}`,
        mimeType: file.mimetype,
        fileName: file.originalname,
        fileSize: file.size,
      },
    };
  }
}
