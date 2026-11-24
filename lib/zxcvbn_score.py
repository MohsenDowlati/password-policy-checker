#!/usr/bin/python3
import sys

try:
    from zxcvbn import zxcvbn
except ImportError:
    print("Missing dependency: install zxcvbn in the active Python environment.", file=sys.stderr)
    raise SystemExit(2)

password = sys.stdin.read()

try:
    result = zxcvbn(password)
    score = int(result["score"])  # zxcvbn score is 0–4
    guesses_log10 = float(result["guesses_log10"])
except Exception:
    print("zxcvbn scoring failed.", file=sys.stderr)
    raise SystemExit(2)

print(f"{score} {guesses_log10:.2f}")
