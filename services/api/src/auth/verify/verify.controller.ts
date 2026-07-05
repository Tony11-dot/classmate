import { BadRequestException, Body, Controller, Get, HttpCode, Param, Post, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../jwt-auth.guard';
import { Roles } from '../decorators/roles.decorator';
import { ALL_APP_ROLES } from '../roles';
import { VerifyService, Channel } from './verify.service';

function parseChannel(raw: string): Channel {
  const v = String(raw ?? '').toLowerCase();
  if (v !== 'email' && v !== 'sms') {
    throw new BadRequestException('channel must be "email" or "sms"');
  }
  return v;
}

@UseGuards(JwtAuthGuard)
@Roles(...ALL_APP_ROLES)
@Controller('me/verify')
export class VerifyController {
  constructor(private readonly verify: VerifyService) {}

  /**
   * Issue + send a 6-digit code. Body may include `newValue` — when present,
   * this kicks off the CHANGE flow (code goes to the OLD email/phone; the
   * change is applied on /confirm). Without `newValue` it's a pure verify
   * of the user's current value.
   */
  @Post(':channel/start')
  @HttpCode(200)
  async start(
    @Req() req: any,
    @Param('channel') channel: string,
    @Body() body: { newValue?: string },
  ) {
    const userId = req.user?.sub ?? req.user?.id;
    if (!userId) throw new BadRequestException('Not authenticated');
    return this.verify.startVerification({
      userId,
      channel: parseChannel(channel),
      newValue: body?.newValue ?? null,
    });
  }

  /**
   * Redeem the code. For a verify-current code: mark the channel verified.
   * For a change code: apply the new value and mark unverified (the new
   * value must be re-verified to be usable for password reset).
   */
  @Post(':channel/confirm')
  @HttpCode(200)
  async confirm(
    @Req() req: any,
    @Param('channel') channel: string,
    @Body() body: { code?: string; newValue?: string },
  ) {
    const userId = req.user?.sub ?? req.user?.id;
    if (!userId) throw new BadRequestException('Not authenticated');
    return this.verify.confirmVerification({
      userId,
      channel: parseChannel(channel),
      code: String(body?.code ?? ''),
      newValue: body?.newValue ?? null,
    });
  }

  /**
   * Lightweight status read used by the Profile screen to render the
   * "Verified" badge + Verify button next to each channel.
   */
  @Get('status')
  async status(@Req() req: any) {
    const userId = req.user?.sub ?? req.user?.id;
    if (!userId) throw new BadRequestException('Not authenticated');
    return { ok: true, ...await this.verify.statusFor(userId) };
  }
}
