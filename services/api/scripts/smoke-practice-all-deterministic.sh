#!/usr/bin/env bash
set -euo pipefail

: "${BASE_URL:?BASE_URL is required}"
: "${TOKEN:?TOKEN is required}"

post() {
  local subject="$1"
  local topic="$2"
  local difficulty="$3"
  local count="${4:-5}"

  echo
  echo "===== ${subject}-${topic}-${difficulty} ====="

  curl -sS \
    -X POST "${BASE_URL}/practice/generate" \
    -H "Authorization: Bearer ${TOKEN}" \
    -H 'Content-Type: application/json' \
    --data "{
      \"subject\":\"${subject}\",
      \"topic\":\"${topic}\",
      \"difficulty\":\"${difficulty}\",
      \"questionCount\":${count},
      \"mode\":\"practice\"
    }"
}

post "Physics" "Energy" "medium" 5
post "Physics" "Energy" "hard" 5
post "Physics" "Momentum" "medium" 5
post "Physics" "Momentum" "hard" 5
post "Physics" "Electricity" "medium" 5
post "Physics" "Electric field" "medium" 5
post "Physics" "Circuits" "medium" 5
post "Physics" "Waves" "medium" 5
post "Physics" "Optics" "medium" 5
post "Physics" "Thermodynamics" "medium" 5
post "Physics" "Kinematics" "medium" 5
post "Physics" "Newton laws" "medium" 5
post "Physics" "Forces" "medium" 5

post "Math" "Linear equations" "medium" 3
post "Math" "Systems of equations" "medium" 3
post "Math" "Probability" "medium" 3
post "Math" "Statistics" "medium" 3
post "Math" "Functions" "medium" 3
post "Math" "Sequences" "medium" 3
post "Math" "Geometry" "medium" 3
post "Math" "Quadratic equations" "easy" 3
post "Math" "Trigonometry" "medium" 3
post "Math" "Derivatives" "medium" 3
post "Math" "Limits" "medium" 3
