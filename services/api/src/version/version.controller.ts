import { Controller, Get } from '@nestjs/common';

@Controller()
export class VersionController {
  @Get('version')
  version() {
    return {
      ok: true,
      sha: process.env.GIT_SHA ?? null,
      env: process.env.NODE_ENV ?? null,
    };
  }
}
