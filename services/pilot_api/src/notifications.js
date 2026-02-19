const express = require("express");

function buildNotificationsRouter({ auth, prisma }) {
  const router = express.Router();

  // GET /api/notifications
  router.get("/", auth, async (req, res) => {
    const userId = req.user?.sub ?? req.user?.id;
    if (!userId) return res.status(401).json({ error: "unauthorized" });

    const unread = req.query.unread === "1";

    const rows = await prisma.notification.findMany({
      where: {
        userId,
        ...(unread ? { seenAt: null } : {}),
      },
      orderBy: { createdAt: "desc" },
      take: 200,
    });

    res.json(rows);
  });

  // POST /api/notifications/:id/read
  router.post("/:id/read", auth, async (req, res) => {
    const userId = req.user?.sub ?? req.user?.id;
    if (!userId) return res.status(401).json({ error: "unauthorized" });

    const id = req.params.id;

    const row = await prisma.notification.findFirst({
      where: { id, userId },
    });

    if (!row) {
      return res.status(404).json({ error: "notification_not_found" });
    }

    const updated = await prisma.notification.update({
      where: { id },
      data: { seenAt: new Date() },
    });

    res.json(updated);
  });

  return router;
}

module.exports = { buildNotificationsRouter };
