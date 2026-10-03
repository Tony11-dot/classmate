import {
  Body,
  Controller,
  Delete,
  Get,
  Header,
  Patch,
  Post,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import { JwtAuthGuard } from '../../auth/jwt-auth.guard';
import { Public } from '../../auth/decorators/public.decorator';
import { Roles } from '../../auth/decorators/roles.decorator';
import { CLASSNOTES_ROLE } from '../../auth/roles';
import { ClassNotesAccountService } from './classnotes-account.service';
import { classNotesResetPage } from './classnotes-reset-page';
import {
  ClassNotesChangePasswordDto,
  ClassNotesDeleteAccountDto,
  ClassNotesForgotPasswordDto,
  ClassNotesLoginDto,
  ClassNotesRegisterDto,
  ClassNotesResetPasswordDto,
  ClassNotesUpdateProfileDto,
} from './dto/classnotes-auth.dto';

/// ClassNotes' own sign-in, entirely separate from ClassMate's `/auth/*`.
///
/// The ClassNotes iPad app used to require a ClassMate school account to open a
/// notebook. These endpoints are what replaced that: `POST register` and `POST
/// login` mint a ClassNotes-only session, and the token they return is what
/// every `/classnotes/*` data endpoint (and NOVA) already accepts.
///
/// The unauthenticated routes are rate-limited HARD compared with the rest of
/// the API. They are the only endpoints here that an anonymous caller can
/// reach, and each one either hashes a password with bcrypt at cost 12 or sends
/// an e-mail — both expensive enough to be worth abusing.
@Controller('classnotes/auth')
export class ClassNotesAuthController {
  constructor(private readonly accounts: ClassNotesAccountService) {}

  @Public()
  @Throttle({ default: { limit: 8, ttl: 60_000 } })
  @Post('register')
  register(@Body() dto: ClassNotesRegisterDto) {
    return this.accounts.register(dto);
  }

  @Public()
  @Throttle({ default: { limit: 10, ttl: 60_000 } })
  @Post('login')
  login(@Body() dto: ClassNotesLoginDto) {
    return this.accounts.login(dto);
  }

  /// Always answers "sent", registered or not — see the service for why.
  @Public()
  @Throttle({ default: { limit: 5, ttl: 60_000 } })
  @Post('forgot-password')
  forgotPassword(@Body() dto: ClassNotesForgotPasswordDto) {
    return this.accounts.requestPasswordReset(dto.email);
  }

  @Public()
  @Throttle({ default: { limit: 10, ttl: 60_000 } })
  @Post('reset-password')
  resetPassword(@Body() dto: ClassNotesResetPasswordDto) {
    return this.accounts.consumePasswordReset(dto.token, dto.password);
  }

  /// The page the reset mail links to. It is served HERE, beside the endpoint it
  /// posts to, because ClassMate's own `/reset-password` page consumes a
  /// different table and would reject every ClassNotes token it was handed.
  @Public()
  @Throttle({ default: { limit: 30, ttl: 60_000 } })
  @Get('reset')
  @Header('Content-Type', 'text/html; charset=utf-8')
  @Header('Cache-Control', 'no-store')
  @Header('Referrer-Policy', 'no-referrer')
  resetPage(@Query('token') token?: string) {
    return classNotesResetPage(String(token ?? ''));
  }

  // ───────── Signed-in: a ClassNotes token and nothing else ─────────
  // `CLASSNOTES_ROLE` is the only role a ClassNotes account carries, and no
  // other controller on this API lists it, so the role guard's default-deny is
  // what keeps these sessions out of ClassMate's school data.

  @UseGuards(JwtAuthGuard)
  @Roles(CLASSNOTES_ROLE)
  @Get('me')
  me(@Req() req: any) {
    return this.accounts.me(String(req.user?.id ?? ''));
  }

  @UseGuards(JwtAuthGuard)
  @Roles(CLASSNOTES_ROLE)
  @Patch('me')
  updateProfile(@Req() req: any, @Body() dto: ClassNotesUpdateProfileDto) {
    return this.accounts.updateName(String(req.user?.id ?? ''), dto.name);
  }

  @UseGuards(JwtAuthGuard)
  @Roles(CLASSNOTES_ROLE)
  @Throttle({ default: { limit: 10, ttl: 60_000 } })
  @Post('change-password')
  changePassword(@Req() req: any, @Body() dto: ClassNotesChangePasswordDto) {
    return this.accounts.changePassword(
      String(req.user?.id ?? ''),
      dto.currentPassword,
      dto.newPassword,
    );
  }

  /// Required by App Store guideline 5.1.1(v): an app that creates accounts
  /// must let the user delete one from inside the app. Takes the password
  /// because it destroys every notebook the account owns on the server.
  @UseGuards(JwtAuthGuard)
  @Roles(CLASSNOTES_ROLE)
  @Throttle({ default: { limit: 5, ttl: 60_000 } })
  @Delete('me')
  deleteAccount(@Req() req: any, @Body() dto: ClassNotesDeleteAccountDto) {
    return this.accounts.deleteAccount(String(req.user?.id ?? ''), dto.password);
  }
}
