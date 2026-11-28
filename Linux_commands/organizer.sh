#!/usr/bin/env bash
set -euo pipefail

if (( $# > 1 )); then
    printf 'Usage: %s [downloads-directory]\n' "${0##*/}" >&2
    exit 2
fi
downloads=${1:-./Downloads}
if [[ ! -d $downloads ]]; then
    printf 'Downloads directory does not exist: %s\n' "$downloads" >&2
    exit 1
fi
cd -- "$downloads"

categories=(Documents Images Audio Videos Archives Scripts Others)
report=organization_report.txt
if [[ -L $report || ( -e $report && ! -f $report ) ]]; then
    printf 'Cannot write report to %s\n' "$report" >&2
    exit 1
fi
for category in "${categories[@]}"; do
    if [[ -L $category || ( -e $category && ! -d $category ) ]]; then
        printf 'Cannot use organizer directory %s\n' "$category" >&2
        exit 1
    fi
done
mkdir -p -- "${categories[@]}"

declare -A counts=()
total=0
shopt -s dotglob nullglob
for source in ./*; do
    filename=${source#./}
    [[ -f $source && ! -L $source && $filename != "$report" ]] || continue

    stem=$filename
    suffix=''
    if [[ $filename == *.* && $filename != *. && -n ${filename%.*} ]]; then
        stem=${filename%.*}
        suffix=.${filename##*.}
    fi
    case ${suffix,,} in
        .pdf|.txt|.doc|.docx|.md|.odt|.rtf|.csv) category=Documents ;;
        .jpg|.jpeg|.png|.gif|.svg|.webp|.bmp|.heic|.tiff) category=Images ;;
        .mp3|.wav|.flac|.ogg|.m4a|.aac) category=Audio ;;
        .mp4|.mov|.mkv|.avi|.webm|.mpeg) category=Videos ;;
        .zip|.tar|.gz|.tgz|.bz2|.xz|.7z|.rar) category=Archives ;;
        .sh|.bash|.zsh|.py) category=Scripts ;;
        *) category=Others ;;
    esac

    destination=$category/$filename
    duplicate_number=0
    while [[ -e $destination || -L $destination ]]; do
        duplicate_number=$((duplicate_number + 1))
        destination="$category/$stem ($duplicate_number)$suffix"
    done
    mv -nT -- "$source" "$destination"
    if [[ -e $source || -L $source ]]; then
        printf 'Could not move %s to %s\n' "$filename" "$destination" >&2
        exit 1
    fi
    counts[$category]=$((${counts[$category]:-0} + 1))
    total=$((total + 1))
done

temporary_report=$(mktemp .organization_report.XXXXXX)
trap 'rm -f -- "$temporary_report"' EXIT
{
    echo 'File organization report'
    echo
    for category in "${categories[@]}"; do
        printf '%-10s %d\n' "$category" "${counts[$category]:-0}"
    done
    printf '\nTotal files moved: %d\n' "$total"
} > "$temporary_report"
mv -fT -- "$temporary_report" "$report"
trap - EXIT
cat -- "$report"
