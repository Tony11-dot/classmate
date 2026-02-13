const express = require("express");

// server.js style: buildAssignmentsRouter({ auth, prisma })
function buildAssignmentsRouter({ auth, prisma }) {
  if (!auth) throw new Error("buildAssignmentsRouter: missing auth");
  if (!prisma) throw new Error("buildAssignmentsRouter: missing prisma");

  const router = express.Router();

  // GET /api/assignments?subjectId=sub_math&from=ISO&to=ISO
  router.get("/", auth, async (req, res) => {
    if (!req.user?.id) return res.status(401).json({ error: "unauthorized" });

    const q = req.query || {};
    const where = {};

    if (q.subjectId) where.subjectId = String(q.subjectId);

    // optional date filters (ISO strings)
    const dueAt = {};
    if (q.from) {
      const d = new Date(String(q.from));
      if (!isNaN(d.getTime())) dueAt.gte = d;
    }
    if (q.to) {
      const d = new Date(String(q.to));
      if (!isNaN(d.getTime())) dueAt.lte = d;
    }
    if (Object.keys(dueAt).length) where.dueAt = dueAt;

    const rows = await prisma.assignment.findMany({
      where,
      include: { Subject: true },
      orderBy: { dueAt: "asc" },
      take: 200,
    });

    res.json(rows);
  });

  // POST /api/assignments
  // body: { subjectId, title, dueAt, details? }
  router.post("/", auth, async (req, res) => {
    if (!req.user?.id) return res.status(401).json({ error: "unauthorized" });

    const { subjectId, title, dueAt, details } = req.body || {};
    if (!subjectId || typeof subjectId !== "string") return res.status(400).json({ error: "subjectId_required" });
    if (!title || typeof title !== "string") return res.status(400).json({ error: "title_required" });
    if (!dueAt || typeof dueAt !== "string") return res.status(400).json({ error: "dueAt_required" });

    const d = new Date(dueAt);
    if (isNaN(d.getTime())) return res.status(400).json({ error: "dueAt_invalid" });

    const row = await prisma.assignment.create({
      data: {
        id: (globalThis.crypto && crypto.randomUUID) ? crypto.randomUUID() : (Math.random().toString(16).slice(2) + Date.now().toString(16)),
        subjectId: subjectId.trim(),
        title: title.trim(),
        dueAt: d,
        details: typeof details === "string" ? details.trim() : null,
      },
      include: { Subject: true },
    });

    res.json(row);
  });

// POST /api/assignments/:id/submissions
  // body: { text?, mediaUrl? }
  router.post("/:id/submissions", auth, async (req, res) => {
    const userId = req.user.id;
    if (!userId) return res.status(401).json({ error: "unauthorized" });

    const assignmentId = req.params.id;
    const exists = await prisma.assignment.findUnique({ where: { id: assignmentId } });
    if (!exists) return res.status(404).json({ error: "assignment_not_found" });

    const { text, mediaUrl } = req.body || {};
    if (text != null && typeof text !== "string") return res.status(400).json({ error: "text_invalid" });
    if (mediaUrl != null && typeof mediaUrl !== "string") return res.status(400).json({ error: "mediaUrl_invalid" });

    // upsert = allow re-submit (overwrite)
    const row = await prisma.assignmentSubmission.upsert({
      where: { assignmentId_userId: { assignmentId, userId } },
      update: {
        text: typeof text === "string" ? text.trim() : null,
        mediaUrl: typeof mediaUrl === "string" ? mediaUrl.trim() : null,
      },
      create: {
        id: (globalThis.crypto && crypto.randomUUID) ? crypto.randomUUID() : (Math.random().toString(16).slice(2) + Date.now().toString(16)),
        assignmentId,
        userId,
        text: typeof text === "string" ? text.trim() : null,
        mediaUrl: typeof mediaUrl === "string" ? mediaUrl.trim() : null,
      },
    });

    res.json(row);
  });

  // GET /api/assignments/:id/submissions
  router.get("/:id/submissions", auth, async (req, res) => {
    if (!req.user?.id) return res.status(401).json({ error: "unauthorized" });

    const schoolId = req.user.schoolId;
    if (!schoolId) return res.status(401).json({ error: "invalid_token" });

    const assignmentId = req.params.id;
    const exists = await prisma.assignment.findUnique({ where: { id: assignmentId } });
    if (!exists) return res.status(404).json({ error: "assignment_not_found" });

    const rows = await prisma.assignmentSubmission.findMany({
      where: { assignmentId, User: { schoolId } },
      include: { User: { select: { id: true, fullName: true, username: true } } },
      orderBy: { createdAt: "asc" },
      take: 200,
    });

    res.json(rows);
  });


  return router;
}

module.exports = { buildAssignmentsRouter };
