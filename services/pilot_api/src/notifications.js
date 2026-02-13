const express = require("express");

function uid() {
  return Math.random().toString(16).slice(2) + Date.now().toString(16);
}
function now() {
  return new Date().toISOString();
}

// In-memory store (MVP)
const notifications = [];

function buildNotificationsRouter({ auth }) {
  const router = express.Router();

  // GET /api/notifications?unread=1&limit=50
  router.get("/", auth, (req, res) => {
    const userId = req.user?.sub ?? req.user?.id ?? null;
    if (!userId) return res.status(401).json({ error: "unauthorized" });

    const unread = (req.query.unread ?? "").toString() === "1";
    const limit = Math.min(parseInt((req.query.limit ?? "50").toString(), 10) || 50, 200);

    let rows = notifications.filter((n) => n.userId === userId);
    if (unread) rows = rows.filter((n) => !n.readAt);

    // newest first
    rows.sort((a, b) => (b.createdAt || "").localeCompare(a.createdAt || ""));
    res.json(rows.slice(0, limit));
  });

  // POST /api/notifications/:id/read
  router.post("/:id/read", auth, (req, res) => {
    const userId = req.user?.sub ?? req.user?.id ?? null;
    if (!userId) return res.status(401).json({ error: "unauthorized" });

    const id = req.params.id;
    const n = notifications.find((x) => x.id === id && x.userId === userId);
    if (!n) return res.status(404).json({ error: "notification_not_found" });

    n.readAt = now();
    res.json(n);
  });

  return router;
}

function addNotification({ userId, title, body, data }) {
  const n = {
    id: uid(),
    userId,
    title: title ?? "Notification",
    body: body ?? "",
    data: data ?? {},
    createdAt: now(),
    readAt: null,
  };
  notifications.unshift(n);
  return n;
}

module.exports = { buildNotificationsRouter, addNotification };
