# UI Features TODO (Tony)

## Mobile (Flutter) — must-fix
- Drawer opens (tap + swipe)
- Dark mode text is white
- Top bar layout: centered “ClassMate” title (bold, capital M) + current tab title elsewhere
- Drawer grouped into 3 sections:
  - Core (bottom-nav): Schedule / Classrooms / AI Tutor / Insights / Solutions
  - LifeDoc: Attendance / Grades / Alerts / Notifications / ...
  - Profile: Profile / Settings / Customization / Logout
- Solutions feed: TikTok/IG-like
  - searchable “liquid glass” dropdown filters (full dropdown glass, not only field)
  - like/comment (optional anonymous)
  - per-solution “Upload for this question” + global “Upload to any question”
- Settings customization restored/expanded:
  - ~6 distinct presets + light/dark/system
  - accent dropdown swatches
  - radius + density + typography/text scale + motion
  - a few more knobs (elevation/border/card opacity)
- Dropdown field size matches text boxes
- Real flows wired (registration/login + real empty states)
- Per-school admin role UI (admins can act as teachers)

## Admin Web (Next) — keep passing E2E
- Attendance page stable (session load + bulk save)
- Remove debug noise, keep trace/report only on failure
