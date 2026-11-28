#!/usr/bin/env bash
set -euo pipefail

printf 'Enter a file or directory path: '
if ! IFS= read -r path; then
    echo >&2
    echo 'A path is required.' >&2
    exit 1
fi
if [[ -z $path || ! -e $path ]]; then
    printf 'The path does not exist: %s\n' "$path" >&2
    exit 1
fi
if [[ $path != /* ]]; then
    path=./$path
fi

echo
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
        echo 'Lines: unavailable'
    fi
elif [[ -d $path ]]; then
    echo 'Type: directory'
    if [[ -r $path && -x $path ]]; then
        echo 'Immediate entries, including hidden entries'
        find -H "$path" -mindepth 1 -maxdepth 1 -printf '%y\n' |
            awk '
                $1 == "f" { files++ }
                $1 == "d" { dirs++ }
                END { printf "Files: %d\nSubdirectories: %d\n", files, dirs }
            '
        if totals=$(
            find -H "$path" -mindepth 1 -printf '%y\n' |
                awk '
                    $1 == "f" { files++ }
                    $1 == "d" { dirs++ }
                    END { printf "Recursive files: %d\nRecursive subdirectories: %d", files, dirs }
                '
        ); then
            printf '%s\n' "$totals"
        else
            echo 'Recursive counts: unavailable'
        fi
    else
        echo 'Directory counts: unavailable'
    fi
else
    echo 'Type: other filesystem entry'
fi

if [[ -r $path ]]; then
    echo 'Readable: yes'
else
    echo 'Readable: no'
fi
if [[ -w $path ]]; then
    echo 'Writable: yes'
else
    echo 'Writable: no'
fi
if [[ -x $path ]]; then
    echo 'Executable: yes'
else
    echo 'Executable: no'
fi
