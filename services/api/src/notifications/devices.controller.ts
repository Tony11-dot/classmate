import { Body, Controller, Delete, Param, Post, Req, UseGuards } from '@nestjs/common';
import { SkipThrottle } from '@nestjs/throttler';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { PushService } from './push.service';

/// Device-token registration. Mobile clients POST their FCM token
/// after the user signs in (or after the token rotates) and DELETE
/// the token when the user signs out.
@SkipThrottle()
@UseGuards(JwtAuthGuard)
@Controller('devices')
export class DevicesController {
  constructor(private readonly push: PushService) {}

  @Post('register')
  async register(
    @Req() req: any,
    @Body() body: { token: string; platform: 'ios' | 'android'; appVersion?: string },
  ) {
    const userId = String(req.user?.sub ?? req.user?.id ?? '').trim();
    if (!userId) return { ok: false };
    await this.push.registerToken({
      userId,
      token: body?.token ?? '',
      platform: body?.platform ?? ('android' as any),
      appVersion: body?.appVersion,
    });
    return { ok: true };
  }

  @Delete(':token')
  async unregister(@Param('token') token: string) {
    await this.push.unregisterToken(token);
    return { ok: true };
  }
}
