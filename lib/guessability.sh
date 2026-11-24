check_guessability() {
  local pw="$1"
  local min_score="$2"
  local result score guesses_log10
  local python_bin="${PYTHON_BIN:-python.exe}"

  if ! command -v "$python_bin" >/dev/null 2>&1; then
    log_error "Python 3 was not found."
    return 2
  fi

  local script_path="$APP_ROOT/lib/zxcvbn_score.py"
  if [[ "$python_bin" == *.exe ]] && command -v wslpath >/dev/null 2>&1; then
    script_path="$(wslpath -w "$script_path")"
  fi

  if ! result=$(printf '%s' "$pw" | "$python_bin" "$script_path" | tr -d '\r'); then
    log_error "Could not calculate zxcvbn score; check that zxcvbn is installed."
    return 2
  fi

  read -r score guesses_log10 <<< "$result"

  if [[ ! "$score" =~ ^[0-4]$ ||
        ! "$guesses_log10" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
    log_error "zxcvbn returned an invalid result."
    return 2
  fi

  if (( score < min_score )); then
    log_fail "Guessability score: ${score}/4 (required: at least ${min_score}/4)"
    return 1
  fi

  log_pass "Guessability score: ${score}/4 (required: at least ${min_score}/4)"
  return 0
}
