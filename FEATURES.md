# ClassMate Features

ClassMate is a school management platform for students, teachers, parents, administrators, and support staff. Every feature below is live and functional.

---

## Authentication & Account Management

### Login
Sign in with your school email and password.
**Routes:** `/login` · `POST /auth/login`
- Open app → enter email and password
- Tap Sign In
- Redirected to your role's home screen (Student/Teacher/Admin/Secretary)

### Register
Create a new student account with email, name, and password.
**Routes:** `POST /auth/register`
- Submit email, full name, and password (min 3 chars)
- System validates email format and checks for duplicates
- Account created with STUDENT role · log in immediately

### Update Multilingual Name
Change your display name in any of 5 languages.
**Routes:** `PATCH /auth/profile/name`
- Go to Profile → edit name in English / Arabic / Hebrew / French / Russian
- Select preferred display language
- Name updates across the entire app

### Change Password
Update your account password securely.
**Routes:** `POST /auth/me/password`
- Go to Settings → Change Password
- Enter current password + new password (min 8 chars)
- System validates current password then updates it

---

## Student App

### Schedule
View today's and this week's class timetable.
**Routes:** `/schedule` · `GET /student/schedule/today` · `GET /student/schedule/week`
- Open Schedule tab → see today's classes with period, time, subject, cohort
- Swipe or tap arrows to navigate by day or week
- Pull to refresh for live updates

### Grades
Track all academic scores across subjects.
**Routes:** `/grades` · `GET /student/grades`
- Open Grades → see all assessments by subject with score and date
- Expand a subject to see individual assessment details and teacher comments
- Grade average calculated and displayed per subject

### Assignments
See all homework with due dates and submit work.
**Routes:** `/assignments` · `GET /student/assignments` · `POST /:id/submit`
- Open Assignments → see active assignments sorted by due date
- Tap assignment → read description and teacher-attached files
- Add note and/or upload files → tap Hand In
- Teacher notified in real-time of new submission
- Submission status updates immediately in list

### Exams
View upcoming exams and see your grades when published.
**Routes:** `/exams` · `GET /student/exams` · `GET /student/exams/:examId`
- Open Exams → see all exams with date, subject, and audience
- Tap exam → view description and attached study materials
- After grading, your score appears inline on the detail screen

### Forms & Surveys
Complete questionnaires assigned by teachers.
**Routes:** `/forms` · `POST /forms/:id/submit`
- Open Forms → see active forms from teachers
- Tap form → fill out all required fields (text, multiple choice, rating scale)
- Submit → system confirms and prevents re-submission (unless teacher allows multiple)

### Meetings
See scheduled online sessions and join with one tap.
**Routes:** `/meetings`
- Open Meetings → see all scheduled meetings with date/time and teacher
- Tap meeting → open in video conferencing app (Zoom, Teams, etc.)

### Materials
Download documents and resources shared by teachers.
**Routes:** `/materials`
- Open Materials → see all files from enrolled classrooms
- Tap to open/download PDFs, images, or follow links
- Materials show source classroom and upload date

### Announcements
Read school-wide and classroom announcements.
**Routes:** `/announcements` · `GET /announcements/feed`
- Open Announcements → see list sorted by date (newest first)
- Pinned announcements appear at top
- Tap to read full text; system marks as seen

### Attendance
Track your attendance record and absence history.
**Routes:** `/attendance`
- Open Attendance → see overall rate (present %, absent %, late %)
- View day-by-day history with period-level breakdown
- Filter by date range

### Classrooms
Browse enrolled virtual classrooms and participate.
**Routes:** `/classrooms` · `GET /student/classrooms`
- Open Classrooms → see all enrolled courses with teacher name
- Tap classroom → tabs: Chat · Assignments · Materials · Meetings · Members
- Chat tab: read discussion, send text, send images/files/voice messages

### Diplomas
Download certificates and diplomas awarded to you.
**Routes:** `/diplomas`
- Open Diplomas → see all certificates awarded
- Tap diploma → opens attached PDF/image file
- If no file attached, shows graceful message

### Insights
AI-powered summary of your academic performance.
**Routes:** `/insights`
- Open Insights → see grade average, attendance rate, submission rate
- View trends over time per subject
- Highlights areas for improvement

---

## Practice (Adaptive Learning)

### Practice Setup
Choose subject, topic, difficulty, and mode.
**Routes:** `/practice`
- Select subject → topic → difficulty level
- Choose practice mode: Standard, Flashcards, Speed Round, Exam Prep, Concept Builder, Adaptive, Bagrut
- Tap Start Session

### Practice Modes
**Standard** — Answer questions with instant feedback and explanations  
**Flashcards** — Spaced repetition for memorizing formulas and concepts  
**Speed Round** — Answer as many questions as possible in a time limit  
**Exam Prep** — Timed full quiz in exam format  
**Concept Builder** — Guided step-by-step concept introduction  
**Adaptive** — AI adjusts difficulty based on your real-time performance  
**Bagrut Prep** — Official Israeli Bagrut exam questions with authentic scoring

### Saved Questions
Bookmark hard questions to review later.
**Routes:** `/saved-questions`
- During practice, mark a question as difficult to save it
- Open Saved Questions → see all bookmarks by subject
- Retry saved questions; remove once mastered

### Practice Progress
Track accuracy, time spent, and improvement.
**Routes:** `GET /practice/progress-summary`
- Open Practice History → see overall accuracy % and time spent
- Breakdown by subject and topic
- View trends over time

---

## Solutions Library

### Browse Solutions
Find step-by-step solutions to textbook problems.
**Routes:** `/solutions` → `/solutions/subjects` → `/solutions/books` → `/solutions/pages` → `/solutions/questions`
- Open Solutions → select subject
- Choose textbook → page → question number
- View community-submitted solutions with full working

### Contribute a Solution
Submit your own solution to help other students.
**Routes:** `POST /solutions`
- Open a question with no solution → tap Add Solution
- Write step-by-step explanation; upload images if needed
- Solution published after moderation

---

## NOVA AI Tutor

### Start a Session
Begin tutoring on any subject with an AI guide.
**Routes:** `/tutor` · `POST /tutor/sessions`
- Open NOVA → select subject and topic
- Choose a tutor character
- Session opens with personalized AI guide

### Chat with NOVA
Ask questions and receive streamed explanations.
**Routes:** `POST /tutor/sessions/:id/messages` · `POST /tutor/sessions/:id/reply/stream`
- Type question → NOVA responds with streamed explanation
- Ask follow-ups; NOVA adapts explanation level
- If stream fails mid-response, partial answer is preserved and shown

### Upload Files to NOVA
Share homework, screenshots, or PDFs for analysis.
**Routes:** `POST /tutor/sessions/:sessionId/upload`
- In session → tap Upload
- Select image or PDF (up to 30MB)
- NOVA analyzes and provides targeted feedback

### Voice Messages
Speak your question; NOVA transcribes and answers.
**Routes:** `POST /tutor/transcribe`
- Tap microphone in session → speak question
- System transcribes audio → NOVA answers the text

### Learning Profile
Customize how NOVA teaches you.
**Routes:** `GET /tutor/me/profile` · `POST /tutor/me/profile`
- Open NOVA Profile → set learning pace, style, preferred language
- NOVA personalizes all explanations based on profile

---

## Messaging & Chat

### Inbox
See all direct and group conversations.
**Routes:** `/messages` · `GET /messages/inbox`
- Open Messages tab → see all chats sorted by recency
- Unread conversations show badge count
- Unread badge decrements immediately when you open a thread

### Direct Messages
Start private conversations with anyone in your school.
**Routes:** `POST /messages/requests/direct`
- Tap New Message → search by name
- First message goes as a request; other party approves or blocks
- After approval, full chat is available

### Message Features
Rich chat: reactions, edits, deletes, replies, pins, forwards.
**Routes:** `POST /messages/send` · `POST /messages/edit` · `POST /messages/delete` · `POST /messages/react` · `POST /messages/forward` · `POST /messages/pin/toggle`
- Long-press message: react with emoji, reply, edit (if yours), delete, forward, pin
- Pinned messages appear at top of thread
- Forwarded messages are delivered in real-time to target thread

### Group Chats
Create group conversations with multiple people.
**Routes:** `POST /messages/threads/group`
- Tap New Group → enter group name (max 50 chars) → select members
- Group created; all members notified
- Group admin can rename, add/remove members, promote/demote admins

### Classroom Chat
Discuss with classmates in course-specific channels.
**Routes:** `POST /student/classrooms/:id/chat/text` · `POST /teacher/classrooms/:id/chat`
- In a classroom → open Chat tab
- Send text, images, files, or voice messages
- All classroom members see messages in real-time

### Message Requests
Control who can contact you.
**Routes:** `POST /messages/requests/approve` · `POST /messages/requests/block`
- Unknown sender appears as pending request
- Preview message before accepting
- Approve to open chat, block to prevent future messages

### Blocked People
Manage who you've blocked.
**Routes:** `GET /messages/blocked`
- Open Messages Settings → Blocked People
- See all blocked contacts; tap to unblock

### Approve Request Real-Time
When you approve a request, the sender is instantly notified.
**Routes:** `POST /messages/requests/approve`
- Tap Approve → request becomes active conversation
- Sender receives real-time notification that they've been approved

---

## Teacher App

### Teacher Schedule
See your teaching timetable.
**Routes:** `/teacher/schedule` · `GET /teacher/schedule/today` · `GET /teacher/schedule/week`
- Open Schedule → see today's periods with cohort, time, subject
- Week view shows all 5 teaching days
- Tap a slot to view cohort roster

### Mark Attendance
Record attendance for each class.
**Routes:** `/teacher/attendance/mark` · `POST /teacher/attendance/bulk`
- Select cohort + period + date
- Roster loads automatically
- Tap each student: Present / Absent / Late / Excused
- Tap Mark All Present for quick bulk entry
- Save → attendance syncs to student records

### Attendance History
Review past attendance sessions.
**Routes:** `/teacher/attendance`
- Open Attendance History → filter by date range
- Tap any session to see full class attendance detail
- View absence patterns per student

### Grades & Assessments
Create assessments and enter student grades.
**Routes:** `/teacher/grades/add` · `POST /teacher/grades/assessment` · `POST /teacher/grades/bulk`
- Tap + → create assessment with title, subject, max grade, audience
- Enter grades per student with optional comments
- Publish grades → students see scores immediately, real-time push sent

### Classrooms
Create and manage virtual course rooms.
**Routes:** `/teacher/classrooms` · `POST /teacher/classrooms`
- Open Classrooms → see all courses you teach
- Tap + → create classroom with name and subject
- Open classroom → manage assignments, materials, meetings, members, chat

### Assignments
Post homework and review student submissions.
**Routes:** `/teacher/assignments/add` · `GET /teacher/classrooms/:id/assignments/:id/submissions`
- Create assignment: title, instructions, due date, audience, optional file attachments
- Files uploaded immediately to server before saving
- Open assignment → see each student's submission status, notes, and uploaded files
- Teacher receives real-time notification when student submits

### Exams
Create exams and enter scores after grading.
**Routes:** `/teacher/exams/create` · `/teacher/exams/:id/grades`
- Create exam: title, subject, date, max grade, audience, optional attachments
- Draft exams show a Publish button — tap to make visible to students
- Open exam grades view → enter each student's score
- Grades emit real-time notification to students

### Forms
Design surveys and view responses.
**Routes:** `/teacher/forms/create` · `/teacher/forms/:id/responses`
- Create form: title, questions (text / multiple choice / rating / checkbox / dropdown / scale)
- Set target audience; toggle accepting responses
- Responses visible per student in responses view

### Materials
Share documents, videos, and links with students.
**Routes:** `/teacher/materials/add`
- Tap Add Material → enter title
- Attach file (picked from device, uploaded immediately) OR paste link URL
- Material published → students see it in real-time

### Meetings
Schedule online sessions with meeting links.
**Routes:** `/teacher/meetings/add`
- Enter title, optional description, start time
- Paste a valid HTTPS meeting link (validated before save)
- Students see meeting in their schedule with join link

### Announcements
Broadcast messages to specific or all audiences.
**Routes:** `/teacher/announcements/new`
- Enter title + body
- If no audience selected, system confirms "Send to everyone?"
- Set publish date / expiration; pin to keep at top

### Diploma Generation
Issue digital certificates to students.
**Routes:** `/diplomas/create`
- Fill diploma details: student name, title, subject, grade, notes
- Upload certificate PDF/image if available
- Student sees diploma in their Diplomas section

### Student Profiles
View individual student records.
**Routes:** `/teacher/student/:studentId`
- Open Students → search by name
- Tap student → see grades, attendance, submissions, cohort
- Start DM directly from profile

### Classroom Analytics
See engagement and performance stats per classroom.
**Routes:** `/teacher/classroom/:courseId/analytics`
- Open a classroom → Analytics tab
- See class average, grade distribution, attendance rate
- Distinguishes "new classroom" (no data yet) from "zero activity"

### Teacher Insights
Analytics across all your courses.
**Routes:** `/teacher/insights`
- Open Insights → see overall performance across all classrooms
- Grade trends, attendance patterns, submission rates

---

## Admin App

### Dashboard
School-wide metrics and setup guide.
**Routes:** `/admin/dashboard`
- See total students, teachers, cohorts, classrooms, today's sessions
- 30-day attendance rates per cohort (color-coded: green ≥90%, orange ≥75%, red <75%)
- First-time setup guide (disappears once school has data) with 7 numbered steps linking to each setup screen

### People Management
Create and manage all user accounts.
**Routes:** `/admin/people`
- Tabs: Students · Teachers · Parents · Secretaries
- Search by name · filter by tab
- Add User: enter name, email, role → system creates account with temp password shown in dialog → sheet stays open during dialog, closes after Done
- After creation, tab automatically switches to the new user's role
- Reset Password: generates new temp password
- Delete User: requires confirmation

### Cohort Management
Create, rename, and populate student groups.
**Routes:** `/admin/cohorts`
- See cohorts grouped by grade with student count + attendance rate + grade average
- Add Cohort: name + grade → saves to school
- Tap cohort → roster detail with per-student names and emails
- Add Students: search + multiselect from all school students → adds to cohort; count updates immediately
- Remove Student: tap X with confirmation
- Generate Join Code: tap QR icon → 6-digit code valid 7 days → copy with one tap
- Student count on card refreshes immediately after adding/removing students

### Weekly Schedule Builder
Assign teachers and cohorts to time slots.
**Routes:** `/admin/schedule`
- See existing periods grouped by day
- Add Period: select day(s) + period number + teacher (searchable) + cohort or individual students + frequency (weekly/bi-weekly/monthly/custom)
- Multiple day+period combos in one save: tap Add Another Slot
- Partial success: if some slots fail, shows "Created X/Y slots" and still closes
- If teacher DDL is empty → shows guidance message to create teachers first

### Bell Schedule
Set start/end times for each school period.
**Routes:** `/admin/bell-schedule`
- See P1–P9 each with start and end time
- Tap any time → system time picker
- Duration label (e.g. "45m") shown per period
- Save FAB → persists to school; reloads from server to confirm

### School Settings
School name, logo, and subjects per grade.
**Routes:** `/admin/school`
- School tab: edit name and logo URL (blank = clear logo) → Save
- Subjects tab: per-grade chip list → add subject by typing + Add button → delete via chip X → Save per grade

### Settings Hub
Links to all configuration areas.
**Routes:** `/admin/settings`
- School Settings, Bell Schedule, Weekly Schedule, Period Defaults, Profile, Appearance

---

## Secretary App

### Students Overview
View all cohorts with attendance and grade aggregates.
**Routes:** `/secretary/students`
- See school summary: total students, cohorts, avg attendance %, avg grade
- Cohort list grouped by grade with color-coded attendance rate pills
- Tap cohort → full student roster with name and email
- Pull to refresh for live data

### Announcements
Read and create school announcements.
**Routes:** `/announcements` · `POST /announcements`
- Read all school announcements as main tab
- Tap + FAB → create announcement with title, body, audience
- If no audience → system asks "Send to everyone?"

### Messages
Direct messages and group chats.
**Routes:** `/messages`
- Same full messaging system as teachers
- Message parents, teachers, and admins directly

---

## Notifications

### Notifications Center
All system alerts in one place.
**Routes:** `/notifications` · `GET /notifications`
- See all notifications: grade posted, assignment created, new message, announcement
- Tap any notification → navigates to relevant screen
- Mark All Read button
- Unread count badge on notification icon

### Real-Time Push (SSE)
Live updates without refreshing.
**Event types:** `grade_updated` · `assignment_created` · `material_created` · `meeting_created` · `notification` · `dm_message` · `classroom_message` · `schedule_updated`
- Server-Sent Events connection maintained in background
- Badge counts, provider caches, and list views update automatically
- Reconnects with exponential backoff on network interruption
- SSE connections cleaned up on network drop to prevent memory leak

---

## Settings & Profile

### Profile
View account info; edit multilingual name.
**Routes:** `/profile`
- See name, email, role, school, cohort
- Edit name in any language via API sync
- Role label shown correctly for all roles

### App Settings
Customize theme, language, and accent color.
**Routes:** `/settings`
- **Language:** 5 options (EN · AR · HE · FR · RU) — changes all text instantly
- **Theme:** Light / Dark / System
- **Accent color:** 7 choices (Blue, Indigo, Violet, Teal, Green, Orange, Rose)
- All preferences persisted to device storage

### Logout
Sign out and clear all credentials.
- Tap Logout in drawer → all tokens and cached data cleared → redirected to login
