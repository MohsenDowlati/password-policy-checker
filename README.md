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
- [ ] Check against a common-password list (rockyou.txt, SecLists/10-million-password-list-top-1000000.txt)
- [ ] Case-insensitive and leetspeak-normalized matching before lookup
- [ ] Check against project/company name, username, email local-part
- [ ] Check against a “context words” file (brand names, product names, city names)
- [ ] Optional: HIBP k-anonymity API check (SHA-1 prefix, first 5 hex chars only — never send the full hash)
## Reuse & History
- [ ] Enforce “not one of the last N passwords” (N = 5–24) via a history file
- [ ] Detect near-duplicates (e.g. Summer2024! → Summer2025!) using edit distance / normalized comparison
- [ ] Detect increment-only changes (Password1 → Password2)
## Expiration & Rotation
- [ ] No forced periodic rotation (NIST: rotate only on evidence of compromise)
- [ ] Optional “max age” flag for compliance profiles (PCI-DSS, ISO 27001) — configurable, off by default
- [ ] Flag accounts/passwords older than a threshold in audit mode
## Rate Limiting & Lockout (policy config, not password content)
- [ ] Max failed attempts before lockout (e.g. 5–10)
- [ ] Exponential backoff / lockout duration
- [ ] Throttling on password-reset requests
## MFA & Recovery
- [ ] Flag whether MFA is required for privileged accounts
- [ ] Recovery questions must not be guessable (or disallowed entirely)
- [ ] Reset tokens: single-use, short TTL (≤ 15–30 min)
## Storage & Handling (audit checks)
- [ ] Detect plaintext passwords in config/env files
- [ ] Detect weak hashing (MD5/SHA-1) vs. acceptable (bcrypt ≥ 12, scrypt, Argon2id)
- [ ] Detect hardcoded credentials in scripts / .env committed to git
- [ ] Check file permissions on credential files (600, owned by service user)
- [ ] Optional: git-secrets / gitleaks-style regex scan
## Usability & Accessibility
- [ ] Allow passphrases with spaces (don’t strip whitespace)
- [ ] Allow all Unicode / non-ASCII (correct byte-length handling, not wc -c blindly)
- [ ] No “security questions” with fixed answer formats
- [ ] Clear, actionable error messages (tell the user why it failed, not just “invalid”)
## Output & Reporting
- [ ] Machine-readable output: --json flag with per-check results
- [ ] Exit codes: 0 = pass, 1 = policy violation, 2 = usage error
- [ ] Verbose mode showing each rule and its result
- [ ] Config file (policy.conf / YAML-ish) so rules are tunable without editing code
- [ ] Batch mode: audit a CSV/list of passwords and produce a summary report
- [ ] Optional HTML/Markdown report for a “security audit” feel

# This Shit Cooked By MOHSEN.