#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:3001}"
TOKEN="${TOKEN:-dev-token-student1@classmate.app}"

run_payload() {
  local name="$1"
  local payload="$2"

  echo
  echo "===== $name ====="

  curl -sS -X POST "$BASE_URL/practice/generate" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    --data "$payload" >/tmp/practice-blocker.json

  jq -e '
    (.questions | length) >= 3 and
    ([.questions[].options | length] | all(. == 4)) and
    ([.questions[].correctIndex] | all(. >= 0 and . < 4)) and
    ([.questions[].topicLabel] | all(type == "string" and length > 0 and . != "General")) and
    ([.questions[].mode] | all(type == "string" and length > 0)) and
    ([.questions[].difficulty] | all(type == "string" and length > 0)) and
    ([.questions[].prompt] | all(type == "string" and length > 0)) and
    ([.questions[].explanation] | all(type == "string" and length > 0)) and
    ([.questions[].recommendedTimeSeconds] | all(type == "number" and . >= 5 and . <= 900))
  ' /tmp/practice-blocker.json >/dev/null || {
    echo 'FAIL_BLOCKER_PAYLOAD'
    cat /tmp/practice-blocker.json
    exit 1
  }

  jq '.questions[] | {topicLabel, mode, difficulty, prompt, recommendedTimeSeconds}' /tmp/practice-blocker.json
}

run_payload \
  "optics_practice_medium_5" \
  '{"subject":"Physics","topic":"Optics","difficulty":"medium","mode":"practice","count":5}'

run_payload \
  "magnetism_practice_easy_3" \
  '{"subject":"Physics","topic":"Magnetism","difficulty":"easy","mode":"practice","count":3,"timePreferenceSeconds":20,"useAiTiming":true,"maxLives":1}'

run_payload \
  "polynomials_examPrep_hard_3" \
  '{"subject":"Math","topic":"Polynomials","difficulty":"hard","mode":"examPrep","count":3,"timePreferenceSeconds":75,"useAiTiming":true,"maxLives":2}'

run_payload \
  "relativity_conceptBuilder_medium_3" \
  '{"subject":"Physics","topic":"Relativity","difficulty":"medium","mode":"conceptBuilder","count":3,"timePreferenceSeconds":45,"useAiTiming":false,"maxLives":3}'

run_payload \
  "set_theory_flashcards_medium_3" \
  '{"subject":"Math","topic":"Set theory","difficulty":"medium","mode":"flashcards","count":3,"timePreferenceSeconds":18,"useAiTiming":true,"maxLives":1}'

echo
echo "practice-blockers-ok"
