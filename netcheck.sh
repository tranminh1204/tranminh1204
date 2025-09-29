#!/bin/sh
# netcheck.sh - wrapper to run speedtest-cli (user-level) and save results
# Usage: ./netcheck.sh [--json] [output_file]

OUT_JSON=0
OUT_FILE=${2:-speedtest_result.txt}
if [ "$1" = "--json" ]; then
  OUT_JSON=1
  shift
fi

timestamp() { date -Iseconds; }

ensure_speedtest_cli() {
  # Prefer 'speedtest' (Ookla CLI), else 'speedtest-cli' (python)
  if command -v speedtest >/dev/null 2>&1; then
    echo "FOUND: speedtest (Ookla CLI)"
    return 0
  fi
  if command -v ~/.local/bin/speedtest-cli >/dev/null 2>&1 || command -v speedtest-cli >/dev/null 2>&1; then
    echo "FOUND: speedtest-cli (python)"
    return 0
  fi
  echo "speedtest not found — installing speedtest-cli (user) via pip..."
  if command -v python3 >/dev/null 2>&1; then
    python3 -m pip install --user speedtest-cli >/dev/null 2>&1 || {
      echo "pip install failed. Please install speedtest or speedtest-cli manually." >&2
      return 1
    }
    # ensure ~/.local/bin is on PATH for this run
    export PATH="$PATH:$HOME/.local/bin"
    return 0
  fi
  echo "python3 not available; cannot install speedtest-cli" >&2
  return 1
}

run_test() {
  echo "$(timestamp) - Running network test..." >> "$OUT_FILE"
  if command -v speedtest >/dev/null 2>&1; then
    if [ "$OUT_JSON" -eq 1 ]; then
      # Ookla Speedtest CLI uses --json for JSON output
      speedtest --json >> "$OUT_FILE" 2>&1
    else
      # Run with interactive-friendly flags; accept license/gdpr where supported
      speedtest --accept-license --accept-gdpr >> "$OUT_FILE" 2>&1
    fi
  else
    if command -v speedtest-cli >/dev/null 2>&1; then
      if [ "$OUT_JSON" -eq 1 ]; then
        speedtest-cli --json >> "$OUT_FILE" 2>&1
      else
        speedtest-cli --simple >> "$OUT_FILE" 2>&1
      fi
    elif command -v ~/.local/bin/speedtest-cli >/dev/null 2>&1; then
      if [ "$OUT_JSON" -eq 1 ]; then
        ~/.local/bin/speedtest-cli --json >> "$OUT_FILE" 2>&1
      else
        ~/.local/bin/speedtest-cli --simple >> "$OUT_FILE" 2>&1
      fi
    else
      echo "No speedtest command available" >&2
      return 2
    fi
  fi
  echo "$(timestamp) - Test finished" >> "$OUT_FILE"
}

main() {
  ensure_speedtest_cli || exit 1
  run_test || exit 2
  echo "Results saved to $OUT_FILE"
}

main "$@"
