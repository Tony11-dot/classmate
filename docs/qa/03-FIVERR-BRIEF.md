# Fiverr — QA tester brief (copy-paste ready)

Everything between the lines below is what you paste into the Fiverr order / project brief.
Attach: `01-FEATURE-SCOPE.md`, `02-TEST-CASES.md`, the credentials sheet, and your bug-report template (or link a Google Sheet made from `05-bug-tracker.csv`).

---

## Project: Full manual QA pass on ClassMate (school app, iOS + Android)

**About the app.** ClassMate is a school-management and learning app used by students, teachers, parents, and school staff in Israel. It includes grades, attendance, schedules, chat with voice messages, school mail, an AI study tutor, practice games, and past-exam libraries. It supports 6 languages including Hebrew and Arabic (RTL). The app is going into a government-mandated technical review soon — I need real bugs found before that.

**What you get from me.**
- A dedicated sandbox school with test accounts for every role (admin, teacher, 2 students, parent) — the admin account can also create new users in-app, and doing that is part of the test.
- A feature & scope document and a structured checklist of ~140 test cases.
- Build access: TestFlight link (iOS) / Play testing opt-in link (Android — I need your Gmail address to register you first).

**Scope of work.**
1. Execute the full test-case checklist on your device(s), marking each case Pass/Fail/Blocked with notes.
2. At least one **complete session in Hebrew** (RTL layout check) — you don't need to speak Hebrew, layout/mirroring issues are visible regardless.
3. Minimum 45 minutes of exploratory testing (try to break it).
4. Chat/receipts/matchmaking cases need two accounts — both student accounts are provided; use two devices or an emulator as the second side.

**Deliverables.**
1. The completed checklist (every case marked P/F/B with notes).
2. A bug report for every failure, each containing: title, feature area, exact steps to reproduce, expected vs actual, severity (Critical / High / Medium / Low — definitions in the scope doc), device model + OS version + app build, and a **screenshot or screen recording** (recording mandatory for Critical/High).
3. A short summary: overall stability impression, the 5 worst issues, and the 3 most confusing UX moments.

**Devices needed** (tell me which you have before we start):
- Android: one mid/low-end device on Android 10–12 AND one recent device on Android 13–15 (or emulator for the second).
- iOS: iPhone on iOS 16+; iPad is a big plus (the app has a distinct tablet layout).

**Timeline.** Full checklist + reports within **3 days** of receiving access. I'm available same-day for any blocking question. A short paid re-test round of fixed bugs may follow.

**Not in scope.** Backend penetration testing, load testing, the web version. But if you ever see another school's data or an action your role shouldn't be able to do — report it immediately as Critical.

---

## Screening questions (ask BEFORE hiring)

1. "How many completed mobile-app testing orders do you have on Fiverr, and can you share one **redacted** example bug report you delivered?" → Hire only if the sample has numbered repro steps, expected-vs-actual, and device info. A screenshot dump without steps = pass.
2. "Which physical devices and OS versions will you personally test on?" → Vague answers ("all devices") = pass.
3. "Have you tested an RTL (Hebrew/Arabic) app before?" → Nice-to-have for 1 of the testers, not mandatory for all.

**Hiring shape (recommendation):** 3 testers — one Android-focused, one iOS-focused (with iPad), one covering both + RTL. Budget $100–200 each for this scope; pay for quality, and offer a bonus (e.g. +$30) for every confirmed Critical/High bug beyond the fifth — it sharply changes how hard people dig.

---

## Outreach message #1 (experienced QA sellers)

> Hi! I'm the founder of ClassMate, a school app (iOS + Android, Flutter) used by students/teachers/parents, heading into a government technical review. I need a full manual QA pass: ~140 structured test cases (provided), plus exploratory testing and per-bug reports with repro steps and recordings. Sandbox school + all test accounts provided. 3-day turnaround. Can you tell me which devices/OS versions you'd test on, and share a redacted sample bug report from a past order? I'll send the full brief right after.

## Outreach message #2 (RTL / Hebrew-market angle)

> Hi! I'm looking for a QA tester for an education app for the Israeli market (iOS + Android). The app is fully localized in Hebrew/Arabic (RTL) — a key part of the test is a full session in Hebrew checking layout mirroring, clipped text, and untranslated strings, plus a ~140-case functional checklist I provide. Test accounts and sandbox provided, 3-day turnaround. Do you have experience testing RTL apps, and on which devices? A redacted sample report would help me confirm fit.

## Outreach message #3 (two-device / realtime angle)

> Hi! I need a manual QA pass on a school communication app (iOS + Android). A core part is real-time chat: delivery/read receipts, typing indicators, voice messages, and a two-player practice mode — so I need someone who can run **two devices side by side** (or device + emulator; I provide both test accounts). Full checklist, sandbox school, and credentials provided; deliverable is a completed checklist + bug reports with recordings within 3 days. Which devices would you use, and how many app-testing orders have you completed?
