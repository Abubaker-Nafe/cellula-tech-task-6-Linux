#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
mkdir -- ProcessLab
cd -- ProcessLab

declare -A running=()
cleanup() {
    local pid
    for pid in "${running[@]}"; do
        kill "$pid" 2>/dev/null || true
        wait "$pid" 2>/dev/null || true
    done
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

all_pids=()
: > processes.txt
for script in process{1..3}.sh; do
    "$script_dir/$script" > "${script%.sh}.log" &
    pid=$!
    running[$script]=$pid
    all_pids+=("$pid")
    printf '%s %s\n' "$script" "$pid" >> processes.txt
done

echo 'Background scripts and recorded PIDs'
cat -- processes.txt
echo
echo 'Process status and resource use (RSS in KiB)'
pid_list=$(IFS=,; printf '%s' "${all_pids[*]}")
ps -p "$pid_list" -o pid,ppid,stat,%cpu,%mem,rss,etime,args
sleep 6

process2_pid=${running[process2.sh]}
printf '\nTerminating process2.sh (PID %s)\n' "$process2_pid"
kill -TERM "$process2_pid"
wait "$process2_pid"
unset 'running[process2.sh]'
if kill -0 "$process2_pid" 2>/dev/null; then
    echo 'process2.sh is still running.' >&2
    exit 1
fi

echo
echo 'Verifying that process1.sh and process3.sh are still running'
kill -0 "${running[process1.sh]}" "${running[process3.sh]}"
ps -p "${running[process1.sh]},${running[process3.sh]}" -o pid,stat,%cpu,%mem,rss,args

for script in process1.sh process3.sh; do
    kill -TERM "${running[$script]}"
    wait "${running[$script]}"
    unset 'running[$script]'
done
for pid in "${all_pids[@]}"; do
    if kill -0 "$pid" 2>/dev/null; then
        printf 'PID %s is still running.\n' "$pid" >&2
        exit 1
    fi
done
echo
echo 'All three processes have stopped. Timestamp logs follow.'
cat -- process{1..3}.log
