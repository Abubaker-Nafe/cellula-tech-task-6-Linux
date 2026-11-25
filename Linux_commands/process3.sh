#!/usr/bin/env bash
set -euo pipefail
export TZ=UTC

sleep_pid=''
trap 'kill "$sleep_pid" 2>/dev/null || true; wait "$sleep_pid" 2>/dev/null || true; exit 0' INT TERM
while true; do
    printf '%s %(%Y-%m-%dT%H:%M:%SZ)T\n' "${0##*/}" -1
    sleep 5 &
    sleep_pid=$!
    wait "$sleep_pid"
done
