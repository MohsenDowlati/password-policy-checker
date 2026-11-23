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

_has_six_char_run() {
  local text="${1,,}"  # Case-insensitive ASCII matching
  shift

  local row i fragment
  for row in "$@"; do
    for ((i = 0; i + 6 <= ${#row}; i++)); do
      fragment="${row:i:6}"
      if [[ "$text" == *"$fragment"* ]]; then
        return 0
      fi
    done
  done

  return 1
}

check_sequential_run() {
  if _has_six_char_run "$1" \
    abcdefghijklmnopqrstuvwxyz zyxwvutsrqponmlkjihgfedcba \
    0123456789 9876543210; then
    log_fail "Sequential run check: six consecutive letters or digits detected"
    return 1
  fi

  log_pass "Sequential run check: Passed"
  return 0
}

check_keyboard_walk() {
  if _has_six_char_run "$1" \
    qwertyuiop poiuytrewq \
    asdfghjkl lkjhgfdsa \
    zxcvbnm mnbvcxz; then
    log_fail "Keyboard walk check: six adjacent keys in a QWERTY row detected"
    return 1
  fi

  log_pass "Keyboard walk check: Passed"
  return 0
}