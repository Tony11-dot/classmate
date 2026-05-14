/**
 * Platform-owner-only setup UI.
 * GET  /platform        → full school + admin creation UI
 * POST /platform/school → create school with all settings (JSON or form)
 *
 * Protected by SETUP_SECRET env variable.
 */

import {
  BadRequestException,
  Body,
  Controller,
  ForbiddenException,
  Get,
  Headers,
  HttpCode,
  Post,
  Res,
} from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import type { Response } from 'express';
import { Public } from '../auth/decorators/public.decorator';
import { PrismaService } from '../prisma/prisma.service';

const LOGO_SVG = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" width="36" height="36">
  <!-- C arc: 288° sweep with 72° gap on the right -->
  <path d="M80.3,72.1 A37.5,37.5 0 1 1 80.3,27.9"
    fill="none" stroke="currentColor" stroke-width="15.5" stroke-linecap="butt"/>
  <!-- M shape -->
  <polyline points="35.4,73.5 35.4,26.5 50,46.2 64.6,26.5 64.6,73.5"
    fill="none" stroke="currentColor" stroke-width="7.7" stroke-linejoin="miter"
    stroke-linecap="butt" stroke-miterlimit="8"/>
</svg>`;

const PAGE = (secret: string) => `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>ClassMate — Platform Admin</title>
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    :root {
      --bg: #0b0b10; --surface: #16161f; --border: #252533;
      --blue: #2563eb; --blue2: #1d4fd7; --text: #e4e4f0;
      --muted: #7070a0; --error-bg: #1f0a0a; --error-border: #5c1a1a;
      --ok-bg: #0a1f12; --ok-border: #1a5c30;
    }
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
           background: var(--bg); color: var(--text); min-height: 100vh;
           display: flex; align-items: flex-start; justify-content: center;
           padding: 40px 20px 80px; }
    .wrap { width: 100%; max-width: 580px; }

    /* ── Header ── */
    .header { display: flex; align-items: center; gap: 12px; margin-bottom: 36px; }
    .header svg { color: #fff; }
    .header-text { font-size: 22px; font-weight: 800; letter-spacing: -0.3px; }
    .header-sub  { font-size: 12px; color: var(--muted); margin-top: 1px; }

    /* ── Card ── */
    .card { background: var(--surface); border: 1px solid var(--border);
            border-radius: 18px; padding: 28px; margin-bottom: 20px; }
    .card-title { font-size: 14px; font-weight: 800; color: var(--blue);
                  text-transform: uppercase; letter-spacing: 0.6px; margin-bottom: 20px;
                  display: flex; align-items: center; gap: 8px; }
    .card-title::after { content: ''; flex: 1; height: 1px; background: var(--border); }

    /* ── Fields ── */
    .row2 { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
    .field { margin-bottom: 16px; }
    .field:last-child { margin-bottom: 0; }
    label { display: block; font-size: 11px; font-weight: 700; color: var(--muted);
            text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 6px; }
    label span { color: var(--blue); margin-left: 2px; }
    input, textarea {
      width: 100%; padding: 11px 13px;
      background: var(--bg); border: 1px solid var(--border); border-radius: 10px;
      color: var(--text); font-size: 14px; font-family: inherit; outline: none;
      transition: border-color 0.15s; resize: vertical;
    }
    input:focus, textarea:focus { border-color: var(--blue); }
    input::placeholder, textarea::placeholder { color: #444; }
    .hint { font-size: 11px; color: var(--muted); margin-top: 5px; line-height: 1.4; }

    /* ── Periods grid ── */
    .periods { display: grid; grid-template-columns: repeat(3, 1fr); gap: 10px; }
    .period-row { background: var(--bg); border: 1px solid var(--border);
                  border-radius: 10px; padding: 10px 12px; }
    .period-label { font-size: 11px; font-weight: 800; color: var(--blue);
                    margin-bottom: 6px; }
    .period-times { display: flex; gap: 6px; align-items: center; }
    .period-times input { padding: 6px 8px; font-size: 12px; text-align: center; }
    .period-sep { color: var(--muted); font-size: 11px; flex-shrink: 0; }

    /* ── Secret field ── */
    .secret-wrap { background: #0f0f18; border: 1px solid #3a1a1a;
                   border-radius: 10px; padding: 14px; margin-bottom: 20px;
                   display: flex; gap: 12px; align-items: flex-start; }
    .secret-icon { font-size: 18px; flex-shrink: 0; margin-top: 1px; }
    .secret-wrap label { color: #e05; text-transform: uppercase; letter-spacing: 0.5px; }
    .secret-wrap input { background: var(--bg); border-color: #3a1a1a; }

    /* ── Submit ── */
    button[type=submit] {
      width: 100%; padding: 15px; background: var(--blue); color: #fff;
      border: none; border-radius: 12px; font-size: 16px; font-weight: 700;
      cursor: pointer; transition: background 0.15s; margin-top: 8px;
    }
    button[type=submit]:hover { background: var(--blue2); }
    button[type=submit]:disabled { background: #2a2a3a; color: #555; cursor: not-allowed; }

    /* ── Result ── */
    .result { margin-top: 20px; padding: 18px; border-radius: 12px;
              font-size: 13px; line-height: 1.6; display: none; }
    .result.ok  { background: var(--ok-bg);    border: 1px solid var(--ok-border);  color: #4ade80; }
    .result.err { background: var(--error-bg); border: 1px solid var(--error-border); color: #f87171; }
    .result pre { font-family: monospace; font-size: 12px; white-space: pre-wrap;
                  margin-top: 10px; padding: 10px; background: rgba(0,0,0,0.3);
                  border-radius: 8px; color: #ccc; }

    @media (max-width: 500px) { .row2, .periods { grid-template-columns: 1fr; } }
  </style>
</head>
<body>
<div class="wrap">

  <div class="header">
    ${LOGO_SVG}
    <div>
      <div class="header-text">ClassMate</div>
      <div class="header-sub">Platform Admin · School Setup</div>
    </div>
  </div>

  <form id="form">

    <!-- ── School Info ── -->
    <div class="card">
      <div class="card-title">School Info</div>
      <div class="field">
        <label>School Name <span>*</span></label>
        <input id="schoolName" type="text" placeholder="e.g. Greenwood Academy" required autocomplete="off">
      </div>
      <div class="field">
        <label>Logo URL <span style="color:var(--muted);font-weight:400">(optional)</span></label>
        <input id="logoUrl" type="url" placeholder="https://..." autocomplete="off">
        <div class="hint">Direct link to a PNG/JPG. Appears in the app drawer next to the school name.</div>
      </div>
    </div>

    <!-- ── Subjects ── -->
    <div class="card">
      <div class="card-title">Subjects</div>
      <div class="field">
        <label>Subject list <span style="color:var(--muted);font-weight:400">(optional)</span></label>
        <textarea id="subjects" rows="3" placeholder="Math, Science, English, History, Art, PE"></textarea>
        <div class="hint">Comma-separated. Available to teachers when creating assignments & assessments.</div>
      </div>
    </div>

    <!-- ── Bell Schedule ── -->
    <div class="card">
      <div class="card-title">Bell Schedule</div>
      <div class="hint" style="margin-bottom:16px">Optional. Set start/end times for each period. Leave blank to configure later in the app.</div>
      <div class="periods" id="periods">
        ${[1,2,3,4,5,6,7,8,9].map(p => `
        <div class="period-row">
          <div class="period-label">Period ${p}</div>
          <div class="period-times">
            <input type="time" name="p${p}start" placeholder="--:--">
            <span class="period-sep">→</span>
            <input type="time" name="p${p}end" placeholder="--:--">
          </div>
        </div>`).join('')}
      </div>
    </div>

    <!-- ── Admin Account ── -->
    <div class="card">
      <div class="card-title">Admin Account</div>
      <div class="hint" style="margin-bottom:16px">The first admin for this school. At least email or username required.</div>
      <div class="row2">
        <div class="field">
          <label>Full Name (English) <span>*</span></label>
          <input id="adminName" type="text" placeholder="John Doe" required>
        </div>
        <div class="field">
          <label>Username</label>
          <input id="adminUsername" type="text" placeholder="john.doe" autocomplete="off">
        </div>
      </div>
      <div class="field">
        <label>Email</label>
        <input id="adminEmail" type="email" placeholder="admin@school.com" autocomplete="off">
        <div class="hint">Either username or email is required.</div>
      </div>
    </div>

    <!-- ── Secret ── -->
    <div class="secret-wrap">
      <div class="secret-icon">🔑</div>
      <div style="flex:1">
        <label style="display:block;margin-bottom:6px">Platform Secret <span style="color:#e05">*</span></label>
        <input id="secret" type="password" placeholder="SETUP_SECRET value" required autocomplete="off">
      </div>
    </div>

    <button type="submit" id="btn">Create School</button>
  </form>

  <div class="result" id="result"></div>

</div>
<script>
  document.getElementById('form').addEventListener('submit', async (e) => {
    e.preventDefault();
    const btn = document.getElementById('btn');
    const result = document.getElementById('result');
    btn.disabled = true; btn.textContent = 'Creating…';
    result.style.display = 'none';

    // Collect bell schedule
    const bell = [];
    for (let p = 1; p <= 9; p++) {
      const s = document.querySelector('[name=p'+p+'start]').value;
      const en = document.querySelector('[name=p'+p+'end]').value;
      if (s && en) bell.push({ period: p, startTime: s, endTime: en });
    }

    // Parse subjects
    const subjectRaw = document.getElementById('subjects').value.trim();
    const subjects = subjectRaw ? subjectRaw.split(',').map(s => s.trim()).filter(Boolean) : [];

    const payload = {
      schoolName:    document.getElementById('schoolName').value.trim(),
      logoUrl:       document.getElementById('logoUrl').value.trim() || undefined,
      subjects:      subjects.length ? subjects : undefined,
      bellSchedule:  bell.length ? bell : undefined,
      adminName:     document.getElementById('adminName').value.trim(),
      adminUsername: document.getElementById('adminUsername').value.trim() || undefined,
      adminEmail:    document.getElementById('adminEmail').value.trim() || undefined,
    };

    try {
      const res = await fetch('/platform/school', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json',
                   'x-setup-secret': document.getElementById('secret').value },
        body: JSON.stringify(payload),
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
      btn.disabled = false; btn.textContent = 'Create School';
    }
  });
</script>
</body>
</html>`;

@Controller('platform')
export class SetupController {
  constructor(private readonly prisma: PrismaService) {}

  @Public()
  @Get()
  ui(@Res() res: Response) {
    res.setHeader('Content-Type', 'text/html');
    res.send(PAGE(''));
  }

  @Public()
  @Post('school')
  @HttpCode(200)
  async bootstrapSchool(
    @Headers('x-setup-secret') secret: string,
    @Body() body: {
      schoolName: string;
      logoUrl?: string;
      subjects?: string[];
      bellSchedule?: { period: number; startTime: string; endTime: string }[];
      adminName: string;
      adminEmail?: string;
      adminUsername?: string;
    },
  ) {
    const expected = process.env.SETUP_SECRET;
    if (!expected || expected.length < 8)
      throw new ForbiddenException('Setup endpoint is disabled (SETUP_SECRET not configured)');
    if (secret !== expected)
      throw new ForbiddenException('Invalid setup secret');

    const schoolName = String(body?.schoolName ?? '').trim();
    const adminName  = String(body?.adminName  ?? '').trim();
    const adminEmail = body?.adminEmail    ? String(body.adminEmail).trim().toLowerCase()   : undefined;
    const adminUsername = body?.adminUsername ? String(body.adminUsername).trim().toLowerCase() : undefined;

    if (!schoolName)  throw new BadRequestException('schoolName is required');
    if (!adminName)   throw new BadRequestException('adminName is required');
    if (!adminEmail && !adminUsername)
      throw new BadRequestException('adminEmail or adminUsername is required');

    // ── Create or update school ──────────────────────────────────────────────
    let school = await this.prisma.school.findFirst({ where: { name: schoolName } });
    const schoolData: any = { name: schoolName };
    if (body?.logoUrl) schoolData.logoUrl = body.logoUrl;
    school = school
      ? await this.prisma.school.update({ where: { id: school.id }, data: schoolData })
      : await this.prisma.school.create({ data: schoolData });

    // ── Subjects (school-wide, grade = 0) ────────────────────────────────────
    if (body?.subjects?.length) {
      await this.prisma.schoolGradeSubjectDefault.upsert({
        where: { schoolId_grade: { schoolId: school.id, grade: 0 } } as any,
        update: { subjects: body.subjects } as any,
        create: { schoolId: school.id, grade: 0, subjects: body.subjects } as any,
      }).catch(() => null); // table may not exist yet — non-fatal
    }

    // ── Bell schedule ─────────────────────────────────────────────────────────
    if (body?.bellSchedule?.length) {
      await Promise.all(
        body.bellSchedule.map((d) =>
          this.prisma.schoolPeriodDefault.upsert({
            where: { schoolId_period: { schoolId: school!.id, period: d.period } },
            update:  { startTime: d.startTime, endTime: d.endTime },
            create:  { schoolId: school!.id, period: d.period, startTime: d.startTime, endTime: d.endTime },
          }).catch(() => null)
        )
      );
    }

    // ── Create or update admin user ───────────────────────────────────────────
    const whereAdmin: any = adminEmail
      ? { email: adminEmail }
      : { username: adminUsername };
    let adminUser = await this.prisma.user.findFirst({ where: whereAdmin });
    let tempPassword: string | null = null;

    if (!adminUser) {
      tempPassword = `Classmate${Math.floor(100000 + Math.random() * 900000)}!`;
      const hash = await bcrypt.hash(tempPassword, 10);
      adminUser = await this.prisma.user.create({
        data: {
          name: adminName,
          nameEn: adminName,
          ...(adminEmail    ? { email: adminEmail }       : {}),
          ...(adminUsername ? { username: adminUsername } : {}),
          password: hash,
          schoolId: school.id,
          status: 'ACTIVE',
          roles: { create: [{ role: 'ADMIN' }] },
        } as any,
      });
    } else {
      await this.prisma.user.update({
        where: { id: adminUser.id },
        data: { schoolId: school.id, name: adminName, nameEn: adminName } as any,
      });
      await this.prisma.userRole.upsert({
        where: { userId_role: { userId: adminUser.id, role: 'ADMIN' as any } },
        update: {}, create: { userId: adminUser.id, role: 'ADMIN' as any },
      });
    }

    return {
      ok: true,
      school:  { id: school.id, name: school.name },
      admin:   { id: adminUser.id, email: adminUser.email, username: (adminUser as any).username },
      login:   { identifier: adminEmail ?? adminUsername, note: 'Use this to log in to the admin app' },
      ...(tempPassword
        ? { tempPassword, passwordNote: 'Save this — shown only once.' }
        : { passwordNote: 'Existing account — password unchanged.' }),
    };
  }
}
