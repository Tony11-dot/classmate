# Classmate API – Permissions Matrix (v1)

## Roles
- STUDENT
- PARENT
- TEACHER
- SECRETARY
- ADMIN

## Scope terms
- cohort scope: user is authorized for cohort (teacher owns a course in cohort)

## Endpoints / Actions

### Auth
- POST /api/auth/register: public
- POST /api/auth/login: public
- GET /api/auth/me: any authenticated

### Seed (tests only)
- POST /api/test/seed/*: test env only

### Admin / Cohorts
- POST /api/admin/cohorts: ADMIN
- POST /api/admin/cohorts/join-code: ADMIN or TEACHER (TEACHER must pass cohort scope) [legacy]
- POST /api/teacher/cohorts/join-code: TEACHER (cohort scope) or ADMIN [preferred]

### Student
- POST /api/student/onboard: STUDENT
- POST /api/student/parent-link-code: STUDENT

### Parent
- POST /api/parent/link: PARENT

### Teacher
- GET /api/teacher/cohort/:cohortId/students: TEACHER (cohort scope)
