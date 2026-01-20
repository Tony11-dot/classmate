const BASE = process.env.API_BASE ?? 'http://localhost:3000';

async function req(path, opts = {}) {
  const res = await fetch(`${BASE}${path}`, {
    ...opts,
    headers: { 'Content-Type': 'application/json', ...(opts.headers ?? {}) },
  });
  const text = await res.text();
  return { res, text };
}

function ok(cond, msg) {
  if (!cond) throw new Error(msg);
}

(async () => {
  console.log('SMOKE API BASE:', BASE);

  const h = await req('/api/health');
  ok(h.res.status === 200, `/api/health expected 200 got ${h.res.status}: ${h.text}`);
  console.log('OK /api/health', h.text);

  const seed = await req('/api/test/seed/admin-web', { method: 'POST' });
  ok(seed.res.status === 201, `/api/test/seed/admin-web expected 201 got ${seed.res.status}: ${seed.text}`);
  const seedJson = JSON.parse(seed.text);
  ok(seedJson.ok === true, 'seed ok=false');
  ok(seedJson.cohortId, 'seed missing cohortId');
  console.log('OK seed', seedJson);

  const login = await req('/api/auth/login', {
    method: 'POST',
    body: JSON.stringify({ email: 'teacher1@classmate.app', password: 'dev' }),
  });
  ok(login.res.status === 201, `/api/auth/login expected 201 got ${login.res.status}: ${login.text}`);
  const loginJson = JSON.parse(login.text);
  ok(!!loginJson.token, 'login missing token');
  console.log('OK login token_len=', loginJson.token.length);

  console.log('SMOKE ✅ all good');
})().catch((e) => {
  console.error('SMOKE ❌', e.message);
  process.exit(1);
});
