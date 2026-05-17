import { BadRequestException, Body, Controller, Get, HttpCode, Post, Query, Res } from '@nestjs/common';
import type { Response } from 'express';

import { Public } from '../decorators/public.decorator';
import { LOGO_DATA_URI } from '../../setup/logo';
import { PasswordResetService, ResetChannel, ResetOutcomeCode } from './password-reset.service';

@Controller()
export class PasswordResetController {
  constructor(private readonly service: PasswordResetService) {}

  /**
   * Kick off a password reset. Body: { identifier, channel }.
   * Always returns 200 with the same generic body whether or not the
   * identifier matched a real account — prevents account enumeration.
   */
  @Public()
  @Post('auth/forgot-password')
  @HttpCode(200)
  async forgot(@Body() body: { identifier?: string; channel?: string }) {
    const identifier = String(body?.identifier ?? '').trim();
    const channel = String(body?.channel ?? 'email').toLowerCase();
    if (!identifier) throw new BadRequestException('identifier is required');
    if (channel !== 'email' && channel !== 'sms') {
      throw new BadRequestException('channel must be "email" or "sms"');
    }

    const outcome = await this.service.requestReset({
      identifier,
      channel: channel as ResetChannel,
    });

    return {
      ok: true,
      code: outcome.code,
      sent: outcome.code === 'sent',
      message: messageForOutcome(outcome.code, channel as ResetChannel),
    };
  }

  /**
   * Consume a reset token and set the new password. Hit from the styled
   * reset-password HTML page (below) or any other client.
   */
  @Public()
  @Post('auth/reset-password')
  @HttpCode(200)
  async reset(@Body() body: { token?: string; newPassword?: string }) {
    const token = String(body?.token ?? '').trim();
    const newPassword = String(body?.newPassword ?? '');
    await this.service.consumeReset({ token, newPassword });
    return { ok: true };
  }

  /**
   * Looks up the school's admins so the Flutter Forgot Password screen can
   * render an admin picker for the "ask an admin" path. Always 200 with
   * empty data when the identifier doesn't match anything.
   */
  @Public()
  @Post('auth/password-request/lookup')
  @HttpCode(200)
  async lookupAdmins(@Body() body: { identifier?: string }) {
    const identifier = String(body?.identifier ?? '').trim();
    if (!identifier) throw new BadRequestException('identifier is required');
    const out = await this.service.lookupAdminsForRequest(identifier);
    return { ok: true, ...out };
  }

  /**
   * User submits the password they want + which admin should approve. Hash
   * is stored, admin gets a notification, but the raw password is never
   * surfaced to the admin.
   */
  @Public()
  @Post('auth/password-request/submit')
  @HttpCode(200)
  async submitRequest(@Body() body: { identifier?: string; adminId?: string; desiredPassword?: string }) {
    const identifier = String(body?.identifier ?? '').trim();
    const adminId = String(body?.adminId ?? '').trim();
    const desiredPassword = String(body?.desiredPassword ?? '');
    if (!identifier || !adminId) throw new BadRequestException('identifier and adminId are required');
    await this.service.submitPasswordChangeRequest({ identifier, adminId, desiredPassword });
    return { ok: true, message: 'Request sent. Your admin will receive a notification.' };
  }

  /**
   * Styled HTML reset page (matches /cms branding). User lands here from the
   * email/SMS link. JS posts to /auth/reset-password and renders success/error
   * inline so it works on any device with no app install.
   */
  @Public()
  @Get('reset-password')
  resetPage(@Query('token') token: string, @Res() res: Response) {
    res.setHeader('Content-Type', 'text/html; charset=utf-8');
    res.send(buildResetPage(token ?? ''));
  }
}

/**
 * Renders the user-facing message for a forgot-password outcome. Channel-aware
 * so "no email on file" and "no phone on file" can each speak its language.
 */
function messageForOutcome(code: ResetOutcomeCode, channel: ResetChannel): string {
  switch (code) {
    case 'sent':
      return channel === 'email'
        ? 'We just sent a reset link to your email. The link expires in 1 hour.'
        : 'We just sent a reset link to your phone. The link expires in 1 hour.';
    case 'no_user':
      return "We couldn't find an account with that email or username. Double-check and try again.";
    case 'no_email_on_file':
      return "This account doesn't have an email on file. Try SMS, or ask an admin to reset your password.";
    case 'no_phone_on_file':
      return "This account doesn't have a phone on file. Try email, or ask an admin to reset your password.";
    case 'email_not_verified':
      return 'Your email isn\'t verified yet. Log in and verify it in Profile → Email → Verify, then try again.';
    case 'phone_not_verified':
      return "Your phone isn't verified yet. Log in and verify it in Profile → Phone → Verify, then try again.";
  }
}

function buildResetPage(token: string): string {
  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>ClassMate — Reset password</title>
  <style>
    *, *::before, *::after { box-sizing:border-box; margin:0; padding:0; }
    :root {
      --bg:#0b0b10; --surface:#16161f; --border:#252533;
      --blue:#2563eb; --blue2:#1d4fd7; --text:#e4e4f0; --muted:#6868a0;
      --err-bg:#1c0808; --err-border:#5c1010; --ok-bg:#081c10; --ok-border:#105c28;
      --red:#ef4444; --green:#22c55e;
    }
    body { font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;
           background:var(--bg); color:var(--text); min-height:100vh;
           display:flex; align-items:flex-start; justify-content:center; padding:40px 20px 100px; }
    .wrap { width:100%; max-width:440px; }

    .hdr { display:block; text-align:center; margin-bottom:36px; }
    .hdr img { display:block; width:200px; max-width:70%; height:auto;
               margin:0 auto 16px;
               filter: brightness(0) invert(1); }
    .hdr h1 { font-size:13px; font-weight:700; color:var(--muted);
              text-transform:uppercase; letter-spacing:1px; }

    .card { background:var(--surface); border:1px solid var(--border);
            border-radius:20px; padding:28px; }
    .card-hdr { font-size:11px; font-weight:800; color:var(--blue);
                text-transform:uppercase; letter-spacing:.7px; margin-bottom:20px;
                display:flex; align-items:center; gap:10px; }
    .card-hdr::after { content:''; flex:1; height:1px; background:var(--border); }

    .field { margin-bottom:16px; }
    label { display:block; font-size:11px; font-weight:700; color:var(--muted);
            text-transform:uppercase; letter-spacing:.5px; margin-bottom:6px; }
    .pw-wrap { position:relative; }
    input { width:100%; padding:11px 42px 11px 14px; background:var(--bg); border:1.5px solid var(--border);
            border-radius:10px; color:var(--text); font-size:14px; outline:none;
            transition:border-color .15s; font-family:inherit; }
    input:focus { border-color:var(--blue); }
    .pw-eye { position:absolute; right:12px; top:50%; transform:translateY(-50%);
              background:none; border:none; cursor:pointer; color:var(--muted);
              font-size:16px; padding:0; line-height:1; }
    .hint { font-size:11px; color:var(--muted); margin-top:5px; line-height:1.5; }

    .btn { width:100%; padding:13px 16px; background:var(--blue); color:#fff;
           border:none; border-radius:12px; font-size:15px; font-weight:700;
           cursor:pointer; transition:background .15s; margin-top:8px; }
    .btn:hover:not(:disabled) { background:var(--blue2); }
    .btn:disabled { opacity:.55; cursor:not-allowed; }

    .msg { padding:12px 14px; border-radius:10px; font-size:13px; margin-top:14px; display:none; }
    .msg.show { display:block; }
    .msg.err  { background:var(--err-bg); border:1px solid var(--err-border); color:var(--red); }
    .msg.ok   { background:var(--ok-bg);  border:1px solid var(--ok-border);  color:var(--green); }
  </style>
</head>
<body>
<div class="wrap">

  <div class="hdr">
    <img src="${LOGO_DATA_URI}" alt="ClassMate">
    <h1>Reset Password</h1>
  </div>

  <div class="card">
    <div class="card-hdr">Set a new password</div>

    <form id="form" autocomplete="off">
      <div class="field">
        <label>New password <span style="color:var(--blue)">*</span></label>
        <div class="pw-wrap">
          <input id="pw1" type="password" minlength="8" required>
          <button type="button" class="pw-eye" data-target="pw1" aria-label="Show password">👁</button>
        </div>
        <div class="hint">At least 8 characters.</div>
      </div>

      <div class="field">
        <label>Confirm new password <span style="color:var(--blue)">*</span></label>
        <div class="pw-wrap">
          <input id="pw2" type="password" minlength="8" required>
          <button type="button" class="pw-eye" data-target="pw2" aria-label="Show password">👁</button>
        </div>
      </div>

      <button type="submit" class="btn" id="submitBtn">Reset password</button>

      <div class="msg err" id="errMsg"></div>
      <div class="msg ok"  id="okMsg"></div>
    </form>
  </div>
</div>

<script>
  const token = ${JSON.stringify(token)};
  const form = document.getElementById('form');
  const pw1 = document.getElementById('pw1');
  const pw2 = document.getElementById('pw2');
  const btn = document.getElementById('submitBtn');
  const errMsg = document.getElementById('errMsg');
  const okMsg = document.getElementById('okMsg');

  document.querySelectorAll('.pw-eye').forEach(b => b.addEventListener('click', () => {
    const t = document.getElementById(b.dataset.target);
    t.type = t.type === 'password' ? 'text' : 'password';
  }));

  function setError(msg) {
    okMsg.classList.remove('show');
    if (!msg) { errMsg.classList.remove('show'); return; }
    errMsg.textContent = msg;
    errMsg.classList.add('show');
  }
  function setOk(msg) {
    errMsg.classList.remove('show');
    okMsg.textContent = msg;
    okMsg.classList.add('show');
  }

  if (!token) {
    setError("This reset link is missing its token. Open the link from your email or SMS again.");
    btn.disabled = true;
  }

  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    setError(null);
    if (pw1.value.length < 8) return setError('Password must be at least 8 characters.');
    if (pw1.value !== pw2.value) return setError('Passwords do not match.');

    btn.disabled = true;
    btn.textContent = 'Resetting…';
    try {
      const res = await fetch('/auth/reset-password', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ token, newPassword: pw1.value }),
      });
      const data = await res.json().catch(() => ({}));
      if (!res.ok) {
        setError(data.message || 'Could not reset password. The link may have expired.');
        btn.disabled = false;
        btn.textContent = 'Reset password';
        return;
      }
      setOk('Password reset! Open the ClassMate app and log in with your new password.');
      btn.disabled = true;
      btn.textContent = 'Done';
      pw1.disabled = true;
      pw2.disabled = true;
    } catch (err) {
      setError('Network error. Check your connection and try again.');
      btn.disabled = false;
      btn.textContent = 'Reset password';
    }
  });
</script>
</body>
</html>`;
}
