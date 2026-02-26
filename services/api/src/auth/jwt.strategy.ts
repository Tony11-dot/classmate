import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { PrismaService } from '../prisma/prisma.service';

export type JwtUser = {
  id: string;
  sub: string;
  userId: string;
  roles: string[];
  email?: string;
  name?: string | null;
};

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(private readonly prisma: PrismaService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey:
        process.env.JWT_SECRET || process.env.JWT_ACCESS_SECRET || 'dev',
    });
  }

  async validate(payload: any): Promise<JwtUser> {
    const raw =
      String(payload?.sub ?? payload?.id ?? payload?.userId ?? '') ||
      String(payload?.email ?? '');

    if (!raw) throw new UnauthorizedException('Invalid token payload');

    // 1) try by id
    let user =
      (await this.prisma.user.findUnique({
        where: { id: raw },
        select: { id: true, email: true, name: true },
      })) ?? null;

    // 2) fallback to email (sub/email-based tokens)
    if (!user) {
      user = await this.prisma.user.findUnique({
        where: { email: raw },
        select: { id: true, email: true, name: true },
      });
    }

    if (!user) throw new UnauthorizedException('User not found');

    const rolesRows = await this.prisma.userRole.findMany({
      where: { userId: user.id },
      select: { role: true },
      orderBy: { role: 'asc' },
    });

    const roles = rolesRows.map((r) => String(r.role));

    return {
      id: user.id,
      sub: user.id,
      userId: user.id,
      roles,
      email: user.email ?? undefined,
      name: user.name ?? null,
    };
  }
}
