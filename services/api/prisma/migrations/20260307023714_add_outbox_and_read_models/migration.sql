-- CreateTable
CREATE TABLE "outbox_events" (
    "id" UUID NOT NULL,
    "type" TEXT NOT NULL,
    "aggregate_id" UUID,
    "payload" JSONB NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "available_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "processed_at" TIMESTAMP(3),
    "failed_at" TIMESTAMP(3),
    "retry_count" INTEGER NOT NULL DEFAULT 0,
    "error" TEXT,

    CONSTRAINT "outbox_events_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "feed_solution_cards" (
    "solution_id" UUID NOT NULL,
    "school_id" UUID NOT NULL,
    "class_id" UUID,
    "author_id" UUID NOT NULL,
    "author_name" TEXT NOT NULL,
    "subject" TEXT NOT NULL,
    "source_type" TEXT NOT NULL,
    "source_name" TEXT,
    "page" INTEGER,
    "question_number" TEXT,
    "title" TEXT,
    "body_preview" TEXT,
    "primary_image_url" TEXT,
    "image_count" INTEGER NOT NULL DEFAULT 0,
    "like_count" INTEGER NOT NULL DEFAULT 0,
    "comment_count" INTEGER NOT NULL DEFAULT 0,
    "repost_count" INTEGER NOT NULL DEFAULT 0,
    "ranking_score" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "teacher_pick" BOOLEAN NOT NULL DEFAULT false,
    "best_solution" BOOLEAN NOT NULL DEFAULT false,
    "difficulty" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "feed_solution_cards_pkey" PRIMARY KEY ("solution_id")
);

-- CreateTable
CREATE TABLE "classroom_preview_cards" (
    "classroom_id" UUID NOT NULL,
    "school_id" UUID,
    "title" TEXT NOT NULL,
    "subject" TEXT,
    "latest_message_text" TEXT,
    "latest_message_at" TIMESTAMP(3),
    "latest_sender_name" TEXT,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "classroom_preview_cards_pkey" PRIMARY KEY ("classroom_id")
);

-- CreateTable
CREATE TABLE "classroom_user_counters" (
    "id" UUID NOT NULL,
    "classroom_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "unread_count" INTEGER NOT NULL DEFAULT 0,
    "last_seen_message_id" UUID,
    "last_seen_at" TIMESTAMP(3),
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "classroom_user_counters_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "weekly_solver_leaderboard" (
    "id" UUID NOT NULL,
    "school_id" UUID NOT NULL,
    "week_key" TEXT NOT NULL,
    "user_id" UUID NOT NULL,
    "user_name" TEXT NOT NULL,
    "solution_count" INTEGER NOT NULL DEFAULT 0,
    "like_count_received" INTEGER NOT NULL DEFAULT 0,
    "comment_count_received" INTEGER NOT NULL DEFAULT 0,
    "repost_count_received" INTEGER NOT NULL DEFAULT 0,
    "score" DOUBLE PRECISION NOT NULL DEFAULT 0,

    CONSTRAINT "weekly_solver_leaderboard_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "idx_outbox_process_queue" ON "outbox_events"("processed_at", "available_at", "created_at");

-- CreateIndex
CREATE INDEX "idx_outbox_type_created_at" ON "outbox_events"("type", "created_at");

-- CreateIndex
CREATE INDEX "idx_feed_solution_cards_school_rank_created" ON "feed_solution_cards"("school_id", "ranking_score" DESC, "created_at" DESC);

-- CreateIndex
CREATE INDEX "idx_feed_solution_cards_school_subject_rank" ON "feed_solution_cards"("school_id", "subject", "ranking_score" DESC);

-- CreateIndex
CREATE INDEX "idx_feed_solution_cards_lookup" ON "feed_solution_cards"("school_id", "source_name", "page", "question_number");

-- CreateIndex
CREATE INDEX "idx_classroom_preview_cards_school_latest" ON "classroom_preview_cards"("school_id", "latest_message_at" DESC);

-- CreateIndex
CREATE INDEX "idx_classroom_user_counters_user_unread" ON "classroom_user_counters"("user_id", "unread_count" DESC);

-- CreateIndex
CREATE UNIQUE INDEX "uq_classroom_user_counters_classroom_user" ON "classroom_user_counters"("classroom_id", "user_id");

-- CreateIndex
CREATE INDEX "idx_weekly_solver_leaderboard_rank" ON "weekly_solver_leaderboard"("school_id", "week_key", "score" DESC);

-- CreateIndex
CREATE UNIQUE INDEX "uq_weekly_solver_leaderboard_school_week_user" ON "weekly_solver_leaderboard"("school_id", "week_key", "user_id");
