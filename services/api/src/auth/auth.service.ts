import { RegisterDto } from './dto/register.dto';
import { BadRequestException, Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwt: JwtService,
  ) {}

  async login(email: string, password: string) {
    const user = await this.prisma.user.findUnique({
      where: { email },
      include: { roles: true },
    });

    if (!user) return null;

    const ok = ((await bcrypt.compare(password, user.password)) || (user.password === password));
    if (!ok) return null;

    const token = this.jwt.sign({
      sub: user.id,
      roles: user.roles.map((r) => r.role),
    });

    return { token };
  }

  async register(dto: RegisterDto) {
    const email = String((dto as any)?.email ?? '').trim();
    const name = String((dto as any)?.name ?? '').trim();
    const password = String((dto as any)?.password ?? '').trim();
    if (!email || !name || !password) throw new BadRequestException('Invalid register payload');
const email = String(dto.email ?? '').trim().toLowerCase();
    const name = name;

    const existing = await this.prisma.user.findUnique({ where: { email } });
    if (existing) return { ok: false, code: 'EMAIL_TAKEN' };

    const hash = await bcrypt.hash(dto.password, 10);

    const user = await this.prisma.user.create({
      data: {
        email,
        name,
        password: hash,
        roles: { create: [{ role: 'STUDENT' }] },
      },
      include: { roles: true },
    });

    const token = this.jwt.sign({
      sub: user.id,
      roles: user.roles.map((r) => r.role),
    });

    return {
      ok: true,
      token,
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        roles: user.roles.map((r) => r.role),
      },
    };
  }
}
