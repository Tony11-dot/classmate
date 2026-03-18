#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:80}"
AUTH_HEADER="${AUTH_HEADER:-}"

run_case() {
  local name="$1"
  local payload="$2"

  echo
  echo "=================================================================="
  echo "CASE: $name"
  echo "=================================================================="

  if [ -n "$AUTH_HEADER" ]; then
    curl -sS \
      -H "Content-Type: application/json" \
      -H "$AUTH_HEADER" \
      -X POST "$BASE_URL/practice/generate" \
      -d "$payload" | jq .
  else
    curl -sS \
      -H "Content-Type: application/json" \
      -X POST "$BASE_URL/practice/generate" \
      -d "$payload" | jq .
  fi
}

run_case "math_quadratics" \
'{
  "subject":"Math",
  "topic":"Quadratic equations",
  "mode":"examPrep",
  "difficulty":"medium",
  "questionCount":3
}'

run_case "physics_optics" \
'{
  "subject":"Physics",
  "topic":"Optics",
  "mode":"conceptBuilder",
  "difficulty":"medium",
  "questionCount":3
}'

run_case "electronics_kirchhoff" \
'{
  "subject":"Electronics",
  "topic":"Kirchhoff Laws",
  "mode":"practice",
  "difficulty":"medium",
  "questionCount":3
}'

run_case "general_knowledge_tennis" \
'{
  "subject":"General Knowledge",
  "topic":"tennis history",
  "mode":"flashcards",
  "difficulty":"easy",
  "questionCount":3
}'

run_case "unsupported_topic_should_be_clean_error" \
'{
  "subject":"General Knowledge",
  "topic":"random thing maybe",
  "mode":"practice",
  "difficulty":"medium",
  "questionCount":3
}'
