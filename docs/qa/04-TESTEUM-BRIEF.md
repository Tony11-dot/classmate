# Testeum — crowdtesting campaign brief (copy-paste into the campaign form)

Field-by-field content for the campaign setup. Where Testeum's form wording differs slightly, map by meaning.

## Product name

ClassMate — School Management & Learning App

## Product description (one paragraph)

ClassMate is a mobile app (iOS + Android) that connects a school in one place: students see grades, schedules, and class materials, chat with classmates, practice with an AI tutor and study games; teachers manage attendance, grades, and class communication; parents follow their children's progress; school admins manage everything. It supports 6 languages including Hebrew and Arabic (right-to-left). Testers get accounts in a dedicated sandbox school — nothing they do affects real users.

## Test type

Functional validation **+ UX/usability** (guided user journeys with post-session questionnaire). Not open-ended exploratory only — testers must complete the defined journeys below, then free-roam.

## Tester profile / criteria

- **Count:** 15 testers (10 phone / 5 tablet if the platform allows the split).
- **Platforms:** ~8 Android (mix of budget and flagship, Android 10–15), ~7 iOS (iPhone iOS 16+, at least 2 iPads).
- **Age:** 16–50 — ideally a mix resembling real users: teens/young adults (student perspective), 25–50 (teacher/parent perspective).
- **Language:** English required; **Hebrew speakers strongly preferred for at least 5 testers** (they run their session in Hebrew).
- **Tech comfort:** mixed — include several low-tech-comfort testers on purpose (teachers/parents are not power users).
- **Important:** testers must NOT have seen the app before (first-contact clarity is the point of this track).

## Access & accounts

- iOS: TestFlight link (provided at launch). Android: Play testing opt-in link (tester Gmail registered by us).
- Credentials provided per tester with an assigned role (we distribute: ~7 student, ~4 teacher, ~2 parent, ~2 admin). Login is by **username**, in a sandbox school ("ClassMate QA School — TESTING ONLY").

## Guided journeys (testers follow their assigned role)

**Journey 1 — First contact (all roles, timed).** Install → log in with the provided username/password → complete consent + onboarding → reach your home screen. *Note the time it took and anything that confused you. Did you understand what this app is for within the first minute?*

**Journey 2 — Student: check your school life.** Find your grades. Find your class schedule. Find materials your teacher shared. *Rate how quickly you found each; note any dead ends.*

**Journey 3 — Student: chat.** Send a text message to the other student account we named in your instructions. Send a **voice message** (hold the microphone button; also try sliding up to lock and sliding left to cancel). Tell us whether the recording gestures felt natural or fiddly.

**Journey 4 — Student: learn with NOVA.** Open the NOVA tutor and ask it to help you understand a school topic (e.g. "explain photosynthesis simply", or a math equation). Follow up twice. *Was the answer helpful? Did anything render oddly (math, formatting)? Would you trust it for homework help?*

**Journey 5 — Teacher: run your class.** Take today's attendance for QA Class 10-A. Enter a grade for a student and publish it. Send an announcement to the class. *Which of the three was hardest to find?*

**Journey 6 — Parent: follow your child.** Find your child's grades and attendance. *Did you feel you saw everything a parent needs? What was missing?*

**Journey 7 — Admin: onboard a user.** Create a new student account (any name), assign them to QA Class 10-A. *Was the form self-explanatory? Was anything scary/unclear about passwords?*

**Journey 8 — Personalization (all roles).** Change the app theme; if you're a Hebrew speaker, switch the app to Hebrew and browse 3 screens. *Report anything unreadable, clipped, or still in English.*

**Journey 9 — Free roam (10 minutes, all roles).** Go anywhere. Try to do something the app doesn't expect.

## Post-session questionnaire

1. In one sentence: what is this app for? (Tests whether the product explains itself.)
2. What was the single most confusing moment in your session? Where did you feel lost?
3. Rate 1–5: how easy was your first login-to-home experience?
4. Rate 1–5: visual polish and consistency. Anything that looked broken or unfinished?
5. Rate 1–5: speed/responsiveness. Where did you wait too long?
6. **Trust:** would you be comfortable with this app holding your (or your child's) grades and school messages? What made it feel trustworthy or not?
7. If you're a teacher/parent: would you actually use this with your students/children? What's the #1 thing missing?
8. Hebrew testers: how natural did the Hebrew feel — translation quality and right-to-left layout?
9. Did anything crash, freeze, or error during your session? Describe exactly what you were doing.
10. What's the one thing you'd fix first?

## Bug reporting requirement

Any crash, error message, or broken feature encountered during journeys: report with steps, device model, OS version, and a screenshot/recording. (Severity definitions attached — `01-FEATURE-SCOPE.md` §8.)

## Turnaround

Campaign window: 7 days from launch. We're reachable daily for tester questions.
