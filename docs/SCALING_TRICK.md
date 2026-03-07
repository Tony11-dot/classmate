# ClassMate scaling trick: WRITE FAST, READ FASTER

## The trick

Do **NOT** make your app read directly from many normalized tables for every screen.

Instead:

1. **Write once** to the source-of-truth tables
2. In the **same DB transaction**, write an **outbox event**
3. A worker consumes outbox events
4. The worker updates **read models / denormalized tables**
5. Mobile/API screens read from the read models only

This is basically:

- transactional outbox
- async projections
- CQRS-lite
- denormalized feed tables
- precomputed counters

---

# Why this scales

Without this:
- feed page = joins on solutions + comments + likes + reposts + users + classrooms
- rankings = expensive aggregations
- unread counts = expensive counts
- classroom previews = expensive latest-message lookups

With this:
- feed = one indexed table read
- classroom preview = one indexed row per classroom
- leaderboard = one indexed table
- notifications = one indexed table
- unread counts = precomputed integers

So your app becomes:
- cheap reads
- fast pagination
- simple mobile endpoints
- easier caching
- much less DB pain

---

# Core rule

## OLTP tables (source of truth)
These stay normalized.

Examples:
- users
- classrooms
- classroom_messages
- solutions
- solution_comments
- solution_likes
- solution_reposts
- notifications
- assignments

## Read models
These are purpose-built for screens.

Examples:
- feed_solution_cards
- classroom_chat_preview
- classroom_unread_counts
- weekly_solver_leaderboard
- notification_inbox_view
- parent_dashboard_summary
- student_insights_snapshot

Your Flutter app should mostly hit **read models**.

---

# The single most important table: outbox_events

Every mutation writes an event here.

Example event types:
- solution.created
- solution.liked
- solution.unliked
- solution.commented
- solution.reposted
- classroom.message.created
- assignment.created
- grade.posted
- notification.created

---

# Flow example: like a solution

1. API receives POST /solutions/:id/like
2. transaction:
   - insert into solution_likes
   - update source counters if needed
   - insert outbox event:
     {
       type: "solution.liked",
       aggregateId: solutionId,
       payload: { solutionId, userId, createdAt }
     }
3. worker picks event
4. worker updates:
   - feed_solution_cards.like_count += 1
   - weekly_solver_leaderboard score
   - maybe notification read model
5. mobile reads feed_solution_cards only

---

# What to precompute for ClassMate first

## 1. Solutions feed read model
Table: `feed_solution_cards`

Columns:
- solution_id
- author_id
- author_name
- subject
- source_type
- source_name
- page
- question_number
- title
- body_preview
- primary_image_url
- image_count
- like_count
- comment_count
- repost_count
- ranking_score
- created_at
- updated_at
- teacher_pick
- best_solution
- difficulty
- school_id
- class_id

Indexes:
- (school_id, ranking_score desc, created_at desc)
- (school_id, subject, ranking_score desc)
- (school_id, source_name, page, question_number)
- (solution_id unique)

## 2. Classroom preview read model
Table: `classroom_preview_cards`

Columns:
- classroom_id
- title
- subject
- latest_message_text
- latest_message_at
- latest_sender_name
- unread_count_by_user? -> separate table preferred

## 3. Unread counters
Table: `classroom_user_counters`

Columns:
- classroom_id
- user_id
- unread_count
- last_seen_message_id
- last_seen_at

Unique:
- (classroom_id, user_id)

## 4. Weekly leaderboard
Table: `weekly_solver_leaderboard`

Columns:
- school_id
- week_key
- user_id
- user_name
- solution_count
- like_count_received
- comment_count_received
- repost_count_received
- score

Unique:
- (school_id, week_key, user_id)

---

# Ranking formula

Keep ranking score precomputed in the read model.

Example:
score =
  likes * 3
+ comments * 5
+ reposts * 4
+ teacher_pick * 20
+ best_solution * 15
+ recency_decay_bonus

Do NOT recompute this live on every request.

Update it when events happen.

---

# Required infra pieces

## 1. transactional outbox
Must be inserted in the SAME transaction as the write.

## 2. projection worker
Can be:
- NestJS cron worker
- BullMQ worker
- dedicated worker process

## 3. idempotency
Projection handlers must be safe to replay.

Use:
- processed_at
- retries
- dedupe keys
- version checks

## 4. backfill command
Need a command to rebuild read models from source tables.

---

# Minimal DB schema sketch

## outbox_events
- id uuid pk
- type text not null
- aggregate_id uuid null
- payload jsonb not null
- created_at timestamptz not null default now()
- available_at timestamptz not null default now()
- processed_at timestamptz null
- failed_at timestamptz null
- retry_count int not null default 0
- error text null

Index:
- (processed_at, available_at, created_at)

## feed_solution_cards
- solution_id uuid pk
- school_id uuid not null
- class_id uuid null
- author_id uuid not null
- author_name text not null
- subject text not null
- source_type text not null
- source_name text null
- page int null
- question_number text null
- title text null
- body_preview text null
- primary_image_url text null
- image_count int not null default 0
- like_count int not null default 0
- comment_count int not null default 0
- repost_count int not null default 0
- ranking_score double precision not null default 0
- teacher_pick boolean not null default false
- best_solution boolean not null default false
- difficulty text null
- created_at timestamptz not null
- updated_at timestamptz not null default now()

Indexes:
- (school_id, ranking_score desc, created_at desc)
- (school_id, subject, ranking_score desc)
- (school_id, source_name, page, question_number)

---

# API shape after this change

## mobile endpoints should become stupid-simple

GET /feed/solutions
- reads feed_solution_cards only
- supports cursor pagination
- supports filters directly on precomputed columns

GET /classrooms
- reads classroom_preview_cards
- joins unread counters if needed

GET /leaderboard/weekly
- reads weekly_solver_leaderboard only

GET /notifications
- reads notification_inbox_view only

No huge live joins.
No expensive per-request aggregations.

---

# NestJS structure

apps/api/src/modules/
- solutions/
- feed/
- outbox/
- projections/
- leaderboard/
- classrooms/

## key services
- OutboxService
- ProjectionRunnerService
- FeedProjectionService
- ClassroomProjectionService
- LeaderboardProjectionService

---

# golden rule for every new feature

Whenever you add a feature, ask:

1. what is the source-of-truth write?
2. what event should be emitted?
3. what read model should be projected?
4. what screen will read that model?

If you do that from now on, ClassMate can scale without a rewrite.

---

# The first 7 things to implement now

1. create `outbox_events` table
2. emit events for:
   - solution.created
   - solution.liked
   - solution.unliked
   - solution.commented
   - solution.reposted
3. create `feed_solution_cards`
4. build projection worker for solutions feed
5. change feed endpoint to read only from `feed_solution_cards`
6. create `classroom_preview_cards`
7. create `classroom_user_counters`

---

# Why this is the right move for ClassMate

Because your product already has:
- feeds
- comments
- likes
- notifications
- classrooms
- leaderboards
- AI summaries
- multi-role dashboards

Those products die when they stay fully live-join based.

This architecture lets you:
- move fast
- keep Postgres
- stay in NestJS + Prisma
- avoid rewriting later
- support very large student usage

This is the scaling move.
