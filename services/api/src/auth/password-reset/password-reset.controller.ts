import { BadRequestException, Body, Controller, Get, HttpCode, Post, Query, Res } from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import type { Response } from 'express';

import { Public } from '../decorators/public.decorator';
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
  @Throttle({ auth: { limit: 5, ttl: 15 * 60_000 } })
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
  @Throttle({ auth: { limit: 5, ttl: 15 * 60_000 } })
  @Post('auth/reset-password')
  @HttpCode(200)
  async reset(@Body() body: { token?: string; newPassword?: string }) {
    const token = String(body?.token ?? '').trim();
    const newPassword = String(body?.newPassword ?? '');
    await this.service.consumeReset({ token, newPassword });
    return { ok: true };
  }

  /**
   * Styled HTML reset page. User lands here from the email/SMS link. JS posts
   * to /auth/reset-password and renders success/error inline so it works on
   * any device with no app install.
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

export function buildResetPage(rawToken: string): string {
  // Tokens are base64url; anything else is dropped so a crafted link can't
  // break out of the <script> block below (reflected XSS on the API origin).
  const token = rawToken.replace(/[^A-Za-z0-9_-]/g, '');
  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Choose a new password · ClassMate</title>
  <meta name="robots" content="noindex">
  <meta name="theme-color" content="#f3f5fb" media="(prefers-color-scheme: light)">
  <meta name="theme-color" content="#080d1e" media="(prefers-color-scheme: dark)">
  <link rel="icon" href="/static/brand/app-icon.png">
  <link rel="apple-touch-icon" href="/static/brand/app-icon.png">
  <style>
    @font-face { font-family: 'Inter'; font-style: normal; font-display: swap; font-weight: 100 900;
                 src: url('/static/fonts/inter-latin-wght-normal.woff2') format('woff2'); }
    :root {
      color-scheme: light dark;
      --paper: #f3f5fb; --card: #ffffff; --ink: #0e1630; --body: #2f3955; --muted: #5d6784;
      --line: #e3e8f4; --field: #f7f9fd; --brand: #0b2398; --brand-ink: #ffffff; --brand-hover: #081a7a;
      --focus: #83b5fe; --good: #157f4a; --good-bg: #e8f6ee; --bad: #c0262d; --bad-bg: #fdeced;
      --glow: rgba(11, 35, 152, .10);
    }
    @media (prefers-color-scheme: dark) {
      :root {
        --paper: #080d1e; --card: #0f172e; --ink: #edf1fc; --body: #c3cbe0; --muted: #8e99b8;
        --line: #1f2a48; --field: #0b1226; --brand: #83b5fe; --brand-ink: #071447; --brand-hover: #a3c8ff;
        --focus: #83b5fe; --good: #5fd39a; --good-bg: #0f2a20; --bad: #ff8a8f; --bad-bg: #2d1218;
        --glow: rgba(131, 181, 254, .10);
      }
    }
    *, *::before, *::after { box-sizing: border-box; }
    body {
      margin: 0; min-height: 100vh; min-height: 100dvh; background: var(--paper); color: var(--body);
      background-image: radial-gradient(60% 40% at 50% 0%, var(--glow), transparent 70%);
      font: 16px/1.55 Inter, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      -webkit-font-smoothing: antialiased; display: flex; justify-content: center;
      padding: 48px 16px 40px;
    }
    .wrap { width: 100%; max-width: 420px; display: flex; flex-direction: column; }
    .logo { display: block; margin: 0 auto 28px; height: 40px; width: auto; }
    .logo.dark { display: none; }
    @media (prefers-color-scheme: dark) { .logo.light { display: none; } .logo.dark { display: block; } }
    .card { background: var(--card); border: 1px solid var(--line); border-radius: 22px; padding: 30px 28px 28px;
            box-shadow: 0 1px 2px rgba(14,22,48,.04), 0 18px 40px -22px rgba(14,22,48,.25); }
    h1 { margin: 0 0 6px; color: var(--ink); font-size: 24px; line-height: 1.2; letter-spacing: -.02em; font-weight: 800; }
    .sub { margin: 0 0 24px; color: var(--muted); font-size: 15px; }
    .field { margin-bottom: 16px; }
    label { display: block; margin-bottom: 7px; color: var(--ink); font-size: 14px; font-weight: 650; }
    .pw { position: relative; }
    input {
      width: 100%; height: 48px; padding: 0 48px 0 14px; border-radius: 12px; outline: none;
      background: var(--field); border: 1.5px solid var(--line); color: var(--ink);
      font: 500 16px Inter, -apple-system, BlinkMacSystemFont, sans-serif; transition: border-color .15s, box-shadow .15s;
    }
    input:focus { border-color: var(--brand); box-shadow: 0 0 0 4px var(--glow); }
    input:disabled { opacity: .6; }
    .eye { position: absolute; right: 4px; top: 4px; width: 40px; height: 40px; border: 0; border-radius: 10px;
           background: transparent; color: var(--muted); cursor: pointer; display: grid; place-items: center; }
    .eye:hover { color: var(--ink); }
    .eye svg { width: 20px; height: 20px; }
    .eye .off { display: none; } .eye[aria-pressed="true"] .on { display: none; } .eye[aria-pressed="true"] .off { display: block; }
    :focus-visible { outline: 3px solid var(--focus); outline-offset: 2px; }
    .checks { list-style: none; margin: 4px 0 22px; padding: 0; display: grid; gap: 6px; font-size: 13.5px; color: var(--muted); }
    .checks li { display: flex; align-items: center; gap: 8px; transition: color .15s; }
    .checks li::before { content: ''; width: 16px; height: 16px; border-radius: 50%; flex: none;
                         border: 1.5px solid var(--line); background: var(--field); }
    .checks li.ok { color: var(--good); }
    .checks li.ok::before { border-color: var(--good); background: var(--good)
      url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3E%3Cpath d='M4.5 8.2l2.3 2.3 4.7-4.9' fill='none' stroke='white' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'/%3E%3C/svg%3E") center/16px no-repeat; }
    .btn { width: 100%; height: 50px; border: 0; border-radius: 13px; cursor: pointer;
           background: var(--brand); color: var(--brand-ink); font: 700 16px Inter, -apple-system, BlinkMacSystemFont, sans-serif;
           display: inline-flex; align-items: center; justify-content: center; gap: 10px; text-decoration: none;
           transition: background .15s, transform .1s; }
    .btn:hover:not(:disabled) { background: var(--brand-hover); }
    .btn:active:not(:disabled) { transform: scale(.99); }
    .btn:disabled { opacity: .5; cursor: not-allowed; }
    .spin { width: 18px; height: 18px; border-radius: 50%; border: 2.5px solid currentColor; border-right-color: transparent;
            animation: spin .7s linear infinite; display: none; }
    .busy .spin { display: block; }
    @keyframes spin { to { transform: rotate(360deg); } }
    .msg { display: none; margin-top: 16px; padding: 12px 14px; border-radius: 12px; font-size: 14px; line-height: 1.45;
           background: var(--bad-bg); color: var(--bad); }
    .msg.show { display: block; }
    .done { display: none; text-align: center; padding: 6px 0 2px; }
    .done .badge { width: 60px; height: 60px; margin: 0 auto 16px; border-radius: 50%; display: grid; place-items: center;
                   background: var(--good-bg); color: var(--good); }
    .done .badge svg { width: 30px; height: 30px; }
    .done p { margin: 0 0 22px; color: var(--muted); font-size: 15px; }
    .link { display: block; margin-top: 14px; color: var(--muted); font-size: 14px; text-align: center; }
    .card.is-done form, .card.is-done .head { display: none; }
    .card.is-done .done { display: block; }
    footer { margin-top: 22px; text-align: center; font-size: 13px; color: var(--muted); }
    footer a { color: var(--muted); }
    @media (max-width: 420px) { body { padding-top: 32px; } .card { padding: 24px 20px 22px; border-radius: 20px; } }
    @media (prefers-reduced-motion: reduce) { * { transition: none !important; animation-duration: 0s !important; } }
  </style>
</head>
<body>
<main class="wrap">
  <img class="logo light" src="/static/brand/wordmark.png" alt="ClassMate" width="146" height="40">
  <img class="logo dark" src="/static/brand/wordmark-dark.png" alt="ClassMate" width="146" height="40">

  <div class="card" id="card">
    <div class="head">
      <h1>Choose a new password</h1>
      <p class="sub">For your ClassMate account. You'll use it to sign in on every device.</p>
    </div>

    <form id="form" novalidate>
      <div class="field">
        <label for="pw1">New password</label>
        <div class="pw">
          <input id="pw1" type="password" autocomplete="new-password" minlength="8" required autofocus>
          <button type="button" class="eye" data-target="pw1" aria-label="Show password" aria-pressed="false">${EYE_ICONS}</button>
        </div>
      </div>
      <div class="field">
        <label for="pw2">Confirm new password</label>
        <div class="pw">
          <input id="pw2" type="password" autocomplete="new-password" minlength="8" required>
          <button type="button" class="eye" data-target="pw2" aria-label="Show password" aria-pressed="false">${EYE_ICONS}</button>
        </div>
      </div>

      <ul class="checks" aria-live="polite">
        <li id="chkLen">At least 8 characters</li>
        <li id="chkMatch">Both passwords match</li>
      </ul>

      <button type="submit" class="btn" id="submitBtn"><span class="spin" aria-hidden="true"></span><span id="btnText">Save new password</span></button>
      <div class="msg" id="errMsg" role="alert"></div>
    </form>

    <div class="done" role="status">
      <div class="badge"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12.5l4.5 4.5L19 7.5"/></svg></div>
      <h1>Password updated</h1>
      <p>Open the ClassMate app and sign in with your new password. You've been signed out on your other devices.</p>
      <a class="btn" href="https://classmate-f17d6.web.app/">Sign in on the web</a>
    </div>
  </div>

  <footer>Need help? <a href="mailto:support@classmateapp.org">support@classmateapp.org</a></footer>
</main>

<script>
  const token = ${JSON.stringify(token)};
  const card = document.getElementById('card');
  const form = document.getElementById('form');
  const pw1 = document.getElementById('pw1');
  const pw2 = document.getElementById('pw2');
  const btn = document.getElementById('submitBtn');
  const btnText = document.getElementById('btnText');
  const errMsg = document.getElementById('errMsg');
  const chkLen = document.getElementById('chkLen');
  const chkMatch = document.getElementById('chkMatch');

  document.querySelectorAll('.eye').forEach((b) => b.addEventListener('click', () => {
    const t = document.getElementById(b.dataset.target);
    const show = t.type === 'password';
    t.type = show ? 'text' : 'password';
    b.setAttribute('aria-pressed', String(show));
    b.setAttribute('aria-label', show ? 'Hide password' : 'Show password');
  }));

  function refreshChecks() {
    chkLen.classList.toggle('ok', pw1.value.length >= 8);
    chkMatch.classList.toggle('ok', pw2.value.length > 0 && pw1.value === pw2.value);
  }
  pw1.addEventListener('input', refreshChecks);
  pw2.addEventListener('input', refreshChecks);

  function setError(msg) {
    errMsg.textContent = msg || '';
    errMsg.classList.toggle('show', !!msg);
  }
  function setBusy(busy) {
    btn.disabled = busy;
    btn.classList.toggle('busy', busy);
    btnText.textContent = busy ? 'Saving…' : 'Save new password';
  }

  if (!token) {
    setError('This link is missing its reset code. Open the link from your email or text again, or ask for a new one from "Forgot password?" in the app.');
    btn.disabled = true;
  }

  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    setError(null);
    if (pw1.value.length < 8) { pw1.focus(); return setError('Use at least 8 characters.'); }
    if (pw1.value !== pw2.value) { pw2.focus(); return setError("The two passwords don't match."); }

    setBusy(true);
    try {
      const res = await fetch('/auth/reset-password', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ token, newPassword: pw1.value }),
      });
      const data = await res.json().catch(() => ({}));
      if (!res.ok) {
        setBusy(false);
        if (res.status === 429) return setError('Too many tries with this link. Wait a few minutes, then try again.');
        const m = Array.isArray(data.message) ? data.message[0] : data.message;
        return setError((m || 'This link may have expired.') + ' You can ask for a new one from "Forgot password?" in the app.');
      }
      card.classList.add('is-done');
    } catch (err) {
      setBusy(false);
      setError('No connection. Check your internet and try again.');
    }
  });
</script>
</body>
</html>`;
}

const EYE_ICONS =
  '<svg class="on" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M2 12s3.6-7 10-7 10 7 10 7-3.6 7-10 7S2 12 2 12z"/><circle cx="12" cy="12" r="3"/></svg>' +
  '<svg class="off" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M3 3l18 18M10.6 5.1A10.4 10.4 0 0 1 12 5c6.4 0 10 7 10 7a17.6 17.6 0 0 1-3.2 4.1M6.6 6.6C3.8 8.4 2 12 2 12s3.6 7 10 7a9.6 9.6 0 0 0 5.4-1.6M9.9 9.9a3 3 0 0 0 4.2 4.2"/></svg>';
