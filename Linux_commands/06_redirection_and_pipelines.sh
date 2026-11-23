#!/usr/bin/env bash
set -euo pipefail

mkdir -- PipelineLab
cd -- PipelineLab
seq 1 100 > numbers.txt
awk '$1 % 2 == 0' numbers.txt > even.txt
awk '$1 % 2 != 0' numbers.txt > odd.txt

: > summary.txt
wc -l -- even.txt odd.txt >> summary.txt
printf 'Line counts appended to summary.txt\n'
cat -- summary.txt

if ls --task9-invalid-option 2> errors.log; then
    printf 'Expected the invalid option to fail.\n' >&2
    exit 1
fi
printf '\nCaptured standard error\n'
cat -- errors.log
printf '\nTen largest numbers\n'
sort -nr -- numbers.txt | head -n 10
