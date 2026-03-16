#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://localhost:3000}"
TOKEN="${TOKEN:-dev-token-student1@classmate.app}"

BASE_URL="${BASE_URL%/}"
BASE_URL="${BASE_URL%/api}"

post() {
  local name="$1"
  local payload="$2"
  echo
  echo "===== $name ====="
  curl -sS -X POST "$BASE_URL/practice/generate" \
    -H "Authorization: Bearer $TOKEN" \
    -H 'Content-Type: application/json' \
    -d "$payload" | jq .
}

post "functions-medium" '{
  "subject":"Math",
  "topicLabel":"Functions",
  "topicPath":["Math","Algebra","Functions"],
  "topicPathText":"Math > Algebra > Functions",
  "strictPromptSummary":"Evaluate functions, slope, intercept, linear functions",
  "questionCount":5,
  "mode":"practice",
  "difficulty":"medium",
  "timePreferenceSeconds":40,
  "useAiTiming":false,
  "maxLives":3
}'

post "functions-hard" '{
  "subject":"Math",
  "topicLabel":"Functions",
  "topicPath":["Math","Algebra","Functions"],
  "topicPathText":"Math > Algebra > Functions",
  "strictPromptSummary":"Evaluate functions, slope, intercept, linear functions",
  "questionCount":5,
  "mode":"practice",
  "difficulty":"hard",
  "timePreferenceSeconds":60,
  "useAiTiming":false,
  "maxLives":3
}'

post "functions-olympiad" '{
  "subject":"Math",
  "topicLabel":"Functions",
  "topicPath":["Math","Algebra","Functions"],
  "topicPathText":"Math > Algebra > Functions",
  "strictPromptSummary":"Evaluate functions, slope, intercept, linear functions",
  "questionCount":5,
  "mode":"practice",
  "difficulty":"olympiad",
  "timePreferenceSeconds":75,
  "useAiTiming":false,
  "maxLives":3
}'
