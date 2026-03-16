#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://localhost:3000}"
TOKEN="${TOKEN:-dev-token-student1@classmate.app}"

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

post "linear-medium" '{
  "subject": "Math",
  "topicLabel": "Linear equations",
  "topicPath": ["Math", "Algebra", "Linear equations"],
  "topicPathText": "Math > Algebra > Linear equations",
  "strictPromptSummary": "Solve one-variable linear equations",
  "questionCount": 3,
  "mode": "practice",
  "difficulty": "medium",
  "timePreferenceSeconds": 45,
  "useAiTiming": false,
  "maxLives": 3
}'

post "systems-medium" '{
  "subject": "Math",
  "topicLabel": "Systems of equations",
  "topicPath": ["Math", "Algebra", "Systems of equations"],
  "topicPathText": "Math > Algebra > Systems of equations",
  "strictPromptSummary": "Solve a system of two linear equations",
  "questionCount": 3,
  "mode": "practice",
  "difficulty": "medium",
  "timePreferenceSeconds": 55,
  "useAiTiming": false,
  "maxLives": 3
}'


post "probability-medium" '{
  "subject": "Math",
  "topicLabel": "Probability",
  "topicPath": ["Math", "Probability"],
  "topicPathText": "Math > Probability",
  "strictPromptSummary": "Basic probability and compound probability",
  "questionCount": 3,
  "mode": "practice",
  "difficulty": "medium",
  "timePreferenceSeconds": 40,
  "useAiTiming": false,
  "maxLives": 3
}'

post "quadratic-easy" '{
  "subject": "Math",
  "topicLabel": "Quadratic equations",
  "topicPath": ["Math", "Algebra", "Quadratic equations"],
  "topicPathText": "Math > Algebra > Quadratic equations",
  "strictPromptSummary": "Solve quadratic equations",
  "questionCount": 3,
  "mode": "practice",
  "difficulty": "easy",
  "timePreferenceSeconds": 30,
  "useAiTiming": false,
  "maxLives": 3
}'

post "trigonometry-medium" '{
  "subject": "Math",
  "topicLabel": "Trigonometry",
  "topicPath": ["Math", "Trigonometry"],
  "topicPathText": "Math > Trigonometry",
  "strictPromptSummary": "Special angles and exact trigonometric values",
  "questionCount": 3,
  "mode": "practice",
  "difficulty": "medium",
  "timePreferenceSeconds": 40,
  "useAiTiming": false,
  "maxLives": 3
}'
