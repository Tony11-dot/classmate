/**
 * Platform-owner-only endpoints.
 * Protected by SETUP_SECRET env variable.
 *
 * GET  /setup       → HTML form UI for creating schools
 * POST /setup/school → create school + link admin (JSON or form submit)
 */

import {
  BadRequestException,
  Body,
  Controller,
  ForbiddenException,
  Get,
  Headers,
  Post,
  Res,
  HttpCode,
} from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { Response } from 'express';
import { Public } from '../auth/decorators/public.decorator';
import { PrismaService } from '../prisma/prisma.service';

@Controller('setup')
export class SetupController {
  constructor(private readonly prisma: PrismaService) {}

  // ── HTML UI ────────────────────────────────────────────────────────────────

  @Public()
  @Get()
  ui(@Res() res: Response) {
    const html = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>ClassMate — School Setup</title>
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
      background: #0f0f14;
      color: #e8e8f0;
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 24px;
    }
    .card {
      background: #1a1a24;
      border: 1px solid #2a2a3a;
      border-radius: 20px;
      padding: 40px;
      width: 100%;
      max-width: 440px;
    }
    .logo {
      display: flex;
      align-items: center;
      gap: 12px;
      margin-bottom: 32px;
    }
    .logo-badge {
      width: 44px; height: 44px;
      background: #2563eb;
      border-radius: 12px;
      display: flex; align-items: center; justify-content: center;
      font-size: 22px; font-weight: 900; color: #fff;
    }
    .logo-text { font-size: 20px; font-weight: 800; color: #fff; }
    .logo-sub  { font-size: 12px; color: #888; margin-top: 1px; }
    h1 { font-size: 24px; font-weight: 800; margin-bottom: 6px; }
    p.sub { color: #888; font-size: 14px; margin-bottom: 28px; line-height: 1.5; }
    .field { margin-bottom: 16px; }
    label { display: block; font-size: 12px; font-weight: 700; color: #aaa;
            text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 6px; }
    input {
      width: 100%; padding: 12px 14px;
      background: #0f0f14; border: 1px solid #2a2a3a; border-radius: 10px;
      color: #e8e8f0; font-size: 15px; outline: none;
      transition: border-color 0.15s;
    }
    input:focus { border-color: #2563eb; }
    input::placeholder { color: #555; }
    button {
      width: 100%; padding: 14px;
      background: #2563eb; color: #fff; border: none; border-radius: 10px;
      font-size: 16px; font-weight: 700; cursor: pointer; margin-top: 8px;
      transition: background 0.15s;
    }
    button:hover { background: #1d4fd7; }
    button:disabled { background: #334; cursor: not-allowed; }
    .result {
      margin-top: 20px; padding: 16px; border-radius: 10px;
      font-size: 13px; line-height: 1.6; display: none;
    }
    .result.ok    { background: #0d2a1a; border: 1px solid #1a5c30; color: #4ade80; }
    .result.err   { background: #2a0d0d; border: 1px solid #5c1a1a; color: #f87171; }
    .result pre   { font-family: monospace; font-size: 12px; white-space: pre-wrap; margin-top: 8px; }
    .divider { border: none; border-top: 1px solid #2a2a3a; margin: 28px 0; }
  </style>
</head>
<body>
  <div class="card">
    <div class="logo">
      <div class="logo-badge">C</div>
      <div>
        <div class="logo-text">ClassMate</div>
        <div class="logo-sub">Platform Admin</div>
      </div>
    </div>

    <h1>Create School</h1>
    <p class="sub">Only you can do this. Each school gets its own isolated environment — users, data, and settings never cross school boundaries.</p>

    <form id="form">
      <div class="field">
        <label>School Name</label>
        <input id="schoolName" name="schoolName" type="text" placeholder="e.g. Greenwood Academy" required autocomplete="off">
      </div>
      <div class="field">
        <label>Admin Email</label>
        <input id="adminEmail" name="adminEmail" type="email" placeholder="admin@school.com" required autocomplete="off">
      </div>
      <div class="field">
        <label>Setup Secret</label>
        <input id="secret" name="secret" type="password" placeholder="Your SETUP_SECRET" required autocomplete="off">
      </div>
      <button type="submit" id="btn">Create School</button>
    </form>

    <div class="result" id="result"></div>

    <hr class="divider">
    <p style="color:#555;font-size:12px;text-align:center">
      Schools already created are listed in your Railway PostgreSQL database.
    </p>
  </div>

  <script>
    document.getElementById('form').addEventListener('submit', async (e) => {
      e.preventDefault();
      const btn = document.getElementById('btn');
      const result = document.getElementById('result');
      btn.disabled = true;
      btn.textContent = 'Creating…';
      result.style.display = 'none';

      try {
        const res = await fetch('/setup/school', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'x-setup-secret': document.getElementById('secret').value,
          },
          body: JSON.stringify({
            schoolName: document.getElementById('schoolName').value,
            adminEmail: document.getElementById('adminEmail').value,
          }),
        });
        const data = await res.json();
        result.className = 'result ' + (res.ok ? 'ok' : 'err');
        result.style.display = 'block';
        if (res.ok) {
          result.innerHTML = '<strong>✓ School created successfully</strong><pre>' +
            JSON.stringify(data, null, 2) + '</pre>';
          document.getElementById('form').reset();
        } else {
          result.innerHTML = '<strong>✗ Error</strong><pre>' +
            JSON.stringify(data, null, 2) + '</pre>';
        }
      } catch (err) {
        result.className = 'result err';
        result.style.display = 'block';
        result.innerHTML = '<strong>✗ Network error</strong><pre>' + err.message + '</pre>';
      } finally {
        btn.disabled = false;
        btn.textContent = 'Create School';
      }
    });
  </script>
</body>
</html>`;
    res.setHeader('Content-Type', 'text/html');
    res.send(html);
  }

  // ── API endpoint ───────────────────────────────────────────────────────────

  @Public()
  @Post('school')
  @HttpCode(200)
  async bootstrapSchool(
    @Headers('x-setup-secret') secret: string,
    @Body() body: { schoolName: string; adminEmail: string },
  ) {
    const expected = process.env.SETUP_SECRET;
    if (!expected || expected.length < 8) {
      throw new ForbiddenException('Setup endpoint is disabled (SETUP_SECRET not configured)');
    }
    if (secret !== expected) {
      throw new ForbiddenException('Invalid setup secret');
    }

    const schoolName = String(body?.schoolName ?? '').trim();
    const adminEmail = String(body?.adminEmail ?? '').trim().toLowerCase();
    if (!schoolName) throw new BadRequestException('schoolName is required');
    if (!adminEmail) throw new BadRequestException('adminEmail is required');

    // Create school (or find existing with same name)
    let school = await this.prisma.school.findFirst({ where: { name: schoolName } });
    if (!school) {
      school = await this.prisma.school.create({ data: { name: schoolName } });
    }

    // Find or create the admin user
    let adminUser = await this.prisma.user.findFirst({ where: { email: adminEmail } });
    let tempPassword: string | null = null;

    if (!adminUser) {
      tempPassword = `Classmate${Math.floor(100000 + Math.random() * 900000)}!`;
      const hash = await bcrypt.hash(tempPassword, 10);
      adminUser = await this.prisma.user.create({
        data: {
          email: adminEmail,
          name: adminEmail.split('@')[0],
          password: hash,
          schoolId: school.id,
          status: 'ACTIVE',
          roles: { create: [{ role: 'ADMIN' }] },
        } as any,
      });
    } else {
      // Link existing user to this school and ensure ADMIN role
      await this.prisma.user.update({
        where: { id: adminUser.id },
        data: { schoolId: school.id } as any,
      });
      await this.prisma.userRole.upsert({
        where: { userId_role: { userId: adminUser.id, role: 'ADMIN' as any } },
        update: {},
        create: { userId: adminUser.id, role: 'ADMIN' as any },
      });
    }

    return {
      ok: true,
      school: { id: school.id, name: school.name },
      admin: {
        id: adminUser.id,
        email: adminUser.email,
        existingAccount: !tempPassword,
      },
      ...(tempPassword ? { tempPassword, note: 'Save this password — it is shown only once.' } : {}),
    };
  }
}
