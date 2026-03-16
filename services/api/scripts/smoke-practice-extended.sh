#!/usr/bin/env bash
set -euo pipefail

BASE="${BASE:-http://localhost:3000}"
TOKEN="${TOKEN:-dev-token-student1@classmate.app}"

post() {
  local name="$1"
  local body="$2"
  echo
  echo "===== $name ====="
  curl -sS -X POST "$BASE/practice/generate" \
    -H "Authorization: Bearer $TOKEN" \
    -H 'Content-Type: application/json' \
    -d "$body" | jq .
}

post "linear-hard" '{
  "subject":"Math",
  "topicLabel":"Linear equations",
  "topicPath":["Math","Algebra","Linear equations"],
  "topicPathText":"Math > Algebra > Linear equations",
  "strictPromptSummary":"Solve one-variable linear equations",
  "questionCount":5,
  "mode":"practice",
  "difficulty":"hard",
  "timePreferenceSeconds":60,
  "useAiTiming":false,
  "maxLives":3
}'

post "systems-hard" '{
  "subject":"Math",
  "topicLabel":"Systems of equations",
  "topicPath":["Math","Algebra","Systems of equations"],
  "topicPathText":"Math > Algebra > Systems of equations",
  "strictPromptSummary":"Solve a system of two linear equations",
  "questionCount":5,
  "mode":"practice",
  "difficulty":"hard",
  "timePreferenceSeconds":70,
  "useAiTiming":false,
  "maxLives":3
}'

post "probability-hard" '{
  "subject":"Math",
  "topicLabel":"Probability",
  "topicPath":["Math","Probability"],
  "topicPathText":"Math > Probability",
  "strictPromptSummary":"Basic probability and compound probability",
  "questionCount":5,
  "mode":"practice",
  "difficulty":"hard",
  "timePreferenceSeconds":60,
  "useAiTiming":false,
  "maxLives":3
}'

post "geometry-olympiad" '{
  "subject":"Math",
  "topicLabel":"Geometry",
  "topicPath":["Math","Geometry"],
  "topicPathText":"Math > Geometry",
  "strictPromptSummary":"Area, perimeter, triangles, circles",
  "questionCount":5,
  "mode":"practice",
  "difficulty":"olympiad",
  "timePreferenceSeconds":75,
  "useAiTiming":false,
  "maxLives":3
}'

post "quadratic-hard" '{
  "subject":"Math",
  "topicLabel":"Quadratic equations",
  "topicPath":["Math","Algebra","Quadratic equations"],
  "topicPathText":"Math > Algebra > Quadratic equations",
  "strictPromptSummary":"Solve quadratic equations",
  "questionCount":5,
  "mode":"practice",
  "difficulty":"hard",
  "timePreferenceSeconds":60,
  "useAiTiming":false,
  "maxLives":3
}'

post "trigonometry-hard" '{
  "subject":"Math",
  "topicLabel":"Trigonometry",
  "topicPath":["Math","Trigonometry"],
  "topicPathText":"Math > Trigonometry",
  "strictPromptSummary":"Special angles and exact trigonometric values",
  "questionCount":5,
  "mode":"practice",
  "difficulty":"hard",
  "timePreferenceSeconds":60,
  "useAiTiming":false,
  "maxLives":3
}'
