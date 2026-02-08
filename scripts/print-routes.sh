#!/usr/bin/env bash
set -euo pipefail

ROOT="services/api/src"

# Prints:
# file | controller_base | METHOD route
# Best-effort: works when decorators use string literals.

current_file=""
controller=""

emit_file_header() {
  :
}

while IFS= read -r line; do
  # file marker lines come from rg --heading output
  if [[ "$line" == services/api/src/* ]]; then
    current_file="$line"
    controller=""
    continue
  fi

  # Controller base
  if [[ "$line" =~ @Controller\((.*)\) ]]; then
    raw="${BASH_REMATCH[1]}"
    # strip quotes/spaces
    controller="$(echo "$raw" | sed -E "s/^[[:space:]]*['\"]?//; s/['\"]?[[:space:]]*$//")"
    continue
  fi

  # Methods
  if [[ "$line" =~ @(Get|Post|Patch|Delete|Put)\((.*)\) ]]; then
    m="${BASH_REMATCH[1]}"
    raw="${BASH_REMATCH[2]}"
    route="$(echo "$raw" | sed -E "s/^[[:space:]]*['\"]?//; s/['\"]?[[:space:]]*$//")"
    # handle empty decorator: @Get()
    if [[ "$raw" == "" ]]; then route=""; fi
    printf "%s\t%s\t%s\t%s\n" "$current_file" "${controller:-<none>}" "$m" "${route:-<none>}"
  fi
done < <(rg -n --heading '@Controller\(|@(Get|Post|Patch|Delete|Put)\(' "$ROOT" \
      | sed -E 's/^[0-9]+://')
