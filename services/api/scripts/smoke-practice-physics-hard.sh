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

post "physics-forces-hard" '{
  "subject":"Physics",
  "topicLabel":"Forces",
  "topicPath":["Physics","Mechanics","Forces"],
  "topicPathText":"Physics > Mechanics > Forces",
  "strictPromptSummary":"Net force, balanced forces, friction, normal force",
  "questionCount":5,
  "mode":"practice",
  "difficulty":"hard",
  "timePreferenceSeconds":60,
  "useAiTiming":false,
  "maxLives":3
}'

post "physics-energy-hard" '{
  "subject":"Physics",
  "topicLabel":"Energy",
  "topicPath":["Physics","Mechanics","Energy"],
  "topicPathText":"Physics > Mechanics > Energy",
  "strictPromptSummary":"Kinetic energy, potential energy, work, power",
  "questionCount":5,
  "mode":"practice",
  "difficulty":"hard",
  "timePreferenceSeconds":60,
  "useAiTiming":false,
  "maxLives":3
}'

post "physics-momentum-hard" '{
  "subject":"Physics",
  "topicLabel":"Momentum",
  "topicPath":["Physics","Mechanics","Momentum"],
  "topicPathText":"Physics > Mechanics > Momentum",
  "strictPromptSummary":"Momentum, impulse, conservation of momentum",
  "questionCount":5,
  "mode":"practice",
  "difficulty":"hard",
  "timePreferenceSeconds":60,
  "useAiTiming":false,
  "maxLives":3
}'
