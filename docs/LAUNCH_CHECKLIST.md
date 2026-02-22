# Classmate Launch Checklist (v0.1.0+)

## A) Must-work user flows (E2E smoke)
- [ ] Admin: register/login
- [ ] Admin: create school / cohort / class
- [ ] Admin: create teacher
- [ ] Admin: create student + assign to class
- [ ] Student: login
- [ ] Parent: login + link child
- [ ] Schedule: view schedule
- [ ] Attendance: mark + view
- [ ] Grades: create + view
- [ ] Notifications: list + mark seen
- [ ] Solutions feed: list + filters + open detail
- [ ] AI Tutor: create session + send message + get reply
- [ ] AI Tutor: brain snapshot endpoints work (get/rebuild)

## B) Security boundaries
- [ ] Auth guards on all routes
- [ ] Roles: ADMIN/TEACHER/STUDENT/PARENT enforced
- [ ] Data isolation by school/cohort/class
- [ ] No admin-only endpoints reachable by student/parent

## C) API correctness
- [ ] Consistent DTO validation
- [ ] Consistent error shapes
- [ ] Pagination on list endpoints
- [ ] Idempotent seed endpoints (dev-only)

## D) Reliability
- [ ] Request logging (done)
- [ ] Rate limit sane defaults
- [ ] Health checks stable
- [ ] No crash loops on missing env

## E) DX / Deploy readiness
- [ ] Golden commands documented
- [ ] One-command local boot
- [ ] Deterministic Docker builds
- [ ] DB migrations story clear
