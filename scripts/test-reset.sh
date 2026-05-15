#!/usr/bin/env bash
# Interactive smoke test for the password-reset flow against Railway.
#
# Usage:
#   ./scripts/test-reset.sh <identifier>          # defaults to email channel
#   ./scripts/test-reset.sh <identifier> sms      # try SMS instead
#
# The script:
#   1. POSTs /auth/forgot-password
#   2. Waits for you to fetch the token from the email/SMS link
#   3. POSTs /auth/reset-password with a new password you type in
#   4. Tries to log in with the new password to confirm it stuck
#
# Override API_URL env var to point at localhost / a staging deploy.

set -euo pipefail

API_URL="${API_URL:-https://pacific-enchantment-production-7a80.up.railway.app}"
identifier="${1:-}"
channel="${2:-email}"

if [[ -z "${identifier}" ]]; then
  echo "Usage: $0 <email-or-username> [email|sms]"
  exit 1
fi
if [[ "${channel}" != "email" && "${channel}" != "sms" ]]; then
  echo "Channel must be 'email' or 'sms'."
  exit 1
fi

bold() { printf '\033[1m%s\033[0m\n' "$*"; }
dim()  { printf '\033[2m%s\033[0m\n' "$*"; }
ok()   { printf '\033[32m✓\033[0m %s\n' "$*"; }
err()  { printf '\033[31m✗\033[0m %s\n' "$*"; }

bold "API: ${API_URL}"
bold "Identifier: ${identifier}    Channel: ${channel}"
echo

# ── 1. Request the reset ─────────────────────────────────────────────────────

bold "1/4  Requesting reset link…"
forgot_body=$(jq -nc --arg id "${identifier}" --arg ch "${channel}" \
  '{identifier:$id, channel:$ch}')

forgot_response=$(curl -fsS -X POST "${API_URL}/auth/forgot-password" \
  -H 'Content-Type: application/json' \
  -d "${forgot_body}") || {
  err "Forgot-password request failed. Is RESEND_API_KEY set in Railway? Has the deploy finished?"
  exit 1
}
echo "${forgot_response}" | jq .
ok "Reset endpoint responded 200."
echo

# ── 2. Wait for the token ────────────────────────────────────────────────────

bold "2/4  Check your ${channel} for the link."
dim   "      Format: ${API_URL}/reset-password?token=<token>"
dim   "      Copy the value AFTER 'token=' (or the full URL — we'll extract it)."
echo
read -r -p "Paste token (or full URL): " raw
echo

# Extract just the token part — accept either bare token or full URL with ?token=…
if [[ "${raw}" == *"token="* ]]; then
  token="${raw##*token=}"
  token="${token%%&*}"  # strip trailing query params if any
else
  token="${raw}"
fi
token="$(echo -n "${token}" | tr -d '[:space:]')"
if [[ -z "${token}" ]]; then
  err "No token captured."
  exit 1
fi
dim "Extracted token: ${token:0:20}…"
echo

# ── 3. Set the new password ──────────────────────────────────────────────────

bold "3/4  Set a new password (8+ chars, won't echo)."
read -r -s -p "New password: " pw1; echo
read -r -s -p "Confirm:      " pw2; echo
if [[ "${pw1}" != "${pw2}" ]]; then
  err "Passwords don't match."
  exit 1
fi
if [[ "${#pw1}" -lt 8 ]]; then
  err "Password must be at least 8 characters."
  exit 1
fi

reset_body=$(jq -nc --arg t "${token}" --arg p "${pw1}" \
  '{token:$t, newPassword:$p}')

reset_response=$(curl -fsS -X POST "${API_URL}/auth/reset-password" \
  -H 'Content-Type: application/json' \
  -d "${reset_body}") || {
  err "Reset failed. Token may be expired, invalid, or already used."
  exit 1
}
echo "${reset_response}" | jq .
ok "Password reset accepted."
echo

# ── 4. Confirm by logging in ─────────────────────────────────────────────────

bold "4/4  Confirming new password works via /auth/login…"
login_body=$(jq -nc --arg id "${identifier}" --arg p "${pw1}" \
  '{identifier:$id, password:$p}')

login_response=$(curl -fsS -X POST "${API_URL}/auth/login" \
  -H 'Content-Type: application/json' \
  -d "${login_body}") || {
  err "Login failed with the new password. (If this is a dev-token deploy, the login endpoint may not actually validate the password — that's expected.)"
  exit 1
}
token_short=$(echo "${login_response}" | jq -r '.token' | head -c 30)
ok "Login succeeded. Token starts with: ${token_short}…"
echo
bold "All four steps green. The reset flow is working end-to-end."
