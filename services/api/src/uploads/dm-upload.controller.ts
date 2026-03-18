import { Controller, Post, Req, UploadedFile, UseGuards, UseInterceptors } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import * as fs from 'fs';
import * as path from 'path';

@Controller('uploads')
@UseGuards(JwtAuthGuard)
export class DmUploadController {
  @Post('dm-media')
  @UseInterceptors(FileInterceptor('file'))
  async upload(@Req() req: any, @UploadedFile() file: any) {
    const uid = String(req?.user?.sub ?? req?.user?.id ?? 'anon');
    const dir = path.join(process.cwd(), 'uploads', 'dm');
    fs.mkdirSync(dir, { recursive: true });

    const ext = path.extname(file?.originalname || '');
    const name = `${Date.now()}-${uid}${ext}`;
    const abs = path.join(dir, name);

    if (file?.buffer) {
      fs.writeFileSync(abs, file.buffer);
    }

    return {
      ok: true,
      file: {
        url: `/uploads/dm/${name}`,
        mimeType: file?.mimetype ?? null,
        fileName: file?.originalname ?? name,
      },
    };
  }
}
