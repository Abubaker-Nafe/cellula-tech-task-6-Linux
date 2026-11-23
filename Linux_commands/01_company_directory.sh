#!/usr/bin/env bash
set -euo pipefail

mkdir -- Company
cd -- Company
mkdir -p -- HR/{Recruitment,Payroll} Engineering/{Development,Testing} Marketing/{SocialMedia,Campaigns}
touch -- company_info.txt

printf 'Company directory tree\n'
find . -print | LC_ALL=C sort
printf '\nCurrent working directory\n'
pwd
printf '\nAll entries, including hidden entries\n'
ls -la
