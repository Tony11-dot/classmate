import { Injectable } from '@nestjs/common';

@Injectable()
export class NovaVerifyService {
  async verifySolution(input: {
    caption?: string;
    files: { mimeType: string }[];
  }) {
    // TEMP LOGIC (replace with AI later)
    if (input.files.length === 0) {
      return { status: 'REJECTED', reason: 'No files attached' };
    }

    return { status: 'VERIFIED', reason: null };
  }
}
