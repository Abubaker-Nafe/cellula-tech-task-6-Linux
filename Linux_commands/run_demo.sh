#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
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

for script in "$script_dir"/0[1-8]_*.sh; do
    printf '\n--- %s ---\n' "${script##*/}"
    "$script"
done

echo
echo '--- 09 Project generator ---'
printf 'MentorDemo\n6\n' | "$script_dir/project_generator.sh"
echo
echo '--- 10 File information checker ---'
echo 'SecurityLab/private.txt' | "$script_dir/file_checker.sh"
echo 'Company' | "$script_dir/file_checker.sh"
echo
echo '--- 11 File organizer ---'
"$script_dir/11_seed_downloads.sh"
echo 'Downloads' | "$script_dir/file_checker.sh"
"$script_dir/organizer.sh" Downloads
printf '\nAll 11 assignments completed in %s\n' "$PWD"
