#!/usr/bin/env bash
set -euo pipefail

API="${API:-http://localhost:3000}"
TOKEN="${TOKEN:-dev-token-student1@classmate.app}"

post() {
  local name="$1"
  local payload="$2"
  echo
  echo "===== $name ====="
  curl -sS -X POST "$API/practice/generate" \
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
