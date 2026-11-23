#!/usr/bin/bash

# Resolve canonical script root directory regardless of symlinks
get_app_root() {
  local source="${BASH_SOURCE[1]}"
  while [[ -h "$source" ]]; do
    local dir
    dir="$(cd -P "$(dirname "$source")" && pwd)"
    source="$(readlink "$source")"
    [[ "$source" != /* ]] && source="$dir/$source"
  done
  cd -P "$(dirname "$source")/.." && pwd
}

# Terminal color definitions
if [[ -t 2 && -z "${NO_COLOR:-}" ]]; then
  readonly C_RESET='\033[0m'
  readonly C_BOLD='\033[1m'
  readonly C_DIM='\033[2m'
  readonly C_RED='\033[31m'
  readonly C_GREEN='\033[32m'
  readonly C_YELLOW='\033[33m'
  readonly C_BLUE='\033[34m'
else
  readonly C_RESET=''
  readonly C_BOLD=''
  readonly C_DIM=''
  readonly C_RED=''
  readonly C_GREEN=''
  readonly C_YELLOW=''
  readonly C_BLUE=''
fi

# Stderr-directed logging helpers
log_info() {
  printf '%b[INFO]%b %s\n' "${C_BLUE}${C_BOLD}" "${C_RESET}" "$1" >&2
}

log_warn() {
  printf '%b[WARN]%b %s\n' "${C_YELLOW}${C_BOLD}" "${C_RESET}" "$1" >&2
}

log_error() {
  printf '%b[ERROR]%b %s\n' "${C_RED}${C_BOLD}" "${C_RESET}" "$1" >&2
}

log_pass() {
  printf '%b[PASS]%b %s\n' "${C_GREEN}${C_BOLD}" "${C_RESET}" "$1" >&2
}

log_fail() {
  printf '%b[FAIL]%b %s\n' "${C_RED}${C_BOLD}" "${C_RESET}" "$1" >&2
}
