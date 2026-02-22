# Finish Map (what exists right now)

## Web apps
### admin-web routes
- /login
- /
- /attendance
- /grades

### parent-web routes
- /login
- /
- /dashboard
- /notifications
- /child/[studentId]
- /child/[studentId]/attendance
- /child/[studentId]/grades
- /child/[studentId]/alerts

## API controllers
- /api/auth
- /api/admin (+ /api/admin/schedule)
- /api/teacher
- /api/student (+ /api/student/schedule)
- /api/parent (+ /api/parent/alerts + /api/parent/attendance + /api/parent/notifications)
- /api/schedule
- /api/notifications
- /api/announcements
- /api/solutions
- /api/tutor
- /api/test/seed
- /api/health
- /api/version

## Immediate blockers to launch
- Expand admin-web beyond attendance/grades (students/teachers/classes/cohorts setup UI)
- Ensure parent linking flow is real (not hardcoded)
- Ensure tutor session flow is real end-to-end in UI
- Enforce auth/role middleware everywhere (see pilot_api TODOs)
