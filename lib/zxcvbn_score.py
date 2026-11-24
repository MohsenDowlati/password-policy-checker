#!/usr/bin/env python3

import sys

USER_INPUTS = ["mohsen","dowlati","cyberphoenix"]

try:
    from zxcvbn import zxcvbn
except ImportError:
    print("Missing dependency: install zxcvbn in the active Python environment.", file=sys.stderr)
    raise SystemExit(2)

password = sys.stdin.read().rstrip('\r\n')


try:
    result = zxcvbn(password, user_inputs=USER_INPUTS)

    labels = set()
    for match in result.get("sequence", []):
        pattern = match.get("pattern")

        if pattern == "dictionary":
            dictionary_name = str(match.get("dictionary_name", "")).lower()

            if dictionary_name == "user_inputs":
                labels.add("context")
            elif dictionary_name in {"female_names", "male_names", "surnames"}:
                labels.add("name")
            else:
                labels.add("dictionary")

            if match.get("l33t"):
                labels.add("leetspeak")

        elif pattern == "date":
            labels.add("date")

    score = int(result["score"])  # zxcvbn score is 0–4
    guesses_log10 = float(result["guesses_log10"])
    pattern_labels = ",".join(sorted(labels)) or "none"

except Exception:
    print("zxcvbn scoring failed.", file=sys.stderr)
    raise SystemExit(2)

print(f"{score} {guesses_log10:.2f} {pattern_labels}")
