#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:3001}"
TOKEN="${TOKEN:-dev-token-student1@classmate.app}"

printf '\n=== LIVE CANARY: OPTICS ===\n'
curl -sS -X POST "$BASE_URL/practice/generate" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  --data '{"subject":"Physics","topic":"Optics","difficulty":"medium","mode":"practice","count":5}' \
  >/tmp/optics-live.json

jq -e '
  (.questions | length) == 5 and
  ([.questions[].options | length] | all(. == 4)) and
  ([.questions[].correctIndex] | all(. >= 0 and . < 4)) and
  ([.questions[].prompt] | all(type == "string" and length > 0)) and
  ([.questions[].explanation] | all(type == "string" and length > 0)) and
  ([.questions[].recommendedTimeSeconds] | all(type == "number" and . >= 5 and . <= 900))
' /tmp/optics-live.json >/dev/null

jq '.questions | length' /tmp/optics-live.json

printf '\n=== FALLBACK LIVE MATRIX ===\n'
for payload in \
  '{"subject":"Physics","topic":"Magnetism","difficulty":"easy","mode":"practice","count":3,"timePreferenceSeconds":20,"useAiTiming":true,"maxLives":1}' \
  '{"subject":"Math","topic":"Polynomials","difficulty":"hard","mode":"examPrep","count":3,"timePreferenceSeconds":75,"useAiTiming":true,"maxLives":2}' \
  '{"subject":"Physics","topic":"Relativity","difficulty":"medium","mode":"conceptBuilder","count":3,"timePreferenceSeconds":45,"useAiTiming":false,"maxLives":3}' \
  '{"subject":"Math","topic":"Set theory","difficulty":"medium","mode":"flashcards","count":3,"timePreferenceSeconds":18,"useAiTiming":true,"maxLives":1}'
do
  echo "PAYLOAD=$payload"

  curl -sS -X POST "$BASE_URL/practice/generate" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    --data "$payload" >/tmp/practice-live.json

  jq -e '
    (.questions | length) == 3 and
    ([.questions[].options | length] | all(. == 4)) and
    ([.questions[].correctIndex] | all(. >= 0 and . < 4)) and
    ([.questions[].prompt] | all(type == "string" and length > 0)) and
    ([.questions[].explanation] | all(type == "string" and length > 0)) and
    ([.questions[].recommendedTimeSeconds] | all(type == "number" and . >= 5 and . <= 900))
  ' /tmp/practice-live.json >/dev/null || {
    echo 'FAIL_PAYLOAD'
    cat /tmp/practice-live.json
    exit 1
  }

  jq '.questions[] | {topicLabel, mode, difficulty, prompt, recommendedTimeSeconds}' /tmp/practice-live.json
done

echo "practice-live-full-ok"
