/**
 * Platform-owner-only school management UI.
 *   GET  /cms           → full school creation UI
 *   POST /cms/upload    → logo upload (protected by x-setup-secret)
 *   POST /cms/school    → create school with all settings
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
  Req,
  Res,
  UploadedFile,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname, join } from 'path';
import { mkdirSync } from 'fs';
import * as bcrypt from 'bcrypt';
import type { Request, Response } from 'express';
import { Public } from '../auth/decorators/public.decorator';
import { PrismaService } from '../prisma/prisma.service';
import { LOGO_DATA_URI } from './logo';

function ensureUploadsDir() {
  mkdirSync(join(process.cwd(), 'uploads', 'setup'), { recursive: true });
}

function checkSecret(provided: string | undefined): void {
  const expected = process.env.SETUP_SECRET;
  if (!expected || expected.length < 4)
    throw new ForbiddenException('SETUP_SECRET is not configured on the server. Add it to your environment variables.');
  if (provided !== expected)
    throw new ForbiddenException('Wrong setup secret. Check your SETUP_SECRET environment variable.');
}

@Controller('cms')
export class SetupController {
  constructor(private readonly prisma: PrismaService) {}

  // ── Page UI ────────────────────────────────────────────────────────────────

  @Public()
  @Get()
  ui(@Res() res: Response) {
    res.setHeader('Content-Type', 'text/html');
    res.send(buildPage());
  }

  // ── Logo upload ────────────────────────────────────────────────────────────

  @Public()
  @Post('upload')
  @HttpCode(200)
  @UseInterceptors(FileInterceptor('file', {
    storage: diskStorage({
      destination: (_req, _file, cb) => {
        ensureUploadsDir();
        cb(null, join(process.cwd(), 'uploads', 'setup'));
      },
      filename: (_req, file, cb) => {
        const stamp = Date.now();
        const ext = extname(file.originalname) || '.png';
        cb(null, `logo-${stamp}${ext}`);
      },
    }),
    limits: { fileSize: 5 * 1024 * 1024 },
    fileFilter: (_req, file, cb) => {
      if (!file.mimetype.startsWith('image/'))
        return cb(new BadRequestException('Only image files are allowed'), false);
      cb(null, true);
    },
  }))
  async uploadLogo(
    @Headers('x-setup-secret') secret: string,
    @UploadedFile() file: Express.Multer.File,
  ) {
    checkSecret(secret);
    if (!file) throw new BadRequestException('No file provided');
    return { ok: true, url: `/uploads/setup/${file.filename}` };
  }

  // ── Create school ──────────────────────────────────────────────────────────

  @Public()
  @Post('school')
  @HttpCode(200)
  async createSchool(
    @Headers('x-setup-secret') secret: string,
    @Body() body: {
      schoolName: string;
      logoUrl?: string;
      subjects?: string[];
      bellSchedule?: { period: number; startTime: string; endTime: string }[];
      adminName: string;
      adminEmail?: string;
      adminUsername?: string;
      adminPassword: string;
    },
  ) {
    checkSecret(secret);

    // ── Validate inputs ──────────────────────────────────────────────────────
    const schoolName    = String(body?.schoolName    ?? '').trim();
    const adminName     = String(body?.adminName     ?? '').trim();
    const adminEmail    = body?.adminEmail    ? String(body.adminEmail).trim().toLowerCase()    : undefined;
    const adminUsername = body?.adminUsername ? String(body.adminUsername).trim().toLowerCase() : undefined;
    const adminPassword = String(body?.adminPassword ?? '').trim();

    const errors: string[] = [];
    if (!schoolName)  errors.push('School name is required.');
    if (!adminName)   errors.push('Admin full name is required.');
    if (!adminEmail && !adminUsername) errors.push('Admin email or username is required.');
    if (!adminPassword || adminPassword.length < 6) errors.push('Password must be at least 6 characters.');
    if (errors.length) throw new BadRequestException(errors.join(' '));

    // ── Check for duplicates ─────────────────────────────────────────────────
    if (adminEmail) {
      const existing = await this.prisma.user.findFirst({ where: { email: adminEmail } });
      if (existing && (existing as any).schoolId) {
        throw new BadRequestException(`A user with email "${adminEmail}" already exists and belongs to another school. Use a different email or update the existing account.`);
      }
    }
    if (adminUsername) {
      const existing = await this.prisma.user.findFirst({ where: { username: adminUsername } } as any);
      if (existing && (existing as any).schoolId) {
        throw new BadRequestException(`Username "${adminUsername}" is already taken by a user in another school. Choose a different username.`);
      }
    }

    // ── Create / update school ───────────────────────────────────────────────
    let school = await this.prisma.school.findFirst({ where: { name: schoolName } });
    const schoolData: any = { name: schoolName };
    if (body?.logoUrl) schoolData.logoUrl = body.logoUrl;

    school = school
      ? await this.prisma.school.update({ where: { id: school.id }, data: schoolData })
      : await this.prisma.school.create({ data: schoolData });

    // ── Subjects ─────────────────────────────────────────────────────────────
    if (body?.subjects?.length) {
      await this.prisma.schoolGradeSubjectDefault.upsert({
        where: { schoolId_grade: { schoolId: school.id, grade: 0 } } as any,
        update: { subjects: body.subjects } as any,
        create: { schoolId: school.id, grade: 0, subjects: body.subjects } as any,
      }).catch(() => null);
    }

    // ── Bell schedule ─────────────────────────────────────────────────────────
    if (body?.bellSchedule?.length) {
      for (const d of body.bellSchedule) {
        await this.prisma.schoolPeriodDefault.upsert({
          where: { schoolId_period: { schoolId: school.id, period: d.period } },
          update: { startTime: d.startTime, endTime: d.endTime },
          create: { schoolId: school.id, period: d.period, startTime: d.startTime, endTime: d.endTime },
        }).catch(() => null);
      }
    }

    // ── Create / update admin ────────────────────────────────────────────────
    const hash = await bcrypt.hash(adminPassword, 10);
    const whereAdmin: any = adminEmail ? { email: adminEmail } : { username: adminUsername };
    let adminUser = await this.prisma.user.findFirst({ where: whereAdmin });

    if (!adminUser) {
      adminUser = await this.prisma.user.create({
        data: {
          name: adminName, nameEn: adminName,
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
        data: { schoolId: school.id, name: adminName, nameEn: adminName, password: hash } as any,
      });
      await this.prisma.userRole.upsert({
        where: { userId_role: { userId: adminUser.id, role: 'ADMIN' as any } },
        update: {}, create: { userId: adminUser.id, role: 'ADMIN' as any },
      });
    }

    return {
      ok: true,
      school:  { id: school.id, name: school.name, logoUrl: (school as any).logoUrl ?? null },
      admin:   { id: adminUser.id, email: adminUser.email, username: (adminUser as any).username },
      loginWith: adminEmail ?? adminUsername,
      note: 'School created. Log in to the admin app with the credentials above.',
    };
  }
}

// ── Page HTML ──────────────────────────────────────────────────────────────

function buildPage(): string {
  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>ClassMate — School Setup</title>
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    :root {
      --bg:#0b0b10; --surface:#16161f; --surface2:#1d1d28; --border:#252533;
      --blue:#2563eb; --blue2:#1d4fd7; --text:#e4e4f0; --muted:#6868a0;
      --err-bg:#1c0808; --err-border:#5c1010; --ok-bg:#081c10; --ok-border:#105c28;
      --red:#ef4444; --green:#22c55e;
    }
    body { font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;
           background:var(--bg); color:var(--text); min-height:100vh;
           display:flex; align-items:flex-start; justify-content:center; padding:40px 20px 100px; }
    .wrap { width:100%; max-width:600px; }

    /* header */
    .hdr { display:flex; align-items:center; gap:14px; margin-bottom:40px; }
    .hdr img { width:160px; height:auto; }
    .hdr-info h1 { font-size:22px; font-weight:900; }
    .hdr-info p { font-size:13px; color:var(--muted); margin-top:2px; }

    /* cards */
    .card { background:var(--surface); border:1px solid var(--border);
            border-radius:20px; padding:28px; margin-bottom:18px; }
    .card-hdr { font-size:11px; font-weight:800; color:var(--blue);
                text-transform:uppercase; letter-spacing:.7px; margin-bottom:20px;
                display:flex; align-items:center; gap:10px; }
    .card-hdr::after { content:''; flex:1; height:1px; background:var(--border); }

    /* fields */
    .row2 { display:grid; grid-template-columns:1fr 1fr; gap:14px; }
    .field { margin-bottom:16px; }
    .field:last-child { margin-bottom:0; }
    label { display:block; font-size:11px; font-weight:700; color:var(--muted);
            text-transform:uppercase; letter-spacing:.5px; margin-bottom:6px; }
    .req { color:var(--blue); }
    input, textarea {
      width:100%; padding:11px 14px; background:var(--bg); border:1.5px solid var(--border);
      border-radius:10px; color:var(--text); font-size:14px; font-family:inherit; outline:none;
      transition:border-color .15s;
    }
    input:focus, textarea:focus { border-color:var(--blue); }
    input::placeholder, textarea::placeholder { color:#404060; }
    textarea { resize:vertical; min-height:70px; }
    .hint { font-size:11px; color:var(--muted); margin-top:5px; line-height:1.5; }

    /* password field with show/hide toggle */
    .pw-wrap { position:relative; }
    .pw-wrap input { padding-right:42px; }
    .pw-eye { position:absolute; right:12px; top:50%; transform:translateY(-50%);
              background:none; border:none; cursor:pointer; color:var(--muted);
              font-size:16px; padding:0; line-height:1; }

    /* logo upload */
    .logo-zone { border:2px dashed var(--border); border-radius:14px; padding:24px;
                 text-align:center; cursor:pointer; transition:border-color .15s; position:relative; }
    .logo-zone:hover { border-color:var(--blue); }
    .logo-zone input { position:absolute; inset:0; opacity:0; cursor:pointer; }
    .logo-preview { display:none; max-height:80px; margin:0 auto 12px; border-radius:8px; }
    .logo-zone.has-file .logo-preview { display:block; }
    .logo-zone.has-file .logo-placeholder { display:none; }
    .logo-placeholder { color:var(--muted); font-size:13px; }
    .logo-placeholder span { display:block; font-size:24px; margin-bottom:6px; }
    .logo-status { font-size:12px; margin-top:8px; }
    .logo-status.ok  { color:var(--green); }
    .logo-status.err { color:var(--red); }

    /* periods */
    .periods { display:grid; grid-template-columns:repeat(3,1fr); gap:10px; }
    .period { background:var(--bg); border:1px solid var(--border); border-radius:10px; padding:10px 12px; }
    .period-lbl { font-size:11px; font-weight:800; color:var(--blue); margin-bottom:6px; }
    .period-times { display:flex; gap:6px; align-items:center; }
    .period-times input { padding:6px 7px; font-size:12px; text-align:center; }
    .period-sep { color:var(--muted); font-size:11px; flex-shrink:0; }

    /* secret */
    .secret-card { background:var(--surface); border:1px solid #3a1010;
                   border-radius:14px; padding:18px; margin-bottom:18px;
                   display:flex; gap:14px; align-items:flex-start; }
    .secret-icon { font-size:22px; }
    .secret-inner { flex:1; }
    .secret-inner label { color:#e05; }

    /* submit */
    .btn { width:100%; padding:15px; background:var(--blue); color:#fff; border:none;
           border-radius:14px; font-size:16px; font-weight:800; cursor:pointer;
           transition:background .15s; margin-top:4px; }
    .btn:hover:not(:disabled) { background:var(--blue2); }
    .btn:disabled { background:#252540; color:#555; cursor:not-allowed; }

    /* result */
    .result { margin-top:20px; padding:20px; border-radius:14px;
              font-size:13px; line-height:1.7; display:none; }
    .result.ok  { background:var(--ok-bg);  border:1px solid var(--ok-border);  color:#4ade80; }
    .result.err { background:var(--err-bg); border:1px solid var(--err-border); color:#f87171; }
    .result pre { font-family:monospace; font-size:12px; white-space:pre-wrap;
                  background:rgba(0,0,0,.3); border-radius:8px; padding:12px; margin-top:10px; color:#ccc; }

    @media(max-width:500px) { .row2, .periods { grid-template-columns:1fr; } }
  </style>
</head>
<body>
<div class="wrap">

  <div class="hdr">
    <img src="${LOGO_DATA_URI}" alt="ClassMate">
    <div class="hdr-info">
      <h1>School Setup</h1>
      <p>Platform admin only · create a new school</p>
    </div>
  </div>

  <form id="form">

    <!-- School Info -->
    <div class="card">
      <div class="card-hdr">School Info</div>
      <div class="field">
        <label>School Name <span class="req">*</span></label>
        <input id="schoolName" type="text" placeholder="e.g. Greenwood Academy" required autocomplete="off">
      </div>
      <div class="field">
        <label>School Logo</label>
        <div class="logo-zone" id="logoZone">
          <input type="file" id="logoFile" accept="image/*">
          <img id="logoPreview" class="logo-preview" alt="Logo preview">
          <div class="logo-placeholder">
            <span>🖼️</span>Upload logo image (PNG, JPG)
          </div>
        </div>
        <div class="logo-status" id="logoStatus"></div>
        <input type="hidden" id="logoUrl">
      </div>
    </div>

    <!-- Subjects -->
    <div class="card">
      <div class="card-hdr">Subjects <span style="font-weight:400;color:var(--muted);text-transform:none;letter-spacing:0">(optional)</span></div>
      <div class="field">
        <textarea id="subjects" placeholder="Math, Science, English, History, Art, Physical Education, Computer Science"></textarea>
        <div class="hint">Comma-separated. Visible to all teachers when creating assignments and assessments.</div>
      </div>
    </div>

    <!-- Bell Schedule -->
    <div class="card">
      <div class="card-hdr">Bell Schedule <span style="font-weight:400;color:var(--muted);text-transform:none;letter-spacing:0">(optional)</span></div>
      <div class="hint" style="margin-bottom:16px">Set default start and end times for each period. Can be changed later in the app.</div>
      <div class="periods">
        ${[1,2,3,4,5,6,7,8,9].map(p => `
        <div class="period">
          <div class="period-lbl">P${p}</div>
          <div class="period-times">
            <input type="time" name="p${p}s">
            <span class="period-sep">→</span>
            <input type="time" name="p${p}e">
          </div>
        </div>`).join('')}
      </div>
    </div>

    <!-- Admin Account -->
    <div class="card">
      <div class="card-hdr">Admin Account <span class="req">*</span></div>
      <div class="hint" style="margin-bottom:16px">This person can manage the school in the ClassMate app. At least email or username is required.</div>
      <div class="row2">
        <div class="field">
          <label>Full Name <span class="req">*</span></label>
          <input id="adminName" type="text" placeholder="e.g. Sarah Ahmed" required autocomplete="off">
        </div>
        <div class="field">
          <label>Username</label>
          <input id="adminUsername" type="text" placeholder="sarah.ahmed" autocomplete="off">
        </div>
      </div>
      <div class="field">
        <label>Email</label>
        <input id="adminEmail" type="email" placeholder="admin@school.com" autocomplete="off">
      </div>
      <div class="field">
        <label>Password <span class="req">*</span></label>
        <div class="pw-wrap">
          <input id="adminPassword" type="password" placeholder="Min 6 characters" required autocomplete="new-password">
          <button type="button" class="pw-eye" id="pwToggle" title="Show/hide password">👁</button>
        </div>
        <div class="hint">This is the admin's initial login password. They can change it after logging in.</div>
      </div>
    </div>

    <!-- Setup Secret -->
    <div class="secret-card">
      <div class="secret-icon">🔑</div>
      <div class="secret-inner">
        <label style="display:block;margin-bottom:6px">Setup Secret <span class="req">*</span></label>
        <div class="pw-wrap">
          <input id="secret" type="password" placeholder="SETUP_SECRET from Railway" required autocomplete="off">
          <button type="button" class="pw-eye" id="secretToggle" title="Show/hide">👁</button>
        </div>
        <div class="hint" style="margin-top:6px">The SETUP_SECRET you set in Railway environment variables.</div>
      </div>
    </div>

    <button type="submit" class="btn" id="btn">Create School</button>
  </form>

  <div class="result" id="result"></div>

</div>
<script>
  // Show/hide password toggles
  function togglePw(inputId, btnId) {
    const inp = document.getElementById(inputId);
    const btn = document.getElementById(btnId);
    btn.addEventListener('click', () => {
      inp.type = inp.type === 'password' ? 'text' : 'password';
      btn.textContent = inp.type === 'password' ? '👁' : '🙈';
    });
  }
  togglePw('adminPassword', 'pwToggle');
  togglePw('secret', 'secretToggle');

  // Logo upload
  const logoFile = document.getElementById('logoFile');
  const logoZone = document.getElementById('logoZone');
  const logoPreview = document.getElementById('logoPreview');
  const logoStatus = document.getElementById('logoStatus');
  const logoUrl = document.getElementById('logoUrl');

  logoFile.addEventListener('change', async () => {
    const file = logoFile.files[0];
    if (!file) return;
    const secret = document.getElementById('secret').value;
    if (!secret) { logoStatus.textContent = 'Enter your setup secret first.'; logoStatus.className = 'logo-status err'; return; }

    // Preview
    const reader = new FileReader();
    reader.onload = e => { logoPreview.src = e.target.result; };
    reader.readAsDataURL(file);
    logoZone.classList.add('has-file');
    logoStatus.textContent = 'Uploading…'; logoStatus.className = 'logo-status';

    // Upload
    const fd = new FormData();
    fd.append('file', file);
    try {
      const res = await fetch('/cms/upload', { method:'POST', headers:{'x-setup-secret':secret}, body:fd });
      const data = await res.json();
      if (res.ok) {
        logoUrl.value = data.url;
        logoStatus.textContent = '✓ Logo uploaded'; logoStatus.className = 'logo-status ok';
      } else {
        logoStatus.textContent = '✗ ' + (data.message || 'Upload failed'); logoStatus.className = 'logo-status err';
        logoUrl.value = '';
      }
    } catch(e) {
      logoStatus.textContent = '✗ Network error'; logoStatus.className = 'logo-status err';
    }
  });

  // Form submit
  document.getElementById('form').addEventListener('submit', async e => {
    e.preventDefault();
    const btn = document.getElementById('btn');
    const result = document.getElementById('result');
    btn.disabled = true; btn.textContent = 'Creating…';
    result.style.display = 'none';

    const bell = [];
    for (let p = 1; p <= 9; p++) {
      const s = document.querySelector('[name=p'+p+'s]').value;
      const en = document.querySelector('[name=p'+p+'e]').value;
      if (s && en) bell.push({ period:p, startTime:s, endTime:en });
    }
    const subjectRaw = document.getElementById('subjects').value.trim();
    const subjects = subjectRaw ? subjectRaw.split(',').map(s=>s.trim()).filter(Boolean) : undefined;

    const payload = {
      schoolName:     document.getElementById('schoolName').value.trim(),
      logoUrl:        document.getElementById('logoUrl').value || undefined,
      subjects,
      bellSchedule:   bell.length ? bell : undefined,
      adminName:      document.getElementById('adminName').value.trim(),
      adminUsername:  document.getElementById('adminUsername').value.trim() || undefined,
      adminEmail:     document.getElementById('adminEmail').value.trim() || undefined,
      adminPassword:  document.getElementById('adminPassword').value,
    };

    try {
      const res = await fetch('/cms/school', {
        method:'POST',
        headers:{'Content-Type':'application/json','x-setup-secret':document.getElementById('secret').value},
        body:JSON.stringify(payload),
      });
      const data = await res.json();
      result.style.display = 'block';
      if (res.ok) {
        result.className = 'result ok';
        result.innerHTML = '<strong>✓ School created!</strong><pre>' + JSON.stringify(data, null, 2) + '</pre>';
        document.getElementById('form').reset();
        logoZone.classList.remove('has-file');
        logoStatus.textContent = ''; logoUrl.value = '';
      } else {
        result.className = 'result err';
        // Show the real error message from the server
        const msg = Array.isArray(data.message) ? data.message.join('<br>') : (data.message || 'Unknown error');
        result.innerHTML = '<strong>✗ ' + (data.error || 'Error') + '</strong><br>' + msg;
      }
    } catch(err) {
      result.className = 'result err';
      result.style.display = 'block';
      result.innerHTML = '<strong>✗ Network error</strong><br>' + err.message;
    } finally {
      btn.disabled = false; btn.textContent = 'Create School';
    }
  });
</script>
</body>
</html>`;
}
