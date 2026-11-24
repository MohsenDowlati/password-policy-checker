check_guessability() {
  local pw="$1"
  local min_score="$2"
  local result score guesses_log10 patterns
  local python_bin="${PYTHON_BIN:-python.exe}"

  if ! command -v "$python_bin" >/dev/null 2>&1; then
    log_error "Python 3 was not found: '$python_bin'"
    return 2
  fi

  local script_path="$APP_ROOT/lib/zxcvbn_score.py"
  if [[ "$python_bin" == *.exe ]] && command -v wslpath >/dev/null 2>&1; then
    script_path="$(wslpath -w "$script_path")"
  fi

  if ! result=$(printf '%s' "$pw" | "$python_bin" "$script_path" 2>/dev/null | tr -d '\r'); then
    log_error "Could not calculate zxcvbn score; check that zxcvbn is installed in the active Python environment."
    return 2
  fi

  IFS=' ' read -r score guesses_log10 patterns <<< "$result"

  if [[ ! "$score" =~ ^[0-4]$ || ! "$guesses_log10" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
    log_error "zxcvbn returned an invalid score or log10 value. Got: '$result'"
    return 2
  fi

  if [[ ! "$patterns" =~ ^(none|[a-z,]+)$ ]]; then
    log_error "zxcvbn returned invalid pattern labels: '$patterns'"
    return 2
  fi

  if [[ "$patterns" != "none" ]]; then
    log_warn "zxcvbn detected pattern categories: $patterns"
  fi

  if (( score < min_score )); then
    log_fail "Guessability score: ${score}/4 (required: at least ${min_score}/4)"
    return 1
  fi

  log_pass "Guessability score: ${score}/4 (required: at least ${min_score}/4)"
  return 0
}
