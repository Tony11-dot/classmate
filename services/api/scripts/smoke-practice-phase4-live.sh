#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:3001}"
TOKEN="${TOKEN:-dev-token-student1@classmate.app}"

run_payload() {
  local payload="$1"
  echo
  echo "PAYLOAD=$payload"

  curl -sS -X POST "$BASE_URL/practice/generate" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    --data "$payload" >/tmp/practice-live-payload.json

  jq -e '
    (.questions | length) == 3 and
    ([.questions[].options | length] | all(. == 4)) and
    ([.questions[].options | unique | length] | all(. == 4)) and
    ([.questions[].correctIndex] | all(. >= 0 and . < 4)) and
    ([.questions[].topicLabel] | all(type == "string" and length > 0 and . != "General")) and
    ([.questions[].prompt] | all(type == "string" and length > 0)) and
    ([.questions[].explanation] | all(type == "string" and length > 0)) and
    ([.questions[].recommendedTimeSeconds] | all(type == "number" and . >= 5 and . <= 900))
  ' /tmp/practice-live-payload.json >/dev/null || {
    echo 'FAIL_PAYLOAD'
    cat /tmp/practice-live-payload.json
    exit 1
  }

  jq '.questions[] | {topicLabel, mode, difficulty, prompt, recommendedTimeSeconds}' /tmp/practice-live-payload.json
}

run_payload '{"subject":"Physics","topic":"Magnetism","difficulty":"easy","mode":"practice","count":3,"timePreferenceSeconds":20,"useAiTiming":true,"maxLives":1}'
run_payload '{"subject":"Math","topic":"Polynomials","difficulty":"hard","mode":"examPrep","count":3,"timePreferenceSeconds":75,"useAiTiming":true,"maxLives":2}'
run_payload '{"subject":"Physics","topic":"Relativity","difficulty":"medium","mode":"conceptBuilder","count":3,"timePreferenceSeconds":45,"useAiTiming":false,"maxLives":3}'
run_payload '{"subject":"Math","topic":"Set theory","difficulty":"medium","mode":"flashcards","count":3,"timePreferenceSeconds":18,"useAiTiming":true,"maxLives":1}'

echo
echo "phase4-live-smoke-ok"
