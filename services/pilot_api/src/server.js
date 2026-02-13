require("dotenv").config();
const express = require("express");
const { buildNotificationsRouter } = require("./notifications");
const { buildGradesRouter } = require("./grades");
const { buildAssignmentsRouter } = require("./assignments");
const cors = require("cors");
const jwt = require("jsonwebtoken");
const bcrypt = require("bcrypt");
const { z } = require("zod");
const { PrismaClient } = require("@prisma/client");

const prisma = new PrismaClient();

async function getUserWithRoles(userId) {
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: {
      id: true,
      email: true,
      fullName: true,
      username: true,
      grade: true,
      schoolId: true,
      roles: { select: { Role: { select: { name: true } } } },
    },
  });

  if (!user) return null;

  const roles = (user.roles || []).map((r) => r.Role?.name).filter(Boolean);

  // flatten roles into top-level, and remove join rows from response object
  return {
    id: user.id,
    email: user.email,
    fullName: user.fullName,
    username: user.username,
    grade: user.grade,
    schoolId: user.schoolId,
    roles,
  };
}
const app = express();

app.use(cors({ origin: true, credentials: true }));
app.use(express.json({ limit: "25mb" }));

app.get("/api/health", (req, res) => res.json({ ok: true, env: "pilot_api" }));

function signToken(user) {
  return jwt.sign({ sub: user.id }, process.env.JWT_SECRET, { expiresIn: "30d" });
}

async function auth(req, res, next) {
  try {
    const header = req.headers.authorization || req.headers.Authorization || "";
    const m = String(header).match(/^Bearer\s+(.+)$/i);
    if (!m) return res.status(401).json({ error: "missing_token" });

    const secret = process.env.JWT_SECRET;
    if (!secret) return res.status(500).json({ error: "server_misconfigured", missing: "JWT_SECRET" });

    let decoded;
    try {
      decoded = jwt.verify(m[1], secret);
    } catch (e) {
      return res.status(401).json({ error: "invalid_token" });
    }

    const sub = decoded && decoded.sub;
    if (!sub) return res.status(401).json({ error: "invalid_token" });

    const dbUser = await getUserWithRoles(sub);
    if (!dbUser) return res.status(401).json({ error: "invalid_token" });

    req.user = dbUser;

    return next();
  } catch (e) {
    return res.status(500).json({ error: "auth_failed" });
  }
}
function requireRole(roleName) {
  return (req, res, next) => {
    const roles = req.user?.roles || [];
    if (!roles.includes(roleName)) return res.status(403).json({ error: "forbidden" });
    next();
  };
}

app.use("/api/grades", buildGradesRouter({ auth, prisma }));

app.use("/api/notifications", buildNotificationsRouter({ auth }));

app.use("/api/assignments", buildAssignmentsRouter({ auth, prisma }));

// Simple admin guard (pilot): header x-admin-secret must match
function adminGuard(req, res, next) {
  const secret = req.headers["x-admin-secret"];
  const expected = process.env.ADMIN_SECRET || "pilot_admin_secret";
  if (secret !== expected) return res.status(403).json({ error: "forbidden" });
  next();
}



// Public lookups
app.get("/api/schools", async (req, res) => {
  const rows = await prisma.school.findMany({ orderBy: { name: "asc" } });
  console.log("DEBUG_GRADES rows.length", rows.length);
  console.log("DEBUG_GRADES rows.length", rows.length);
  res.json(rows);
});

app.get("/api/subjects", async (req, res) => {
  const rows = await prisma.subject.findMany({ orderBy: { name: "asc" } });
  res.json(rows);
});

// Auth
app.post("/api/auth/register", async (req, res) => {
  const S = z.object({
    email: z.string().email(),
    password: z.string().min(6),
    fullName: z.string().min(2),
    username: z.string().min(3),
    nationalId: z.string().min(5).optional(),
    grade: z.number().int().min(7).max(12),
    schoolId: z.string().min(1),

    // grade 10+ fields (optional; we’ll enforce in UI)
    scientificMajor: z.string().optional(),
    technologicalMajor: z.string().optional(),
    mathUnits: z.string().optional(),
    englishUnits: z.string().optional(),
  });

  const body = S.safeParse(req.body);
  if (!body.success) return res.status(400).json({ error: "bad_request", details: body.error.flatten() });

  const {
    email,
    password,
    fullName,
    username,
    nationalId,
    grade,
    schoolId,
    scientificMajor,
    technologicalMajor,
    mathUnits,
    englishUnits,
  } = body.data;

  const passwordHash = await bcrypt.hash(password, 10);

  try {
    const user = await prisma.user.create({
      data: {
        email,
        passwordHash,
        fullName,
        username,
        nationalId,
        grade,
        schoolId,
        scientificMajor: scientificMajor || null,
        technologicalMajor: technologicalMajor || null,
        mathUnits: mathUnits || null,
        englishUnits: englishUnits || null,
      },
    });

    // 1) Determine subjects for the student
    const packs = await prisma.gradeSubjectPack.findMany({
      where: { grade },
      include: { Subject: true },
    });

    const subjects = new Map(); // name -> {id, source}
    for (const p of packs) subjects.set(p.Subject.name, { id: p.SubjectId, source: p.kind });

    // grade >= 10 majors decide extra subjects
    const majorNames = [];
    if (grade >= 10) {
      if (scientificMajor && scientificMajor.trim()) majorNames.push(scientificMajor.trim());
      if (technologicalMajor && technologicalMajor.trim()) majorNames.push(technologicalMajor.trim());
    }

    if (majorNames.length) {
      const subs = await prisma.subject.findMany({ where: { name: { in: majorNames } } });
      for (const s of subs) subjects.set(s.name, { id: s.id, source: "major" });
    }

    // 2) Persist StudentSubject rows
    const ssRows = [];
    for (const v of subjects.values()) ssRows.push({ userId: user.id, subjectId: v.id, source: v.source });
    if (ssRows.length) await prisma.studentSubject.createMany({ data: ssRows, skipDuplicates: true });

    // 3) Ensure classrooms exist for this (school, grade, subject)
    const classroomIds = [];
    for (const [name, v] of subjects.entries()) {
      const existing = await prisma.classroom.findUnique({
        where: { schoolId_grade_subjectId: { schoolId, grade, subjectId: v.id } },
      }).catch(() => null);

      let c = existing;
      if (!c) {
        c = await prisma.classroom.create({
          data: {
            schoolId,
            grade,
            subjectId: v.id,
            title: `${name} - Grade ${grade}`,
          },
        });
      }
      classroomIds.push(c.id);
    }

    // 4) Join user to those classrooms
    const cmRows = classroomIds.map((cid) => ({ classroomId: cid, userId: user.id, role: "student" }));
    if (cmRows.length) await prisma.classroomMember.createMany({ data: cmRows, skipDuplicates: true });

    const token = signToken(user);
    res.json({
      token,
      email: user.email,
      name: user.fullName,
      roles: ["student"],
      user: { id: user.id, email: user.email, fullName: user.fullName, username: user.username, grade: user.grade, schoolId: user.schoolId },
    });
  } catch (e) {
    console.error("❌ /api/auth/register failed:", e);

    // Prisma errors often have `code` and `meta`
    return res.status(500).json({
      error: "register_failed",
      code: e && e.code,
      message: e && e.message,
      meta: e && e.meta,
    });
  }
});

app.post("/api/auth/login", async (req, res) => {
  const S = z.object({ email: z.string().email(), password: z.string().min(1) });
  const body = S.safeParse(req.body);
  if (!body.success) return res.status(400).json({ error: "bad_request" });

  const u = await prisma.user.findUnique({ where: { email: body.data.email } });
  if (!u) return res.status(401).json({ error: "invalid_credentials" });

  const ok = await bcrypt.compare(body.data.password, u.passwordHash);
  if (!ok) return res.status(401).json({ error: "invalid_credentials" });

  const token = signToken(u);

  // DB roles (source of truth)
  const dbUser = await getUserWithRoles(u.id);
  const roles = dbUser?.roles || [];

  return res.json({
    roles,
    token,
    email: u.email,
    name: u.fullName,
    user: {
      id: u.id,
      email: u.email,
      fullName: u.fullName,
      username: u.username,
      grade: u.grade,
      schoolId: u.schoolId,
    },
  });
});

// Me
app.get("/api/me", auth, async (req, res) => {
  const userId = req.user.id;
  if (!userId) return res.status(401).json({ error: "invalid_token" });

  const user = await prisma.user.findUnique({ where: { id: userId } });
  if (!user) return res.status(404).json({ error: "not_found" });

  res.json({
    id: user.id,
    email: user.email,
    fullName: user.fullName,
    username: user.username,  // <-- correct field
    grade: user.grade,
    schoolId: user.schoolId,
    roles: req.user?.roles || [],
  });
});

// Alias (mobile-friendly)
app.get("/api/auth/me", auth, async (req, res) => {
  res.json(req.user);
});

app.get("/api/me/subjects", auth, async (req, res) => {
  const rows = await prisma.studentSubject.findMany({
    where: { userId: req.user.id },
    include: { Subject: true },
    orderBy: { createdAt: "asc" },
  });
  res.json(rows.map((r) => ({ id: r.Subject.id, name: r.Subject.name, source: r.source })));
});

app.patch("/api/me", auth, async (req, res) => {
  const S = z.object({
    fullName: z.string().min(2).optional(),
    username: z.string().min(3).optional(),
    email: z.string().email().optional(),
  });
  const body = S.safeParse(req.body);
  if (!body.success) return res.status(400).json({ error: "bad_request" });

  const updated = await prisma.user.update({
    where: { id: req.user.id },
    data: body.data,
    select: { id: true, email: true, fullName: true, username: true, grade: true, schoolId: true },
  });
  res.json(updated);
});

app.post("/api/me/change-password", auth, async (req, res) => {
  const S = z.object({ currentPassword: z.string().min(1), newPassword: z.string().min(6) });
  const body = S.safeParse(req.body);
  if (!body.success) return res.status(400).json({ error: "bad_request" });

  const u = await prisma.user.findUnique({ where: { id: req.user.id } });
  if (!u) return res.status(404).json({ error: "not_found" });

  const ok = await bcrypt.compare(body.data.currentPassword, u.passwordHash);
  if (!ok) return res.status(401).json({ error: "invalid_password" });

  const passwordHash = await bcrypt.hash(body.data.newPassword, 10);
  await prisma.user.update({ where: { id: req.user.id }, data: { passwordHash } });
  res.json({ ok: true });
});

/** Pilot endpoints **/
app.get("/api/schedule", auth, async (req, res) => {
  const day = req.query.day; // YYYY-MM-DD
  const from = day ? new Date(`${day}T00:00:00.000Z`) : new Date(Date.now() - 24 * 3600 * 1000);
  const to = day ? new Date(`${day}T23:59:59.999Z`) : new Date(Date.now() + 7 * 24 * 3600 * 1000);
  const rows = await prisma.scheduleEntry.findMany({
    where: { userId: req.user.id, startAt: { gte: from, lte: to } },
    include: { Subject: true },
    orderBy: { startAt: "asc" },
  });
  res.json(rows);
});

// My classrooms only (membership-based)
app.get("/api/classrooms", auth, async (req, res) => {
  const rows = await prisma.classroomMember.findMany({
    where: { userId: req.user.id },
    include: { Classroom: { include: { Subject: true } } },
    orderBy: { createdAt: "desc" },
  });

  res.json(
    rows.map((r) => {
      if (!r.Classroom) throw new Error('Invariant failed: missing Classroom relation');
      return {
      id: r.Classroom.id,
      title: r.Classroom.title,
      grade: r.Classroom.grade,
      schoolId: r.Classroom.schoolId,
      subject: r.Classroom.Subject,
      role: r.role,
      createdAt: r.Classroom.createdAt,
      };
    })
  );
});

async function requireMember(req, res, next) {
  const classroomId = req.params.id;
  const m = await prisma.classroomMember.findFirst({ where: { classroomId, userId: req.user.id } });
  if (!m) return res.status(403).json({ error: "forbidden" });
  next();
}

app.get("/api/classrooms/:id/messages", auth, requireMember, async (req, res) => {
  const rows = await prisma.message.findMany({
    where: { classroomId: req.params.id },
    include: { User: { select: { id: true, fullName: true, username: true } } },
    orderBy: { createdAt: "asc" },
  });
  res.json(rows);
});

app.post("/api/classrooms/:id/messages", auth, requireMember, async (req, res) => {
  const S = z.object({ kind: z.string().default("text"), text: z.string().optional(), mediaUrl: z.string().url().optional() });
  const body = S.safeParse(req.body);
  if (!body.success) return res.status(400).json({ error: "bad_request" });

  const msg = await prisma.message.create({
    data: { classroomId: req.params.id, userId: req.user.id, kind: body.data.kind, text: body.data.text, mediaUrl: body.data.mediaUrl },
  });
  res.json(msg);
});

// Solutions feed: default = my grade + my subjects
app.get("/api/solutions", auth, async (req, res) => {
  const schoolId = req.user.schoolId;
  if (!schoolId) return res.status(401).json({ error: "invalid_token" });
  const q = req.query;

  const user = await prisma.user.findUnique({ where: { id: req.user.id } });
  if (!user) return res.status(401).json({ error: "invalid_token" });

  const where = {};
  // school isolation (always)
  where.User = { schoolId };

  // explicit filters win
  if (q.SubjectId) where.SubjectId = String(q.SubjectId);
  if (q.grade) where.grade = Number(q.grade);
  if (q.book) where.book = String(q.book);
  if (q.page) where.page = Number(q.page);

  // default filtering if no explicit grade/subjectId
  const hasExplicit = !!q.SubjectId || !!q.grade;
  if (!hasExplicit) {
    where.grade = user.grade;
    const mySubs = await prisma.studentSubject.findMany({ where: { userId: user.id } });
    const subjectIds = mySubs.map((x) => x.SubjectId).filter(Boolean);
    if (subjectIds.length) where.SubjectId = { in: subjectIds };
  }

  const rows = await prisma.solution.findMany({
    where,
    include: {
      Subject: true,
      User: { select: { id: true, fullName: true, username: true } },
      _count: { select: { SolutionLike: true, SolutionComment: true } },
    },
    orderBy: { createdAt: "desc" },
    take: 50,
  });
  res.json(rows.map(r => ({
    ...r,
    _count: r._count ? {
      likes: r._count.SolutionLike ?? 0,
      comments: r._count.SolutionComment ?? 0,
    } : undefined,
  })));

});

app.post("/api/solutions", auth, async (req, res) => {
  const S = z.object({
    subjectId: z.string().min(1),
    grade: z.number().int().min(7).max(12),
    book: z.string().min(1),
    page: z.number().int().min(1),
    question: z.string().min(1),
    caption: z.string().optional(),
    mediaUrl: z.string().min(1),
  });
  const body = S.safeParse(req.body);
  if (!body.success) return res.status(400).json({ error: "bad_request", details: body.error.flatten() });

  const s = await prisma.solution.create({ data: { ...body.data, userId: req.user.id } });
  res.json(s);
});

app.post("/api/solutions/:id/like", auth, async (req, res) => {
  const schoolId = req.user.schoolId;
  if (!schoolId) return res.status(401).json({ error: "invalid_token" });

  const sol = await prisma.solution.findFirst({
    where: { id: req.params.id, User: { schoolId } },
    select: { id: true },
  });
  if (!sol) return res.status(404).json({ error: "not_found" });

  try {
    await prisma.solutionLike.create({ data: { solutionId: req.params.id, userId: req.user.id } });
  } catch {}
  res.json({ ok: true });
});

app.delete("/api/solutions/:id/like", auth, async (req, res) => {
  const schoolId = req.user.schoolId;
  if (!schoolId) return res.status(401).json({ error: "invalid_token" });

  const sol = await prisma.solution.findFirst({
    where: { id: req.params.id, User: { schoolId } },
    select: { id: true },
  });
  if (!sol) return res.status(404).json({ error: "not_found" });

  await prisma.solutionLike.deleteMany({ where: { solutionId: req.params.id, userId: req.user.id } });
  res.json({ ok: true });
});

app.get("/api/solutions/:id/comments", auth, async (req, res) => {
  const schoolId = req.user.schoolId;
  if (!schoolId) return res.status(401).json({ error: "invalid_token" });

  const sol = await prisma.solution.findFirst({
    where: { id: req.params.id, User: { schoolId } },
    select: { id: true },
  });
  if (!sol) return res.status(404).json({ error: "not_found" });

  const rows = await prisma.solutionComment.findMany({
    where: { solutionId: req.params.id, User: { schoolId } },
    include: { User: { select: { id: true, fullName: true, username: true } } },
    orderBy: { createdAt: "asc" },
  });
  res.json(rows);
});

app.post("/api/solutions/:id/comments", auth, async (req, res) => {
  const schoolId = req.user.schoolId;
  if (!schoolId) return res.status(401).json({ error: "invalid_token" });

  const sol = await prisma.solution.findFirst({
    where: { id: req.params.id, User: { schoolId } },
    select: { id: true },
  });
  if (!sol) return res.status(404).json({ error: "not_found" });

  const S = z.object({ text: z.string().min(1) });
  const body = S.safeParse(req.body);
  if (!body.success) return res.status(400).json({ error: "bad_request" });

  const c = await prisma.solutionComment.create({
    data: { solutionId: req.params.id, userId: req.user.id, text: body.data.text },
  });
  res.json(c);
});

app.get("/api/grades_legacy", auth, async (req, res) => {
  console.log("DEBUG_GRADES user", { reqUser: req.user?.id, reqUserCap: req.user?.id });
  const rows = await prisma.grade.findMany({
    where: { userId: req.user.id },
    include: { Subject: true },
    orderBy: { date: "desc" },
  });
  res.json(rows);
});

app.get("/api/attendance", auth, async (req, res) => {
  const q = req.query;
  const where = { userId: req.user.id };
  if (q.day) {
    const from = new Date(`${q.day}T00:00:00.000Z`);
    const to = new Date(`${q.day}T23:59:59.999Z`);
    where.date = { gte: from, lte: to };
  }
  if (q.SubjectId) where.SubjectId = String(q.SubjectId);
  if (q.teacher) where.teacher = String(q.teacher);

  const rows = await prisma.attendanceRecord.findMany({
    where,
    include: { Subject: true },
    orderBy: { date: "desc" },
  });
  res.json(rows);
});

app.get("/api/alerts", auth, async (req, res) => {
  const rows = await prisma.notification.findMany({
    where: { userId: req.user.id, kind: "alert" },
    orderBy: { createdAt: "desc" },
  });
  res.json(rows);
});

app.get("/api/announcements", auth, async (req, res) => {
  const rows = await prisma.notification.findMany({
    where: { userId: req.user.id, kind: "announcement" },
    orderBy: { createdAt: "desc" },
  });
  res.json(rows);
});

// Admin endpoints: grade packs
app.get("/api/admin/grade-packs", auth, adminGuard, async (req, res) => {
  const rows = await prisma.gradeSubjectPack.findMany({
    include: { Subject: true },
    orderBy: [{ grade: "asc" }, { kind: "asc" }],
  });
  res.json(rows);
});

app.put("/api/admin/grade-packs", auth, adminGuard, async (req, res) => {
  const S = z.object({
    grade: z.number().int().min(7).max(12),
    core: z.array(z.string()).default([]),
    gradeSubjects: z.array(z.string()).default([]),
  });
  const body = S.safeParse(req.body);
  if (!body.success) return res.status(400).json({ error: "bad_request", details: body.error.flatten() });

  const subs = await prisma.subject.findMany();
  const byName = new Map(subs.map((s) => [s.name, s.id]));

  const grade = body.data.grade;

  await prisma.gradeSubjectPack.deleteMany({ where: { grade } });

  const rows = [];
  for (const n of body.data.core) {
    const id = byName.get(n);
    if (id) rows.push({ grade, subjectId: id, kind: "core" });
  }
  for (const n of body.data.gradeSubjects) {
    const id = byName.get(n);
    if (id) rows.push({ grade, subjectId: id, kind: "grade" });
  }

  if (rows.length) await prisma.gradeSubjectPack.createMany({ data: rows, skipDuplicates: true });
  res.json({ ok: true });
});

const port = Number(process.env.PORT || 3000);
app.get("/api/admin/ping", auth, requireRole("admin"), (req, res) => {
  res.json({ ok: true, role: "admin", user: req.user });
});

app.listen(port, () => console.log(`pilot_api listening on ${port}`));
