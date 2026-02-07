# Notifications Premium Sprint

## A) Realtime (SSE)
- API: GET /parent/notifications/stream (SSE)
- Emits: notification.created, notification.seen, unread.count
- Auth: JWT (same guard)
- Heartbeat: 15s ping
- Backpressure: drop old events if client slow (keep last 100)

## B) Mark all as seen
- PATCH /parent/notifications/mark-all-seen
- returns { updated }

## C) Undo (30s)
- PATCH /parent/notifications/undo
- server keeps last action per user (ids + timestamp) in memory (ok for now)
- later: persist to Redis

## UI (parent-web)
- Live updates on /notifications
- Toast with Undo
- Mark all button
