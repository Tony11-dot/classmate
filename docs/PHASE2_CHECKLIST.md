# Phase 2 checklist — every role, every tab, every sub-screen

Companion to `REDESIGN_PROGRESS.md` ("Phase 2"). One row per screen a person can reach. Three ticks
per row, in order:

- **Chrome** — the screen shows the right frame for its kind. Navbar tab: shell top bar + navbar.
  Drawer tab: shell top bar, navbar hidden. Sub-screen: no shell, no logo, no pill.
- **Bar** — sub-screens use `CmSubBar` (glass back button + bold title); tabs use the shell bar.
  Chat threads, NOVA chat, media preview / viewer / trimmer keep their own purpose-built bars (noted).
- **Polish** — the screen was reviewed on the rig contact sheet (en, light) and every button, text
  and card on it was checked; fixes, if any, are listed in the round's notes.

Legend: ✅ done · ☐ pending · — not applicable · R## = round that did it.

## Student (R26 ✅ chrome + bar; polish reviewed R26)

| Screen | Route | Kind | Chrome | Bar | Polish |
|---|---|---|---|---|---|
| Schedule | /schedule | navbar | ✅ | — | ✅ |
| Classrooms | /classrooms | navbar | ✅ | — | ✅ |
| Practice | /practice | navbar | ✅ | — | ✅ |
| Insights | /insights | navbar | ✅ | — | ✅ |
| NOVA | /tutor | navbar | ✅ | — | ✅ |
| Messages | /messages | drawer | ✅ | — | ✅ |
| Attendance | /attendance | drawer | ✅ | — | ✅ |
| Grades | /grades | drawer | ✅ | — | ✅ |
| Assignments | /assignments | drawer | ✅ | — | ✅ |
| Materials | /materials | drawer | ✅ | — | ✅ |
| Solutions | /solutions | drawer | ✅ | — | ✅ |
| Bagrut | /bagrut | drawer | ✅ | — | ✅ |
| Meetings | /meetings | drawer | ✅ | — | ✅ |
| Announcements | /announcements | drawer | ✅ | — | ✅ |
| Notifications | /notifications | drawer | ✅ | — | ✅ |
| Exams | /exams | drawer | ✅ | — | ✅ |
| Forms | /forms | drawer | ✅ | — | ✅ |
| Saved questions | /saved-questions | drawer | ✅ | — | ✅ |
| Certificates | /certificates | drawer | ✅ | — | ✅ |
| CMail | /cmail | drawer | ✅ | — | ✅ |
| Profile | /profile | drawer (Account) | ✅ | — | ✅ |
| NOVA plans | /plans | drawer (Account) | ✅ | — | ✅ |
| Settings | /settings | drawer (Account) | ✅ | — | ✅ |
| Support | /support | drawer (Account) | ✅ | — | ✅ |
| About | /about | drawer (Account) | ✅ | — | ✅ |
| Assignment detail | /assignments/:id | sub | ✅ | ✅ (own glass bar, R12) | ✅ |
| Meeting detail | /meetings/:id | sub | ✅ | ✅ (own glass bar, R12) | ✅ |
| Announcement detail | /announcements/:id | sub | ✅ | ✅ (own glass bar, R12) | ✅ |
| Exam detail | /exams/:id | sub | ✅ | ✅ R26 | ✅ |
| Form detail | /forms/:id | sub | ✅ | ✅ R26 | ✅ |
| Notification detail | /notifications/:id | sub | ✅ | ✅ R26 | ✅ |
| Classroom detail | /classrooms/:id | sub | ✅ | — (tabbed workspace, own header) | ✅ |
| Chat thread | /messages/:id | sub | ✅ | — (chat bar) | ✅ |
| Message request | /messages/request/:id | sub | ✅ | ✅ R26 | ✅ |
| New chat | (pushed) | sub | ✅ | ✅ R26 | ✅ |
| New group | (pushed) | sub | ✅ | ✅ R26 | ✅ |
| Blocked people | (pushed) | sub | ✅ | ✅ R26 | ✅ |
| Chat media preview | (pushed) | sub | ✅ | — (media bar) | ✅ |
| Practice session | /practice/session | sub | ✅ | — (session header) | ✅ |
| Practice history | (pushed) | sub | ✅ | ✅ R26 | ✅ |
| Practice session review | (pushed) | sub | ✅ | ✅ R26 | ✅ |
| Solutions subjects | /solutions/subjects | sub | ✅ | — (grid, no bar) | ✅ |
| Solutions books | /solutions/books | sub | ✅ | ✅ R26 | ✅ |
| Solutions filters | /solutions/pages | sub | ✅ | ✅ R26 | ✅ |
| Solutions questions | /solutions/questions | sub | ✅ | ✅ R26 | ✅ |
| Manage books | /solutions/manage-books | sub | ✅ | ✅ R26 | ✅ |
| Bagrut exams | (pushed) | sub | ✅ | ✅ R26 | ✅ |
| Bagrut exam | (pushed) | sub | ✅ | ✅ R26 | ✅ |
| Bagrut file viewer | (pushed) | sub | ✅ | ✅ R26 | ✅ |
| CMail compose | (pushed) | sub | ✅ | ✅ R26 | ✅ |
| CMail detail | (pushed) | sub | ✅ | ✅ R26 | ✅ |
| Note editor | (pushed) | sub | ✅ | ✅ R26 | ✅ |
| Reorder tools | /settings/reorder-tools | sub | ✅ | ✅ R26 | ✅ |
| Reorder classrooms | (pushed) | sub | ✅ | ✅ R26 | ✅ |
| Theme gallery | (pushed) | sub | ✅ | ✅ R26 | ✅ |
| Phone link | (pushed) | sub | ✅ | — (onboarding step) | ✅ |
| Login | /login | pre-login | ✅ | — | ✅ |
| Forgot password | /forgot-password | pre-login | ✅ | ✅ R26 | ✅ |
| NOVA chat | (pushed) | sub | ✅ | — (chat bar) | ✅ |

## Teacher (R27 ✅ chrome + bar; polish reviewed R27)

| Screen | Route | Kind | Chrome | Bar | Polish |
|---|---|---|---|---|---|
| Schedule | /teacher/schedule | navbar | ✅ | — | ✅ |
| Classrooms | /teacher/classrooms | navbar | ✅ | — | ✅ |
| Announcements | /announcements | navbar | ✅ | — | ✅ |
| Insights | /teacher/insights | navbar | ✅ | — | ✅ |
| NOVA | /tutor | navbar | ✅ | — | ✅ |
| Messages | /messages | drawer | ✅ | — | ✅ |
| Workspace | /teacher/home | drawer | ✅ | — | ✅ |
| Cohorts | /teacher/cohorts | drawer | ✅ | — | ✅ |
| Attendance | /teacher/attendance | drawer | ✅ | — | ✅ |
| Grades | /teacher/grades | drawer | ✅ | — | ✅ |
| Notifications | /notifications | drawer | ✅ | — | ✅ |
| Assignments | /teacher/assignments | drawer | ✅ | — | ✅ |
| Materials | /teacher/materials | drawer | ✅ | — | ✅ |
| Meetings | /teacher/meetings | drawer | ✅ | — | ✅ |
| Solutions | /solutions | drawer | ✅ | — | ✅ |
| Bagrut | /bagrut | drawer | ✅ | — | ✅ |
| Students | /teacher/students | drawer | ✅ | — | ✅ |
| Exams | /teacher/exams | drawer | ✅ | — | ✅ |
| Certificates | /teacher/certificates | drawer | ✅ | — | ✅ |
| Forms | /teacher/forms | drawer | ✅ | — | ✅ |
| CMail | /cmail | drawer | ✅ | — | ✅ |
| Profile · Settings · Support · About | /profile … | drawer (Account) | ✅ | — | ✅ |
| Classroom detail | /teacher/classroom/:id | sub | ✅ | — (tabbed workspace) | ✅ |
| Classroom analytics | /teacher/classroom/:id/analytics | sub | ✅ | ✅ R27 | ✅ |
| New announcement | /teacher/announcements/new | sub | ✅ | ✅ R27 | ✅ |
| Create form | /teacher/forms/create | sub | ✅ | ✅ R27 | ✅ |
| Form responses | /teacher/forms/:id/responses | sub | ✅ | ✅ R27 | ✅ |
| Create / edit exam | /teacher/exams/create · /edit | sub | ✅ | ✅ R27 | ✅ |
| Exam grades | /teacher/exams/:id/grades | sub | ✅ | ✅ R27 | ✅ |
| Add grade | /teacher/grades/add | sub | ✅ | ✅ R27 | ✅ |
| Slot attachments | /teacher/slot/:id/attachments | sub | ✅ | ✅ R27 | ✅ |
| Add material | /teacher/materials/add | sub | ✅ | ✅ R27 | ✅ |
| Add meeting | /teacher/meetings/add | sub | ✅ | ✅ R27 | ✅ |
| Add assignment | /teacher/assignments/add | sub | ✅ | ✅ R27 | ✅ |
| Assignment detail | /teacher/assignments/:id/detail | sub | ✅ | ✅ R27 | ✅ |
| Classroom: add assignment / material / meeting | /teacher/classroom/:id/… | sub | ✅ | ✅ R27 | ✅ |
| Mark attendance | /teacher/attendance/mark | sub | ✅ | ✅ R27 | ✅ |
| Student detail | /teacher/student/:id | sub | ✅ | ✅ R27 | ✅ |
| Student grade detail | (pushed) | sub | ✅ | ✅ R27 | ✅ |
| Averages | /teacher/averages | sub (in shell) | ✅ shell bar hidden R27 | ✅ R27 | ✅ |
| Create classroom | (pushed) | sub | ✅ | ✅ R27 | ✅ |
| Certificate form | (pushed) | sub | ✅ | ✅ R27 | ✅ |
| Certificates per student | (pushed) | sub | ✅ | ✅ R26 | ✅ |

## Parent (R28)

| Screen | Route | Kind | Chrome | Bar | Polish |
|---|---|---|---|---|---|
| Home | /parent/home | navbar | ☐ | — | ☐ |
| Schedule | /parent/schedule | navbar | ☐ | — | ☐ |
| Overview | /parent/overview | navbar | ☐ | — | ☐ |
| Messages | /messages | navbar | ☐ | — | ☐ |
| Announcements | /announcements | navbar | ☐ | — | ☐ |
| Attendance · Grades · Exams · Certificates · Assignments · Meetings · Materials · Notifications · CMail | /parent/… | drawer | ☐ | — | ☐ |
| Profile · Settings · Support · About | /profile … | drawer (Account) | ☐ | — | ☐ |
| Child picker | (sheet) | sub | ☐ | — (sheet) | ☐ |
| Shared details (assignment / meeting / announcement / exam / form / notification) | /…/:id | sub | ✅ R26 | ✅ | ☐ |
| Chat thread | /messages/:id | sub | ☐ | — (chat bar) | ☐ |

## Admin (R29)

| Screen | Route | Kind | Chrome | Bar | Polish |
|---|---|---|---|---|---|
| Dashboard | /admin/dashboard | drawer | ☐ | — | ☐ |
| People | /admin/people | drawer | ☐ | — | ☐ |
| Cohorts | /admin/cohorts | drawer | ☐ | — | ☐ |
| Schedule | /admin/schedule | drawer | ☐ | — | ☐ |
| School settings (School · Subjects · Bell schedule) | /admin/school | drawer | ☐ | — | ☐ |
| Grade scales | /admin/grade-scales | drawer | ☐ | — | ☐ |
| Permissions | /admin/permissions | drawer | ☐ | — | ☐ |
| Reports | /admin/reports | drawer | ☐ | — | ☐ |
| Certificates | /admin/certificates | drawer | ☐ | — | ☐ |
| Export | /admin/export | drawer | ☐ | — | ☐ |
| Students | /teacher/students | drawer | ☐ | — | ☐ |
| Settings | /admin/settings | drawer | ☐ | — | ☐ |
| CMail · Messages · Announcements · Notifications | … | drawer | ☐ | — | ☐ |
| Profile · Settings · Support · About | /profile … | drawer (Account) | ☐ | — | ☐ |
| Periods | /admin/periods | sub (in shell) | ☐ hide shell bar | ☐ | ☐ |
| Import users | /admin/import-users | sub (in shell) | ☐ | ☐ | ☐ |
| Bell schedule (standalone) | /admin/bell-schedule | sub (in shell) | ☐ | ☐ | ☐ |
| Cohort detail | (pushed) | sub | ☐ | ☐ | ☐ |
| Add period | (pushed) | sub | ☐ | ☐ | ☐ |
| Edit user | (pushed) | sub | ☐ | ☐ | ☐ |
| Subject detail | (pushed) | sub | ☐ | ☐ | ☐ |
| Export options sheet | (sheet) | sub | ☐ | — (sheet) | ☐ |

## Secretary (R30)

| Screen | Route | Kind | Chrome | Bar | Polish |
|---|---|---|---|---|---|
| Home | /secretary/home | drawer | ☐ | — | ☐ |
| Schedule | /secretary/schedule | drawer | ☐ | — | ☐ |
| Students | /secretary/students | drawer | ☐ | — | ☐ |
| People | /secretary/people | drawer | ☐ | — | ☐ |
| Cohorts | /secretary/cohorts | drawer | ☐ | — | ☐ |
| Certificates | /secretary/certificates | drawer | ☐ | — | ☐ |
| Announcements · Messages · Export · CMail | … | drawer | ☐ | — | ☐ |
| Profile · Settings · Support · About | /profile … | drawer (Account) | ☐ | — | ☐ |
| Student editor | (pushed) | sub | ☐ | ☐ | ☐ |
| Cohort detail · Edit user · Export sheet | (pushed) | sub | ☐ | ☐ | ☐ |

## Manager (R31)

| Screen | Route | Kind | Chrome | Bar | Polish |
|---|---|---|---|---|---|
| Console home | /manager/home | root | ☐ | — | ☐ |
| Schools | (pushed) | sub | ☐ | ☐ | ☐ |
| Managers | (pushed) | sub | ☐ | ☐ | ☐ |
| Bagrut exams | (pushed) | sub | ☐ | ☐ | ☐ |
| Bagrut manage | (pushed) | sub | ☐ | ☐ | ☐ |
| School form | (pushed) | sub | ☐ | ☐ | ☐ |
| Exam form | (pushed) | sub | ☐ | ☐ | ☐ |

## Cross-role surfaces (own bars, kept)

| Screen | Why it keeps its own bar |
|---|---|
| Chat thread, NOVA chat | message header with avatar / presence / actions |
| Chat media preview, image viewer, video trimmer | dark full-bleed media chrome |
| Practice session | timed session header |
| Classroom detail (student + teacher) | tabbed workspace header |
