#!/usr/bin/env bash
set -euo pipefail

mkdir -- DatabaseLab
cd -- DatabaseLab
cat > employees.csv <<'EMPLOYEES'
ID,Name,Department,Salary
1,Karim Ali,Marketing,9600
2,Amina Saleh,HR,8400
3,Noor Saad,Engineering,13800
4,Youssef Ashraf,Finance,10700
5,Layla Hassan,Engineering,12600
6,Salma Tarek,Marketing,10400
7,Ahmed Mostafa,Operations,9300
8,Omar Nasser,HR,9900
9,Maya Khalil,Operations,13200
10,Hana Adel,Finance,8700
11,Bilal Amin,Engineering,14900
12,Samir Fouad,Marketing,7900
13,Dina Samy,HR,10200
14,Mariam Omar,Finance,11500
15,Rami Hany,Operations,9800
16,Farah Nabil,Engineering,12100
17,Tamer Hamid,Finance,10000
18,Nadia Emad,Marketing,8800
19,Leen Ibrahim,Operations,10100
20,Hamza Said,HR,9500
21,Sara Zaki,Engineering,13500
22,Hadi Yassin,Operations,9100
23,Lina Fahmy,Finance,11200
24,Malik Samy,Marketing,9200
EMPLOYEES

tail -n +2 -- employees.csv | cut -d, -f2 > names.txt
{
    head -n 1 -- employees.csv
    tail -n +2 -- employees.csv | LC_ALL=C sort -t, -k2,2 -k1,1n
} > sorted_employees.csv
printf 'Employees sorted alphabetically by name\n'
cat -- sorted_employees.csv

printf '\nUnique departments\n'
tail -n +2 -- employees.csv | cut -d, -f3 | LC_ALL=C sort -u
printf '\nEmployees per department\n'
tail -n +2 -- employees.csv | cut -d, -f3 | LC_ALL=C sort | uniq -c

awk -F, 'NR == 1 || $4 + 0 > 10000' employees.csv > high_salary.csv
printf '\nEmployees earning more than 10000\n'
cat -- high_salary.csv
