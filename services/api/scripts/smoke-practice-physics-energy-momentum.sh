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

post "physics-energy-medium" '{
  "subject":"Physics",
  "topicLabel":"Energy",
  "topicPath":["Physics","Mechanics","Energy"],
  "topicPathText":"Physics > Mechanics > Energy",
  "strictPromptSummary":"Work, kinetic energy, potential energy, conservation of energy",
  "questionCount":5,
  "mode":"practice",
  "difficulty":"medium",
  "timePreferenceSeconds":40,
  "useAiTiming":false,
  "maxLives":3
}'

post "physics-energy-hard" '{
  "subject":"Physics",
  "topicLabel":"Energy",
  "topicPath":["Physics","Mechanics","Energy"],
  "topicPathText":"Physics > Mechanics > Energy",
  "strictPromptSummary":"Work, power, kinetic energy, potential energy, conservation of energy",
  "questionCount":5,
  "mode":"practice",
  "difficulty":"hard",
  "timePreferenceSeconds":60,
  "useAiTiming":false,
  "maxLives":3
}'

post "physics-momentum-medium" '{
  "subject":"Physics",
  "topicLabel":"Momentum",
  "topicPath":["Physics","Mechanics","Momentum"],
  "topicPathText":"Physics > Mechanics > Momentum",
  "strictPromptSummary":"Momentum, impulse, collisions",
  "questionCount":5,
  "mode":"practice",
  "difficulty":"medium",
  "timePreferenceSeconds":40,
  "useAiTiming":false,
  "maxLives":3
}'

post "physics-momentum-hard" '{
  "subject":"Physics",
  "topicLabel":"Momentum",
  "topicPath":["Physics","Mechanics","Momentum"],
  "topicPathText":"Physics > Mechanics > Momentum",
  "strictPromptSummary":"Momentum, impulse, conservation of momentum, collisions",
  "questionCount":5,
  "mode":"practice",
  "difficulty":"hard",
  "timePreferenceSeconds":60,
  "useAiTiming":false,
  "maxLives":3
}'
