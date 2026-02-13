const express = require("express");

// server.js style: buildGradesRouter({ auth, prisma })
function buildGradesRouter({ auth, prisma }) {
  if (!auth) throw new Error("buildGradesRouter: missing auth");
  if (!prisma) throw new Error("buildGradesRouter: missing prisma");

  const router = express.Router();

  // GET /api/grades
  router.get("/", auth, async (req, res) => {
    // your auth middleware sometimes sets req.user, sometimes req.user — support both
    const userId = req.user.id;
    if (!userId) return res.status(401).json({ error: "unauthorized" });

    const rows = await prisma.grade.findMany({
      where: { userId },
      include: { Subject: true },
      orderBy: { date: "desc" },
      take: 200,
    });

    res.json(rows);
  });

  return router;
}

module.exports = { buildGradesRouter };
