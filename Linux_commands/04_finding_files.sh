#!/usr/bin/env bash
set -euo pipefail

mkdir -- ProjectFiles
cd -- ProjectFiles
mkdir -- Backup Config Scripts

printf '%s\n' 'Project notes' > notes.txt
printf '%s\n' 'Review staging deployment' > tasks.txt
printf 'port=8080\nenvironment=production\n' > server.conf
printf 'INFO Application started\nERROR Database connection timed out\n' > app.log
printf 'id,item\n1,router\n' > inventory.csv
printf 'INFO Login audit started\nINFO ERROR_COUNT=0\n' > audit.log
printf '%s\n' 'Notes from the previous release' > Backup/old_notes.txt
printf 'id,item\n1,spare switch\n' > Backup/snapshot.csv
printf 'INFO Backup started\nERROR Backup destination unavailable\n' > Backup/backup.log
printf 'Archived release manifest, record %03d\n' {1..80} > Backup/archive.txt
printf '%s\n' 'retention_days=30' > Backup/settings.conf
printf 'port=8081\nenvironment=staging\n' > Config/server.conf
printf '%s\n' 'timeout_seconds=10' > Config/client.conf
printf '%s\n' 'retries=3' > Config/defaults.conf
printf '%s\n' 'Configuration for the staging service' > Config/readme.txt
printf 'id,role\n1,operator\n' > Config/users.csv
printf '#!/usr/bin/env bash\nprintf "Deploy\\n"\n' > Scripts/deploy.sh
printf '#!/usr/bin/env bash\nprintf "Healthy\\n"\n' > Scripts/health.sh
printf '#!/usr/bin/env bash\nprintf "Maintenance complete\\n"\n' > Scripts/maintenance.sh
printf 'INFO Health check started\nERROR: Disk quota reached\n' > Scripts/maintenance.log

printf 'Number of project files before generating the error report\n'
find . -type f -printf '.' | wc -c
printf '\nAll .txt files\n'
find . -type f -name '*.txt' -print | LC_ALL=C sort
printf '\nEvery server.conf\n'
find . -type f -name 'server.conf' -print | LC_ALL=C sort
printf '\nFiles larger than 1 KB (1,024 bytes)\n'
find . -type f -size +1024c -printf '%s bytes  %p\n' | LC_ALL=C sort

find . -type f -name '*.log' -print0 | LC_ALL=C sort -z | xargs -0 -r grep -Hnw -- ERROR > errors.txt
printf '\nLog entries matching the whole word ERROR\n'
cat -- errors.txt
