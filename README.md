# Password Policy Checker

# TODO
## Length & Composition
- [x] Minimum length ≥ 14 (NIST SP 800-63B favors length over complexity)
- [x] Maximum length ≥ 64 (don’t truncate — bcrypt’s 72-byte limit is the classic pitfall)
- [x] No forced character-class rules (upper/lower/digit/symbol) — modern guidance discourages them
- [x] Reject passwords composed of a single repeated character (aaaaaa…)
- [x] Reject sequential runs (abcdef, 123456, qwerty) — forwards and backwards
- [x] Reject keyboard-walk patterns (asdfgh, zxcvbn-style rows)
## Entropy & Strength Estimation
- [x] Shannon entropy estimate (bits) with a configurable threshold (e.g. ≥ 60 bits)
- [x] Character-set-size based entropy: log2(pool_size) × length
- [x] Optional: integrate zxcvbn (via zxcvbn-cli or a small Python/Node call) for realistic guessability scoring
- [x] Penalize dictionary words, names, dates, and leetspeak substitutions (p@ssw0rd)
## Blocklist / Denylist Checks
- [x] Check against a common-password list (rockyou.txt, SecLists/10-million-password-list-top-1000000.txt)
- [x] Case-insensitive and leetspeak-normalized matching before lookup
- [x] Optional: HIBP k-anonymity API check (SHA-1 prefix, first 5 hex chars only — never send the full hash)
## Reuse & History
- [x] Enforce “not one of the last N passwords” (N = 5–24) via a history file
- [x] Detect near-duplicates (e.g. Summer2024! → Summer2025!) using edit distance / normalized comparison
- [x] Detect increment-only changes (Password1 → Password2)


# This Shit Cooked By MOHSEN.