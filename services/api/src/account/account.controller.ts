import { Body, Controller, Get, Post, Req } from '@nestjs/common';
import { Roles } from '../auth/decorators/roles.decorator';
import { ALL_APP_ROLES } from '../auth/roles';
import { AccountService } from './account.service';

/**
 * Self-service account endpoints. Any authenticated user manages their OWN
 * account here — export a copy of their data, or delete the account. Scoped
 * entirely to `req.user`; never takes another user's id.
 */
@Roles(...ALL_APP_ROLES)
@Controller('account')
export class AccountController {
  constructor(private readonly account: AccountService) {}

  @Post('consent')
  consent(
    @Req() req: any,
    @Body()
    body: { guardianConsent?: boolean; birthDate?: string; consentVersion?: string },
  ) {
    return this.account.recordConsent(req.user.sub ?? req.user.id, body);
  }

  @Get('export')
  export(@Req() req: any) {
    return this.account.exportMyData(req.user.sub ?? req.user.id);
  }

  // POST (not DELETE) so the confirmation password travels in the body.
  @Post('delete')
  remove(@Req() req: any, @Body() body: { currentPassword?: string }) {
    return this.account.deleteMyAccount(
      req.user.sub ?? req.user.id,
      body?.currentPassword,
    );
  }
}
