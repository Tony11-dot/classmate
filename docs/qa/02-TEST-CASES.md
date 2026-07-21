# ClassMate — Manual Test Case Checklist

> Work top-to-bottom. Mark **Result** = P (pass) / F (fail) / B (blocked) and add a note for every F/B.
> Every **F** must also become a row in the bug tracker (see `05-BUG-TRACKER-GUIDE.md`) with steps + screenshot/recording.
> Accounts: see the credentials sheet. "S1/S2" = the two students, "T" = teacher, "A" = admin, "P" = parent.
> Where a case needs two devices, an emulator/second phone or the two student accounts on two testers' phones both work.

## 1. Install & first run

| ID | Test case | Expected | Result | Notes |
|---|---|---|---|---|
| INS-01 | Install from TestFlight (iOS) / Play opt-in link (Android) | Installs and launches, no crash | | |
| INS-02 | First launch → login screen | Branded login screen, no blank/white screen | | |
| INS-03 | Kill app during first launch, reopen | Recovers normally | | |

## 2. Authentication & session

| ID | Test case | Expected | Result | Notes |
|---|---|---|---|---|
| AUTH-01 | Login with username + correct password (S1) | Lands on student home | | |
| AUTH-02 | Login with wrong password | Clear localized error, no technical jargon, field not cleared unreasonably | | |
| AUTH-03 | Login with empty fields | Inline validation, no request sent | | |
| AUTH-04 | 5+ rapid failed logins | Friendly "too many attempts" message (rate limit), app remains usable | | |
| AUTH-05 | First login shows consent screen | Cannot enter app without accepting; declining does not silently proceed | | |
| AUTH-06 | After consent, onboarding slides shown once | Role-appropriate content; never shown again on next login | | |
| AUTH-07 | Logout | Confirmation dialog; after confirm, returns to login; back button cannot re-enter the session | | |
| AUTH-08 | Password reset: as A set a real email on S2, then "Forgot password" with that email | Reset email arrives; link works; new password logs in; old one doesn't; link cannot be used twice | | |
| AUTH-09 | Admin sets a user's password (A → user → set password) | New password works immediately | | |
| AUTH-10 | Biometric unlock (device with Face/Touch ID or fingerprint) | Offered after first login; works; declining still allows password login | | |
| AUTH-11 | Leave app logged in for a long period / revoke by changing password from another device | Session expires gracefully to login, no crash, no stuck spinner | | |

## 3. Account switcher & isolation (high priority)

| ID | Test case | Expected | Result | Notes |
|---|---|---|---|---|
| ACC-01 | Add a second account (S1 + T) on one device | Both listed; switching is instant and lands on correct role home | | |
| ACC-02 | After switching S1→T | NOTHING of S1 visible: no chats, notifications, cached screens, name anywhere | | |
| ACC-03 | Remove an account from the switcher | Confirmation; removed account leaves no trace; other account unaffected | | |
| ACC-04 | Switch account, then check theme/language | Settings apply per user, don't leak between accounts | | |
| ACC-05 | Delete a user (as A) that is signed in on another device | Deleted user's session ends; account disappears from that device's switcher | | |

## 4. Role & permission boundaries (report failures as CRITICAL)

| ID | Test case | Expected | Result | Notes |
|---|---|---|---|---|
| SEC-01 | As S1, look for any admin/teacher functionality (menus, long-press, deep screens) | No admin/teacher actions reachable | | |
| SEC-02 | As T, attempt admin-only areas (user management, branding) | Not reachable | | |
| SEC-03 | As P, verify you see ONLY your linked child (Student One) | Student Two's data never appears | | |
| SEC-04 | As S1, verify grades shown are only PUBLISHED ones (see GRD cases) | Draft grades invisible to students/parents | | |
| SEC-05 | Any place showing "other people" (chat contacts, pickers) | Only QA-school members appear — never another school's users | | |
| SEC-06 | Blocked user (see CHT-19) tries to DM the blocker | Message not delivered to blocker; no crash | | |
| SEC-07 | Error messages anywhere | Never show stack traces, server internals, or other users' data | | |

## 5. Chat — direct messages

| ID | Test case | Expected | Result | Notes |
|---|---|---|---|---|
| CHT-01 | S1 → S2 first DM (find user, send "hello") | Delivered; appears instantly on S2 without refresh | | |
| CHT-02 | Receipts | Single/sent → delivered → read states update live as S2 receives then opens | | |
| CHT-03 | Typing indicator | S2 sees "typing…" while S1 types; disappears when idle | | |
| CHT-04 | Voice message: hold mic, speak 5s, release | Sends; playable on both sides with waveform/duration | | |
| CHT-05 | Voice: hold, slide LEFT (cancel) | Recording discarded, nothing sent | | |
| CHT-06 | Voice: hold, slide UP (lock), continue hands-free, then send | Lock works; timer runs; sends correctly | | |
| CHT-07 | Voice: start recording, receive a call / switch app / lock phone | No crash; recording cancels or recovers cleanly | | |
| CHT-08 | Voice: deny microphone permission, then try recording | Clear prompt to enable permission; no crash | | |
| CHT-09 | Reply to a specific message | Quoted preview correct; tapping it jumps to original | | |
| CHT-10 | Edit own message | Updates on both sides, marked edited | | |
| CHT-11 | Delete for me | Gone only for deleter; still visible to other side | | |
| CHT-12 | Delete for everyone | Gone/placeholder on both sides | | |
| CHT-13 | React to a message (both sides) | Reactions render and sync live | | |
| CHT-14 | Pin a message | Pinned indicator visible to both | | |
| CHT-15 | Message info (long-press) | Delivered/read timestamps plausible and consistent | | |
| CHT-16 | Send in airplane mode, then reconnect | Clear pending state; sends on reconnect or offers retry; never silently lost | | |
| CHT-17 | Background the app; other side sends | Push notification arrives; tapping opens the right conversation | | |
| CHT-18 | Inbox actions: pin, mute, mark-unread, clear, delete conversation | Each works and persists after app restart | | |
| CHT-19 | Block user from inbox; then unblock | Block confirmed; see SEC-06; unblock restores messaging | | |
| CHT-20 | Very long message (2000+ chars), emoji-only, RTL text mixed with English | Renders correctly, no layout break | | |
| CHT-21 | Rapid-fire 20 messages | Order preserved, no duplicates/drops | | |

## 6. Chat — classroom group

| ID | Test case | Expected | Result | Notes |
|---|---|---|---|---|
| GRP-01 | T opens QA Class 10-A group chat, sends text + voice | Both students receive live | | |
| GRP-02 | Group member list | Correct members (T, S1, S2) | | |
| GRP-03 | S1 sends; S2 and T see sender name/avatar correctly | | | |
| GRP-04 | Delete-for-everyone by author in group | Removed for all members | | |

## 7. CMail (school mail)

| ID | Test case | Expected | Result | Notes |
|---|---|---|---|---|
| CML-01 | T composes to "students of QA Class 10-A" | Both students receive it; parent/admin only per selected audience | | |
| CML-02 | Attach an image + a PDF | Upload progress; recipients can open both | | |
| CML-03 | Huge attachment (>20 MB) | Friendly size-limit error, not a raw failure | | |
| CML-04 | Long-press actions on a mail | Action sheet fully visible and scrollable on small screens | | |
| CML-05 | A composes school-wide announcement mail | All QA accounts receive | | |

## 8. NOVA (AI tutor) — students & teachers

| ID | Test case | Expected | Result | Notes |
|---|---|---|---|---|
| NVA-01 | S1 asks a math question ("solve x² − 5x + 6 = 0 step by step") | Helpful tutoring answer; math renders properly (no raw LaTeX/$$ artifacts) | | |
| NVA-02 | Long conversation (10+ turns) | Context kept; scrolling smooth; no truncation glitches | | |
| NVA-03 | Ask in Hebrew and Arabic | Answers in the same language; RTL text renders correctly | | |
| NVA-04 | Ask NOVA to write a graded essay / do homework verbatim | Redirects to teaching/guiding rather than plain cheating | | |
| NVA-05 | T uses NOVA (teacher variant) | Works; tone/content appropriate for a teacher assistant | | |
| NVA-06 | Kill network mid-answer | Graceful error + retry, no frozen spinner | | |
| NVA-07 | Support/help chat | Responds as ClassMate support persona, consistent identity | | |

## 9. Practice

| ID | Test case | Expected | Result | Notes |
|---|---|---|---|---|
| PRC-01 | S1 solo practice: pick subject + topic | Topics match grade 10; questions load; scoring works | | |
| PRC-02 | Matchmaking: S1 and S2 queue for the same subject | Countdown/ETA shown; match found; both play the same game | | |
| PRC-03 | One player quits mid-match | Other player informed gracefully, no hang | | |
| PRC-04 | Matchmaking timeout (queue alone) | ETA counts; sensible timeout message; can cancel cleanly | | |

## 10. Solutions & Bagrut

| ID | Test case | Expected | Result | Notes |
|---|---|---|---|---|
| SOL-01 | Browse solutions feed; filter by subject | Filters work; content loads with images | | |
| SOL-02 | Report a solution | Report flow completes with confirmation | | |
| BGR-01 | Open Bagrut library (student + teacher) | Subjects/years browsable | | |
| BGR-02 | Open each file kind (questions/answers/solution) | PDFs open in-app; zoom/scroll fine; empty kinds handled gracefully | | |

## 11. Materials, assignments & notes

| ID | Test case | Expected | Result | Notes |
|---|---|---|---|---|
| MAT-01 | T uploads class material (PDF + image) to QA Class 10-A | Students see and open it | | |
| MAT-02 | T creates an assignment/form with due date | Students see it; submission flow works; T sees the submission | | |
| MAT-03 | P checks forms area | Sees only own child's relevant items | | |
| NOT-01 | S1 creates private notes; log in as S2/T | Notes visible ONLY to S1 (privacy failure = Critical) | | |

## 12. Grades (draft → publish is the core flow)

| ID | Test case | Expected | Result | Notes |
|---|---|---|---|---|
| GRD-01 | T creates an assessment with weights, enters grades for S1+S2 | Saves; weighted average computes correctly (verify by hand) | | |
| GRD-02 | Before publishing: check S1 and P | Draft grades NOT visible (failure = Critical) | | |
| GRD-03 | T publishes | S1 sees the grade; P sees it for Student One; notification arrives | | |
| GRD-04 | Edge values: 0, 100, decimals | Accepted/validated sensibly; average updates | | |
| GRD-05 | Invalid input (negative, >max, letters) | Blocked with clear validation | | |
| GRD-06 | S1 insights/average views | Numbers consistent with published grades | | |

## 13. Attendance, schedule, announcements

| ID | Test case | Expected | Result | Notes |
|---|---|---|---|---|
| ATT-01 | T takes attendance for today (present/absent/late mix) | Saves; re-open shows same state | | |
| ATT-02 | T edits attendance for a PAST date via date picker | Correct date edited, today's untouched | | |
| ATT-03 | S1/P view attendance | Matches what T entered | | |
| SCH-01 | View schedule as S1 and T | Renders correctly incl. RTL locales | | |
| ANN-01 | T/A creates an announcement | Students receive; content renders; long text OK | | |

## 14. Certificates & admin operations

| ID | Test case | Expected | Result | Notes |
|---|---|---|---|---|
| CRT-01 | T certificate flow: pick class → student → create/edit certificate | Saves and re-opens correctly | | |
| CRT-02 | A exports annual report-card PDF | PDF generates and opens (known cosmetic issues — see scope §7 — don't re-report those) | | |
| ADM-01 | A creates a TEACHER (in-app) | Username availability check works; password toggle shows/hides; account can log in | | |
| ADM-02 | A creates a STUDENT with grade + class | Appears in class; can log in; sees class content | | |
| ADM-03 | A creates a PARENT and links to a student | Parent sees that child only | | |
| ADM-04 | Validation: bad email, short password, phone without +country code | Each blocked with a clear message | | |
| ADM-05 | Duplicate username | Friendly conflict error + suggestions | | |
| ADM-06 | A edits a user (rename, change details) | Changes reflected for that user on next refresh/login | | |
| ADM-07 | A deletes a user | Gone from lists; cannot log in anymore | | |
| ADM-08 | School branding: A uploads logo + name | Appears in drawer/app for all QA users | | |
| ADM-09 | Cohort management: create class, add/remove students | Membership changes reflect in class content and group chat | | |

## 15. Localization & RTL (run at least one FULL session in Hebrew)

| ID | Test case | Expected | Result | Notes |
|---|---|---|---|---|
| L10N-01 | Switch app language to Hebrew; navigate every main screen | Full RTL mirroring; no clipped/overlapping text; no untranslated English fragments | | |
| L10N-02 | Same for Arabic (spot-check main screens) | Same bar | | |
| L10N-03 | Chat/CMail previews, notifications, dates/times in Hebrew | Localized, correct number/date formats | | |
| L10N-04 | Switch back to English | Everything returns; no stuck strings | | |

## 16. Themes & visual

| ID | Test case | Expected | Result | Notes |
|---|---|---|---|---|
| THM-01 | Cycle all 9 themes | Each applies fully (no half-themed screens); readable text everywhere | | |
| THM-02 | Dark-family themes | Logos/images swap correctly; splash matches | | |
| THM-03 | Theme persists after app restart and is per-account | | | |

## 17. Tablet / iPad layout

| ID | Test case | Expected | Result | Notes |
|---|---|---|---|---|
| TAB-01 | iPad or Android tablet, landscape + portrait | Persistent sidebar + top bar on EVERY screen incl. chat and detail pages | | |
| TAB-02 | Tap sidebar items while a detail page is open | Content pane actually changes (highlight AND content) | | |
| TAB-03 | Rotate mid-flow | No crash, layout adapts | | |

## 18. Platform behaviors & resilience

| ID | Test case | Expected | Result | Notes |
|---|---|---|---|---|
| PLT-01 | Android hardware/gesture back everywhere | From non-home tab → returns to home tab; on home → back again exits; never dead-ends | | |
| PLT-02 | Kill app anytime, reopen | Returns logged-in to a sane screen | | |
| PLT-03 | Poor network (enable airplane mid-action) across features | Localized error + Retry everywhere; NEVER a raw exception string | | |
| PLT-04 | Push notifications with app killed | Arrive; deep-link to right place | | |
| PLT-05 | App permissions: deny mic/photos/notifications first, grant later | Each feature recovers once granted | | |
| PLT-06 | Small phone (≤5.5") + large phone | No clipped buttons/overflows on key screens | | |
| PLT-07 | Battery saver / low power mode | App remains functional | | |
| PLT-08 | In-app update prompt (if an older build is available to you) | Shows once, links to store, dismissible | | |

## 19. Exploratory (minimum 45 minutes, required)

Free-roam with intent to break things: weird inputs, double-taps on submit buttons, fast navigation during loads, rotating during dialogs, filling storage, switching accounts mid-upload. Log anything odd — even "feels wrong" UX notes are wanted (mark severity Low).
