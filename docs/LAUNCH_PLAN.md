# ClassMate Launch Plan (Sessions 0–15) — Source of Truth

Rules:
- Execute sessions strictly in order (0 → 15).
- No scope additions mid-session. Only: bugfixes required to complete the session.
- Each session ends with: green checks + golden commands run + git commit.

## Session 0 — Baseline / Branch Hygiene + Golden Commands
- [ ] repo boots clean
- [ ] env templates present and documented
- [ ] installs: root + apps + services
- [ ] prisma migrate/seed works
- [ ] golden commands script exists and works
- [ ] CI-friendly: deterministic ports, env, no prompts

## Session 1 — Env / Networking / Prod Config
- [ ] dev/staging/prod env separation
- [ ] base URLs consistent (web/mobile/api)
- [ ] uploads + storage config
- [ ] CORS + cookies/token handling correct

## Session 2 — Auth / Role Resolution + Role Shells
- [x] auth flows (student/parent/teacher/admin)
- [x] role-based shells
- [x] parent-child context
- [x] dev override (local only)

## Session 3 — Typed Data Contracts + Client SDK / Repo Layer
- [ ] DTOs stable
- [ ] shared types or generated client
- [ ] repo layer used everywhere
- [ ] contracts tested

## Session 4 — Student Schedule
- [ ] schedule CRUD + view
- [ ] empty/loading states
- [ ] permissions correct

## Session 5 — Student Classrooms
- [ ] classroom list/detail
- [ ] join/leave/invite
- [ ] permissions correct

## Session 6 — Announcements + Notifications Across Roles
- [ ] announcements feed + create
- [ ] notifications contract + delivery
- [ ] mark-seen + pagination

## Session 7 — Attendance + Grades + Teacher/Admin Flows
- [ ] attendance entry + views
- [ ] grades entry + assessments
- [ ] admin overrides

## Session 8 — Solutions Feed + Uploads + Pagination/Filters
- [ ] feed (IG/TikTok style)
- [ ] search + filters
- [ ] upload to question + global upload

## Session 9 — AI Tutor (Characters/Threads/Brain)
- [ ] characters default + manage
- [ ] threads per character
- [ ] brain snapshot + rebuild
- [ ] adaptive tutoring + quizzes (Bagrut level)

## Session 10 — Admin School Management
- [ ] per-grade default subjects
- [ ] per-student overrides
- [ ] admin-as-teacher
- [ ] UI-only management

## Session 11 — Mobile UX Polish
- [ ] Apple-clean + liquid-glass dropdowns (full dropdown, searchable)
- [ ] dark mode contrast (white text)
- [ ] drawer: tap+swipe, grouped sections
- [ ] top bar layout spec
- [ ] empty/loading states everywhere

## Session 12 — Backend Hardening
- [ ] Prisma constraints/migrations/seed hardening
- [ ] auth boundaries + data isolation
- [ ] observability
- [ ] rate-limits sane + E2E bypass header

## Session 13 — Deployment / Infrastructure
- [ ] staging + prod
- [ ] TLS
- [ ] uploads
- [ ] backups

## Session 14 — QA + RC Builds
- [ ] full E2E green
- [ ] mobile RC builds
- [ ] regression checklist

## Session 15 — Final Launch
- [ ] prod deploy
- [ ] store submissions
- [ ] onboarding kit
- [ ] day-1 drill
