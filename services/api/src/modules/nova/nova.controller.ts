import { Controller, Post, UploadedFile, UseGuards, UseInterceptors, Body } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import Anthropic from '@anthropic-ai/sdk';
import fs from 'fs';
import { JwtAuthGuard } from '../../auth/jwt-auth.guard';

const anthropic = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });

@UseGuards(JwtAuthGuard)
@Controller('nova')
export class NovaController {

  @Post('image')
  @UseInterceptors(FileInterceptor('file'))
  async analyzeImage(@UploadedFile() file: Express.Multer.File) {
    const base64 = fs.readFileSync(file.path, { encoding: 'base64' });
    const mimeType = (file.mimetype || 'image/jpeg') as
      | 'image/jpeg'
      | 'image/png'
      | 'image/gif'
      | 'image/webp';

    const res = await anthropic.messages.create({
      model: process.env.ANTHROPIC_MODEL || 'claude-sonnet-4-6',
      max_tokens: 1024,
      messages: [
        {
          role: 'user',
          content: [
            { type: 'text', text: 'Explain this image for a student clearly.' },
            {
              type: 'image',
              source: { type: 'base64', media_type: mimeType, data: base64 },
            },
          ],
        },
      ],
    });

    const text = res.content[0]?.type === 'text' ? res.content[0].text : '';
    return { text };
  }

  @Post('voice')
  @UseInterceptors(FileInterceptor('file'))
  async transcribe(@UploadedFile() file: Express.Multer.File) {
    // Audio transcription requires OpenAI Whisper (Claude has no audio API).
    // Set OPENAI_API_KEY in .env to enable this endpoint.
    const openaiKey = process.env.OPENAI_API_KEY;
    if (!openaiKey) {
      return { text: '' };
    }

    try {
      const OpenAI = require('openai');
      const client = new OpenAI({ apiKey: openaiKey });
      const transcription = await client.audio.transcriptions.create({
        file: fs.createReadStream(file.path),
        model: 'whisper-1',
      });
      return { text: transcription.text };
    } catch {
      return { text: '' };
    }
  }
}
