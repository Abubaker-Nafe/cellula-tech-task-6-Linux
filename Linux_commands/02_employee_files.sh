#!/usr/bin/env bash
set -euo pipefail

cd -- Company
for path in employee{1..5}.txt manager.txt HR/employee{1,2}.txt Engineering/employee3.txt Marketing/employee4.txt; do
    if [[ -e $path || -L $path ]]; then
        printf 'Employee output already exists at %s\n' "$path" >&2
        exit 1
    fi
done

touch -- employee{1..5}.txt
while IFS='|' read -r file employee department; do
    printf 'Name: %s\nDepartment: %s\n' "$employee" "$department" > "$file"
done <<'EMPLOYEES'
employee1.txt|Amina Saleh|HR
employee2.txt|Omar Nasser|HR
employee3.txt|Layla Hassan|Engineering
employee4.txt|Karim Ali|Marketing
employee5.txt|Maya Khalil|Management
EMPLOYEES

cp -v -- employee1.txt employee2.txt HR/
mv -v -- employee3.txt Engineering/
mv -v -- employee4.txt Marketing/
mv -v -- employee5.txt manager.txt
rm -v -- HR/employee2.txt

echo
echo 'Final employee files'
find . -type f \( -name 'employee*.txt' -o -name manager.txt \) -print | LC_ALL=C sort
