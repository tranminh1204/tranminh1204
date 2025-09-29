#!/bin/sh
# Helper runner included in the package
# Usage: ./run.sh [interval_seconds] [log_path] [timestamp_path]

INTERVAL=${1:-60}
LOG=${2:-keepalive_sh.log}
TOUCH=${3:-keepalive_sh.timestamp}

echo "Starting keepalive.sh with interval=${INTERVAL}s, log=${LOG}, touch=${TOUCH}"
# run with low priority and nohup so it survives logout
nohup nice -n 19 ./keepalive.sh "$INTERVAL" "$LOG" "$TOUCH" >/dev/null 2>&1 &
echo $! > keepalive_sh.pid
echo "Started PID $(cat keepalive_sh.pid)"
