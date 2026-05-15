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
      subjects?: { nameEn: string; nameAr?: string; nameHe?: string; nameFr?: string; nameRu?: string }[];
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

    /* header — always vertical, centred. Force logo white via CSS filter. */
    .hdr { display:block; text-align:center; margin-bottom:44px; }
    .hdr img { display:block; width:200px; max-width:70%; height:auto;
               margin:0 auto 16px;
               filter: brightness(0) invert(1); /* turns any colour into pure white */ }
    .hdr-info h1 { font-size:13px; font-weight:700; color:var(--muted);
                   text-transform:uppercase; letter-spacing:1px; }
    .hdr-info p  { font-size:12px; color:#444; margin-top:4px; }

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

    /* chips */
    .chips { display:flex; flex-wrap:wrap; gap:8px; margin-bottom:10px; min-height:4px; }
    .chip { display:flex; align-items:center; gap:6px; padding:6px 10px 6px 12px;
            background:var(--surface2); border:1px solid var(--border); border-radius:20px;
            font-size:13px; font-weight:600; }
    .chip-del { background:none; border:none; color:var(--muted); cursor:pointer;
                font-size:16px; line-height:1; padding:0; transition:color .1s; }
    .chip-del:hover { color:var(--red); }

    /* add row */
    .add-row { display:flex; gap:10px; }
    .add-row input { flex:1; }
    .add-btn { padding:10px 18px; background:var(--blue); color:#fff; border:none;
               border-radius:10px; font-size:13px; font-weight:700; cursor:pointer;
               white-space:nowrap; transition:background .15s; flex-shrink:0; }
    .add-btn:hover { background:var(--blue2); }

    /* period rows */
    .period-row { display:flex; align-items:center; gap:10px; padding:10px 14px;
                  background:var(--bg); border:1px solid var(--border); border-radius:12px;
                  margin-bottom:8px; }
    .period-badge { min-width:32px; font-size:12px; font-weight:900; color:var(--blue); }
    .period-row input[type=time] { flex:1; padding:8px 10px; font-size:13px; }
    .period-sep { color:var(--muted); font-size:13px; flex-shrink:0; }
    .period-del { background:none; border:none; color:var(--muted); cursor:pointer;
                  font-size:18px; padding:0 4px; transition:color .1s; }
    .period-del:hover { color:var(--red); }

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

    /* subject list */
    .subj-item { display:flex; align-items:flex-start; gap:12px; padding:12px 14px;
                 background:var(--bg); border:1px solid var(--border); border-radius:12px;
                 margin-bottom:8px; }
    .subj-names { flex:1; }
    .subj-en { font-size:14px; font-weight:700; }
    .subj-langs { font-size:12px; color:var(--muted); margin-top:2px; }
    .subj-del { background:none; border:none; color:var(--muted); cursor:pointer;
                font-size:18px; padding:0; transition:color .1s; flex-shrink:0; }
    .subj-del:hover { color:var(--red); }
    .subj-form { background:var(--surface2); border:1px solid var(--border);
                 border-radius:14px; padding:16px; margin-bottom:10px; }
    .subj-lang-row { display:grid; grid-template-columns:1fr 1fr; gap:12px; margin-bottom:0; }
    .subj-lang-row .field { margin-bottom:12px; }

    @media(max-width:500px) {
      .row2, .periods, .subj-lang-row { grid-template-columns:1fr; }
    }
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
      <div id="subjectList"></div>
      <button type="button" class="add-btn" id="showAddSubject" style="margin-bottom:8px">+ Add Subject</button>
      <!-- inline add form, hidden by default -->
      <div id="subjectForm" class="subj-form" style="display:none">
        <div class="subj-lang-row">
          <div class="field">
            <label>English <span class="req">*</span></label>
            <input id="sEn" type="text" placeholder="Mathematics" autocomplete="off">
          </div>
          <div class="field">
            <label>Arabic</label>
            <input id="sAr" type="text" placeholder="رياضيات" autocomplete="off" dir="auto">
          </div>
        </div>
        <div class="subj-lang-row">
          <div class="field">
            <label>Hebrew</label>
            <input id="sHe" type="text" placeholder="מתמטיקה" autocomplete="off" dir="auto">
          </div>
          <div class="field">
            <label>French</label>
            <input id="sFr" type="text" placeholder="Mathématiques" autocomplete="off">
          </div>
        </div>
        <div class="field" style="max-width:50%">
          <label>Russian</label>
          <input id="sRu" type="text" placeholder="Математика" autocomplete="off">
        </div>
        <div style="display:flex;gap:8px;margin-top:4px">
          <button type="button" class="add-btn" id="confirmAddSubject">Add Subject</button>
          <button type="button" class="add-btn" id="cancelAddSubject"
            style="background:var(--surface2);color:var(--muted);border:1px solid var(--border)">Cancel</button>
        </div>
      </div>
      <div class="hint" style="margin-top:8px">Visible to all teachers when creating assignments and assessments.</div>
    </div>

    <!-- Bell Schedule -->
    <div class="card">
      <div class="card-hdr">Bell Schedule <span style="font-weight:400;color:var(--muted);text-transform:none;letter-spacing:0">(optional)</span></div>
      <div class="hint" style="margin-bottom:14px">Set default start/end times per period. Can be changed later in the app.</div>
      <div id="periodList"></div>
      <button type="button" class="add-btn" id="addPeriod" style="margin-top:8px">+ Add Period</button>
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
  // ── Subjects (multi-lang) ──────────────────────────────────────────────────
  const subjects = []; // each: { nameEn, nameAr, nameHe, nameFr, nameRu }
  const subjectList = document.getElementById('subjectList');
  const subjectForm = document.getElementById('subjectForm');

  function renderSubjects() {
    subjectList.innerHTML = subjects.map((s, i) => {
      const langs = [s.nameAr, s.nameHe, s.nameFr, s.nameRu].filter(Boolean).join(' · ');
      return '<div class="subj-item">' +
        '<div class="subj-names">' +
          '<div class="subj-en">' + s.nameEn + '</div>' +
          (langs ? '<div class="subj-langs">' + langs + '</div>' : '') +
        '</div>' +
        '<button type="button" class="subj-del" data-i="'+i+'">×</button>' +
      '</div>';
    }).join('');
    subjectList.querySelectorAll('.subj-del').forEach(b =>
      b.addEventListener('click', () => { subjects.splice(+b.dataset.i, 1); renderSubjects(); })
    );
  }

  document.getElementById('showAddSubject').addEventListener('click', () => {
    subjectForm.style.display = 'block';
    document.getElementById('sEn').focus();
  });
  document.getElementById('cancelAddSubject').addEventListener('click', () => {
    subjectForm.style.display = 'none';
    ['sEn','sAr','sHe','sFr','sRu'].forEach(id => document.getElementById(id).value = '');
  });
  document.getElementById('confirmAddSubject').addEventListener('click', () => {
    const nameEn = document.getElementById('sEn').value.trim();
    if (!nameEn) { document.getElementById('sEn').focus(); return; }
    subjects.push({
      nameEn,
      nameAr: document.getElementById('sAr').value.trim() || undefined,
      nameHe: document.getElementById('sHe').value.trim() || undefined,
      nameFr: document.getElementById('sFr').value.trim() || undefined,
      nameRu: document.getElementById('sRu').value.trim() || undefined,
    });
    ['sEn','sAr','sHe','sFr','sRu'].forEach(id => document.getElementById(id).value = '');
    subjectForm.style.display = 'none';
    renderSubjects();
  });
  document.getElementById('sEn').addEventListener('keydown', e => {
    if (e.key === 'Enter') { e.preventDefault(); document.getElementById('confirmAddSubject').click(); }
  });

  // ── Bell Schedule ──────────────────────────────────────────────────────────
  let periodCount = 0;
  const periodList = document.getElementById('periodList');

  function addPeriod(startTime, endTime) {
    periodCount++;
    const n = periodCount;
    const row = document.createElement('div');
    row.className = 'period-row'; row.dataset.n = n;
    row.innerHTML =
      '<span class="period-badge">P'+n+'</span>' +
      '<input type="time" class="ps" value="'+(startTime||'')+'">' +
      '<span class="period-sep">→</span>' +
      '<input type="time" class="pe" value="'+(endTime||'')+'">' +
      '<button type="button" class="period-del" title="Remove">×</button>';
    row.querySelector('.period-del').addEventListener('click', () => {
      row.remove();
      // Renumber remaining periods
      periodList.querySelectorAll('.period-row').forEach((r,i) => {
        r.querySelector('.period-badge').textContent = 'P'+(i+1);
      });
    });
    periodList.appendChild(row);
  }

  document.getElementById('addPeriod').addEventListener('click', () => addPeriod());
  // Seed with P1–P5 to start
  for (let i = 0; i < 5; i++) addPeriod();

  // ── Show/hide password toggles ─────────────────────────────────────────────
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

  // Logo — show preview immediately on file select, upload at submit time
  const logoFile = document.getElementById('logoFile');
  const logoZone = document.getElementById('logoZone');
  const logoPreview = document.getElementById('logoPreview');
  const logoStatus = document.getElementById('logoStatus');
  const logoUrl = document.getElementById('logoUrl');

  logoFile.addEventListener('change', () => {
    const file = logoFile.files[0];
    if (!file) return;
    // Show local preview immediately — no secret needed yet
    const reader = new FileReader();
    reader.onload = e => { logoPreview.src = e.target.result; };
    reader.readAsDataURL(file);
    logoZone.classList.add('has-file');
    logoStatus.textContent = 'Ready to upload'; logoStatus.className = 'logo-status';
    logoUrl.value = ''; // cleared until actual upload at submit
  });

  async function uploadLogoIfPending(secret) {
    const file = logoFile.files[0];
    if (!file) return true; // no file selected — ok
    logoStatus.textContent = 'Uploading logo…'; logoStatus.className = 'logo-status';
    const fd = new FormData();
    fd.append('file', file);
    const res = await fetch('/cms/upload', { method:'POST', headers:{'x-setup-secret':secret}, body:fd });
    const data = await res.json();
    if (res.ok) {
      logoUrl.value = data.url;
      logoStatus.textContent = '✓ Logo uploaded'; logoStatus.className = 'logo-status ok';
      return true;
    } else {
      logoStatus.textContent = '✗ ' + (data.message || 'Upload failed'); logoStatus.className = 'logo-status err';
      return false;
    }
  }

  // Form submit
  document.getElementById('form').addEventListener('submit', async e => {
    e.preventDefault();
    const btn = document.getElementById('btn');
    const result = document.getElementById('result');
    btn.disabled = true; btn.textContent = 'Creating…';
    result.style.display = 'none';

    // Collect bell schedule from dynamic rows
    const bell = [];
    document.querySelectorAll('#periodList .period-row').forEach((row, i) => {
      const s = row.querySelector('.ps').value;
      const en = row.querySelector('.pe').value;
      if (s && en) bell.push({ period: i+1, startTime: s, endTime: en });
    });

    // Upload logo first if a file was picked
    const secret = document.getElementById('secret').value;
    const logoOk = await uploadLogoIfPending(secret);
    if (!logoOk) { btn.disabled = false; btn.textContent = 'Create School'; return; }

    const payload = {
      schoolName:     document.getElementById('schoolName').value.trim(),
      logoUrl:        document.getElementById('logoUrl').value || undefined,
      subjects: subjects.length ? subjects : undefined,
      bellSchedule: bell.length ? bell : undefined,
      adminName:      document.getElementById('adminName').value.trim(),
      adminUsername:  document.getElementById('adminUsername').value.trim() || undefined,
      adminEmail:     document.getElementById('adminEmail').value.trim() || undefined,
      adminPassword:  document.getElementById('adminPassword').value,
    };

    try {
      const res = await fetch('/cms/school', {
        method:'POST',
        headers:{'Content-Type':'application/json','x-setup-secret':secret},
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
