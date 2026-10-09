# UI Redesign — Progress Sheet

Branch `feat/ui-overhaul-phase0` (unmerged → fully revertable). Rules: visuals only; same info,
functionality and navigation unless 100% better; bottom navbar untouched. Shipped to TestFlight,
Play internal, web and Railway — never production.

Status key: ✅ redesigned by hand · 🎨 app-wide polish only (theme, shadows, search bar, colours) ·
⬜ untouched · ➖ intentionally left (viewer/system screen, nothing to redesign)

Update this file in the same commit as each screen's redesign.

## App-wide (reaches every screen)
- ✅ Design tokens (`CmTokens`: shadows, radii, motion, good/warn colours) + `CmPress` tap feedback
- ✅ Theme: cards, sheets, dialogs, snackbars, chips, tabs, inputs
- ✅ All 50 search bars → `CmSearchField`; code entry → `CmCodeField`
- ✅ Chat composer (Instagram style) + WhatsApp-style bubble timestamps
- ✅ Shared surfaces `lib/ui/widgets/cm_surfaces.dart`: `CmCard`, `CmIconTile`, `CmPill`, `CmEmptyState`, `CmReorderTile` + `cmReorderProxy`, `CmDateStub`, `CmIconAction` (40px footer action), `CmSectionHeader`, `CmMonogram` (stable-colour initials avatar), `CmFormSection`/`CmFormSectionHeader`, `CmPickerRow`, `CmFileRow` — use these for new redesigns
- ✅ Top bar same colour as screen; bigger logo; sheets open above the nav bar

## Student
| Screen | Status |
|---|---|
| Schedule | ✅ |
| Classrooms home / classroom detail | ✅ / ✅ |
| Grades, Exams, Exam detail | ✅ |
| Assignments, Meetings, Attendance | ✅ |
| Announcements, Notifications | ✅ |
| Forms (form detail) | ✅ |
| Insights | ✅ |
| Practice setup / session / results | ✅ |
| Practice history / review / saved questions | ✅ |
| NOVA home / NOVA chat | ✅ / ✅ (empty state) |
| Solutions home | ✅ |
| Solutions books / pages / questions / subject | ✅ / ✅ / ✅ (not previewed: flow state) / ➖ (wraps Solutions home) |
| Bagrut home | ✅ |
| Bagrut exams list / exam | ✅ / ✅ |
| Certificates home / list | ✅ / ✅ |
| Student materials | ✅ |
| Student notes editor | ✅ |

## Shared (all roles)
| Screen | Status |
|---|---|
| Messages inbox | ✅ |
| Message thread (header, request/pending banners, info sheet) | ✅ |
| New chat / new group | ✅ / ✅ |
| Message request / blocked people | ✅ / ✅ |
| CMail inbox | ✅ |
| CMail detail / compose | ✅ / ✅ |
| Profile | ✅ |
| Settings | ✅ |
| Plans (billing) | ✅ |
| Support | ✅ |
| Login | ✅ (already polished) |
| Forgot password / phone link | ✅ / ✅ |
| Onboarding | ✅ (was already polished; aligned to shared card/loader) |
| Drawer tools order / classroom order | ✅ |
| Image viewer / PDF viewer / video trimmer / media preview / splash | ➖ |

## Teacher
| Screen | Status |
|---|---|
| Home, Classrooms, Classroom detail, Schedule | ✅ |
| Grades, Attendance, Meetings | ✅ |
| Forms list / create / responses | ✅ |
| Insights / New announcement | ✅ / ✅ |
| Add grade / assignment / material, Create classroom / exam | ✅ (shared `CmFormSection`, `CmPickerRow`, `CmFileRow`) |
| Materials list | ✅ |
| Exams, Assignments | ✅ |
| Assignment detail, Exam grades | ✅ |
| Student profile, Student grade detail, Averages, Analytics | ✅ |
| Slot attachments | ✅ |
| Classroom add assignment / meeting / material | ✅ |
| Attendance history, Cohorts | ✅ |

## Admin / Secretary
| Screen | Status |
|---|---|
| Dashboard, People, Permissions, Cohorts, Schedule | ✅ |
| Secretary home, Secretary students, Student detail | ✅ |
| Students hub | ✅ |
| Settings | ✅ |
| Edit user | ✅ |
| Import users | ✅ |
| School settings (info, subjects, bell tab) | ✅ |
| Export (main screen) / export options sheet | ✅ / ✅ (sheet not previewed) |
| Grade scales, Subject detail | ✅ |
| Reports | ✅ |
| Periods | ✅ (not previewed: private data provider) |
| Bell schedule | ✅ |
| Solutions books admin | ✅ (not previewed: loads via raw HTTP) |

## Parent
| Screen | Status |
|---|---|
| Parent home | ✅ |
| Parent notifications | ✅ (matches student notifications) |

## Manager
| Screen | Status |
|---|---|
| School form, Bagrut exam form | ✅ |
| Schools, Managers, Bagrut exams, Bagrut manage | ✅ |

## Outside the app (2026-10-09)
| Surface | Status |
|---|---|
| Emails — reset, password changed, verification code | ✅ shared shell, dark mode, code in subject; From + Reply-To = support@classmateapp.org |
| Reset-password page (API `/reset-password`) | ✅ new wordmark, live checks, success state; token sanitized (XSS) |
| Legal site (classmate-legal: index, privacy, terms, accessibility, delete account) | ✅ shared site.css/site.js, light + dark, Hebrew RTL; text unchanged except Gmail → support@ |
| Verify-code sheet (Profile → Verify) | ✅ |
| ClassNotes reset page | ➖ separate product, own design + tests |
| Website screenshots (classmateapp.org) | ✅ re-shot from the redesigned app (new logo); WebP, 6 × ~40–85 KB |
| Website demo video | ✅ new white mark in both logo moments; re-encoded (10.9 MB, fast start); WebP poster |
| Pitch deck (~/Desktop/CM/CM_Pitch.pptx + PDF) | ✅ all 20 phone mockups re-shot from the redesigned app (same 3D outline + shadow); backup of the previous deck in ~/Documents/ClassMate docs/CM-backup-2026-10-09/CM_Pitch.pre-screens.* |

## Fixes found while re-shooting (2026-10-09, round 11)
- Schedule header: "Next up" and "Upcoming exam" get full rows — on a 402 pt iPhone both were cut
  off ("08:00–08:45…", "13/10/20…"); the two counts stay side by side
- Chat bubbles stripped every comma from messages, reply quotes and NOVA prompts — fixed (+ test)
- NOVA answers: punctuation (and the space) after inline math is glued to it, so a line can't
  start with a lone "," or a stray space (LTR only; RTL unchanged)
- Admin dashboard stat tiles overflowed by 2.4 pt on a standard iPhone (fixed-ratio grid) — now
  content-sized two columns
- Hebrew/Arabic (RTL): chat + inbox times were English "AM 9:07" (flipped) → 24-hour "09:07"
  outside English, day chips/"Yesterday" localized; schedule time ranges showed reversed
  ("08:45–08:00") → kept left-to-right; English messages in the Hebrew app (and vice versa) read
  in their own direction, so punctuation stays at the end; previews isolate name + text
- Chips (choice/filter) and popup-menu items used the system font instead of the app font the
  user picked — theme now passes the font, like buttons and tabs
- Parent home tool tiles clipped the "No child linked yet" note on a standard iPhone — tiles keep
  their shape but never get shorter than their content
- Large system text (checked every rigged screen at 1.3×, 1.5×, 2×): Settings header, NOVA's
  "can make mistakes" line, grade badges, Solutions subject tiles and the parent child picker
  overflowed — they now wrap or grow; look unchanged at normal size. (Bottom nav untouched by rule.)
- Marketing shots come from a local rig (real AppShell + screens, demo data, fake HTTP via
  `http.runWithClient`) kept outside git; re-run it to refresh the site/video/deck shots

## Up next (in order)
1. Every screen is ✅ or ➖. Next: on-device QA pass of build 303 (TestFlight / Play internal), then fix anything found.

## Known open items (not redesign)
- Anthropic key: new key is live on Railway (2026-10-09). Still to do: confirm NOVA answers, then
  delete the old key (not in the "ClassMate" Console org — check other orgs/workspaces)
- ⚠ Any Railway variable change redeploys GitHub `main` and drops this branch's backend — use
  `--skip-deploys`, then `railway up` from the repo root
- Apple-review demo password is committed in 4 files of the public repo
- Secretary student create/delete UI not wired
- 11 stale failing tests (also fail on `main`)
- Composer mic/classroom bug report — waiting on repro details
