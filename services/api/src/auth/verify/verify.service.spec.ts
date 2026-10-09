import { normalizeCode, VerifyService } from './verify.service';

/** Minimal in-memory stand-in for the two Prisma tables VerifyService touches. */
function fakePrisma() {
  const rows: any[] = [];
  let seq = 0;
  const live = (where: any) =>
    rows.filter(
      (r) =>
        r.userId === where.userId &&
        r.channel === where.channel &&
        (where.usedAt !== null || r.usedAt === null) &&
        (!where.expiresAt || r.expiresAt > where.expiresAt.gt) &&
        (!where.createdAt || r.createdAt > where.createdAt.gt),
    );
  const newestFirst = (a: any, b: any) => b.createdAt - a.createdAt || b.seq - a.seq;
  return {
    rows,
    user: {
      findUnique: async () => ({ id: 'u1', email: 'kid@school.org', phone: null, school: { name: 'School' } }),
      update: async () => ({}),
      findFirst: async () => null,
    },
    verificationCode: {
      findFirst: async ({ where }: any) => live(where).sort(newestFirst)[0] ?? null,
      findMany: async ({ where, skip = 0, take }: any) => {
        const list = live(where).sort(newestFirst).slice(skip);
        return take ? list.slice(0, take) : list;
      },
      create: async ({ data }: any) => {
        rows.push({ ...data, id: `c${++seq}`, seq, attempts: 0, usedAt: null, createdAt: new Date(0) });
      },
      update: async ({ where, data }: any) => {
        const r = rows.find((x) => x.id === where.id);
        if (data.attempts?.increment) r.attempts += data.attempts.increment;
        if (data.usedAt) r.usedAt = data.usedAt;
      },
      updateMany: async ({ where, data }: any) => {
        for (const r of rows) if (where.id.in.includes(r.id)) r.usedAt = data.usedAt;
      },
    },
  };
}

describe('VerifyService codes', () => {
  const sent: string[] = [];
  const email = {
    sendVerificationCode: async ({ code }: { code: string }) => {
      sent.push(code);
      return true;
    },
  };

  beforeEach(() => {
    sent.length = 0;
  });

  it('normalizes Arabic-Indic digits and pasted separators', () => {
    expect(normalizeCode('١٢٣٤٥٦')).toBe('123456');
    expect(normalizeCode('۱۲۳ ۴۵۶')).toBe('123456');
    expect(normalizeCode(' 123-456 ')).toBe('123456');
  });

  it('still accepts an earlier code after a resend (late email)', async () => {
    const prisma = fakePrisma();
    const svc = new VerifyService(prisma as any, email as any, {} as any);
    await svc.startVerification({ userId: 'u1', channel: 'email' });
    await svc.startVerification({ userId: 'u1', channel: 'email' });
    expect(sent).toHaveLength(2);
    expect(sent[0]).not.toBe(sent[1]);

    const res = await svc.confirmVerification({ userId: 'u1', channel: 'email', code: sent[0] });
    expect(res).toEqual({ ok: true, changed: false });
    // Redeeming one closes the flow: the sibling code is spent too.
    await expect(
      svc.confirmVerification({ userId: 'u1', channel: 'email', code: sent[1] }),
    ).rejects.toThrow('No active verification code');
  });

  it('accepts a code typed with an Arabic keyboard', async () => {
    const prisma = fakePrisma();
    const svc = new VerifyService(prisma as any, email as any, {} as any);
    await svc.startVerification({ userId: 'u1', channel: 'email' });
    const arabic = sent[0].replace(/\d/g, (d) => String.fromCharCode(0x0660 + Number(d)));
    await expect(
      svc.confirmVerification({ userId: 'u1', channel: 'email', code: arabic }),
    ).resolves.toEqual({ ok: true, changed: false });
  });

  it('keeps at most three codes live', async () => {
    const prisma = fakePrisma();
    const svc = new VerifyService(prisma as any, email as any, {} as any);
    for (let i = 0; i < 4; i++) await svc.startVerification({ userId: 'u1', channel: 'email' });
    await expect(
      svc.confirmVerification({ userId: 'u1', channel: 'email', code: sent[0] }),
    ).rejects.toThrow('Incorrect code');
    await expect(
      svc.confirmVerification({ userId: 'u1', channel: 'email', code: sent[1] }),
    ).resolves.toEqual({ ok: true, changed: false });
  });
});
