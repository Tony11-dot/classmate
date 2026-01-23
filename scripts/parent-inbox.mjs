const API_BASE = process.env.API_BASE ?? 'http://localhost:3000';
const token = process.env.PARENT_TOKEN;

if (!token) {
  console.error('Missing PARENT_TOKEN env var');
  process.exit(1);
}

async function get(path) {
  const res = await fetch(`${API_BASE}${path}`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  const text = await res.text();
  const json = text ? JSON.parse(text) : null;
  if (!res.ok) throw new Error(`${res.status} ${JSON.stringify(json)}`);
  return json;
}

function fmt(ts) {
  try { return new Date(ts).toISOString().replace('T',' ').slice(0,19); }
  catch { return String(ts); }
}

(async () => {
  const [lookup, notifs] = await Promise.all([
    get('/api/parent/lookup'),
    get('/api/parent/notifications?take=50'),
  ]);

  const studentName = new Map((lookup.students || []).map(s => [s.id, s.name]));
  const courseName  = new Map((lookup.courses  || []).map(c => [c.id, c.name]));

  const items = notifs.notifications || [];
  console.log(`Notifications: ${items.length}\n`);

  for (const n of items) {
    const sname = studentName.get(n.studentId) || n.studentId || '—';
    const cid = n.data?.courseId;
    const cname = cid ? (courseName.get(cid) || cid) : null;

    let extra = '';
    if (n.type === 'ATTENDANCE_RECORDED') {
      extra =
        ` status=${n.data?.status ?? '?'}` +
        (typeof n.data?.period === 'number' ? ` period=${n.data.period}` : '') +
        (n.data?.date ? ` date=${String(n.data.date).slice(0,10)}` : '');
    }
    if (n.type === 'GRADE_POSTED') {
      extra = ` grade=${n.data?.grade ?? '?'}`;
    }

    const bits = [];
    if (cname) bits.push(cname);
    bits.push(sname);

    console.log(
      `- [${fmt(n.at)}] ${n.type}` +
      ` | ${n.title || ''}` +
      ` | ${bits.join(' · ')}` +
      (extra ? ` |${extra}` : '')
    );
  }
})().catch((e) => {
  console.error('Error:', e?.message || e);
  process.exit(1);
});
