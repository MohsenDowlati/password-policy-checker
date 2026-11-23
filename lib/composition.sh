#!/usr/bin/bash


# Returns 0 if password is composed of a single character (VIOLATION)
# Returns 1 if password contains diverse characters
# O(N) and didn't use grep
is_single_char_repeated() {
  local pw="$1"
  local len="${#pw}"

  (( len <= 1 )) && return 1

  local first_char="${pw:0:1}"

  local stripped="${pw//"$first_char"/}"

  if [[ -z "$stripped" ]]; then
    return 0
  fi

  return 1
}


check_single_char_repeat() {
  local pw="$1"

  if is_single_char_repeated "$pw"; then
    log_fail "Repeated character check: Password consists of only a single repeated character ('${pw:0:1}')"
    return 1
  fi

  log_pass "Repeated character check: Passed (no single-character repetition)"
  return 0
}
