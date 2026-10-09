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
| Export (main screen) / add-filter sheet / export options sheet | ✅ / ✅ / ✅ |
| Grade scales, Subject detail | ✅ |
| Reports | ✅ |
| Periods | ✅ (+ delete now asks first) |
| Bell schedule | ✅ |
| Solutions books admin | ✅ |

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
| Emails — reset, password changed, verification code | ✅ shared shell, dark mode, code in subject; From + Reply-To = support@classmateapp.org; in the user's language (en/he/ar/fr/ru, RTL for he/ar) |
| SMS — reset link, password changed, verification code | ✅ in the user's language |
| Reset-password page (API `/reset-password`) | ✅ new wordmark, live checks, success state; token sanitized (XSS); in the email's language (or the browser's); dead links say so up front |
| Legal site (classmate-legal: index, privacy, terms, accessibility, delete account) | ✅ shared site.css/site.js, light + dark, Hebrew RTL; text unchanged except Gmail → support@ |
| Verify-code sheet (Profile → Verify) | ✅ |
| ClassNotes reset page | ➖ separate product, own design + tests |
| Website screenshots (classmateapp.org) | ✅ re-shot from the redesigned app (new logo); WebP, 6 × ~40–85 KB |
| Website (classmateapp.org) icons, store badges, FAQ | ✅ emoji → line icons (+ theme toggle), Google Play badge live, FAQ matches the app |
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

## Round 12 (2026-10-09) — the last unpreviewed screens + Arabic/Hebrew at large text
- Previewed for the first time: Admin Periods (list, new-period sheet, delete), Solutions books
  admin, Export add-filter sheet and export options sheet — in English, Hebrew, Arabic, dark, 2× text
- Admin Periods: the bin deleted a period on one tap with no undo and failed silently — now asks
  "Delete period?" (same wording as Admin Schedule) and says when it fails; time ranges stay
  left-to-right in Hebrew/Arabic; the period badge grows with large text instead of breaking "08:00"
- New-period sheet: ran up under the status bar → stays below it; "Period" and "Time" labels line up
  and the time boxes match the dropdown's height; stacks at large text
- All 23 tall sheets (font picker, new chat, profile, emoji, export, practice…) now stop below the
  status bar instead of sliding under the clock when their content is long
- Top bar: the page-name pill caps its text size like the iOS navigation bar, and when it's long
  (Arabic, large text) the logo moves next to the menu button instead of shrinking to a speck;
  normal sizes look exactly as before
- Group chat previews and New-group chips showed "Ms.:" for "Ms. Golan" → titles keep the surname
  (Mr./Ms./Dr.) — shared `shortName()` + test
- Large text: Bagrut subject tiles cut the name off and the plan card's "resets on…" line ran off
  the edge — both fixed; whole sweep now clean in Arabic and Hebrew at 1.5× and 2×

## Round 13 (2026-10-09) — the account flows in your language + help that matches the app
- Reset / password-changed / verification-code emails and their SMS twins now come in the user's
  language (en, he, ar, fr, ru; Pashto is a pseudo locale → English). Hebrew and Arabic are laid out
  right to left; the link and the code stay left to right; no letter-spacing on Arabic
- Language = the one the app is in when asking (Forgot password sends it), else the one the app last
  reported for the account, else English. The link carries it, so the reset page matches the email
- Reset page: checks the link before showing the form — an expired, used or broken link says so right
  away (with "Get a new link" → the web app's Forgot password, and "Sign in") instead of after
  typing two passwords. Server errors carry a code so the page shows its own translated message
- Forgot-password screen: intro and expiry note were hard-coded English → translated; the SMS helper
  line was English-only in he/ar/fr/ru → translated; the result message comes back in the app's language
- Help FAQ (in-app, all 6 ARBs, and the website) said things the app no longer does — cohort join
  codes, parent link codes, "Password Requests", "Diplomas", "preferred name language", attendance
  saving by itself, "include current passwords" in export, Schedule/NOVA "in the drawer", the old
  dark-mode switch, "a code by SMS". Every answer now matches the app (labels as they appear in each
  language); deleting an account also mentions support@ (same as the legal page)
- Support assistant notes: SMS sends a link (not a code); "Join Classroom" label
- Website: emoji icons → line icons (features, FAQ groups, contact, download, theme toggle); Google Play
  badge was "Coming soon" though the app is live on Play → links to the listing
- Verify-code SMS log line no longer prints the code and number when Twilio isn't configured

## Up next (in order)
1. Every screen is ✅ or ➖. Next: on-device QA pass of build 305 (TestFlight / Play internal), then fix anything found.

## Known open items (not redesign)
- Anthropic key: the second new key is live and NOVA answers (confirmed by Tony 2026-10-09). Still
  to do: delete the old keys in the Console. If NOVA ever says "Failed to stream reply", the server
  log line `[NOVA_PROVIDER_ERROR]` names the cause
- ⚠ `railway up` is SKIPPED when nothing in the API changed — to apply a variable change alone, use
  `railway redeploy -y` (never `--from-source`, which pulls `main`)
- ⚠ Any Railway variable change redeploys GitHub `main` and drops this branch's backend — use
  `--skip-deploys`, then `railway up` from the repo root
- Apple-review demo password is committed in 4 files of the public repo
- Secretary student create/delete UI not wired
- Self-service account deletion: the API has `POST /account/delete` but the app has no button for it
  (the FAQ points to the school admin or support@)
- 11 stale failing tests (also fail on `main`)
- Composer mic/classroom bug report — waiting on repro details
