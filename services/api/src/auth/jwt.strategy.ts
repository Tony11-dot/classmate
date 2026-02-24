import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';

export type JwtUser = {id: string; sub: string; userId: string; roles: string[]; email?: string };

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor() {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: process.env.JWT_SECRET || process.env.JWT_ACCESS_SECRET || 'dev',
    });
  }

  async validate(payload: any): Promise<JwtUser> {
    const sub = String(payload?.sub ?? '');
    const roles = Array.isArray(payload?.roles) ? payload.roles : [];
    return { id: sub, sub, userId: sub, roles };
  }
}
