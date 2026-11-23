#!/usr/bin/env bash
set -euo pipefail

scripts=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
if (( $# > 1 )); then
    printf 'Usage: %s [new-output-directory]\n' "${0##*/}" >&2
    exit 2
fi
if (( $# == 1 )); then
    output=$1
    mkdir -- "$output"
else
    output=$(mktemp -d "${TMPDIR:-/tmp}/cellula-linux.XXXXXX")
fi
cd -- "$output"

for script in "$scripts"/0[1-8]_*.sh; do
    printf '\n--- %s ---\n' "${script##*/}"
    "$script"
done

printf '\n--- 09 Project generator ---\n'
printf 'MentorDemo\n6\n' | "$scripts/project_generator.sh"
printf '\n--- 10 File information checker ---\n'
printf 'SecurityLab/private.txt\n' | "$scripts/file_checker.sh"
printf 'Company\n' | "$scripts/file_checker.sh"
printf '\n--- 11 File organizer ---\n'
"$scripts/11_seed_downloads.sh"
printf 'Downloads\n' | "$scripts/file_checker.sh"
"$scripts/organizer.sh" Downloads
printf '\nAll 11 assignments completed in %s\n' "$PWD"
