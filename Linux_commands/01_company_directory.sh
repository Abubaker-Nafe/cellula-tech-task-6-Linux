#!/usr/bin/env bash
set -euo pipefail

mkdir -- Company
cd -- Company
mkdir -p -- HR/{Recruitment,Payroll} Engineering/{Development,Testing} Marketing/{SocialMedia,Campaigns}
touch -- company_info.txt

echo 'Company directory tree'
find . -print | LC_ALL=C sort
echo
echo 'Current working directory'
pwd
echo
echo 'All entries, including hidden entries'
ls -la
