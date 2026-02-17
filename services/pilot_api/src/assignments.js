const express = require("express");
const { z } = require("zod");

// server.js style: buildAssignmentsRouter({ auth, prisma })
function buildAssignmentsRouter({ auth, prisma }) {
  if (!auth) throw new Error("buildAssignmentsRouter: missing auth");
  if (!prisma) throw new Error("buildAssignmentsRouter: missing prisma");

  const router = express.Router();

  const isAdmin = (req) => Array.isArray(req.user?.roles) && req.user.roles.includes("admin");

  async function adminHasScopeForGrade({ userId, schoolId, grade }) {
    const scope = await prisma.adminScope.findFirst({
      where: {
        userId,
        schoolId,
        gradeMin: { lte: grade },
        gradeMax: { gte: grade },
      },
      select: { id: true },
    });
    return !!scope;
  }

  async function requireClassroomAccess({ req, res, classroomId, needsTeacher }) {
    const schoolId = req.user?.schoolId;
    const userId = req.user?.id;
    if (!schoolId || !userId) {
      res.status(401).json({ error: "invalid_token" });
      return null;
    }

    const classroom = await prisma.classroom.findUnique({
      where: { id: classroomId },
      select: { id: true, schoolId: true, grade: true, subjectId: true },
    });

    if (!classroom) {
      res.status(400).json({ error: "invalid_classroomId" });
      return null;
    }

    if (classroom.schoolId !== schoolId) {
      res.status(403).json({ error: "forbidden" });
      return null;
    }

    // membership check
    const member = await prisma.classroomMember.findFirst({
      where: {
        classroomId: classroom.id,
        userId,
        ...(needsTeacher ? { role: "teacher" } : {}),
      },
      select: { id: true },
    });

    if (member) return classroom;

    // admin: allow by scope (even without membership)
    if (isAdmin(req)) {
      const ok = await adminHasScopeForGrade({ userId, schoolId, grade: classroom.grade });
      if (ok) return classroom;
    }

    res.status(403).json({ error: "forbidden" });
    return null;
  }

  // GET /api/assignments?classroomId=...&from=ISO&to=ISO
  router.get("/", auth, async (req, res) => {
    const classroomId = String(req.query.classroomId || "").trim();
    if (!classroomId) return res.status(400).json({ error: "classroomId_required" });

    const classroom = await requireClassroomAccess({ req, res, classroomId, needsTeacher: false });
    if (!classroom) return;

    const from = typeof req.query.from === "string" ? new Date(req.query.from) : null;
    const to = typeof req.query.to === "string" ? new Date(req.query.to) : null;
    if (from && isNaN(from.getTime())) return res.status(400).json({ error: "bad_request", message: "Invalid from" });
    if (to && isNaN(to.getTime())) return res.status(400).json({ error: "bad_request", message: "Invalid to" });

    const rows = await prisma.assignment.findMany({
      where: {
        schoolId: classroom.schoolId,
        classroomId: classroom.id,
        ...(from || to
          ? {
              createdAt: {
                ...(from ? { gte: from } : {}),
                ...(to ? { lte: to } : {}),
              },
            }
          : {}),
      },
      orderBy: { createdAt: "desc" },
      select: {
        id: true,
        classroomId: true,
        title: true,
        details: true,
        dueAt: true,
        createdAt: true,
        User: { select: { id: true, fullName: true, username: true } },
      },
    });

    res.json(
      rows.map((r) => ({
        id: r.id,
        classroomId: r.classroomId,
        title: r.title,
        details: r.details ?? null,
        dueAt: r.dueAt ?? null,
        createdAt: r.createdAt,
        createdBy: r.User,
      }))
    );
  });

  // POST /api/assignments (teacher/admin only)
  router.post("/", auth, async (req, res) => {
    const S = z.object({
      classroomId: z.string().min(1),
      title: z.string().min(1),
      details: z.string().nullable().optional(),
      dueAt: z.string().nullable().optional(), // ISO or null
    });
    const body = S.safeParse(req.body);
    if (!body.success) return res.status(400).json({ error: "bad_request", details: body.error.flatten() });

    const classroomId = body.data.classroomId;
    const classroom = await requireClassroomAccess({ req, res, classroomId, needsTeacher: true });
    if (!classroom) return;

    let dueAt = null;
    if (typeof body.data.dueAt === "string") {
      const d = new Date(body.data.dueAt);
      if (isNaN(d.getTime())) return res.status(400).json({ error: "bad_request", message: "Invalid dueAt" });
      dueAt = d;
    }

    const row = await prisma.assignment.create({
      data: {
        schoolId: classroom.schoolId,
        classroomId: classroom.id,
        subjectId: classroom.subjectId,
        createdById: req.user.id,
        title: body.data.title,
        details: body.data.details ?? null,
        dueAt,
      },
      select: {
        id: true,
        classroomId: true,
        title: true,
        details: true,
        dueAt: true,
        createdAt: true,
        User: { select: { id: true, fullName: true, username: true } },
      },
    });

    res.json({
      id: row.id,
      classroomId: row.classroomId,
      title: row.title,
      details: row.details ?? null,
      dueAt: row.dueAt ?? null,
      createdAt: row.createdAt,
      createdBy: row.User,
    });
  });

  // POST /api/assignments/:id/submissions (student member or scoped admin)
  router.post("/:id/submissions", auth, async (req, res) => {
    const schoolId = req.user?.schoolId;
    if (!schoolId) return res.status(401).json({ error: "invalid_token" });

    const id = req.params.id;

    const assignment = await prisma.assignment.findUnique({
      where: { id },
      select: {
        id: true,
        schoolId: true,
        classroomId: true,
        Classroom: { select: { id: true, schoolId: true, grade: true } },
      },
    });
    if (!assignment || assignment.schoolId !== schoolId) return res.status(404).json({ error: "assignment_not_found" });

    const classroom = assignment.Classroom;
    if (!classroom || classroom.schoolId !== schoolId) return res.status(403).json({ error: "forbidden" });

    // member OR (admin + scope)
    const member = await prisma.classroomMember.findFirst({
      where: { classroomId: classroom.id, userId: req.user.id },
      select: { id: true },
    });

    if (!member) {
      if (!isAdmin(req)) return res.status(403).json({ error: "forbidden" });
      const ok = await adminHasScopeForGrade({ userId: req.user.id, schoolId, grade: classroom.grade });
      if (!ok) return res.status(403).json({ error: "forbidden" });
    }

    const S = z.object({
      text: z.string().nullable().optional(),
      mediaUrl: z.string().url().nullable().optional(),
    });
    const body = S.safeParse(req.body);
    if (!body.success) return res.status(400).json({ error: "bad_request", details: body.error.flatten() });

    const submission = await prisma.assignmentSubmission.upsert({
      where: { assignmentId_userId: { assignmentId: id, userId: req.user.id } },
      update: {
        text: body.data.text ?? null,
        mediaUrl: body.data.mediaUrl ?? null,
      },
      create: {
        assignmentId: id,
        userId: req.user.id,
        text: body.data.text ?? null,
        mediaUrl: body.data.mediaUrl ?? null,
      },
      select: { id: true, assignmentId: true, userId: true, text: true, mediaUrl: true, createdAt: true },
    });

    res.json(submission);
  });

  // GET /api/assignments/:id/submissions (teacher member OR scoped admin)
  router.get("/:id/submissions", auth, async (req, res) => {
    const schoolId = req.user?.schoolId;
    if (!schoolId) return res.status(401).json({ error: "invalid_token" });

    const id = req.params.id;

    const assignment = await prisma.assignment.findUnique({
      where: { id },
      select: {
        id: true,
        schoolId: true,
        classroomId: true,
        Classroom: { select: { id: true, schoolId: true, grade: true } },
      },
    });
    if (!assignment || assignment.schoolId !== schoolId) return res.status(404).json({ error: "assignment_not_found" });

    const classroom = assignment.Classroom;
    if (!classroom || classroom.schoolId !== schoolId) return res.status(403).json({ error: "forbidden" });

    const teacher = await prisma.classroomMember.findFirst({
      where: { classroomId: classroom.id, userId: req.user.id, role: "teacher" },
      select: { id: true },
    });

    if (!teacher) {
      if (!isAdmin(req)) return res.status(403).json({ error: "forbidden" });
      const ok = await adminHasScopeForGrade({ userId: req.user.id, schoolId, grade: classroom.grade });
      if (!ok) return res.status(403).json({ error: "forbidden" });
    }

    const rows = await prisma.assignmentSubmission.findMany({
      where: { assignmentId: id },
      orderBy: { createdAt: "desc" },
      select: {
        id: true,
        text: true,
        mediaUrl: true,
        createdAt: true,
        User: { select: { id: true, fullName: true, username: true } },
      },
    });

    res.json(
      rows.map((r) => ({
        id: r.id,
        text: r.text ?? null,
        mediaUrl: r.mediaUrl ?? null,
        createdAt: r.createdAt,
        user: r.User,
      }))
    );
  });

  return router;
}

module.exports = { buildAssignmentsRouter };
