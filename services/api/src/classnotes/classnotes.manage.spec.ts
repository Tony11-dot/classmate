import { ClassnotesService } from './classnotes.service';
import { ClassnotesAiService } from './classnotes.ai.service';

/**
 * Managing the ClassNotes library from the ClassMate tab has to survive the one
 * thing that makes it hard: the iPad pushes its ENTIRE library up on every launch.
 * A plain delete or rename here would be silently undone. These tests pin the
 * tombstone + remote-edit rules that stop that.
 */
describe('ClassnotesService — managing notebooks from ClassMate', () => {
  const user = { id: 'user-1' };
  const upsertBody = {
    title: 'From the iPad',
    coverColorHex: '#112233',
    template: 'ruled',
    shelfId: null,
    pageCount: 3,
    createdAt: '2026-07-01T00:00:00.000Z',
    updatedAt: '2026-07-27T00:00:00.000Z',
  };

  /** A prisma stand-in that records what the service tried to write. */
  function fakePrisma(notebook: any) {
    const calls: any = { updates: [], upserts: [], deleteManys: [], findMany: [] };
    const notebookDelegate = {
      findUnique: jest.fn().mockResolvedValue(notebook),
      findMany: jest.fn().mockImplementation((args: any) => {
        calls.findMany.push(args);
        return Promise.resolve(notebook ? [{ ...notebook, id: 'nb-1' }] : []);
      }),
      update: jest.fn().mockImplementation((args: any) => {
        calls.updates.push(args);
        return Promise.resolve({});
      }),
      upsert: jest.fn().mockImplementation((args: any) => {
        calls.upserts.push(args);
        return Promise.resolve({});
      }),
      updateMany: jest.fn().mockResolvedValue({ count: 1 }),
      deleteMany: jest.fn().mockResolvedValue({ count: 1 }),
    };
    const prisma: any = {
      classNotesNotebook: notebookDelegate,
      classNotesShelf: { findMany: jest.fn().mockResolvedValue([]) },
      classNotesPage: {
        deleteMany: jest.fn().mockImplementation((args: any) => {
          calls.deleteManys.push(args);
          return Promise.resolve({ count: 0 });
        }),
      },
      // The real client runs the array and returns each result; awaiting the
      // promises the delegates already returned is equivalent here.
      $transaction: (ops: any[]) => Promise.all(ops),
    };
    return { prisma, calls };
  }

  it('does not resurrect a notebook deleted from ClassMate', async () => {
    const { prisma, calls } = fakePrisma({
      userId: 'user-1',
      deletedAt: new Date(),
      remoteEditedAt: null,
    });
    const svc = new ClassnotesService(prisma);

    const result = await svc.upsertNotebook(user, 'nb-1', upsertBody as any);

    expect(result).toEqual({ ok: true, skipped: 'deleted' });
    expect(calls.upserts).toHaveLength(0);
    expect(calls.updates).toHaveLength(0);
  });

  it('keeps a ClassMate rename when the iPad pushes its older title', async () => {
    const { prisma, calls } = fakePrisma({
      userId: 'user-1',
      deletedAt: null,
      remoteEditedAt: new Date(),
    });
    const svc = new ClassnotesService(prisma);

    const result = await svc.upsertNotebook(user, 'nb-1', upsertBody as any);

    expect(result).toEqual({ ok: true, skipped: 'remoteEdited' });
    // The push still lands — page count, template, dates — but NOT the title or
    // the shelf, which the user changed here more recently.
    expect(calls.updates).toHaveLength(1);
    const written = calls.updates[0].data;
    expect(written.pageCount).toBe(3);
    expect(written).not.toHaveProperty('title');
    expect(written).not.toHaveProperty('shelfId');
  });

  it('applies a normal push in full when nothing was changed here', async () => {
    const { prisma, calls } = fakePrisma({
      userId: 'user-1',
      deletedAt: null,
      remoteEditedAt: null,
    });
    const svc = new ClassnotesService(prisma);

    await svc.upsertNotebook(user, 'nb-1', upsertBody as any);

    expect(calls.upserts).toHaveLength(1);
    expect(calls.upserts[0].update.title).toBe('From the iPad');
  });

  it('stores the cover render the iPad sends with the notebook', async () => {
    const { prisma, calls } = fakePrisma({
      userId: 'user-1',
      deletedAt: null,
      remoteEditedAt: null,
    });
    const svc = new ClassnotesService(prisma);

    await svc.upsertNotebook(user, 'nb-1', {
      ...upsertBody,
      coverImage: 'data:image/png;base64,AAAA',
    } as any);

    expect(calls.upserts[0].update.coverImage).toBe('data:image/png;base64,AAAA');
    expect(calls.upserts[0].create.coverImage).toBe('data:image/png;base64,AAAA');
  });

  it('a push with no render leaves the stored cover alone', async () => {
    // An older build — or a notebook whose cover hasn't been opened since the
    // update — omits the field. Writing undefined would blank a good cover.
    const { prisma, calls } = fakePrisma({
      userId: 'user-1',
      deletedAt: null,
      remoteEditedAt: null,
    });
    const svc = new ClassnotesService(prisma);

    await svc.upsertNotebook(user, 'nb-1', upsertBody as any);

    expect(calls.upserts[0].update).not.toHaveProperty('coverImage');
    expect(calls.upserts[0].create).not.toHaveProperty('coverImage');
  });

  it('a cover render still lands while a ClassMate rename is pending', async () => {
    const { prisma, calls } = fakePrisma({
      userId: 'user-1',
      deletedAt: null,
      remoteEditedAt: new Date(),
    });
    const svc = new ClassnotesService(prisma);

    await svc.upsertNotebook(user, 'nb-1', {
      ...upsertBody,
      coverImage: 'data:image/png;base64,BBBB',
    } as any);

    // The title is held back, but the artwork isn't a remote edit — it's what
    // the notebook now looks like.
    const written = calls.updates[0].data;
    expect(written.coverImage).toBe('data:image/png;base64,BBBB');
    expect(written).not.toHaveProperty('title');
  });

  it('a rename is marked so the iPad pulls it', async () => {
    const { prisma, calls } = fakePrisma({
      userId: 'user-1',
      deletedAt: null,
      remoteEditedAt: null,
    });
    const svc = new ClassnotesService(prisma);

    await svc.patchNotebook(user, 'nb-1', { title: '  Physics  ' } as any);

    expect(calls.updates).toHaveLength(1);
    const data = calls.updates[0].data;
    expect(data.title).toBe('Physics');
    expect(data.remoteEditedAt).toBeInstanceOf(Date);
  });

  it('unfiling a notebook sends shelfId null, not "leave it alone"', async () => {
    const { prisma, calls } = fakePrisma({
      userId: 'user-1',
      deletedAt: null,
      remoteEditedAt: null,
    });
    const svc = new ClassnotesService(prisma);

    await svc.patchNotebook(user, 'nb-1', { shelfId: null } as any);
    expect(calls.updates[0].data.shelfId).toBeNull();

    calls.updates.length = 0;
    await svc.patchNotebook(user, 'nb-1', { title: 'x' } as any);
    expect(calls.updates[0].data).not.toHaveProperty('shelfId');
  });

  it('deleting tombstones the notebook and drops its page images', async () => {
    const { prisma, calls } = fakePrisma({
      userId: 'user-1',
      deletedAt: null,
      remoteEditedAt: null,
    });
    const svc = new ClassnotesService(prisma);

    await svc.deleteNotebook(user, 'nb-1');

    expect(calls.deleteManys).toHaveLength(1);
    expect(calls.updates[0].data.deletedAt).toBeInstanceOf(Date);
  });

  it('the library hides tombstoned notebooks and honours the manual order', async () => {
    const { prisma, calls } = fakePrisma(null);
    const svc = new ClassnotesService(prisma);

    await svc.getLibrary(user);

    const args = calls.findMany[0];
    expect(args.where).toEqual({ userId: 'user-1', deletedAt: null });
    expect(args.orderBy).toEqual([{ sortIndex: 'asc' }, { updatedAt: 'desc' }]);
  });

  it('reordering numbers only the notebooks the caller owns', async () => {
    const { prisma, calls } = fakePrisma({ userId: 'user-1', deletedAt: null });
    prisma.classNotesNotebook.findMany = jest
      .fn()
      .mockResolvedValue([{ id: 'a' }, { id: 'b' }]);
    const svc = new ClassnotesService(prisma);

    const result = await svc.reorderNotebooks(user, ['b', 'someone-elses', 'a']);

    expect(result).toEqual({ ok: true, count: 2 });
    expect(calls.updates.map((u: any) => [u.where.id, u.data.sortIndex])).toEqual([
      ['b', 0],
      ['a', 1],
    ]);
  });
});

describe('ClassnotesAiService.stripReasoning', () => {
  it('removes a think block', () => {
    expect(
      ClassnotesAiService.stripReasoning('<think>hmm, tidy it</think>Clean text.'),
    ).toBe('Clean text.');
  });

  it('removes an unterminated think block', () => {
    expect(ClassnotesAiService.stripReasoning('<think>still going')).toBe('');
  });

  it('keeps the final harmony channel only', () => {
    const raw =
      '<|channel|>analysis<|message|>weighing<|end|>' +
      '<|start|>assistant<|channel|>final<|message|>The answer.';
    expect(ClassnotesAiService.stripReasoning(raw)).toBe('The answer.');
  });

  it('leaves a real answer alone', () => {
    const raw = 'Water boils at 100 °C at sea level.';
    expect(ClassnotesAiService.stripReasoning(raw)).toBe(raw);
  });
});

describe('ClassnotesAiService — snips', () => {
  it('accepts raw base64 and turns it into a data URL', () => {
    expect(ClassnotesAiService.imageDataURL('AAAA')).toBe('data:image/jpeg;base64,AAAA');
  });

  it('leaves a data URL the client already built alone', () => {
    const url = 'data:image/png;base64,BBBB';
    expect(ClassnotesAiService.imageDataURL(url)).toBe(url);
  });

  it('keeps only real user/assistant turns, most recent first out of the door', () => {
    const history = [
      { role: 'system', content: 'ignore me' },
      { role: 'user', content: '  what is this?  ' },
      { role: 'assistant', content: '' },
      { role: 'assistant', content: 'A free-body diagram.' },
    ];
    expect(ClassnotesAiService.trimHistory(history as any)).toEqual([
      { role: 'user', content: 'what is this?' },
      { role: 'assistant', content: 'A free-body diagram.' },
    ]);
    expect(ClassnotesAiService.trimHistory(undefined as any)).toEqual([]);
  });
});
