# ClassMate — QA Feature & Scope Document

> **Status:** FINAL (v2, 2026-07-21) — derived from the codebase at build 1.0.9 (233).
> Send this to every tester together with `02-TEST-CASES.md` and the credentials sheet.

---

## 1. Product summary

ClassMate is a school-management and learning app for schools in Israel (Android + iOS). It connects **students, teachers, parents, and school administration**: grades, attendance, schedules, chat, school mail, past-exam (Bagrut) libraries, practice games, and an AI study tutor ("NOVA"). The backend is a hosted API — testers never interact with it directly.

- **Languages:** English, Hebrew, Arabic, French, Russian, Pashto. Hebrew/Arabic are **RTL** — RTL layout is explicitly in scope.
- **Realtime:** typing indicators, delivered/read receipts and live updates arrive over a live connection — behavior on flaky networks is explicitly in scope.

## 2. Platforms, builds, access

| Platform | Minimum OS | How testers get the build |
|---|---|---|
| iOS (iPhone + iPad) | iOS 13.0+ | TestFlight invite link (build 1.0.9/233) — provided by us. iPad matters: tablets get a different desktop-style layout. |
| Android (phone + tablet) | Android 5.0+ (API 21) | Play testing-track opt-in link: <https://play.google.com/apps/testing/com.tonyaboud.classmate> — your Gmail must be registered by us first; send it before you start. |

The iOS App Store version (1.0.7) is **older** — do not test it; use TestFlight.

## 3. Test accounts — IMPORTANT

The QA school is a **dedicated sandbox**: "**ClassMate QA School (TESTING ONLY)**". You cannot see or affect any real school. Do anything you like inside it.

- Log in with **username** (not email) + password from the credentials sheet we send separately.
- Pre-made accounts: **1 admin, 1 teacher, 2 students (grade 10, same class "QA Class 10-A"), 1 parent** (linked to Student One).
- The **admin account can create more users in-app** (Admin → Users → Create). Creating your own teacher/student accounts **is itself a test case** — do it at least once.
- Two student accounts exist so one tester (or two devices) can test chat, receipts, typing indicators, and practice matchmaking **between** them.
- To test password reset, first (as admin) set a **real email you own** on a user, then use "Forgot password".

## 4. User roles

| Role | Can do |
|---|---|
| **Student** | Grades (published only), schedule, class materials/assignments, chat (DMs + class groups, incl. voice messages), CMail (school mail), NOVA AI tutor, Practice (solo + live matchmaking), Solutions feed, Bagrut library, private Notes, certificates, insights, notifications |
| **Teacher** | Classrooms, attendance by date, grade entry → weighted averages → publish, announcements, materials, forms/assignments, certificates per student, Bagrut, chat/CMail, NOVA (teacher variant), student insights |
| **Admin** | User management (create/edit/delete all roles), cohorts/classes, subjects, schedule management, school branding, report-card PDF export, password set/reset, announcements, CMail |
| **Secretary** | Admin subset for office tasks (cannot create user accounts) |
| **Parent** | Own children only: grades, insights, attendance, forms, school communications |

Multi-account: one device can hold several accounts via the account switcher — in scope.

## 5. Feature inventory (the test surface)

**A. Auth & account** — login (username or email), logout confirm, password reset (email link; SMS exists but test only if you have a working number on the account), consent gate + age gating, per-role onboarding slides, account switcher (add/switch/remove), biometric unlock, session expiry handling.

**B. Communication** — 1:1 DMs and classroom group chat: text, voice messages (hold to record, slide up to lock, slide left to cancel), sent/delivered/read receipts, typing indicator, reply, edit, delete for me / for everyone, react, pin; inbox actions (pin/mute/mark-unread/clear/delete/block); CMail school mail (compose with audience targeting, attachments, long-press actions); push + in-app notifications; support chat.

**C. Learning** — NOVA AI tutor (student + teacher variants, math rendering); Practice (18 subjects, grade-aware topics, solo + live matchmaking with ETA countdown); Solutions feed (subject filters, report-content flow); Bagrut past-exam library (browse, view files by kind: questions/answers/solution/advanced); class materials & assignments/forms; private student Notes.

**D. School operations** — grades (teacher entry, weighted averages, **draft vs published** — students/parents must never see drafts), attendance by date, schedule/timetable, announcements, certificates (teacher per-student flow + admin annual report-card PDF), insights dashboards, admin user management (validation, username availability check, password visibility toggle), school branding (logo + name).

**E. Cross-cutting UX** — 9 themes (light + dark families); 6 languages with full RTL (Hebrew/Arabic); tablet/desktop layout (persistent sidebar + top bar on iPad/tablets — phones get bottom tabs); Android back-button behavior (to home tab, back-again-to-exit); in-app update prompt; offline/poor-network behavior (graceful localized errors with Retry — raw technical errors are always bugs).

## 6. Out of scope

- **Manager console** (platform-owner only — unreachable with your accounts).
- **Billing / subscriptions** — not user-facing yet.
- **Web app** — this round is mobile only.
- **Active penetration testing** of the backend (a separate professional security review is scheduled). *However*: if you stumble on anything that looks like a data leak, another school's data, or an action your role shouldn't be allowed to do — **report it as Critical**.
- Load/performance benchmarking.

## 7. Known issues — do NOT re-report

1. Audience-targeting edge cases in forms/assignments authorization and duplicate class materials (known, queued).
2. Certificate PDF export polish: multi-page layout issues; footer italic font renders placeholder boxes in some locales.
3. iOS App Store listing shows v1.0.7 — expected; test TestFlight build 233.

## 8. Severity scale (use in every report)

| Severity | Meaning | Example |
|---|---|---|
| **Critical** | Data loss/leak, security hole, crash on a core flow, cannot log in | Student sees another school's grades; app crashes when opening chat |
| **High** | Core feature broken, no workaround | Voice message never sends; grades don't publish |
| **Medium** | Feature partially broken or workaround exists | Receipt shows wrong state until re-open; layout breaks on tablet |
| **Low** | Cosmetic, typo, minor UX friction | Misaligned icon, untranslated string, awkward wording |
