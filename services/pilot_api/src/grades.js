const express = require("express");

// server.js style: buildGradesRouter({ auth, prisma })
function buildGradesRouter({ auth, prisma }) {
  if (!auth) throw new Error("buildGradesRouter: missing auth");
  if (!prisma) throw new Error("buildGradesRouter: missing prisma");

  const router = express.Router();

  // GET /api/grades
  // Optional: ?classroomId=... to filter by that classroom's subject
  router.get("/", auth, async (req, res) => {
    const userId = req.user?.id;
    const schoolId = req.user?.schoolId;
    if (!userId) return res.status(401).json({ error: "unauthorized" });

    const classroomId = String(req.query.classroomId || "").trim();

    let subjectId = null;
    if (classroomId) {
      const classroom = await prisma.classroom.findUnique({
        where: { id: classroomId },
        select: { id: true, schoolId: true, subjectId: true },
      });

      if (!classroom) {
        return res.status(400).json({ error: "invalid_classroomId" });
      }
      if (schoolId && classroom.schoolId !== schoolId) {
        return res.status(403).json({ error: "forbidden" });
      }

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
