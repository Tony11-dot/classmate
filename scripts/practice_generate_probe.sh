#!/usr/bin/env bash
set -euo pipefail

BASE="${BASE:-http://127.0.0.1:3001}"
TOKEN="${CM_DEV_TOKEN:?CM_DEV_TOKEN is required}"

auth=(-H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json')

probe() {
  local name="$1"
  local payload="$2"

  echo
  echo "===== ${name} ====="

  local body
  body="$(curl -fsS "${auth[@]}" "$BASE/practice/generate" --data @"$payload")"

  echo "-- count --"
  jq '.questions | length' <<<"$body"

  echo "-- ids --"
  jq -r '.questions[].id' <<<"$body"

  echo "-- prompts --"
  jq -r '.questions[].prompt' <<<"$body"

  echo "-- structural check --"
  jq '
    (.questions | length) > 0 and
    ([.questions[] |
      ((.prompt | type) == "string") and
      ((.explanation | type) == "string") and
      ((.options | type) == "array") and
      ((.options | length) == 4) and
      ((.correctIndex | type) == "number") and
      (.correctIndex >= 0 and .correctIndex <= 3) and
      ((.recommendedTimeSeconds | type) == "number")
    ] | all)
  ' <<<"$body"

  echo "-- duplicate fingerprint check --"
  jq -r '
    .questions[]
    | ((.prompt | ascii_downcase | gsub("\\s+";" ")) + "##" + ((.options | map(ascii_downcase) | join("||"))))
  ' <<<"$body" | sort | uniq -d || true

  echo "-- duplicate count --"
  jq -r '
    [.questions[]
      | ((.prompt | ascii_downcase | gsub("\\s+";" ")) + "##" + ((.options | map(ascii_downcase) | join("||"))))
    ] as $fps
    | ($fps | length) - ($fps | unique | length)
  ' <<<"$body"

  echo "-- weak explanation phrases --"
  jq -r '
    .questions[]
    | select(
        (.explanation | ascii_downcase | contains("correction needed")) or
        (.explanation | ascii_downcase | contains("adjust options")) or
        (.explanation | ascii_downcase | contains("options should be adjusted")) or
        (.explanation | ascii_downcase | contains("must be adjusted")) or
        (.explanation | ascii_downcase | contains("re-check calculation")) or
        (.explanation | ascii_downcase | contains("recheck calculation")) or
        (.explanation | ascii_downcase | contains("correction:")) or
        (.explanation | ascii_downcase | contains("this contradicts options")) or
        (.explanation | ascii_downcase | contains("correct option is")) or
        (.explanation | ascii_downcase | contains("wait:")) or
        (.explanation | ascii_downcase | contains("to align with problem")) or
        (.explanation | ascii_downcase | contains("to match options")) or
        (.explanation | ascii_downcase | contains("options mismatch")) or
        (.explanation | ascii_downcase | contains("accept as final")) or
        (.explanation | ascii_downcase | contains("for coherence")) or
        (.explanation | ascii_downcase | contains("closest is"))
      )
    | .prompt
  ' <<<"$body"
}

probe "quadratic_olympiad" /tmp/practice_quadratic.json
probe "trigonometry_hard" /tmp/practice_trig.json
probe "cs_conditions_easy" /tmp/practice_cs_conditions.json
