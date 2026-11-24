#!/usr/bin/env bash

# Default fallbacks
MIN_LENGTH=14
MAX_LENGTH=64
MIN_POOL_ENTROPY=60
MIN_SHANNON_ENTROPY=50
MIN_ZXCVBN_SCORE=3
DENYLIST_ENABLED=0
DENYLIST_PATH=""
HIBP_CHECK_ENABLED=0
HIBP_TIMEOUT=0

load_config() {
  local conf_path="$1"
  [[ -f "$conf_path" ]] || { log_error "Config file not found: $conf_path"; return 2; }

  local line_no=0
  local line key val
  declare -A seen_keys=()

  while IFS= read -r line || [[ -n "$line" ]]; do
    ((line_no++))
    # Strip leading/trailing whitespace
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"

    # Skip comments and empty lines
    [[ -z "$line" || "$line" == \#* ]] && continue

    # Ensure format is KEY=VALUE
    if [[ ! "$line" =~ ^([A-Za-z_][A-Za-z0-9_]*)=(.*)$ ]]; then
      log_error "Malformed line $line_no in $conf_path: $line"
      return 2
    fi

    key="${BASH_REMATCH[1]}"
    val="${BASH_REMATCH[2]}"

    # Prevent duplicate definitions
    if [[ -n "${seen_keys[$key]:-}" ]]; then
      log_error "Duplicate key '$key' at line $line_no in $conf_path"
      return 2
    fi
    seen_keys["$key"]=1

    # Validate according to allowlisted keys
    case "$key" in
  MIN_LENGTH|MAX_LENGTH|MIN_POOL_ENTROPY|MIN_SHANNON_ENTROPY|MIN_ZXCVBN_SCORE|DENYLIST_ENABLED|HIBP_CHECK_ENABLED|HIBP_TIMEOUT)
    if [[ ! "$val" =~ ^[0-9]+$ ]]; then
      log_error "Key '$key' must be a numeric integer. Got '$val' at line $line_no"
      return 2
    fi
    printf -v "$key" '%d' "$val"
    ;;
  DENYLIST_PATH)
    DENYLIST_PATH="$val"
    ;;
  *)
    log_error "Unknown configuration key '$key' at line $line_no in $conf_path"
    return 2
    ;;
    esac
  done < "$conf_path"

  # Validate logical ranges
  if (( MIN_LENGTH < 1 || MIN_LENGTH > 4096 )); then
    log_error "MIN_LENGTH ($MIN_LENGTH) must be between 1 and 4096."
    return 2
  fi

  if (( MAX_LENGTH < 64 || MAX_LENGTH > 4096 )); then
    log_error "MAX_LENGTH ($MAX_LENGTH) must be at least 64 per modern standards."
    return 2
  fi

  if (( MIN_LENGTH > MAX_LENGTH )); then
    log_error "MIN_LENGTH ($MIN_LENGTH) cannot exceed MAX_LENGTH ($MAX_LENGTH)."
    return 2
  fi

    if (( MIN_POOL_ENTROPY < 0 || MIN_POOL_ENTROPY > 1024 )); then
    log_error "MIN_POOL_ENTROPY ($MIN_POOL_ENTROPY) must be between 0 and 1024."
    return 2
  fi

  if (( MIN_SHANNON_ENTROPY < 0 || MIN_SHANNON_ENTROPY > 1024 )); then
    log_error "MIN_SHANNON_ENTROPY ($MIN_SHANNON_ENTROPY) must be between 0 and 1024."
    return 2
  fi

  if (( MIN_ZXCVBN_SCORE < 0 || MIN_ZXCVBN_SCORE > 4 )); then
  log_error "MIN_ZXCVBN_SCORE must be between 0 and 4."
  return 2
fi

if (( DENYLIST_ENABLED != 0 && DENYLIST_ENABLED != 1 )); then
  log_error "DENYLIST_ENABLED must be 0 or 1."
  return 2
fi

if (( HIBP_CHECK_ENABLED != 0 && HIBP_CHECK_ENABLED != 1 )); then
  log_error "HIBP_CHECK_ENABLED must be 0 or 1."
  return 2
fi

if (( HIBP_CHECK_ENABLED == 1)); then
  if (( HIBP_TIMEOUT <= 0 && HIBP_TIMEOUT >= 5*60)); then 
    log_error "HIBP_TIMEOUT must be between 0s and 5min."
    return 2
  fi
fi    

if (( DENYLIST_ENABLED == 1 )); then
  if [[ -z "$DENYLIST_PATH" ]]; then
    log_error "DENYLIST_PATH must be set when DENYLIST_ENABLED=1."
    return 2
  fi

  if [[ ! -f "$DENYLIST_PATH" ]]; then
    log_error "DENYLIST_PATH does not exist: $DENYLIST_PATH"
    return 2
  fi

  if [[ ! -r "$DENYLIST_PATH" ]]; then
    log_error "DENYLIST_PATH is not readable: $DENYLIST_PATH"
    return 2
  fi
fi



  return 0
}
