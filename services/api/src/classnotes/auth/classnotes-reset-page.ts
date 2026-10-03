/// The page a ClassNotes reset link opens.
///
/// It is served by the API itself rather than by the ClassMate web app, because
/// the two reset flows consume DIFFERENT tables: ClassMate's `/reset-password`
/// page posts to `/auth/reset-password`, which looks the token up in
/// `PasswordResetToken` and would never find a `ClassNotesPasswordResetToken`.
/// Pointing ClassNotes' mail at that page would have produced a link that looks
/// right, loads, and then refuses every token it is given.
///
/// One self-contained document — no external stylesheet, script or font — so it
/// renders identically wherever the mail is opened and needs no asset pipeline.
export function classNotesResetPage(token: string): string {
  const safeToken = escapeForJS(token);
  return `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Reset your ClassNotes password</title>
<style>
  :root { color-scheme: light dark; --bg: #f5f6f8; --card: #ffffff; --ink: #11161f;
          --muted: #5c6673; --accent: #2266dd; --line: #e2e5ea; --bad: #c02b36; --good: #1d7a43; }
  @media (prefers-color-scheme: dark) {
    :root { --bg: #0d1117; --card: #161b22; --ink: #e9edf2; --muted: #9aa4b1;
            --accent: #5b94f0; --line: #272d36; --bad: #ff6b6b; --good: #4ec98a; }
  }
  * { box-sizing: border-box; }
  body { margin: 0; min-height: 100vh; display: grid; place-items: center; padding: 24px;
         background: var(--bg); color: var(--ink);
         font: 16px/1.5 -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; }
  main { width: 100%; max-width: 420px; background: var(--card); border: 1px solid var(--line);
         border-radius: 16px; padding: 28px; }
  h1 { font-size: 1.35rem; margin: 0 0 6px; }
  p.sub { margin: 0 0 22px; color: var(--muted); font-size: 0.95rem; }
  label { display: block; font-size: 0.85rem; font-weight: 600; margin-bottom: 6px; }
  input { width: 100%; padding: 12px 14px; font-size: 1rem; color: var(--ink);
          background: var(--bg); border: 1px solid var(--line); border-radius: 10px; }
  input:focus { outline: 2px solid var(--accent); outline-offset: 1px; }
  .field { margin-bottom: 16px; }
  button { width: 100%; padding: 13px 16px; font-size: 1rem; font-weight: 600; cursor: pointer;
           color: #fff; background: var(--accent); border: 0; border-radius: 10px; }
  button[disabled] { opacity: 0.55; cursor: default; }
  #note { margin: 18px 0 0; font-size: 0.9rem; min-height: 1.2em; }
  #note.bad { color: var(--bad); }
  #note.good { color: var(--good); }
</style>
</head>
<body>
<main>
  <h1>Reset your password</h1>
  <p class="sub">Choose a new password for your ClassNotes account. It needs at least 8 characters.</p>
  <form id="form" novalidate>
    <div class="field">
      <label for="password">New password</label>
      <input id="password" type="password" autocomplete="new-password" minlength="8" required>
    </div>
    <div class="field">
      <label for="confirm">Confirm password</label>
      <input id="confirm" type="password" autocomplete="new-password" minlength="8" required>
    </div>
    <button id="submit" type="submit">Set new password</button>
  </form>
  <p id="note" role="status" aria-live="polite"></p>
</main>
<script>
  var TOKEN = "${safeToken}";
  var form = document.getElementById('form');
  var note = document.getElementById('note');
  var submit = document.getElementById('submit');

  function say(text, kind) { note.textContent = text; note.className = kind || ''; }

  form.addEventListener('submit', function (event) {
    event.preventDefault();
    var password = document.getElementById('password').value;
    var confirm = document.getElementById('confirm').value;
    if (password.length < 8) { say('Password must be at least 8 characters.', 'bad'); return; }
    if (password !== confirm) { say('Those passwords do not match.', 'bad'); return; }
    submit.disabled = true;
    say('Saving…');
    fetch('reset-password', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ token: TOKEN, password: password })
    }).then(function (response) {
      return response.json().catch(function () { return {}; }).then(function (body) {
        return { ok: response.ok, body: body };
      });
    }).then(function (result) {
      if (result.ok) {
        form.style.display = 'none';
        say('Password changed. Open ClassNotes and sign in with your new password.', 'good');
        return;
      }
      var message = result.body && result.body.message;
      if (Array.isArray(message)) { message = message.join(' '); }
      say(message || 'That did not work. Request a new link and try again.', 'bad');
      submit.disabled = false;
    }).catch(function () {
      say('Could not reach ClassNotes. Check your connection and try again.', 'bad');
      submit.disabled = false;
    });
  });
</script>
</body>
</html>`;
}

/// The token is a hex string from `randomBytes`, but it arrives as a query
/// parameter and is therefore attacker-controlled: it is escaped for the JS
/// string literal it lands in rather than trusted to be hex.
///
/// `JSON.stringify` covers quotes, backslashes and newlines. What it does NOT
/// cover is what matters here: `<` and `>` (so nothing can close the script
/// element the token sits inside) and U+2028/U+2029, which are valid JSON but
/// terminate a JavaScript line.
function escapeForJS(raw: string): string {
  const quoted = JSON.stringify(String(raw ?? ''));
  const inner = quoted.slice(1, -1);
  let out = '';
  for (const char of inner) {
    const code = char.codePointAt(0) ?? 0;
    if (char === '<' || char === '>' || char === '&' || code === 0x2028 || code === 0x2029) {
      out += '\\u' + code.toString(16).padStart(4, '0');
    } else {
      out += char;
    }
  }
  return out;
}
