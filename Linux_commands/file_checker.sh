#!/usr/bin/env bash
set -euo pipefail

printf 'Enter a file or directory path: '
IFS= read -r path || { printf '\nA path is required.\n' >&2; exit 1; }
if [[ -z $path || ! -e $path ]]; then
    printf 'The path does not exist: %s\n' "$path" >&2
    exit 1
fi
if [[ $path != /* ]]; then
    path=./$path
fi

printf '\n'
if [[ -f $path ]]; then
    filename=${path##*/}
    extension='(none)'
    if [[ $filename == *.* && $filename != *. && -n ${filename%.*} ]]; then
        extension=${filename##*.}
    fi
    printf 'Type: regular file\nFilename: %s\nExtension: %s\n' "$filename" "$extension"
    stat -L -c $'Size: %s bytes\nPermissions: %A (%a)' -- "$path"
    if [[ -r $path ]] && lines=$(wc -l < "$path"); then
        printf 'Lines: %s\n' "$lines"
    else
        printf 'Lines: unavailable\n'
    fi
elif [[ -d $path ]]; then
    printf 'Type: directory\n'
    if [[ -r $path && -x $path ]]; then
        printf 'Immediate entries, including hidden entries\n'
        find -H "$path" -mindepth 1 -maxdepth 1 -printf '%y\n' |
            awk '$1 == "f" {files++} $1 == "d" {dirs++} END {printf "Files: %d\nSubdirectories: %d\n", files, dirs}'
        if totals=$(find -H "$path" -mindepth 1 -printf '%y\n' |
            awk '$1 == "f" {files++} $1 == "d" {dirs++} END {printf "Recursive files: %d\nRecursive subdirectories: %d", files, dirs}'); then
            printf '%s\n' "$totals"
        else
            printf 'Recursive counts: unavailable\n'
        fi
    else
        printf 'Directory counts: unavailable\n'
    fi
else
    printf 'Type: other filesystem entry\n'
fi

if [[ -r $path ]]; then printf 'Readable: yes\n'; else printf 'Readable: no\n'; fi
if [[ -w $path ]]; then printf 'Writable: yes\n'; else printf 'Writable: no\n'; fi
if [[ -x $path ]]; then printf 'Executable: yes\n'; else printf 'Executable: no\n'; fi
