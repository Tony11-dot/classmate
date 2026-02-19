NEXT (pick order, ship vertically)

1) Backend foundations
- Auth (register/login/me) ✅ (already scaffolded)
- Role gating + school scoping for every query
- CRUD: classes, enrollments, parent-child links, teacher assignments
- Seed: demo school + users (admin/teacher/parent/student)

2) Mobile UI shells
- Role router: StudentShell / TeacherShell / ParentShell / AdminShell
- Parents: Children list -> each child dashboard (attendance/grades/alerts/notifications)
- Teachers: Classes list -> roster -> attendance/grades posting
- Admin: manage users/classes/subjects

3) Core product flows
- Attendance events + streaks
- Grades (per subject, per period) + insights
- Notifications feed + mark-seen + pagination

4) Polish
- Apple-clean theme presets + density/radius + liquid-glass dropdowns
- Empty states + skeletons + error toasts
- Offline-safe caching where needed

Definition of Done (per feature)
- Works end-to-end: mobile -> API -> DB
- Role + school isolation enforced
- Empty/error/loading states done
- Basic tests (API) + smoke run script kept green
