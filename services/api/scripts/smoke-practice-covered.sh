#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:3001}"
TOKEN="${TOKEN:-dev-token-student1@classmate.app}"
AUTH="Authorization: Bearer ${TOKEN}"


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




post "statistics-medium" '{
  "subject":"Math",
  "topicLabel":"Statistics",
  "topicPath":["Math","Statistics"],
  "topicPathText":"Math > Statistics",
  "strictPromptSummary":"Mean, median, mode, range, averages",
  "questionCount":3,
  "mode":"practice",
  "difficulty":"medium",
  "timePreferenceSeconds":40,
  "useAiTiming":false,
  "maxLives":3
}'

post "functions-medium" '{
  "subject":"Math",
  "topicLabel":"Functions",
  "topicPath":["Math","Algebra","Functions"],
  "topicPathText":"Math > Algebra > Functions",
  "strictPromptSummary":"Evaluate functions, slope, intercept, linear functions",
  "questionCount":3,
  "mode":"practice",
  "difficulty":"medium",
  "timePreferenceSeconds":40,
  "useAiTiming":false,
  "maxLives":3
}'


post "sequences-medium" '{
  "subject":"Math",
  "topicLabel":"Sequences",
  "topicPath":["Math","Sequences"],
  "topicPathText":"Math > Sequences",
  "strictPromptSummary":"Arithmetic sequences, geometric sequences, common difference, common ratio",
  "questionCount":3,
  "mode":"practice",
  "difficulty":"medium",
  "timePreferenceSeconds":40,
  "useAiTiming":false,
  "maxLives":3
}'

post "geometry-medium" '{
  "subject": "Math",
  "topicLabel": "Geometry",
  "topicPath": ["Math", "Geometry"],
  "topicPathText": "Math > Geometry",
  "strictPromptSummary": "Area, perimeter, triangles, circles",
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

echo
echo "===== derivatives-medium ====="
curl -sS -X POST "$BASE_URL/practice/generate" \
  -H "$AUTH" \
  -H 'Content-Type: application/json' \
  -d '{
    "subject":"Math",
    "topicLabel":"Derivatives",
    "topicPath":["Math","Calculus","Derivatives"],
    "topicPathText":"Math > Calculus > Derivatives",
    "strictPromptSummary":"Derivative rules, tangent slope, power rule",
    "questionCount":3,
    "mode":"practice",
    "difficulty":"medium",
    "timePreferenceSeconds":40,
    "useAiTiming":false,
    "maxLives":3
  }' | jq .

echo
echo "===== limits-medium ====="
curl -sS -X POST "$BASE_URL/practice/generate" \
  -H "$AUTH" \
  -H 'Content-Type: application/json' \
  -d '{
    "subject":"Math",
    "topicLabel":"Limits",
    "topicPath":["Math","Calculus","Limits"],
    "topicPathText":"Math > Calculus > Limits",
    "strictPromptSummary":"Limits, approaching values, continuity, removable discontinuities",
    "questionCount":3,
    "mode":"practice",
    "difficulty":"medium",
    "timePreferenceSeconds":40,
    "useAiTiming":false,
    "maxLives":3
  }' | jq .




post "physics-kinematics-medium" '{
  "subject":"Physics",
  "topicLabel":"Kinematics",
  "topicPath":["Physics","Mechanics","Kinematics"],
  "topicPathText":"Physics > Mechanics > Kinematics",
  "strictPromptSummary":"Speed, velocity, acceleration, distance-time",
  "questionCount":5,
  "mode":"practice",
  "difficulty":"medium",
  "timePreferenceSeconds":40,
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

post "physics-electricity-medium" '{
  "subject":"Physics",
  "topicLabel":"Electricity",
  "topicPath":["Physics","Electricity"],
  "topicPathText":"Physics > Electricity",
  "strictPromptSummary":"Charge current voltage resistance power basic electricity",
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
  "strictPromptSummary":"Electric force electric field field direction charge interactions",
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
