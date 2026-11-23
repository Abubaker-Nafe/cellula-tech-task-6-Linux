#!/usr/bin/env bash
set -euo pipefail

mkdir -- Downloads
cd -- Downloads
touch -- 'Project brief.pdf' handbook.PDF agenda.txt draft.md meeting.txt \
    cover.jpg diagram.png banner.JPG logo.svg team.jpeg \
    interview.mp3 theme.MP3 narration.wav \
    demo.mp4 presentation.MP4 walkthrough.mov \
    files.zip export.tar.gz submission.ZIP \
    prepare.sh backup.SH helper.py \
    format.bin LICENSE .incoming
printf 'Created %s sample downloads in %s\n' "$(find . -maxdepth 1 -type f -printf '.' | wc -c)" "$PWD"
