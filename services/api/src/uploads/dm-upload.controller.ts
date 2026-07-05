import { BadRequestException, Controller, Post, Req, UploadedFile, UseGuards, UseInterceptors } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname } from 'path';
import { mkdirSync } from 'fs';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { ALL_APP_ROLES } from '../auth/roles';

// Specific document/text/archive MIMEs we accept. Anything that starts
// with image/ audio/ video/ is accepted via the category check below —
// iOS in particular uses non-standard subtypes like audio/m4a,
// audio/x-m4a, video/quicktime variations, image/heic that we don't
// want to enumerate one-by-one.
const ALLOWED_DOC_MIMES = new Set([
  'application/pdf',
  'application/msword',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  'application/vnd.ms-excel',
  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  'application/vnd.ms-powerpoint',
  'application/vnd.openxmlformats-officedocument.presentationml.presentation',
  'application/zip',
  'application/octet-stream', // generic fallback some clients send
  'text/plain',
  'text/csv',
]);

function isAllowedMime(mime: string): boolean {
  if (!mime) return false;
  const m = mime.toLowerCase();
  if (m.startsWith('image/')) return true;
  if (m.startsWith('audio/')) return true;
  if (m.startsWith('video/')) return true;
  return ALLOWED_DOC_MIMES.has(m);
}

const MAX_FILE_SIZE = 50 * 1024 * 1024; // 50 MB

function ensureDir() {
  mkdirSync('uploads/dm', { recursive: true });
}

@Controller('uploads')
@UseGuards(JwtAuthGuard)
@Roles(...ALL_APP_ROLES)
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
        if (!isAllowedMime(mime)) {
          cb(new BadRequestException(`File type "${mime}" is not allowed`), false);
          return;
        }
        cb(null, true);
      },
    }),
  )
  async upload(@Req() req: any, @UploadedFile() file: Express.Multer.File) {
    if (!file) throw new BadRequestException('file is required');
    const proto = (req.headers['x-forwarded-proto'] as string)?.split(',')[0].trim() || req.protocol;
    const host = (req.headers['x-forwarded-host'] as string) || req.get('host');
    return {
      ok: true,
      file: {
        url: `${proto}://${host}/uploads/dm/${file.filename}`,
        mimeType: file.mimetype,
        fileName: file.originalname,
        fileSize: file.size,
      },
    };
  }
}
