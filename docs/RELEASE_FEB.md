# February Release Checklist (Classmate)

## Definition of Done (MVP)
- [ ] Admin-web: Login works, no dev overlays in prod
- [ ] Attendance: load session, mark attendance, save, reopen shows persisted data
- [ ] Grades: create assessment, enter grades, save, reopen prefilled
- [ ] API: auth + core endpoints stable; tests passing
- [ ] E2E: attendance + grades green in CI/local
- [ ] Errors: user-visible error messages (no silent failures)
- [ ] UX: saving states + success feedback on Save actions
- [ ] Deployment: one-click run instructions (local) + one deploy target (staging)

## Week-by-week Plan
### Week 1 (Now → Jan end)
- [ ] Stabilize core flows + remove flaky states
- [ ] Add minimal seed/test data path
- [ ] E2E for attendance + grades + login

### Week 2 (Early Feb)
- [ ] Dashboard summary (basic)
- [ ] Role/permissions sanity check
- [ ] Polish UX + empty states

### Week 3 (Mid Feb)
- [ ] Staging deploy
- [ ] Bug bash + fixes
- [ ] Performance quick pass

### Week 4 (Late Feb)
- [ ] Final QA checklist
- [ ] “Demo script” + screenshots
- [ ] Release tagging + version notes
