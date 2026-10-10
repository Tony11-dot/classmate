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
- Teachers and parents saw Announcements twice in the drawer / desktop sidebar (Core + School Tools)
  → once, in Core (found by the new desktop/iPad shots)
- Wide screens: the shot rig now renders iPad (both orientations) and desktop web through the real
  sidebar chrome — every rigged screen passes at all three sizes
- Support assistant still described the ClassNotes tool (removed from the app in build 268) and
  called the admin user list "People" (the app says "Users") → matches the app
- Tests: ClassNotes tests (feature gone since build 268) removed; the sidebar test follows the
  redesign's font weights → Flutter 58 pass / 5 known failures (was 57 / 11)
- French & Russian pass (first time; earlier sweeps were en/he/ar) — every rigged screen at 1× and
  1.3× text, no overflows. Fixed what the pictures showed:
  - Messages: "Démarrer une discussion" squeezed the title to one letter per line → when the title,
    icons and button don't fit in one row, the actions move under the title (English unchanged)
  - Student + teacher Schedule: "08:00" broke in two at large text (time column grows now); the
    count labels ("Недельное расписание", "Jour sélectionné") and "no upcoming exams" were cut off
    → wrap to two lines, tiles stay equal height
  - French day bar read "ven. 9 oct. · vendredi 9 octo…" (date twice) → "ven. 9 oct. · vendredi"
  - Russian counts: "31 урок" showed as "1 урок" (Russian's singular form also covers 21, 31…, and
    24 strings had a fixed "1"), and most lacked the 2–4 form ("2 ученика", not "2 учеников") →
    proper one/few/many forms; French showed "1 livre" for zero books (16 strings) → real number
    (+ tests)
- 32 strings had never been translated (the whole admin Permissions screen, theme editing, Support
  AI suggestions, export layout, a few notices) — Hebrew/Arabic/French/Russian admins saw English →
  translated with the app's existing terms; every locale now has every key
- Permissions screen rows and sections came from the server's English catalog → translated in the
  app by capability key (server text stays the fallback); a test reads the server catalog and fails
  if a new capability arrives without a translation
- Counts built as "number + word" ("4 классы", "0 Ученики", "1 classrooms") → real plurals in every
  language; "Объявления для Учитель" / "pour enseignant" → correct case and article
- One-word stat labels ("Непрочитанные") broke mid-word or ended in "…" in narrow tiles → shrink to fit
- Form fields: helper and error lines ended in "…" when a translation ran long (e.g. the Forgot-
  password SMS hint in Arabic) → wrap up to 3 lines, app-wide via the theme
- Web app shell: a startup failure showed a raw red stack-trace page → a card with "ClassMate
  couldn't start", Reload, support@ and the details folded away (light + dark); installed-app colour
  was the old indigo → brand blue

## Round 14 (2026-10-09) — every corner: the 49 screens no round had rendered
- New rig sweep (`test/_mk/corners_test.dart` + `corners_api.dart`, ~30 demo endpoints): student
  Assignments/Meetings/Exams/Materials/Saved questions/NOVA home/About/Practice history; Login,
  Phone link, Reorder tools, Reorder classrooms, Blocked people, New chat, CMail compose, Theme
  gallery; teacher Home/Assignments/Materials/Cohorts/Averages/Exams/Meetings/Forms/Attendance
  history/Students/Certificates + the 9 create/add screens; admin School settings/Grade scales/Bell
  schedule/Reports/Settings/Import users; secretary Home/Students; manager Schools/Managers/Bagrut/
  New school. Each in en/he/ar/fr/ru, dark, and at 1.3× / 2× text (en + ar). Found and fixed:
  - **Launch screen** (Tony's ask): just the animation on the plain theme surface — the gradient
    blobs and floating symbols around it are gone. Measured the Lottie: its resting frame (mark +
    wordmark) sat 28 px left and 5 px above the canvas centre → moved in the JSON (start frame still
    centred, the mark's slide-left keyframes and the wordmark group shifted together). Backup of
    the previous JSON: scratchpad only — it's in git history (commit before this round)
  - **About** said "v1.0.0" on every build (constructor default) → real version + build from the
    installed package ("v1.1.9 (308)")
  - **Dates with seconds** everywhere `FriendlyDate.dateTime/time` was used (meeting chips
    "10/10/2026 17:00:00", parent notification times "22:18:45", "Overdue … 23:59:00") → no
    seconds, app-wide; and the date-time keeps left-to-right order in Hebrew/Arabic (was
    "17:00 10/10/2026"). NOVA history dates were US "10/8/2026" → "08/10/2026" like the rest
  - **Meetings**: "Mid-term review was updated Not available." when a meeting was never edited →
    falls back to when it was posted
  - **Reports**: "Reported 2026-10-09" (English + ISO) → "Reported 09/10/2026", translated
  - **Hard-coded English** in every language: attendance history "1st period" → "Period 1";
    "Grade 11"; New classroom "Select cohorts… / Select students…"; Create exam "Create" and
    "Pick a date" (new key `commonPickDate`)
  - **App-bar titles with two actions** ("New Assignment" + Save draft + Publish → "New Assi…"):
    new `CmBarTitle` shrinks the title to at most 72 % before ellipsizing; used on the 9 create/edit
    screens + the two reorder screens. French "Enregistrer un brouillon" → "Brouillon", Russian
    "Сохранить черновик" → "Черновик" (the long button squeezed the title out of the bar)
  - **French** called Materials three things (Supports de cours / Documents / Ressources) → one
  - **Raw error text** ("not found" in red at the top-left) on Certificates (3 places), Blocked
    people, Manager schools, Averages compute sheet, Slot attachments, Secretary students → the
    shared illustrated `CmErrorState` (full-screen failures) or new `CmErrorBanner` with Retry
    (inline, screen stays usable)
  - **Overflows**: picker rows in Add grade (fr/ru at 1×: the "Tap to select students…" prompt
    now wraps), Forms card (View responses drops under the count at large text), Secretary and
    Manager Bagrut tiles grow with text size, teacher "Join meeting" pill wraps (ar 2×)
  - Phone-number hint read "4567 123 50 972+" in Hebrew/Arabic → left-to-right
  - Theme names in the gallery ("Par défaut du système", "ברירת מחדל של המערכת") get two lines
- Known, left as is: the Manager console (platform owner only) is English-only (fixed in round 17);
  English demo text inside Hebrew/Arabic screens keeps RTL punctuation placement (real content is
  in the school's language)

## Round 15 (2026-10-10) — every letter: the strings themselves
Audited all 2,820 strings in the five languages, plus the website and the account emails.
- **Counts read right in every language:** 31 counters said "1 students", "1 questions", "Учеников: 3"
  or used one Arabic form for every number → real plural forms (Russian one/few/many, Arabic
  1/2/3–10/11+, Hebrew "תלמיד אחד"). Covers cohorts, schedule clashes, announcement audiences,
  import rows, forms, exams, materials, lessons, CMail recipients and the "Showing X of Y" lines
- **One word for "meeting":** Russian mixed "занятие" (lesson) and "встреча"; Arabic mixed "حصة"
  (class period) and "اجتماع"; Hebrew mixed "מפגש" and "פגישה" → one term each
- **One word for "email":** Russian mixed "Email" and "эл. почта"; Hebrew mixed "אימייל" and "דוא\"ל"
- **English capitalisation:** 84 labels in Title Case ("Add Students", "Save Draft") → sentence case
  like the other 788 ("Add students"). Brand names, Privacy Policy and Face ID kept
- **Typography:** "..." → "…" everywhere; straight quotes → “ ” in English, « » with no-break spaces in
  French and Russian; ’ for apostrophes in English and French, in the app, the website and the emails;
  American spelling throughout ("Recognized", "canceled")
- **English text that bypassed translation:** Admin cohorts "No students found", "Classroom
  created!", the classroom library sheet ("Add meeting", "Create new …"), the paywall error title,
  Solutions "All questions", attachment "Open link", empty announcement body
- Hebrew "Showing X of Y" lines used four verb forms → agree with each noun; one sentence mixed
  singular and plural address → plural (Hebrew keeps its gender-neutral plural where it uses it)
- Website FAQ and app FAQ say "School tools" like the menu
- Checked: analyzer at baseline, tests at baseline, all 103 rig screens pass in en/he/ar/fr/ru and at
  2× text (en, ar); mail tests pass, API type-check clean
- Left as is then, fixed in round 16: the support assistant's knowledge base wrote "School Tools"

## Round 16 (2026-10-10) — QA round 2 + the English hiding behind the data
- **Natan's round 2 (Fiverr; Android; admin Permissions), 3 issues:**
  - #1 A secretary granted "Add / delete student accounts" could do neither. Two causes: the People
    screen showed Add and Delete to admins only (role check, not the granted capability), and the
    API's delete path read the roles *relation* as plain strings, so every secretary delete was
    refused as "not a student". Now the Students tab offers Add (role locked to Student) and Delete
    when the capability is granted, and a failed delete shows the real error instead of the "Cancel"
    label. Hardened on the way: a secretary may edit student accounts only and can no longer change
    a role or principal settings through Edit user (that was an open promotion path to admin)
  - #2 The Secretary chip felt "not clickable" and once switched itself off: only the small switch
    reacted to taps, and a pull-to-refresh rebuilt the list from the server and dropped unsaved
    toggles. The whole chip now toggles; refresh keeps the list on screen and re-applies unsaved
    toggles on top of the fresh values
  - #3 "Restore defaults" under the header puts every switch back to its catalog default; the Save
    bar then confirms. Disabled when nothing deviates
  - iOS note: builds 303–309 reached only the internal "Devs" group on TestFlight, so the external
    "QA testers" group never received them. Build 310 is in that group and submitted for beta review
    (`asc.rb distribute`, 2026-10-10)
- **English that could still reach the screen from the data layer** (round 15 covered the strings;
  this covers what the API or an empty field puts in their place): the forms API sent the literal
  words "Teacher" and "Class" for every form → it now sends the author's real name, and the client
  renders Class / Teacher / School in the app's language; empty titles, attachment names and
  captions ("Untitled", "Assessment", "Attachment", "Shared solution", "File", "Material", "Student",
  "Image"); the join-code error; the admin Reports line "X reported Y"; the grade notification body;
  the calendar export's "Teacher:"; the NOVA exam-prep prompt that is prefilled in the composer
- Support assistant knowledge base says "School tools"
- Checked: analyzer 50 (baseline), tests 66/5 (baseline), all 103 rig screens pass in en/he/ar/fr/ru
  and at 2× text (en, ar); API type-check clean; permissions + mail tests 29 pass

## Round 17 (2026-10-10) — the last English screens + the last unlabeled buttons
- **Manager console in the app's language.** The platform-owner screens (Schools, Managers, Bagrut
  library, New school, New/Edit exam, sign-out) were the only screens still written in English:
  59 new strings in he/ar/fr/ru, and the dialogs reuse the app's own Cancel / Save / Delete / Log out
  terms. User counts per role show the role name, not the API code ("STUDENT"); "3 users" and
  "2 cohorts" are real plurals; "Min/Max grade" → "Lowest/Highest grade"; the Bagrut file slots use
  the student library's names (Questions / Answers / Solution / Full solution). Two small fixes on the
  way: the "School created" toast now shows (it fired after the screen closed), and the logo button
  turns into a check mark once a logo is uploaded
- **Every icon button has a name** for screen readers and long-press: the schedule day arrows
  (student + teacher), Bagrut "Open externally", the support assistant's Close, the Manager
  add-subject, show/hide password and clear-file buttons were the last 7 of 148 without one
- Checked: analyzer 50 (baseline); tests and rig below

## Round 18 (2026-10-10) — the English behind the data, part 2 + the last unnamed controls
- **Grade labels built in code.** "Grade 7 · A" was still assembled in English in six places that
  bypass the strings file: the teacher's Create classroom student picker and its "N students in
  selected cohorts" line, the classroom header subtitle, the Add students sheet (rows, the "Add 3
  students" button — now a real plural — and "Done"), the parent-child summary in New announcement,
  the admin Cohorts student rows, and the people directory in New chat / New group / Add participants.
  The server built that last one; it now also sends the raw grade and cohort name so the app renders
  the label in its own language (search matches both). The teacher's assignment card says
  "Due <date>" in the app's language; the admin dashboard's attendance tiles say "12 records" as a
  real plural and the "G7" badge drops its Latin "G" (the number alone, next to the cohort name) —
  likewise the grade tiles on the admin Cohorts and secretary Students lists ("7", "7-9"), the
  cohort pills on the admin Edit user screen (now "Grade 7" / "Grades 7, 9" in the app's language)
  and the grade line under each child in the parent's child picker
- **Attendance notifications** ("Absence recorded", "Late arrival recorded", "Absence marked as
  excused", "Attendance updated") were English with the server's raw status word in the body. They
  now use the same template mechanism as the grade notifications: localized title and a
  "Subject • Period 3 • Absent" body built from the app's own attendance terms
- **Three forgotten strings**: the forward sheet's "Recent chats" / "Other chats" headers, the Bagrut
  preview error ("Unable to preview this file…") and the Create classroom validation toasts ("Enter a
  classroom name." / "Select a subject." / "Error: …")
- **Names for the last icon-only controls** that weren't `IconButton`s (so round 17's sweep missed
  them): the school-settings grade stepper's − / + ("Decrease" / "Increase"), NOVA's Send and
  attachment ×, the chat composer's cancel-reply × and discard-recording bin, voice-note and video
  play/pause, the "jump to latest" chat pill and the theme card's ⋯ menu. 19 new strings in
  he/ar/fr/ru
- Left as is: `practice_mode_specs.dart` keeps English `label/subtitle/flow/bestFor` fields that
  nothing renders (the screens use the localized `practiceModeLabel/Description`); the English
  `title/body` fallbacks on templated notifications and announcements are log-only
- Checked: analyzer 50 (baseline); API `tsc` clean; tests and rig below

## Round 19 (2026-10-10) — the practice catalog, OS banners and error toasts in the app's language
- **Practice topics.** The grade-aware topic catalog (231 topics across 18 subjects — "Counting",
  "Human body systems", "The Cold War"…) showed its English labels in every language; only 58 had
  strings. Every topic now has he/ar/fr/ru, and the picker, the session header, history and saved
  questions all read through the same `localizedPracticeTopicSegment`
- **OS notification banners.** The system notification (and the in-app snackbar) for a synced event
  used the English log fallback ("New grade posted in Math") even though the in-app list was
  localized. Both now share the Notifications screen's text (`notification_text.dart`); the Android
  channel is "ClassMate updates" in the app's language and "+2 more" is a real plural
- **API error toasts.** The fallback text for a failed request with no usable server message ("Your
  session has expired…", "You don't have permission…", 5xx) was English in every toast and banner
  that prints the error. The API layer now reads the UI language the app root sets on it, so every
  `'$e'` comes out localized. Server-generated messages (NestJS validation) still arrive in English
- **Small ones**: the admin Cohorts empty state ("No grade 9 students found"), the PDF viewer's
  "Unable to preview" line, the form builder's default "Option 1 / Option 2" choices, and the
  practice session no longer bakes an English "solution unavailable" sentence into a question (the
  view shows its own localized line; history hides an empty explanation block). 245 new strings in
  he/ar/fr/ru
- Left as is: the `novaPlans` specs in `nova_plan_models.dart` and the repository's "Week Schedule"
  title — nothing renders them
- Checked: analyzer 50 (baseline); tests and rig below

## Round 20 (2026-10-10) — the pseudo-locale leak run
- **New check.** The shot rig can now run every screen in the `ps` pseudo-locale with
  `--dart-define=LEAK=true`: every localized string renders wrapped in ‹‹…››, so any rendered Latin
  text without the wrapper is either data or hard-coded English. 103 screens → 69 reports, almost all
  mock data (names, course titles, chat text) or older rig tests that run in English. Four were real:
- **Notification section pill / filter** showed the server's raw type ("NEW_ASSIGNMENT", "new_exam")
  for everything except grades/attendance/practice/solutions. Every server kind now maps to the
  section's own name (Assignments, Exams, Messages, Classrooms, Forms, Materials, Meetings,
  Certificates, Announcements, Reports, NOVA); unknown values are humanized instead of shouted
- **Theme gallery** section headers "CUSTOM / LIGHT / DARK" were literals → the Settings strings
- **Bagrut subjects** had English + Hebrew names only, so ar/fr/ru saw English ("Hebrew Expression",
  "Bible (Tanakh)") → names in all five languages; the subject search matches any of them
- **Export sheet** language chips said "EN / AR / HE / FR / RU" → the language's own name, like the
  Settings picker
- Left as is: `navBagrut` stays "Bagrut" in the pseudo-locale (proper noun, the generator skips it);
  the PDF viewer, About and Support show the support address as is; hint URLs and font names are
  not strings to translate
- Checked: analyzer 50 (baseline); tests and rig below

## Round 21 (2026-10-10) — every pixel in Hebrew and Arabic: the RTL sweep
- **New check.** Every physical `left` / `right` in the widget tree was listed (asymmetric
  `EdgeInsets.fromLTRB`, `EdgeInsets.only(left|right)`, `Alignment.centerLeft`, `BorderRadius.only`,
  `Border(left:)`, `Positioned(right:)`) and each one judged: does it mark a *side of the screen* or
  the *start / end of reading*? 94 sites → 41 files changed, everything else intentional.
- **38 card, header and pill insets** were written for English — wider on the left where the text
  starts, tighter on the right where the chevron or action sits. In Hebrew and Arabic they came out
  backwards: the chevron got the wide gap and the text was crowded against the edge. All are now
  `EdgeInsetsDirectional`: teacher Attendance / Meetings / Cohorts / Forms / Classrooms / Classroom
  detail / Create form / Announcement audience tree / Schedule rows / Grades header, admin Cohorts /
  Schedule / Export chips, manager Schools / Managers / Bagrut exams, Bagrut exams, Classrooms list +
  hero card, Blocked people, NOVA thinking row + suggestion chips, Support sheet, Settings theme
  headers, drawer section headers, the student picker sheet, the exam countdown pill, the assignment
  attachment chip, the chat bubble's own text inset
- **Colour edges** on the admin schedule's period chips and NOVA's blockquote bar were drawn on the
  physical left; they now sit on the start side (right in Hebrew)
- **Corner radii that mark a side**: the drawer's rounded edge, the message-request "first message"
  bubble, the chat info-page preview bubble and the reply quote bar now round start/end corners. The
  chat bubbles themselves and the support sheet already mirrored (tails placed by `isMine != rtl`)
- **Overlays**: the media bubble's timestamp, the theme tile's ✓ badge and its ⋯ affordance, the chat
  scroll-to-bottom unread badge, the attachment-remove ✕ and the PDF badge pin to the end/start
  corner instead of the physical right/left
- **Alignment**: the schedule's attachment / attendance pills, the composer's switcher and the typing
  bubble align to start (the typing bubble keeps its 64 px breathing room on the end side, and its
  three dots keep their gap in RTL — the last dot used to touch the middle one)
- Left as is: forced-LTR rows (time ranges, phone number, class codes, math, code blocks), gradients,
  the bottom nav bar's indicator (physical by design), the composer's drag bubble (follows the finger)
- Checked: 81 Hebrew shots before/after → 14 screens changed, every change a mirror shift (side-by-side
  diffs reviewed); analyzer 50 (baseline); tests +66 −5 (baseline)

## Round 22 (2026-10-10) — the server's English, in the app's language + the stress sweep
- **The last English letters.** The API answers every refused request with developer wording
  (`{ "message": "Student not onboarded" }`, 331 distinct strings) and the app's error wrapper
  showed any non-technical one as is — so Hebrew and Arabic toasts said "Invalid or expired code",
  "You have already submitted this form", "Only the sender can edit this message". New
  `core/http/server_messages.dart` maps 275 of the 331 strings — every one a person can reach from
  the UI — to 108 app strings in all five languages (families collapse: nine "no school" wordings → one, 40
  permission wordings → "You don’t have permission to do that", the not-found set → one per thing).
  Values carry over: "Please wait 30s…" → a real plural, password length, grade label, email,
  username, solution count
- **Rule** (`CMApiException.friendlyMessage`): known text → app string; unknown text (validation
  wording like "studentId is required") → shown raw only in an English UI, the status-based
  message everywhere else; framework text ("Unauthorized", "ThrottlerException…") never
- **Every path now goes through it**: the messages API's group-join and the classrooms and NOVA
  repositories used to throw "label failed (400): {…}" or the raw server text — all three throw the
  same sanitized exception now; the form-submit toast and the manager console's "Failed: …"
  replies are localized; the password-change screen reads its `WRONG_PASSWORD` marker from the
  body instead of the shown text
- **Stress sweep.** All 81 rig screens were re-shot at 1.3× text (English and Hebrew), on iPad
  (1366×1024) and on desktop (1440×900). Large text: clean. Wide screens: one real overflow — the
  admin Import users grade dropdown spilled 6 px past its cell → `isExpanded`
- Left as is: the forgot-password reply (the server already answers in the user's language,
  round 13); class-validator arrays (already the generic message); the 56 developer-only
  validation strings ("studentId is required") the UI prevents before sending
- Checked: new `test/core/server_messages_test.dart` (families, values, unknown text, the
  English-only rule); analyzer 50 (baseline); tests +73 −5 (baseline +7)

## Round 23 (2026-10-10) — stress pass 2: the long languages, dark mode, wide RTL
- **Large text in Arabic, French and Russian** (1.3×, all 81 rig screens): Arabic clean; French
  and Russian both broke the same row — the teacher's Add material "Add link / Add file" buttons
  ("Ajouter un lien / Ajouter un fichier") overflowed 22 px and 53 px → the pair wraps to a
  second line when it must (no change when it fits)
- **Hebrew on iPad and desktop**: the sidebar, inbox rows, hero cards and quick actions all mirror;
  no overflow
- **Dark mode sample** (Settings, Attendance, NOVA, themes, login, the Hebrew chat): contrast and
  bubble colours hold; nothing to change
- **NOVA's stream errors** ("NOVA is temporarily unavailable." from the server's `error` event)
  now go through the round-22 mapper like every other server message
- **Rig**: button, chip, tab, input and dialog text styles now carry the Hebrew/Arabic fallback
  fonts, so every RTL shot is legible (phones were always fine — the rig has no system fallback)
- Checked: dead-end controls (none beyond intentional tap-swallowers); emails and the reset page
  already render `dir="rtl"` (round 13); analyzer 50 (baseline); tests +73 −5 (baseline)

## Round 24 (2026-10-10) — one icon family + the last 18 rig screens leak-checked
- **Icons.** The app draws its icons from Material's rounded family; 17 controls still used the
  plain set (`Icons.add` on nine "Add" buttons, the form builder's radio/checkbox placeholders,
  the password eye, the PDF viewer's open-in-browser, a close ✕). All rounded now — one stroke
  style everywhere; nothing else changes
- **Leak check closed.** The seven older rig tests (schedule, grades, NOVA, classrooms, deck,
  teacher, more — 18 shots) didn't honor the locale define, so round 20's pseudo-locale pass
  never saw them. They do now; the ‹‹…›› run over them reports mock data only (names, chat
  text, subjects, "Period 1 · 90 min" labels from the fixtures). All 95 rig screens are covered
- Measured and left as is: corner radii — the 14/18/20/24 values outside the token scale are
  per-screen choices from rounds 1–12 (chat bubbles, chips, cards) and a mass change would be a
  redesign, not a fix; no Cupertino icons anywhere; elevations already come from the tokens
- Checked: analyzer 50 (baseline); tests +73 −5 (baseline)

## Round 25 (2026-10-10) — the accessibility audit: names, tap targets, signal colours
- **Audit.** The rig now evaluates Flutter's three accessibility guidelines on every shot (WCAG
  text contrast, 44 pt tap targets, unlabeled tap targets) and prints `A11Y [screen]: …`. The
  first English/light pass over 77 screens flagged 135 nodes on 28 screens: 50 contrast, 42
  tap-target, 43 unlabeled
- **Names (43 → 0).** The seven shell FABs and the Classrooms FAB had no accessible name (VoiceOver
  said "button") — each now carries its screen's existing action string as the tooltip (New
  announcement, Create exam, Add grade, Create form, Schedule meeting, New assignment, Add material,
  Create classroom). The 20 theme tiles announce their name and selected state (the caption under
  the swatch is excluded so it isn't read twice). Admin schedule grid cells say "Monday, Period 3"
  or "Monday, Period 3: empty" (2 new keys × 6 locales). Permissions role chips are one node —
  name, state, tap — instead of a nameless switch beside a label. The login screen's tap-anywhere
  keyboard dismissal is out of the tree
- **Tap targets (42 → 24), visuals kept.** Forgot-password row 28 → 44 pt; attachment pills (14
  screens) keep their 34 pt look inside a 44 pt hit area; the school-settings grade steppers get a
  44 pt hit circle around the same 34 pt disc; import toolbar chips 37 → 44 via invisible padding;
  parent-notifications filter pills and the announcements Received | Published toggle are 44 pt
  (the toggle's glass rim went 4 → 2 so the pill stays 48 tall); the Practice "Details" ⓘ is 44
  wide with the glyph where it was. Left alone: Material-standard 40 pt segmented and tonal
  buttons, the 32 pt inline "Create new exam", the 30 pt "No parent" chip in the import grid, the
  40 pt schedule date pill
- **Contrast — 2 real, 48 not.** 28 flags are the bottom-navbar labels (off-limits) and 1 its
  badge. 19 are measurement artefacts: the guideline takes the most common "dark" colour inside
  the text rect, and at 1× that is an anti-aliased blend (#C7CBD0, #DFE3E8…) or a card edge, not
  the text — a theme probe (`test/_mk/probe_test.dart`) shows the real pairs: onSurfaceVariant on
  surface 8.9:1, tonal buttons 13:1, helper texts 8.5:1. The two real ones were the signal
  tokens: success green #12935B and attention amber #B4710F sat at 3.7:1 on light surfaces (and
  white on them at 3.9:1). Light values are now #0F7D4D / #99600A — ≥4.6:1 as text on every light
  surface tint and ≥4.9:1 for white on the fill; dark values unchanged
- Also: the custom chips, pills and toggles built on GestureDetector (`_FilterChipItem`,
  `_FreqChip`, `_Pill`, `_ViewToggle`) now declare button / selected / enabled semantics
- Checked: analyzer 50 (baseline); tests +73 −5 (baseline); rig re-audit over the 23 touched
  screens: 0 unlabeled, no overflow; before/after pixdiff shows only the intended deltas

## Phase 2 (started 2026-10-10) — role by role, tab by tab
Tony's brief: every role (6), every tab of each role, every button / text / div made better, with
the **chrome rule**:
1. **Navbar tabs** (the role's bottom nav) — shell top bar + navbar.
2. **Drawer tabs** (Core / School Tools / Account entries) — shell top bar (☰ · logo · pill), navbar
   hidden.
3. **Sub-screens** (anything entered from another screen: a detail, an editor, a picker) — no shell
   at all: no logo, no pill, no navbar. The screen's own bar only — the glass back button + bold title
   that assignment / announcement / meeting detail already use. No stock Material `AppBar`.

Measured 2026-10-10: 61 screens still use a stock `AppBar` (3 use the glass detail bar); 7 shell
routes are sub-screens but keep the shell bar (`/admin/periods`, `/teacher/averages`, …). Rig: the
text-scale 1.5×/2.0× and phone-landscape sweeps over all 81 locale-aware screens are clean (0
overflows), so the per-screen work is chrome + polish, not layout rescue.

**Per-screen checklist:** `docs/PHASE2_CHECKLIST.md` — one row per reachable screen with Chrome /
Bar / Polish ticks; updated every round.

**Foundation (Round 26):** `CmSubBar` in `lib/ui/widgets/cm_sub_bar.dart` — a `PreferredSizeWidget`
drop-in for `Scaffold.appBar` (glass 44 pt back button, titleLarge w900 title, optional subtitle,
actions, optional `bottom`), transparent, no elevation; `_hideTopBarForRoute` extended for in-shell
sub-screens. Then each role below is one round: chrome check per route → sub-screen bars → polish.

| Role | Navbar tabs | Drawer tabs | Sub-screens (own bar) | Status |
|---|---|---|---|---|
| Student | Schedule · Classrooms · Practice · Insights · NOVA | Messages, Attendance, Grades, Assignments, Materials, Solutions, Bagrut, Meetings, Announcements, Notifications, Exams, Forms, Saved questions, Certificates, CMail · Profile, Plans, Settings, Support, About | assignment ✓ · meeting ✓ · announcement ✓ · exam · form · notification · classroom · chat · message request · new group · practice session/history/review · solutions subjects/books/pages/questions · bagrut list/exam/file · certificate · cmail compose/detail · note editor · reorder tools · classroom order · theme gallery · forgot password | ☑ R26 (build 320) |
| Teacher | Schedule · Classrooms · Announcements · Insights · NOVA | Messages, Workspace, Cohorts, Attendance, Grades, Notifications, Assignments, Materials, Meetings, Solutions, Bagrut, Students, Exams, Certificates, Forms, CMail · Account | classroom detail/analytics · new announcement · create form · form responses · create/edit exam · exam grades · add grade · slot attachments · add material/meeting/assignment (+ classroom variants) · assignment detail · attendance mark · student detail · averages · create classroom · student grade detail | ☑ R27 (build 321) |
| Parent | Home · Schedule · Overview · Messages · Announcements | Attendance, Grades, Exams, Certificates, Assignments, Meetings, Materials, Notifications, CMail · Account | child picker · the shared lifedoc details · chat | ☑ R28 (build 322) |
| Admin | — (drawer only) | Dashboard, People, Cohorts, Schedule, School, Grade scales, Permissions, Reports, Certificates, Export, Students, Settings, CMail · Messages, Announcements, Notifications · Account | periods · import users · cohort detail · add period · edit user · subject detail · school form · certificates per student | ☑ R29 (build 322) |
| Secretary | — (drawer only) | Home, Schedule, People, Cohorts, Certificates, Announcements, Messages, Export, CMail · Account | student editor · cohort detail · export sheet | ☑ R30 (build 322) |
| Manager | — (console) | Home: Schools · Managers · Bagrut exams | school form · exam form · bagrut manage | ☐ R31 |

Kept as specialised full-screen surfaces (own dark/overlay bars, not converted): chat media preview,
image viewer, video trimmer, NOVA chat and chat threads (message bars).

## Round 26 (2026-10-10) — Phase 2 foundation + the Student role
- **`CmSubBar`** (`lib/ui/widgets/cm_sub_bar.dart`): the one bar for sub-screens — 44 pt glass back
  button, titleLarge w900 title (a heading for screen readers), optional subtitle, the screen's
  actions, optional bottom strip; transparent, no elevation, its own Material, drop-in for
  `Scaffold.appBar`. It is the bar assignment / announcement / meeting detail already had, shared
- **Student sub-screens on it (29 bars in 25 screens):** exam detail (3 states), form detail (3),
  notification detail, message request, new group, practice history + session review, solutions
  books / filters / questions / manage books, Bagrut exams + exam + file viewer, certificates editor
  + per-student page, CMail compose + detail, note editor, reorder tools, reorder classrooms, theme
  gallery, forgot password — plus New chat and Blocked people, which had hand-made chevron rows.
  Titles, actions (Send, Save, Reset, delete, open-externally…), close-vs-back and custom back
  handlers all carried over by a transformer (`scratchpad/subbar.py`) that refuses anything it
  can't map, so nothing was dropped silently
- Solutions questions title no longer ends in a dangling "•" before a book is chosen
- Rig: 12 Student sub-screens added to `corners_test` (exam/form/notification detail, message
  request, new group, 4 solutions screens, Bagrut exams, CMail detail, note editor); `sheet.py`
  builds a contact sheet per role (25 tabs / 23 sub-screens reviewed in two images)
- Chrome check, Student: 5 navbar tabs and 20 drawer tabs keep the shell; every sub-screen is now
  shell-free with the shared bar. Nothing in-shell needed hiding for this role
- Measured and left: at 2.0× text the hero stat tiles on Schedule / Classrooms / Grades break
  words mid-way ("Selecte d day") — no clipping, but worth a stacked layout later
- Checked: analyzer 50 (baseline); tests +73 −5 (baseline); rig: all converted screens render,
  no overflow

## Round 27 (2026-10-10) — the Teacher role
- **19 stock bars → `CmSubBar`:** add assignment / grade / material / meeting (+ the three
  classroom-scoped variants), create classroom (close ✕), create exam, create form, form responses,
  exam grades, assignment detail, new announcement, slot attachments (keeps its subtitle strip),
  student detail (avatar title), student grade detail, averages, practice analytics. Two-line titles
  and the avatar title ride along as `titleWidget`
- **Chrome:** Averages is a sub-screen that lived in the shell with two bars — the shell bar is now
  hidden there (`_hideTopBarForRoute`). The 5 navbar tabs and 16 drawer tabs keep the shell
  (reviewed on the Teacher contact sheet: 21 tabs, 10 sub-screens)
- `CmSubBar` titles shrink before they ellipsise (`CmBarTitle`, min 64 %) so "New assignment"
  stays whole beside Save draft · Publish
- Checked: analyzer 50 (baseline); tests +73 −5 (baseline); rig: 10 sub-screens + 4 navbar tabs +
  teacher rig, no overflow

## Round 28 (2026-10-10) — the Parent role
- **Chrome verified** on a 14-screen Parent contact sheet (12 shared tabs rendered as PARENT were
  added to the sweep rig): the navbar shows only on Home · Schedule · Insights · Messages ·
  Announcements; every drawer tab keeps the shell bar with the "Viewing as ‹child›" strip; the
  parent's sub-screens are the shared details, all on `CmSubBar` since R26; chat keeps its bar
- **One term per concept:** the Parent home tool said "Diplomas" while the drawer, the screen and
  every other role say "Certificates" — it is Certificates now (the stray key is gone from all six
  locales)
- Checked: analyzer 50 (baseline); rig: 13 parent shots, no overflow

## Round 29 (2026-10-10) — the Admin role
- **The example Tony gave:** Import users (Admin settings → Import people) had a stock Material
  bar with a tab strip. It is on `CmSubBar` now, the Grid | CSV tabs riding as its bottom strip
- **Hand-made chevron rows → the bar:** Edit user (monogram + name as the title), Add user (role
  as the title), Add students to a cohort (cohort name as subtitle, the Add/Skip action in the
  bar), Add / edit period, Subject detail (subject as title, "School settings" as subtitle — the
  breadcrumb pill is retired, the back button is the way back), Cohort detail and Periods (stock
  bars). Each of these pages had drawn its own back arrow because it had no bar
- **Chrome:** Periods is a sub-screen in the shell (pushed from Admin settings) and showed the
  shell bar above its own — hidden there now. Admin has no navbar; the 16 drawer tabs keep the
  shell bar (Admin contact sheet: 11 tabs, 8 sub-screens)
- Secretary and Manager stock bars were converted in the same pass and land in their own rounds
- Checked: analyzer 50 (baseline); rig: all admin sub-screens render on the bar, no overflow

## Round 30 (2026-10-10) — the Secretary role
- **Chrome verified** (Secretary contact sheet): no navbar; Home, Students, Schedule and the other
  drawer tabs keep the shell bar. The secretary's pushed pages are the admin ones converted in R29
  (edit user, add students, cohort detail, export sheet) plus the cohort students page in the
  Students tool, whose stock bar (cohort name + average pill) is now `CmSubBar` with the pill as its
  action
- Checked: analyzer 50 (baseline); rig: s-home, s-students, no overflow

## Up next (in order)
1. On-device QA pass of build 322 (TestFlight / Play internal). Natan retests Permissions on
   Android and, once beta review clears, on iOS via the external group (310 is in it, waiting for
   Apple's beta review).

## Known open items (not redesign)
- Anthropic key: the second new key is live and NOVA answers (confirmed by Tony 2026-10-09). Still
  to do: delete the old keys in the Console. If NOVA ever says "Failed to stream reply", the server
  log line `[NOVA_PROVIDER_ERROR]` names the cause
- ⚠ `railway up` is SKIPPED when nothing in the API changed — to apply a variable change alone, use
  `railway redeploy -y` (never `--from-source`, which pulls `main`)
- ⚠ Any Railway variable change redeploys GitHub `main` and drops this branch's backend — use
  `--skip-deploys`, then `railway up` from the repo root
- Apple-review demo password is committed in 4 files of the public repo
- Self-service account deletion: the API has `POST /account/delete` but the app has no button for it
  (the FAQ points to the school admin or support@)
- 5 stale failing tests, all practice text repair (bare LaTeX / code-tail heuristics the code
  doesn't do); also fail on `main`
- Composer mic/classroom bug report — waiting on repro details
