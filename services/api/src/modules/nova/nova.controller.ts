import { Controller, Post, UploadedFile, UseInterceptors, Body } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import OpenAI from 'openai';
import fs from 'fs';

const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

@Controller('nova')
export class NovaController {

  @Post('image')
  @UseInterceptors(FileInterceptor('file'))
  async analyzeImage(@UploadedFile() file: Express.Multer.File) {
    const base64 = fs.readFileSync(file.path, { encoding: 'base64' });

    const res = await openai.chat.completions.create({
      model: 'gpt-4o-mini',
      messages: [
        {
          role: 'user',
          content: [
            { type: 'text', text: 'Explain this image for a student clearly.' },
            { type: 'image_url', image_url: { url: `data:image/jpeg;base64,${base64}` } }
          ],
        },
      ],
    });

    return { text: res.choices[0].message.content };
  }

  @Post('voice')
  @UseInterceptors(FileInterceptor('file'))
  async transcribe(@UploadedFile() file: Express.Multer.File) {
    const transcription = await openai.audio.transcriptions.create({
      file: fs.createReadStream(file.path),
      model: 'gpt-4o-mini-transcribe',
    });

    return { text: transcription.text };
  }
}
