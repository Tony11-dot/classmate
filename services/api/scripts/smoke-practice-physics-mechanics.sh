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

post "physics-kinematics-medium" '{
  "subject":"Physics",
  "topicLabel":"Kinematics",
  "topicPath":["Physics","Mechanics","Kinematics"],
  "topicPathText":"Physics > Mechanics > Kinematics",
  "strictPromptSummary":"Speed, velocity, acceleration, distance-time, motion",
  "questionCount":5,
  "mode":"practice",
  "difficulty":"medium",
  "timePreferenceSeconds":40,
  "useAiTiming":false,
  "maxLives":3
}'

post "physics-kinematics-hard" '{
  "subject":"Physics",
  "topicLabel":"Kinematics",
  "topicPath":["Physics","Mechanics","Kinematics"],
  "topicPathText":"Physics > Mechanics > Kinematics",
  "strictPromptSummary":"Speed, velocity, acceleration, motion equations",
  "questionCount":5,
  "mode":"practice",
  "difficulty":"hard",
  "timePreferenceSeconds":60,
  "useAiTiming":false,
  "maxLives":3
}'

post "physics-newton-laws-medium" '{
  "subject":"Physics",
  "topicLabel":"Newton laws",
  "topicPath":["Physics","Mechanics","Newton laws"],
  "topicPathText":"Physics > Mechanics > Newton laws",
  "strictPromptSummary":"Force, mass, acceleration, Newton second law, F=ma",
  "questionCount":5,
  "mode":"practice",
  "difficulty":"medium",
  "timePreferenceSeconds":40,
  "useAiTiming":false,
  "maxLives":3
}'

post "physics-newton-laws-hard" '{
  "subject":"Physics",
  "topicLabel":"Newton laws",
  "topicPath":["Physics","Mechanics","Newton laws"],
  "topicPathText":"Physics > Mechanics > Newton laws",
  "strictPromptSummary":"Force mass acceleration, net force, F=ma",
  "questionCount":5,
  "mode":"practice",
  "difficulty":"hard",
  "timePreferenceSeconds":60,
  "useAiTiming":false,
  "maxLives":3
}'

post "physics-forces-medium" '{
  "subject":"Physics",
  "topicLabel":"Forces",
  "topicPath":["Physics","Mechanics","Forces"],
  "topicPathText":"Physics > Mechanics > Forces",
  "strictPromptSummary":"Net force, balanced forces, friction basics",
  "questionCount":5,
  "mode":"practice",
  "difficulty":"medium",
  "timePreferenceSeconds":40,
  "useAiTiming":false,
  "maxLives":3
}'

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
