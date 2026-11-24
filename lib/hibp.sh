#!/usr/bin/bash

check_hibp_pwned() {
  local pw="$1"
  local timeout="${2:-3}"

  if ! command -v curl >/dev/null 2>&1; then
    log_error "curl is required for HIBP check but was not found."
    return 2
  fi

  local sha1_hash
  if command -v sha1sum >/dev/null 2>&1; then
    sha1_hash="$(printf '%s' "$pw" | sha1sum | awk '{print toupper($1)}')"
  elif command -v shasum >/dev/null 2>&1; then
    sha1_hash="$(printf '%s' "$pw" | shasum -a 1 | awk '{print toupper($1)}')"
  else
    log_error "sha1sum or shasum is required for HIBP check."
    return 2
  fi

  # Extract 5-character prefix and 35-character suffix
  local prefix="${sha1_hash:0:5}"
  local suffix="${sha1_hash:5}"
  local api_url="https://api.pwnedpasswords.com/range/${prefix}"

  local response
  if ! response=$(curl -fsS --max-time "$timeout" \
                       -H "User-Agent: PasswordPolicyChecker-CLI" \
                       "$api_url"); then
    log_warn "HIBP API request failed or timed out. Skipping check."
    return 0
  fi

  # Strip carriage returns (\r) completely so CRLF doesn't break matching
  response="$(printf '%s' "$response" | tr -d '\r')"

  # Search for "${suffix}:"
  # Using awk guarantees line-by-line prefix matching without shell regex anchor quirks
  local count
  count="$(printf '%s\n' "$response" | awk -F: -v target="$suffix" 'toupper($1) == target { print $2; exit }')"

  if [[ -n "$count" ]]; then
    log_fail "HIBP check: Password has been exposed in data breaches (found $count times in HIBP database)"
    return 1
  fi

  log_pass "HIBP check: Password not found in known breach databases"
  return 0
}
