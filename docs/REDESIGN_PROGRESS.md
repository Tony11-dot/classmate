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
| Solutions books / pages / questions / subject | 🎨 / 🎨 / 🎨 / ➖ (wraps Solutions home) |
| Bagrut home | 🎨 |
| Bagrut exams list / exam | ✅ / ✅ |
| Certificates home / list | ✅ / 🎨 |
| Student materials | 🎨 |
| Student notes editor | 🎨 |

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
| Support | 🎨 |
| Login | ✅ (already polished) |
| Forgot password / phone link | 🎨 |
| Onboarding | ⬜ |
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
| Students hub | 🎨 |
| Settings | ✅ |
| School settings, Edit user, Import users, Export | 🎨 |
| Reports, Grade scales, Subject detail, Periods | 🎨 |
| Bell schedule | ✅ |
| Solutions books admin | 🎨 |

## Parent
| Screen | Status |
|---|---|
| Parent home | ✅ |
| Parent notifications | 🎨 |

## Manager
| Screen | Status |
|---|---|
| School form, Bagrut exam form | ✅ |
| Schools, Managers, Bagrut exams, Bagrut manage | ✅ |

## Up next (in order)
1. 🎨 admin settings screens, students hub, reports etc.
2. 🎨 student solutions / bagrut home / certificates list / materials / notes, support, forgot password, parent notifications
3. Onboarding (low priority)

## Known open items (not redesign)
- Secretary student create/delete UI not wired
- 11 stale failing tests (also fail on `main`)
- Composer mic/classroom bug report — waiting on repro details
