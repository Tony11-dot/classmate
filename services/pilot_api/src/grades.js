const express = require("express");

function buildGradesRouter({ auth, prisma }) {
  if (!auth) throw new Error("buildGradesRouter: missing auth");
  if (!prisma) throw new Error("buildGradesRouter: missing prisma");

  const router = express.Router();

  const isAdmin = (req) => Array.isArray(req.user?.roles) && req.user.roles.includes("admin");

  // GET /api/grades?classroomId=...
  router.get("/", auth, async (req, res) => {
    const userId = req.user?.id;
    const schoolId = req.user?.schoolId;
    if (!userId || !schoolId) return res.status(401).json({ error: "unauthorized" });

    const classroomId = String(req.query.classroomId || "").trim();

    // default: return user's grades (no classroom filter)
    let subjectId = null;

    if (classroomId) {
      const classroom = await prisma.classroom.findUnique({
        where: { id: classroomId },
        select: { id: true, schoolId: true, subjectId: true, grade: true },
      });

      if (!classroom) return res.status(400).json({ error: "invalid_classroomId" });
      if (classroom.schoolId !== schoolId) return res.status(403).json({ error: "forbidden" });

      
      // rule-3: classroomId filter requires membership (even for admin)
      const member = await prisma.classroomMember.findFirst({
        where: { classroomId: classroom.id, userId },
        select: { id: true },
      });
      if (!member) return res.status(403).json({ error: "forbidden" });


      subjectId = classroom.subjectId;
    }

    const where = { userId };
    if (subjectId) where.subjectId = subjectId;

    const rows = await prisma.grade.findMany({
      where,
      include: { Subject: true },
      orderBy: { date: "desc" },
      take: 200,
    });

    res.json(rows);
  });

  return router;
}

module.exports = { buildGradesRouter };
