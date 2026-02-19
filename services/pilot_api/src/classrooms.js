const express = require("express");

// server.js style: buildClassroomsRouter({ auth, prisma })
function buildClassroomsRouter({ auth, prisma }) {
  if (!auth) throw new Error("buildClassroomsRouter: missing auth");
  if (!prisma) throw new Error("buildClassroomsRouter: missing prisma");

  const router = express.Router();

  // GET /api/classrooms
  // Rule 3: Only classrooms the user is a member of (even if admin).
  router.get("/", auth, async (req, res) => {
    const userId = req.user?.id;
    const schoolId = req.user?.schoolId;
    if (!userId || !schoolId) return res.status(401).json({ error: "unauthorized" });

    const rows = await prisma.classroomMember.findMany({
      where: {
        userId,
        Classroom: { schoolId }, // ensure same school as token
      },
      select: {
        role: true,
        Classroom: {
          select: {
            id: true,
            title: true,
            grade: true,
            schoolId: true,
            createdAt: true,
            Subject: { select: { id: true, schoolId: true, name: true } },
          },
        },
      },
      orderBy: { createdAt: "desc" },
      take: 500,
    });

    const out = rows
      .filter((r) => r.Classroom)
      .map((r) => ({
        id: r.Classroom.id,
        title: r.Classroom.title,
        grade: r.Classroom.grade,
        schoolId: r.Classroom.schoolId,
        subject: r.Classroom.Subject,
        role: r.role,
        createdAt: r.Classroom.createdAt,
      }));

    res.json(out);
  });

  return router;
}

module.exports = { buildClassroomsRouter };
