import {
  Body,
  Controller,
  Get,
  Post,
  Req,
  UnauthorizedException,
  UseGuards,
} from '@nestjs/common';
import { RegisterDto } from './dto/register.dto';
import { AuthService } from './auth.service';

import { PrismaService } from '../prisma/prisma.service';
import { LoginDto } from './dto/login.dto';
import { AuthGuard } from '@nestjs/passport';
import { Throttle } from '@nestjs/throttler';

@Controller('auth')
export class AuthController {
  constructor(private readonly auth: AuthService, private readonly prisma: PrismaService) {}

  @Throttle({ default: { limit: 5, ttl: 60 } })
  @Post('login')
  async login(@Body() dto: LoginDto) {
    const result = await this.auth.login(dto.email, dto.password);
    if (!result) throw new UnauthorizedException('Invalid credentials');
    return result;
  }

  @Throttle({ default: { limit: 5, ttl: 60 } })
  @Post('register')
  register(@Body() body: RegisterDto) {
    return this.auth.register(body);
  }

  @UseGuards(AuthGuard('jwt'))
  @Get('me')
  async me(@Req() req: any) {
    const u = req.user;
    const uid = u?.sub ?? u?.id;
    if (!uid) return { ok: true, user: u };

    const db = await this.prisma.user.findUnique({
      where: { id: uid },
      include: { roles: true },
    });

    const roles = (db?.roles ?? []).map((r: any) => r.role);
    return { ok: true, user: { ...(u ?? {}), id: uid, roles } };
  }
}
