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

post "physics-electricity-medium" '{
  "subject":"Physics",
  "topicLabel":"Electricity",
  "topicPath":["Physics","Electricity"],
  "topicPathText":"Physics > Electricity",
  "strictPromptSummary":"Charge current voltage power electrical work",
  "questionCount":5,
  "mode":"practice",
  "difficulty":"medium",
  "timePreferenceSeconds":40,
  "useAiTiming":false,
  "maxLives":3
}'

post "physics-electric-field-medium" '{
  "subject":"Physics",
  "topicLabel":"Electric field",
  "topicPath":["Physics","Electricity","Electric field"],
  "topicPathText":"Physics > Electricity > Electric field",
  "strictPromptSummary":"Electric field strength force on charge uniform field",
  "questionCount":5,
  "mode":"practice",
  "difficulty":"medium",
  "timePreferenceSeconds":40,
  "useAiTiming":false,
  "maxLives":3
}'

post "physics-circuits-medium" '{
  "subject":"Physics",
  "topicLabel":"Circuits",
  "topicPath":["Physics","Electricity","Circuits"],
  "topicPathText":"Physics > Electricity > Circuits",
  "strictPromptSummary":"Ohm law series circuits parallel circuits current voltage resistance",
  "questionCount":5,
  "mode":"practice",
  "difficulty":"medium",
  "timePreferenceSeconds":40,
  "useAiTiming":false,
  "maxLives":3
}'

post "physics-waves-medium" '{
  "subject":"Physics",
  "topicLabel":"Waves",
  "topicPath":["Physics","Waves"],
  "topicPathText":"Physics > Waves",
  "strictPromptSummary":"Wave speed frequency wavelength amplitude period",
  "questionCount":5,
  "mode":"practice",
  "difficulty":"medium",
  "timePreferenceSeconds":40,
  "useAiTiming":false,
  "maxLives":3
}'

post "physics-optics-medium" '{
  "subject":"Physics",
  "topicLabel":"Optics",
  "topicPath":["Physics","Optics"],
  "topicPathText":"Physics > Optics",
  "strictPromptSummary":"Reflection refraction mirrors lenses image formation",
  "questionCount":5,
  "mode":"practice",
  "difficulty":"medium",
  "timePreferenceSeconds":40,
  "useAiTiming":false,
  "maxLives":3
}'

post "physics-thermodynamics-medium" '{
  "subject":"Physics",
  "topicLabel":"Thermodynamics",
  "topicPath":["Physics","Thermodynamics"],
  "topicPathText":"Physics > Thermodynamics",
  "strictPromptSummary":"Temperature heat specific heat thermal equilibrium expansion",
  "questionCount":5,
  "mode":"practice",
  "difficulty":"medium",
  "timePreferenceSeconds":40,
  "useAiTiming":false,
  "maxLives":3
}'
