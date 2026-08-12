import { ClassnotesService } from './classnotes.service';

/**
 * A user's ClassNotes setup — their pens, the Pencil gestures, their theme —
 * lives on the account so a second device comes up configured.
 *
 * The whole difficulty is that BOTH devices push independently, on launch and
 * after every change. Without an arbiter, whichever one happens to write last
 * wins, and an iPhone that has been sitting in a drawer would post its factory
 * defaults over an evening's worth of tuning. `revision` is that arbiter, and
 * these tests pin it.
 */
describe('ClassnotesService — settings across a user\'s devices', () => {
  const user = { id: 'user-1' };

  const body = (revision: number) => ({
    revision,
    updatedAt: '2026-08-12T10:00:00.000Z',
    tools: { penPresetID: 'fountain', eraserWidth: 30 },
    themeSelection: 'midnight',
    paperTone: 'warm',
  });

  function fakePrisma(existing: any) {
    const calls: any = { upserts: [] };
    const prisma: any = {
      classNotesSettings: {
        findUnique: jest.fn().mockResolvedValue(existing),
        upsert: jest.fn().mockImplementation((args: any) => {
          calls.upserts.push(args);
          return Promise.resolve({});
        }),
      },
    };
    return { prisma, calls };
  }

  it('saves the first device\'s setup', async () => {
    const { prisma, calls } = fakePrisma(null);
    const svc = new ClassnotesService(prisma);

    const result = await svc.putSettings(user, body(4) as any);

    expect(result).toEqual({ ok: true, stored: true, revision: 4 });
    expect(calls.upserts[0].create).toMatchObject({
      userId: 'user-1',
      revision: 4,
      payload: {
        tools: { penPresetID: 'fountain', eraserWidth: 30 },
        themeSelection: 'midnight',
        paperTone: 'warm',
      },
    });
  });

  it('refuses an older revision instead of overwriting the newer one', async () => {
    // The iPad is on revision 9. The iPhone launches holding revision 3 and
    // pushes. Accepting that would undo six changes the user actually made.
    const { prisma, calls } = fakePrisma({ userId: 'user-1', revision: 9 });
    const svc = new ClassnotesService(prisma);

    const result = await svc.putSettings(user, body(3) as any);

    expect(result).toEqual({ ok: true, stored: false, revision: 9 });
    expect(calls.upserts).toHaveLength(0);
  });

  it('accepts an equal revision, so a re-push is never rejected as stale', async () => {
    const { prisma, calls } = fakePrisma({ userId: 'user-1', revision: 5 });
    const svc = new ClassnotesService(prisma);

    const result = await svc.putSettings(user, body(5) as any);

    expect(result.stored).toBe(true);
    expect(calls.upserts).toHaveLength(1);
  });

  it('reports no settings for an account that has never saved any', async () => {
    // First run is not an error: the device keeps whatever it already has.
    const { prisma } = fakePrisma(null);
    const svc = new ClassnotesService(prisma);

    await expect(svc.getSettings(user)).resolves.toEqual({ settings: null });
  });

  it('returns the stored setup with the row\'s own revision and time', async () => {
    const { prisma } = fakePrisma({
      userId: 'user-1',
      revision: 7,
      updatedAt: new Date('2026-08-12T10:00:00.000Z'),
      payload: {
        tools: { penPresetID: 'fountain' },
        themeSelection: 'midnight',
        paperTone: 'warm',
      },
    });
    const svc = new ClassnotesService(prisma);

    await expect(svc.getSettings(user)).resolves.toEqual({
      settings: {
        tools: { penPresetID: 'fountain' },
        themeSelection: 'midnight',
        paperTone: 'warm',
        revision: 7,
        updatedAt: '2026-08-12T10:00:00.000Z',
      },
    });
  });

  it('never reads another user\'s settings', async () => {
    const { prisma } = fakePrisma(null);
    const svc = new ClassnotesService(prisma);

    await svc.getSettings({ id: 'user-1' });

    expect(prisma.classNotesSettings.findUnique).toHaveBeenCalledWith({
      where: { userId: 'user-1' },
    });
  });
});
