#!/usr/bin/bash

compute_entropy() {
  local pw="$1"

  # Use awk to compute both values safely without external subprocesses per character
  awk -v pw="$pw" '
  BEGIN {
    len = length(pw)
    if (len == 0) {
      print "0.0 0.0"
      exit
    }

    has_lower = 0
    has_upper = 0
    has_digit = 0
    has_symbol = 0
    has_other = 0

    # Count character frequencies and identify pools
    for (i = 1; i <= len; i++) {
      ch = substr(pw, i, 1)
      counts[ch]++

      if (ch ~ /[a-z]/) {
        has_lower = 1
      } else if (ch ~ /[A-Z]/) {
        has_upper = 1
      } else if (ch ~ /[0-9]/) {
        has_digit = 1
      } else if (index(" !\"#$%&\x27()*+,-./:;<=>?@[\\]^_`{|}~", ch) > 0) {
        has_symbol = 1
      } else {
        has_other = 1
      }
    }

    # Determine Pool Size R
    pool = 0
    if (has_lower)  pool += 26
    if (has_upper)  pool += 26
    if (has_digit)  pool += 10
    if (has_symbol) pool += 33
    if (has_other)  pool += 128

    ln2 = log(2)

    # Pool Entropy: L * log2(R)
    pool_entropy = (pool > 1) ? (len * (log(pool) / ln2)) : 0.0

    # 2. Shannon Entropy: -sum(p * log2(p)) * len
    shannon_per_char = 0.0
    for (ch in counts) {
      p = counts[ch] / len
      shannon_per_char -= p * (log(p) / ln2)
    }
    total_shannon = shannon_per_char * len

    printf "%.2f %.2f\n", pool_entropy, total_shannon
  }
  '
}

# Policy check function
check_entropy() {
  local pw="$1"
  local min_pool="$2"
  local min_shannon="$3"

  local read_pool read_shannon
  read -r read_pool read_shannon < <(compute_entropy "$pw")

  local status=0

  local pool_pass shannon_pass
  pool_pass=$(awk -v val="$read_pool" -v min="$min_pool" 'BEGIN { print (val >= min) ? 1 : 0 }')
  shannon_pass=$(awk -v val="$read_shannon" -v min="$min_shannon" 'BEGIN { print (val >= min) ? 1 : 0 }')

  if [[ "$pool_pass" -eq 1 ]]; then
    log_pass "Pool entropy: ${read_pool} bits (required: ≥ ${min_pool})"
  else
    log_fail "Pool entropy: ${read_pool} bits (insufficient, required: ≥ ${min_pool})"
    status=1
  fi

  if [[ "$shannon_pass" -eq 1 ]]; then
    log_pass "Shannon entropy: ${read_shannon} bits (required: ≥ ${min_shannon})"
  else
    log_fail "Shannon entropy: ${read_shannon} bits (insufficient, required: ≥ ${min_shannon})"
    status=1
  fi

  return "$status"
}