#!/usr/bin/bash

normalize_for_denylist() {
  local s="$1"

  # ASCII lowercase
  s="${s,,}"

  # Common leetspeak substitutions
  s="${s//@/a}"
  s="${s//4/a}"
  s="${s//3/e}"
  s="${s//0/o}"
  s="${s//5/s}"
  s="${s//\$/s}"
  s="${s//7/t}"
  s="${s//!/i}"
  s="${s//1/l}"
  s="${s//8/b}"
  s="${s//9/g}"

  printf '%s' "$s"
}

check_common_password_denylist() {
  local pw="$1"
  local denylist_path="$2"
  local normalized

  if [[ -z "$denylist_path" ]]; then
    log_error "Denylist path is empty."
    return 2
  fi

  if [[ ! -r "$denylist_path" ]]; then
    log_error "Denylist file is not readable: $denylist_path"
    return 2
  fi

  normalized="$(normalize_for_denylist "$pw")"

  # grep -Fxiq ( fixed string - not regex, whole line exact match, case-insensitive, quiet)
  # Preprocess once
  if grep -Fxiq -- "$normalized" "$denylist_path"; then
    log_fail "Common-password denylist check: Password matched a blocked password"
    return 1
  fi

  log_pass "Common-password denylist check: Passed"
  return 0
}

