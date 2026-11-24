#!/usr/bin/bash

# Simple Levenshtein distance calculator in awk
calc_levenshtein() {
  local s1="$1"
  local s2="$2"
  awk -v s1="$s1" -v s2="$s2" '
  BEGIN {
    n = length(s1);
    m = length(s2);
    for (i = 0; i <= n; i++) d[i, 0] = i;
    for (j = 0; j <= m; j++) d[0, j] = j;
    
    for (i = 1; i <= n; i++) {
      c1 = substr(s1, i, 1);
      for (j = 1; j <= m; j++) {
        c2 = substr(s2, j, 1);
        cost = (c1 == c2 ? 0 : 1);
        val1 = d[i-1, j] + 1;
        val2 = d[i, j-1] + 1;
        val3 = d[i-1, j-1] + cost;
        min = val1;
        if (val2 < min) min = val2;
        if (val3 < min) min = val3;
        d[i, j] = min;
      }
    }
    print d[n, m];
  }'
}

is_increment_change() {
  local new_pw="$1"
  local old_pw="$2"

  # If they are identical, handled by exact history check
  [[ "$new_pw" == "$old_pw" ]] && return 1

  # Check if removing trailing digits/numbers leaves the same base string
  local new_base new_num old_base old_num
  new_base="${new_pw//[0-9]/}"
  old_base="${old_pw//[0-9]/}"

  if [[ "$new_base" == "$old_base" ]]; then
    # Extract trailing numbers
    new_num=$(printf '%s' "$new_pw" | grep -oE '[0-9]+$' || echo "")
    old_num=$(printf '%s' "$old_pw" | grep -oE '[0-9]+$' || echo "")
    
    if [[ -n "$new_num" && -n "$old_num" ]]; then
      # If numeric difference is small
      local diff=$((10#$new_num - 10#$old_num))
      if (( diff >= -5 && diff <= 5 )); then
        return 0 # True, it's an increment-only change
      fi
    fi
  fi
  return 1
}

check_password_history() {
  local pw="$1"
  local history_path="$2"
  local max_count="$3"
  local max_dist="$4"

  if [[ ! -f "$history_path" ]]; then
    return 0 # No history file yet, pass
  fi

  local current_hash
  current_hash="$(printf '%s' "$pw" | sha256sum | awk '{print $1}')"

  local line_count=0
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" ]] && continue
    ((line_count++))
    if (( line_count > max_count )); then
      break
    fi

    # Format in history file: hash:plain
    # For history comparison (like near-duplicate/increment), we need either stored plaintexts 
    # or we store plaintexts securely in local encrypted/restricted file. 
    local stored_hash stored_plain
    stored_hash="${line%% *}"
    stored_plain="${line#* }"

    # Exact match check
    if [[ "$current_hash" == "$stored_hash" ]]; then
      log_fail "History check: Password matches one of your last $max_count used passwords"
      return 1
    fi

    if [[ -n "$stored_plain" && "$stored_plain" != "$line" ]]; then
      # Increment-only check
      if is_increment_change "$pw" "$stored_plain"; then
        log_fail "History check: Password is an incremental variant of a recent password ($stored_plain -> $pw)"
        return 1
      fi

      # Near-duplicate check (Levenshtein distance)
        local dist
        dist=$(calc_levenshtein "$pw" "$stored_plain")
        if (( dist <= max_dist )); then
          log_fail "History check: Password is too similar to a recent password (edit distance: $dist ≤ $max_dist)"
          return 1
        fi
    fi

  done < <(tail -n "$max_count" "$history_path" 2>/dev/null)

  log_pass "Password history & uniqueness check passed"
  return 0
}

# Helper to record a new password to history upon successful change
append_password_history() {
  local pw="$1"
  local history_path="$2"
  local max_count="$3"

  mkdir -p "$(dirname "$history_path")"
  
  local current_hash
  current_hash="$(printf '%s' "$pw" | sha256sum | awk '{print $1}')"

  # Append "hash plaintext"
  printf '%s %s\n' "$current_hash" "$pw" >> "$history_path"
  chmod 600 "$history_path" 2>/dev/null || true

  # Keep only last N lines
  if [[ -f "$history_path" ]]; then
    local tmp_file
    tmp_file="$(mktemp)"
    tail -n "$max_count" "$history_path" > "$tmp_file"
    mv "$tmp_file" "$history_path"
    chmod 600 "$history_path" 2>/dev/null || true
  fi
}
