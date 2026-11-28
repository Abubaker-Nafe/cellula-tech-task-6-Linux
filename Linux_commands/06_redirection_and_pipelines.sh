#!/usr/bin/env bash
set -euo pipefail

mkdir -- PipelineLab
cd -- PipelineLab
seq 1 100 > numbers.txt
awk '$1 % 2 == 0' numbers.txt > even.txt
awk '$1 % 2 != 0' numbers.txt > odd.txt

: > summary.txt
wc -l -- even.txt odd.txt >> summary.txt
echo 'Line counts appended to summary.txt'
cat -- summary.txt

if ls --task9-invalid-option 2> errors.log; then
    echo 'Expected the invalid option to fail.' >&2
    exit 1
fi
echo
echo 'Captured standard error'
cat -- errors.log
echo
echo 'Ten largest numbers'
sort -nr -- numbers.txt | head -n 10
