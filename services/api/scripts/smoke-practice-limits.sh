#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:3001}"
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

post "limits-medium" '{
  "subject":"Math",
  "topicLabel":"Limits",
  "topicPath":["Math","Calculus","Limits"],
  "topicPathText":"Math > Calculus > Limits",
  "strictPromptSummary":"Limits by substitution, factorization, one-sided intuition",
  "questionCount":5,
  "mode":"practice",
  "difficulty":"medium",
  "timePreferenceSeconds":40,
  "useAiTiming":false,
  "maxLives":3
}'

post "limits-hard" '{
  "subject":"Math",
  "topicLabel":"Limits",
  "topicPath":["Math","Calculus","Limits"],
  "topicPathText":"Math > Calculus > Limits",
  "strictPromptSummary":"Limits by substitution, factorization, one-sided intuition",
  "questionCount":5,
  "mode":"practice",
  "difficulty":"hard",
  "timePreferenceSeconds":60,
  "useAiTiming":false,
  "maxLives":3
}'

post "limits-olympiad" '{
  "subject":"Math",
  "topicLabel":"Limits",
  "topicPath":["Math","Calculus","Limits"],
  "topicPathText":"Math > Calculus > Limits",
  "strictPromptSummary":"Limits by substitution, factorization, one-sided intuition",
  "questionCount":5,
  "mode":"practice",
  "difficulty":"olympiad",
  "timePreferenceSeconds":75,
  "useAiTiming":false,
  "maxLives":3
}'
