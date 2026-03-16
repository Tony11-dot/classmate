#!/usr/bin/env bash
set -euo pipefail

: "${CM_DEV_TOKEN:?CM_DEV_TOKEN is required}"
probe_failed=0

probe() {
  local name="$1"
  local payload="$2"

  echo
  echo "===== ${name} ====="

  local body
  body="$(
    curl -fsS \
      -H "Authorization: Bearer ${CM_DEV_TOKEN}" \
      -H 'Content-Type: application/json' \
      http://127.0.0.1:3001/practice/generate \
      --data @"${payload}"
  )"

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
  weak="$(
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
          (.explanation | ascii_downcase | contains("closest is")) or
          (.explanation | ascii_downcase | contains("not in the options")) or
          (.explanation | ascii_downcase | contains("not among the options")) or
          (.explanation | ascii_downcase | contains("option mismatch")) or
          (.explanation | ascii_downcase | contains("mismatch")) or
          (.explanation | ascii_downcase | contains("re-examine")) or
          (.explanation | ascii_downcase | contains("reconsider")) or
          (.explanation | ascii_downcase | contains("fixing this accordingly")) or
          (.explanation | ascii_downcase | contains("replace options")) or
          (.explanation | ascii_downcase | contains("change question")) or
          (.explanation | ascii_downcase | contains("choose option")) or
          (.explanation | ascii_downcase | contains("check again")) or
          (.explanation | ascii_downcase | contains("double-check")) or
          (.explanation | ascii_downcase | contains("review again")) or
          (.explanation | ascii_downcase | contains("revisit")) or
          (.explanation | ascii_downcase | contains("but the options")) or
          (.explanation | ascii_downcase | contains("however the options")) or
          (.explanation | ascii_downcase | contains("does not match the options")) or
          (.explanation | ascii_downcase | contains("doesn'\''t match the options")) or
          (.explanation | ascii_downcase | contains("approximately")) or
          (.explanation | ascii_downcase | contains("approximate")) or
          (.explanation | ascii_downcase | contains("assuming a typo")) or
          (.explanation | ascii_downcase | contains("nearest option")) or
          (.explanation | ascii_downcase | contains("pick the closest")) or
          (.explanation | ascii_downcase | contains("best match")) or
          (.explanation | ascii_downcase | contains("none of the options")) or
          (.explanation | ascii_downcase | contains("option not listed")) or
          (.explanation | ascii_downcase | contains("not listed")) or
          (.explanation | ascii_downcase | contains("none match"))
      )
      | .prompt
    ' <<<"$body"
  )"

  printf '%s\n' "$weak"

  if [[ -n "$weak" ]]; then
    probe_failed=1
    echo "probe_status=FAIL weak_explanations_present"
  fi
}

probe "quadratic_olympiad" /tmp/practice_quadratic.json
probe "trigonometry_hard" /tmp/practice_trig.json
probe "cs_conditions_easy" /tmp/practice_cs_conditions.json

exit "$probe_failed"
